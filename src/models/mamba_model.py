"""MambaClassifier for behavioral event sequences.

Modes:
  python -m src.models.mamba_model train   [options]
  python -m src.models.mamba_model test
  python -m src.models.mamba_model predict <meta_json_path>
  python -m src.models.mamba_model train --loo   (Leave-One-Out fallback)

Requirements (GPU only):
  pip install mamba-ssm causal-conv1d
  (See requirements-mamba.txt)

WARNING: The TEST command evaluates on held-out data that was never used for
tuning. Run it ONCE at the very end. Do not use test metrics to adjust
hyperparameters — that invalidates the evaluation.
"""
import argparse
import json
import math
import os
import sys
import time

import numpy as np
import torch
import torch.nn as nn
from torch.utils.data import DataLoader

SPLITS_PATH = os.path.join("data", "splits.json")
SEQ_DIR = os.path.join("data", "sequences")
INDEX_PATH = os.path.join("data", "sequences_index.csv")
MODEL_DIR = os.path.join("models", "mamba")
RESULTS_DIR = "results"

# ── Defaults ────────────────────────────────────────────────────────────────
D_MODEL = 64
N_LAYERS = 2
DROPOUT = 0.2
EPOCHS = 80
LR = 1e-3
WEIGHT_DECAY = 0.01
PATIENCE = 10
BATCH_SIZE = 8
MAX_LEN = 1000


# ── Mamba import with helpful error ──────────────────────────────────────────
def _import_mamba():
    try:
        from mamba_ssm import Mamba
        return Mamba
    except ImportError:
        sys.exit(
            "[ERROR] mamba-ssm not installed or no CUDA GPU available.\n"
            "Mamba requires a NVIDIA GPU with CUDA.\n"
            "Install:\n"
            "  pip install mamba-ssm causal-conv1d\n"
            "On Google Colab/Kaggle GPU runtime this works out-of-the-box.\n"
            "CPU-only machines cannot run Mamba."
        )


# ── Model ────────────────────────────────────────────────────────────────────
class MambaBlock(nn.Module):
    def __init__(self, d_model: int):
        super().__init__()
        Mamba = _import_mamba()
        self.norm = nn.LayerNorm(d_model)
        self.mamba = Mamba(d_model=d_model, d_state=16, d_conv=4, expand=2)

    def forward(self, x):
        return x + self.mamba(self.norm(x))


class MambaClassifier(nn.Module):
    def __init__(self, n_features: int, d_model: int = D_MODEL, n_layers: int = N_LAYERS, dropout: float = DROPOUT):
        super().__init__()
        self.input_proj = nn.Linear(n_features, d_model)
        self.blocks = nn.Sequential(*[MambaBlock(d_model) for _ in range(n_layers)])
        self.dropout = nn.Dropout(dropout)
        self.head = nn.Linear(d_model, 1)

    def forward(self, x: torch.Tensor, mask: torch.Tensor) -> torch.Tensor:
        """x: [B, L, F]  mask: [B, L] bool (True = valid token)"""
        h = self.input_proj(x)            # [B, L, d_model]
        h = self.blocks(h)                # [B, L, d_model]
        # Masked mean pooling
        mask_f = mask.unsqueeze(-1).float()
        pooled = (h * mask_f).sum(dim=1) / mask_f.sum(dim=1).clamp(min=1)  # [B, d_model]
        pooled = self.dropout(pooled)
        return self.head(pooled).squeeze(-1)  # [B]


# ── Metrics ──────────────────────────────────────────────────────────────────
def _metrics(y_true, y_pred, y_prob):
    y_true = np.array(y_true)
    y_pred = np.array(y_pred)
    y_prob = np.array(y_prob)

    acc = (y_true == y_pred).mean()
    results = {"accuracy": float(acc)}

    for cls_name, cls_val in [("cheat", 1), ("normal", 0)]:
        tp = ((y_pred == cls_val) & (y_true == cls_val)).sum()
        fp = ((y_pred == cls_val) & (y_true != cls_val)).sum()
        fn = ((y_pred != cls_val) & (y_true == cls_val)).sum()
        p = tp / (tp + fp) if (tp + fp) > 0 else 0.0
        r = tp / (tp + fn) if (tp + fn) > 0 else 0.0
        f1 = 2 * p * r / (p + r) if (p + r) > 0 else 0.0
        results[f"{cls_name}_precision"] = float(p)
        results[f"{cls_name}_recall"] = float(r)
        results[f"{cls_name}_f1"] = float(f1)

    results["macro_f1"] = (results["cheat_f1"] + results["normal_f1"]) / 2.0

    # Confusion matrix [[TN, FP], [FN, TP]]
    tn = ((y_pred == 0) & (y_true == 0)).sum()
    fp = ((y_pred == 1) & (y_true == 0)).sum()
    fn = ((y_pred == 0) & (y_true == 1)).sum()
    tp = ((y_pred == 1) & (y_true == 1)).sum()
    results["confusion"] = [[int(tn), int(fp)], [int(fn), int(tp)]]

    return results


def _print_metrics(m: dict, title: str = ""):
    if title:
        print(f"\n{'='*50}\n{title}\n{'='*50}")
    print(f"  Accuracy     : {m['accuracy']:.3f}")
    print(f"  Macro F1     : {m['macro_f1']:.3f}")
    print(f"  Cheat   P/R/F1 : {m['cheat_precision']:.3f} / {m['cheat_recall']:.3f} / {m['cheat_f1']:.3f}")
    print(f"  Normal  P/R/F1 : {m['normal_precision']:.3f} / {m['normal_recall']:.3f} / {m['normal_f1']:.3f}")
    [[tn, fp], [fn, tp]] = m["confusion"]
    print(f"  Confusion (rows=true, cols=pred):")
    print(f"    Normal  -> Normal={tn}, Cheat={fp}")
    print(f"    Cheat   -> Normal={fn}, Cheat={tp}")


# ── Train one epoch ──────────────────────────────────────────────────────────
def _run_epoch(model, loader, device, criterion=None, optimizer=None):
    training = criterion is not None and optimizer is not None
    model.train(training)
    total_loss = 0.0
    y_true, y_pred, y_prob = [], [], []

    with torch.set_grad_enabled(training):
        for padded, lengths, mask, ids, labels in loader:
            padded = padded.to(device)
            mask = mask.to(device)
            labels = labels.to(device)

            logits = model(padded, mask)
            if training:
                loss = criterion(logits, labels)
                optimizer.zero_grad()
                loss.backward()
                nn.utils.clip_grad_norm_(model.parameters(), 1.0)
                optimizer.step()
                total_loss += loss.item() * len(labels)

            probs = torch.sigmoid(logits).detach().cpu().numpy()
            preds = (probs >= 0.5).astype(int)
            y_true.extend(labels.cpu().numpy().tolist())
            y_pred.extend(preds.tolist())
            y_prob.extend(probs.tolist())

    avg_loss = total_loss / max(len(loader.dataset), 1) if training else 0.0
    return avg_loss, y_true, y_pred, y_prob


# ── TRAIN mode ────────────────────────────────────────────────────────────────
def cmd_train(args):
    from src.models.mamba_dataset import SequenceDataset, build_scaler_from_ids, collate_fn

    if not os.path.isfile(SPLITS_PATH):
        sys.exit(f"[ERROR] {SPLITS_PATH} not found. Run make_splits.py first.")

    with open(SPLITS_PATH, encoding="utf8") as f:
        splits = json.load(f)

    train_ids = splits["train"]
    val_ids = splits["val"]

    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    print(f"Device: {device}")
    if str(device) == "cpu":
        print("[WARNING] Mamba runs on CPU — this will be very slow and may not converge well.")
        print("          Consider using Google Colab/Kaggle GPU runtime.")

    # Scaler fit on train only
    scaler = build_scaler_from_ids(train_ids, SEQ_DIR)
    os.makedirs(MODEL_DIR, exist_ok=True)
    scaler.save(os.path.join(MODEL_DIR, "scaler.json"))

    train_ds = SequenceDataset(train_ids, SEQ_DIR, scaler=scaler, max_len=args.max_len)
    val_ds = SequenceDataset(val_ids, SEQ_DIR, scaler=scaler, max_len=args.max_len)

    train_loader = DataLoader(train_ds, batch_size=args.batch_size, shuffle=True,
                              collate_fn=collate_fn, drop_last=False)
    val_loader = DataLoader(val_ds, batch_size=args.batch_size, shuffle=False, collate_fn=collate_fn)

    # pos_weight from train labels
    train_labels = np.array([item["label"].item() for item in train_ds])
    n_pos = train_labels.sum()
    n_neg = len(train_labels) - n_pos
    pos_weight = torch.tensor([n_neg / max(n_pos, 1)], dtype=torch.float32).to(device)
    print(f"Train: {len(train_ids)} samples (cheat={int(n_pos)}, normal={int(n_neg)}), pos_weight={pos_weight.item():.2f}")

    n_features = train_ds[0]["seq"].shape[1]
    model = MambaClassifier(n_features, args.d_model, args.n_layers, args.dropout).to(device)
    criterion = nn.BCEWithLogitsLoss(pos_weight=pos_weight)
    optimizer = torch.optim.AdamW(model.parameters(), lr=args.lr, weight_decay=args.weight_decay)

    best_val_f1 = -1.0
    best_epoch = 0
    patience_count = 0

    print(f"\nTraining {args.epochs} epochs (patience={args.patience})...")
    print(f"{'Epoch':>5} {'TrainLoss':>10} {'ValLoss':>8} {'ValF1':>7}")

    for epoch in range(1, args.epochs + 1):
        tr_loss, _, _, _ = _run_epoch(model, train_loader, device, criterion, optimizer)
        val_loss, vt, vp, vprob = _run_epoch(model, val_loader, device)
        vm = _metrics(vt, vp, vprob)
        val_f1 = vm["macro_f1"]

        # Compute val loss manually for display
        model.eval()
        vl_total = 0.0
        with torch.no_grad():
            for padded, lengths, mask, ids, labels in val_loader:
                logits = model(padded.to(device), mask.to(device))
                vl_total += criterion(logits, labels.to(device)).item() * len(labels)
        val_loss_disp = vl_total / max(len(val_ds), 1)

        print(f"{epoch:>5} {tr_loss:>10.4f} {val_loss_disp:>8.4f} {val_f1:>7.4f}", end="")

        if val_f1 > best_val_f1:
            best_val_f1 = val_f1
            best_epoch = epoch
            patience_count = 0
            torch.save(model.state_dict(), os.path.join(MODEL_DIR, "mamba.pt"))
            print(" *")
        else:
            patience_count += 1
            print()
            if patience_count >= args.patience:
                print(f"  Early stopping at epoch {epoch} (best epoch={best_epoch}, best_val_f1={best_val_f1:.4f})")
                break

    cfg = {
        "n_features": n_features,
        "d_model": args.d_model,
        "n_layers": args.n_layers,
        "dropout": args.dropout,
        "max_len": args.max_len,
        "best_epoch": best_epoch,
        "best_val_f1": float(best_val_f1),
    }
    with open(os.path.join(MODEL_DIR, "config.json"), "w", encoding="utf8") as f:
        json.dump(cfg, f, indent=2)

    print(f"\nSaved best model (epoch={best_epoch}) -> {MODEL_DIR}/mamba.pt")


# ── TEST mode ─────────────────────────────────────────────────────────────────
def cmd_test(args):
    from src.models.mamba_dataset import SequenceDataset, SequenceScaler, collate_fn

    if not os.path.isfile(SPLITS_PATH):
        sys.exit(f"[ERROR] {SPLITS_PATH} not found.")
    if not os.path.isfile(os.path.join(MODEL_DIR, "mamba.pt")):
        sys.exit(f"[ERROR] No trained model at {MODEL_DIR}/mamba.pt. Run 'train' first.")

    with open(SPLITS_PATH, encoding="utf8") as f:
        splits = json.load(f)
    with open(os.path.join(MODEL_DIR, "config.json"), encoding="utf8") as f:
        cfg = json.load(f)

    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    scaler = SequenceScaler.load(os.path.join(MODEL_DIR, "scaler.json"))
    test_ids = splits["test"]

    test_ds = SequenceDataset(test_ids, SEQ_DIR, scaler=scaler, max_len=cfg["max_len"])
    test_loader = DataLoader(test_ds, batch_size=8, shuffle=False, collate_fn=collate_fn)

    model = MambaClassifier(cfg["n_features"], cfg["d_model"], cfg["n_layers"], cfg["dropout"])
    model.load_state_dict(torch.load(os.path.join(MODEL_DIR, "mamba.pt"), map_location=device))
    model.to(device)

    _, y_true, y_pred, y_prob = _run_epoch(model, test_loader, device)
    m = _metrics(y_true, y_pred, y_prob)

    # Majority baseline
    majority = int(np.array(y_true).mean() >= 0.5)
    maj_pred = [majority] * len(y_true)
    maj_m = _metrics(y_true, maj_pred, [float(majority)] * len(y_true))

    _print_metrics(m, "Mamba — TEST RESULTS (held-out, run once)")
    _print_metrics(maj_m, "Majority Baseline")
    print(f"\nMamba vs Baseline  accuracy: {m['accuracy']:.3f} vs {maj_m['accuracy']:.3f}")
    print(f"                   macro F1: {m['macro_f1']:.3f} vs {maj_m['macro_f1']:.3f}")

    os.makedirs(RESULTS_DIR, exist_ok=True)
    out = {
        "mamba": m,
        "majority_baseline": maj_m,
        "n_test": len(y_true),
        "test_ids": test_ids,
        "predictions": [
            {"id": test_ids[i], "true": int(y_true[i]), "pred": int(y_pred[i]), "prob": float(y_prob[i])}
            for i in range(len(y_true))
        ],
    }
    out_path = os.path.join(RESULTS_DIR, "mamba_metrics.json")
    with open(out_path, "w", encoding="utf8") as f:
        json.dump(out, f, indent=2)
    print(f"\nResults saved -> {out_path}")


# ── LOO fallback ──────────────────────────────────────────────────────────────
def cmd_loo(args):
    from src.models.mamba_dataset import SequenceDataset, SequenceScaler, collate_fn, build_scaler_from_ids
    import csv as csv_mod

    print("[INFO] LOO mode: trains model N times. Slow but valid for small datasets.")
    print("[INFO] Recommended: use train/val/test (default) when n >= 50.\n")

    if not os.path.isfile(INDEX_PATH):
        sys.exit(f"[ERROR] {INDEX_PATH} not found. Run build_sequences.py first.")

    import pandas as pd
    df = pd.read_csv(INDEX_PATH)
    df = df[df["label"].isin([0, 1])].reset_index(drop=True)
    all_ids = df["id"].tolist()
    all_labels = df["label"].tolist()

    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    print(f"Device: {device}, n={len(all_ids)}")

    y_true_all, y_pred_all, y_prob_all = [], [], []

    for i in range(len(all_ids)):
        train_ids = [all_ids[j] for j in range(len(all_ids)) if j != i]
        test_id = all_ids[i]
        true_label = all_labels[i]

        scaler = build_scaler_from_ids(train_ids, SEQ_DIR)
        train_ds = SequenceDataset(train_ids, SEQ_DIR, scaler=scaler, max_len=args.max_len)
        test_ds = SequenceDataset([test_id], SEQ_DIR, scaler=scaler, max_len=args.max_len)

        train_loader = DataLoader(train_ds, batch_size=args.batch_size, shuffle=True, collate_fn=collate_fn)
        test_loader = DataLoader(test_ds, batch_size=1, shuffle=False, collate_fn=collate_fn)

        train_labels_arr = np.array([item["label"].item() for item in train_ds])
        n_pos = train_labels_arr.sum()
        n_neg = len(train_labels_arr) - n_pos
        pos_weight = torch.tensor([n_neg / max(n_pos, 1)], dtype=torch.float32).to(device)

        n_features = train_ds[0]["seq"].shape[1]
        model = MambaClassifier(n_features, args.d_model, args.n_layers, args.dropout).to(device)
        criterion = nn.BCEWithLogitsLoss(pos_weight=pos_weight)
        optimizer = torch.optim.AdamW(model.parameters(), lr=args.lr, weight_decay=args.weight_decay)

        best_f1, best_state, patience_count = -1.0, None, 0
        for epoch in range(1, args.epochs + 1):
            _run_epoch(model, train_loader, device, criterion, optimizer)
            # No separate val in LOO — use early stopping on train loss as proxy
            # (full val fold would leak test into stopping criterion)
        model.eval()

        _, yt, yp, yprob = _run_epoch(model, test_loader, device)
        y_true_all.extend(yt)
        y_pred_all.extend(yp)
        y_prob_all.extend(yprob)
        print(f"  Fold {i+1:2d}/{len(all_ids)}  id={test_id}  true={true_label}  pred={yp[0]}  prob={yprob[0]:.3f}")

    m = _metrics(y_true_all, y_pred_all, y_prob_all)
    _print_metrics(m, "Mamba LOO Results")

    os.makedirs(RESULTS_DIR, exist_ok=True)
    out_path = os.path.join(RESULTS_DIR, "mamba_loo_metrics.json")
    with open(out_path, "w", encoding="utf8") as f:
        json.dump({"loo": m, "n": len(all_ids)}, f, indent=2)
    print(f"\nLOO results saved -> {out_path}")


# ── PREDICT mode ──────────────────────────────────────────────────────────────
def cmd_predict(args):
    from src.models.mamba_dataset import SequenceScaler
    from src.data.build_sequences import extract_sequence, _find_meta_jsons

    model_pt = os.path.join(MODEL_DIR, "mamba.pt")
    cfg_path = os.path.join(MODEL_DIR, "config.json")
    scaler_path = os.path.join(MODEL_DIR, "scaler.json")

    for p in [model_pt, cfg_path, scaler_path]:
        if not os.path.isfile(p):
            sys.exit(f"[ERROR] Missing {p}. Run 'train' first.")

    path = args.input
    if os.path.isdir(path):
        meta_paths = _find_meta_jsons(path)
    elif path.endswith("meta.json"):
        meta_paths = [path]
    else:
        meta_paths = _find_meta_jsons(os.path.dirname(path))

    if not meta_paths:
        sys.exit(f"[ERROR] No meta.json found at: {path}")

    seq, _ = extract_sequence(meta_paths)
    if not seq:
        sys.exit("[ERROR] No valid events (T/P/C) found in the meta.json.")

    with open(cfg_path, encoding="utf8") as f:
        cfg = json.load(f)

    scaler = SequenceScaler.load(scaler_path)
    seq = scaler.transform(seq[:cfg["max_len"]])
    seq_t = torch.tensor(seq, dtype=torch.float32).unsqueeze(0)
    mask = torch.ones(1, seq_t.shape[1], dtype=torch.bool)

    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    model = MambaClassifier(cfg["n_features"], cfg["d_model"], cfg["n_layers"], cfg["dropout"])
    model.load_state_dict(torch.load(model_pt, map_location=device))
    model.to(device).eval()

    with torch.no_grad():
        logit = model(seq_t.to(device), mask.to(device))
        prob = torch.sigmoid(logit).item()

    label = 1 if prob >= 0.5 else 0
    label_name = "CHEAT" if label == 1 else "NORMAL"
    print(f"\nPrediction: {label_name}  (prob={prob:.3f}, events={len(seq)})")
    return {"label": label, "label_name": label_name, "prob": prob}


# ── Entry point ───────────────────────────────────────────────────────────────
def main():
    parser = argparse.ArgumentParser(description="Mamba behavioral sequence classifier")
    sub = parser.add_subparsers(dest="cmd")

    def _add_common(p):
        p.add_argument("--d-model",       type=int,   default=D_MODEL)
        p.add_argument("--n-layers",      type=int,   default=N_LAYERS)
        p.add_argument("--dropout",       type=float, default=DROPOUT)
        p.add_argument("--epochs",        type=int,   default=EPOCHS)
        p.add_argument("--lr",            type=float, default=LR)
        p.add_argument("--weight-decay",  type=float, default=WEIGHT_DECAY)
        p.add_argument("--patience",      type=int,   default=PATIENCE)
        p.add_argument("--batch-size",    type=int,   default=BATCH_SIZE)
        p.add_argument("--max-len",       type=int,   default=MAX_LEN)

    p_train = sub.add_parser("train", help="Train model on train split or LOO")
    _add_common(p_train)
    p_train.add_argument("--loo", action="store_true", help="Leave-One-Out fallback (for small datasets)")

    sub.add_parser("test", help="Evaluate on held-out test split (run once only)")

    p_pred = sub.add_parser("predict", help="Predict single student from meta.json or folder")
    p_pred.add_argument("input", help="Path to meta.json file or student folder")

    args = parser.parse_args()

    if args.cmd == "train":
        if args.loo:
            cmd_loo(args)
        else:
            cmd_train(args)
    elif args.cmd == "test":
        cmd_test(args)
    elif args.cmd == "predict":
        cmd_predict(args)
    else:
        parser.print_help()


if __name__ == "__main__":
    main()
