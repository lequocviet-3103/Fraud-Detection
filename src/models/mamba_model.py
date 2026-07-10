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
SEQ_DIR = os.path.join("data", "train_sequences")
INDEX_PATH = os.path.join("data", "sequences_index.csv")
MODEL_DIR = os.path.join("models", "mamba")
CASE_STUDY_ROOT = "test_new_cohort"

# ── Defaults ────────────────────────────────────────────────────────────────
D_MODEL = 64
N_LAYERS = 2
DROPOUT = 0.2
EPOCHS = 80
LR = 1e-3
WEIGHT_DECAY = 0.05
LABEL_SMOOTHING = 0.05
PATIENCE = 10
BATCH_SIZE = 8
MAX_LEN = 1000
VAL_FRAC = 0.15  # only used when splits.json is absent
SEED = 42


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




# ── Train one epoch ──────────────────────────────────────────────────────────
def _accumulate_stats(logits, labels, stats, y_true, y_pred, y_prob):
    l = logits.detach()
    stats["min"] = min(stats["min"], float(l.min().item()))
    stats["max"] = max(stats["max"], float(l.max().item()))
    stats["sum_abs"] += float(l.abs().sum().item())
    stats["count"] += int(l.numel())
    probs = torch.sigmoid(logits).detach().cpu().numpy()
    preds = (probs >= 0.5).astype(int)
    y_true.extend(labels.cpu().numpy().tolist())
    y_pred.extend(preds.tolist())
    y_prob.extend(probs.tolist())


def _run_epoch(model, loader, device, criterion=None, optimizer=None, label_smoothing=0.0):
    training = criterion is not None and optimizer is not None
    model.train(training)
    total_loss = 0.0
    y_true, y_pred, y_prob = [], [], []
    logits_stats = {"min": float("inf"), "max": -float("inf"),
                    "sum_abs": 0.0, "count": 0}

    if training:
        with torch.set_grad_enabled(True):
            for padded, lengths, mask, ids, labels in loader:
                padded = padded.to(device)
                mask = mask.to(device)
                labels = labels.to(device)

                # Apply label smoothing to training targets only
                if label_smoothing > 0:
                    soft_labels = labels.float() * (1.0 - label_smoothing) + label_smoothing * 0.5
                else:
                    soft_labels = labels.float()

                logits = model(padded, mask)
                loss = criterion(logits, soft_labels)
                optimizer.zero_grad()
                loss.backward()
                nn.utils.clip_grad_norm_(model.parameters(), 1.0)
                optimizer.step()
                total_loss += loss.item() * len(labels)
                _accumulate_stats(logits, labels, logits_stats, y_true, y_pred, y_prob)
    else:
        with torch.set_grad_enabled(False):
            for padded, lengths, mask, ids, labels in loader:
                padded = padded.to(device)
                mask = mask.to(device)
                labels = labels.to(device)

                logits = model(padded, mask)
                loss = criterion(logits, labels)
                total_loss += loss.item() * len(labels)
                _accumulate_stats(logits, labels, logits_stats, y_true, y_pred, y_prob)

    avg_loss = total_loss / max(len(loader.dataset), 1)
    return avg_loss, y_true, y_pred, y_prob, logits_stats
    return avg_loss, y_true, y_pred, y_prob, logits_stats


# ── TRAIN mode ────────────────────────────────────────────────────────────────
def _make_stratified_split(ids, labels, val_frac, seed):
    """Stratified split into (train_ids, val_ids). Falls back to random on tiny classes."""
    n_pos = sum(labels)
    n_neg = len(labels) - n_pos
    try:
        from sklearn.model_selection import train_test_split
        can_strat = min(n_pos, n_neg) >= 2 and len(set(labels)) > 1
        if can_strat:
            tr, va, _, _ = train_test_split(
                ids, labels, test_size=val_frac, stratify=labels, random_state=seed
            )
            return tr, va
    except Exception:
        pass
    rng = np.random.default_rng(seed)
    perm = rng.permutation(len(ids))
    n_val = max(1, int(round(len(ids) * val_frac)))
    val_idx = set(perm[:n_val].tolist())
    val_ids = [ids[i] for i in sorted(val_idx)]
    train_ids = [ids[i] for i in range(len(ids)) if i not in val_idx]
    return train_ids, val_ids


def _load_split_ids(val_frac, seed):
    """Return (train_ids, val_ids). Uses data/splits.json if present, else stratified split."""
    import pandas as pd
    df = pd.read_csv(INDEX_PATH)
    df = df[df["label"].isin([0, 1])].reset_index(drop=True)
    ids = df["id"].tolist()
    labels = df["label"].tolist()

    if os.path.isfile(SPLITS_PATH):
        with open(SPLITS_PATH, encoding="utf8") as f:
            sp = json.load(f)
        train_ids = sp.get("train", [])
        val_ids = sp.get("val", [])
        if train_ids and val_ids:
            return train_ids, val_ids

    return _make_stratified_split(ids, labels, val_frac, seed)


def cmd_train(args):
    from src.models.mamba_dataset import SequenceDataset, build_scaler_from_ids, collate_fn

    if args.train_data_dir and args.train_data_dir != CASE_STUDY_ROOT:
        train_dir = args.train_data_dir
        print(f"Rebuilding sequences from: {train_dir}")
        from src.data.build_sequences import main as rebuild_main
        import sys as _sys
        saved_argv = _sys.argv
        _sys.argv = ["build_sequences.py", "--data-dir", train_dir, "--output-dir", SEQ_DIR]
        try:
            rebuild_main()
        finally:
            _sys.argv = saved_argv
    else:
        train_dir = CASE_STUDY_ROOT
        if not os.path.isfile(INDEX_PATH):
            print(f"{INDEX_PATH} not found. Building from {train_dir}...")
            from src.data.build_sequences import main as rebuild_main
            import sys as _sys
            saved_argv = _sys.argv
            _sys.argv = ["build_sequences.py", "--data-dir", train_dir, "--output-dir", SEQ_DIR]
            try:
                rebuild_main()
            finally:
                _sys.argv = saved_argv

    if not os.path.isfile(INDEX_PATH):
        sys.exit(f"[ERROR] {INDEX_PATH} not found. Run build_sequences.py first.")

    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    print(f"Device: {device}")
    if str(device) == "cpu":
        print("[WARNING] Mamba runs on CPU — this will be very slow and may not converge well.")
        print("          Consider using Google Colab/Kaggle GPU runtime.")

    train_ids, val_ids = _load_split_ids(args.val_frac, SEED)

    scaler = build_scaler_from_ids(train_ids, SEQ_DIR)
    os.makedirs(MODEL_DIR, exist_ok=True)
    scaler.save(os.path.join(MODEL_DIR, "scaler.json"))

    train_ds = SequenceDataset(train_ids, SEQ_DIR, scaler=scaler, max_len=args.max_len)
    val_ds   = SequenceDataset(val_ids,   SEQ_DIR, scaler=scaler, max_len=args.max_len)

    train_loader = DataLoader(train_ds, batch_size=args.batch_size, shuffle=True,
                              collate_fn=collate_fn, drop_last=False)
    val_loader   = DataLoader(val_ds,   batch_size=args.batch_size, shuffle=False,
                              collate_fn=collate_fn, drop_last=False)

    train_labels = np.array([item["label"].item() for item in train_ds])
    n_pos = int(train_labels.sum())
    n_neg = int(len(train_labels) - n_pos)
    pos_weight = torch.tensor([1.0], dtype=torch.float32).to(device)
    use_pos_weight = not args.no_pos_weight
    if use_pos_weight:
        pos_weight = torch.tensor([n_neg / max(n_pos, 1)], dtype=torch.float32).to(device)

    val_labels = np.array([item["label"].item() for item in val_ds])
    val_pos = int(val_labels.sum())
    val_neg = int(len(val_labels) - val_pos)

    print(f"Train: {len(train_ids)} samples (cheat={n_pos}, normal={n_neg}), "
          f"pos_weight={pos_weight.item():.2f}" + (
              f", label_smoothing={args.label_smoothing}" if args.label_smoothing else ""))
    print(f"Val  : {len(val_ids)} samples (cheat={val_pos}, normal={val_neg}) "
          f"[stratified {args.val_frac:.0%}]")

    n_features = train_ds[0]["seq"].shape[1]
    model = MambaClassifier(n_features, args.d_model, args.n_layers, args.dropout).to(device)
    criterion = nn.BCEWithLogitsLoss(pos_weight=pos_weight)
    optimizer = torch.optim.AdamW(model.parameters(), lr=args.lr, weight_decay=args.weight_decay)

    def _apply_smoothing(labels, eps):
        return labels * (1.0 - eps) + eps * 0.5

    best_val_loss = math.inf
    best_epoch = 0
    bad_epochs = 0
    best_state = None

    print(f"\nTraining {args.epochs} epochs (patience={args.patience})...")
    print(f"{'Epoch':>5} {'TrainLoss':>10} {'ValLoss':>10} {'ValAcc':>8}  {'|logit|':>8}  Notes")
    print("-" * 64)

    for epoch in range(1, args.epochs + 1):
        ls = args.label_smoothing if args.label_smoothing else 0.0
        tr_loss, _, _, _, tr_logits = _run_epoch(model, train_loader, device, criterion, optimizer, label_smoothing=ls)
        # Validation always uses hard labels (no smoothing at eval time)
        va_loss, y_true, y_pred, _, va_logits = _run_epoch(model, val_loader, device, criterion, None, label_smoothing=0.0)
        val_acc = float((np.array(y_true) == np.array(y_pred)).mean()) if y_true else 0.0
        mean_abs = va_logits["sum_abs"] / max(va_logits["count"], 1)
        sat = " !SAT" if mean_abs > 50 else ""

        improved = va_loss < best_val_loss - 1e-6
        note = ""
        if improved:
            best_val_loss = va_loss
            best_epoch = epoch
            bad_epochs = 0
            best_state = {k: v.detach().cpu().clone() for k, v in model.state_dict().items()}
            note = f"*best"
        else:
            bad_epochs += 1
            note = f"bad={bad_epochs}/{args.patience}"

        print(f"Epoch {epoch:3d}  Loss={tr_loss:.4f}  ValLoss={va_loss:.4f}  "
              f"Acc={val_acc:.3f}  |logit|={mean_abs:6.2f}{sat}  {note}")

        if bad_epochs >= args.patience:
            print(f"\n[Early stop] No improvement for {args.patience} epochs. "
                  f"Best epoch={best_epoch}, best_val_loss={best_val_loss:.4f}")
            break

    if best_state is not None:
        model.load_state_dict(best_state)
        print(f"\nRestored best model from epoch {best_epoch} (val_loss={best_val_loss:.4f})")

    final_path = os.path.join(MODEL_DIR, "mamba.pt")
    torch.save(model.state_dict(), final_path)
    cfg = {
        "n_features": n_features,
        "d_model": args.d_model,
        "n_layers": args.n_layers,
        "dropout": args.dropout,
        "max_len": args.max_len,
        "best_epoch": best_epoch,
        "best_val_loss": float(best_val_loss),
        "pos_weight": float(pos_weight.item()),
    }
    with open(os.path.join(MODEL_DIR, "config.json"), "w", encoding="utf8") as f:
        json.dump(cfg, f, indent=2)

    print(f"\nSaved {final_path}")
    print(f"Saved {os.path.join(MODEL_DIR, 'config.json')}")






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
        p.add_argument("--label-smoothing", type=float, default=LABEL_SMOOTHING,
                       help="Soft target smoothing [0-0.5]. Default: 0.05.")
        p.add_argument("--patience",      type=int,   default=PATIENCE)
        p.add_argument("--val-frac",      type=float, default=VAL_FRAC,
                       help="Validation fraction for stratified split. Default: 0.15.")
        p.add_argument("--batch-size",    type=int,   default=BATCH_SIZE)
        p.add_argument("--max-len",       type=int,   default=MAX_LEN)
        p.add_argument("--no-pos-weight", action="store_true",
                       help="Disable pos_weight (use uniform class weighting)")
        p.add_argument("--train-data-dir", default=CASE_STUDY_ROOT,
                       help="Source folder for training data (default: test_new_cohort)")

    p_train = sub.add_parser("train", help="Train model on all dataset")
    _add_common(p_train)

    p_pred = sub.add_parser("predict", help="Predict single student from meta.json or folder")
    p_pred.add_argument("input", help="Path to meta.json file or student folder")

    args = parser.parse_args()

    if args.cmd == "train":
        cmd_train(args)
    elif args.cmd == "predict":
        cmd_predict(args)
    else:
        parser.print_help()


if __name__ == "__main__":
    main()
