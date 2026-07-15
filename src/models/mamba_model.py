"""Mamba classifier for normalized behavioral event sequences.

Commands::

    python -m src.models.mamba_model train
    python -m src.models.mamba_model test
    python -m src.models.mamba_model predict pastetrace/normalized/111_A.json

Training and validation use TaskTracker only. ``test`` evaluates the frozen
model on PasteTrace, which is kept as a fully external test dataset.
"""

from __future__ import annotations

import argparse
import csv
import json
import os
import sys
from pathlib import Path

import numpy as np
import torch
import torch.nn as nn
from sklearn.metrics import (
    accuracy_score,
    confusion_matrix,
    f1_score,
    precision_recall_fscore_support,
    roc_auc_score,
)
from torch.utils.data import DataLoader


MAMBA_DATA_DIR = Path("data") / "mamba"
SPLITS_PATH = MAMBA_DATA_DIR / "splits.json"
TRAIN_SEQ_DIR = MAMBA_DATA_DIR / "train_sequences"
TEST_SEQ_DIR = MAMBA_DATA_DIR / "test_sequences"
TRAIN_INDEX_PATH = MAMBA_DATA_DIR / "train_index.csv"
TEST_INDEX_PATH = MAMBA_DATA_DIR / "test_index.csv"
MODEL_DIR = os.path.join("models", "mamba")
RESULTS_DIR = Path("results")

D_MODEL = 64
N_LAYERS = 2
DROPOUT = 0.2
EPOCHS = 80
LR = 1e-3
WEIGHT_DECAY = 0.01
PATIENCE = 10
BATCH_SIZE = 8
MAX_LEN = 1000
SAME_MACHINE_FEATURE_IDX = 6


def _import_mamba():
    try:
        from mamba_ssm import Mamba

        return Mamba
    except (ImportError, OSError) as exc:
        raise RuntimeError(
            "Khong import duoc mamba-ssm. Hay dung moi truong GPU NVIDIA/CUDA "
            "va cai requirements-mamba.txt."
        ) from exc


class MambaBlock(nn.Module):
    def __init__(self, d_model: int):
        super().__init__()
        mamba_class = _import_mamba()
        self.norm = nn.LayerNorm(d_model)
        self.mamba = mamba_class(
            d_model=d_model, d_state=16, d_conv=4, expand=2
        )

    def forward(self, inputs: torch.Tensor) -> torch.Tensor:
        return inputs + self.mamba(self.norm(inputs))


class MambaClassifier(nn.Module):
    def __init__(
        self,
        n_features: int,
        d_model: int = D_MODEL,
        n_layers: int = N_LAYERS,
        dropout: float = DROPOUT,
    ):
        super().__init__()
        self.input_proj = nn.Linear(n_features, d_model)
        # TaskTracker has no same_machine source. Start this unseen feature at
        # zero influence; it can still learn if future training data contains it.
        if n_features > SAME_MACHINE_FEATURE_IDX:
            with torch.no_grad():
                self.input_proj.weight[:, SAME_MACHINE_FEATURE_IDX].zero_()
        self.blocks = nn.Sequential(
            *[MambaBlock(d_model) for _ in range(n_layers)]
        )
        self.dropout = nn.Dropout(dropout)
        self.head = nn.Linear(d_model, 1)

    def forward(self, inputs: torch.Tensor, mask: torch.Tensor) -> torch.Tensor:
        hidden = self.blocks(self.input_proj(inputs))
        mask_float = mask.unsqueeze(-1).float()
        pooled = (hidden * mask_float).sum(dim=1) / mask_float.sum(dim=1).clamp(
            min=1
        )
        return self.head(self.dropout(pooled)).squeeze(-1)


def _run_epoch(
    model: nn.Module,
    loader: DataLoader,
    device: torch.device,
    criterion: nn.Module,
    optimizer: torch.optim.Optimizer | None = None,
) -> tuple[float, list[int], list[int], list[float], list[str]]:
    training = optimizer is not None
    model.train(training)
    total_loss = 0.0
    y_true: list[int] = []
    y_pred: list[int] = []
    y_prob: list[float] = []
    sample_ids: list[str] = []

    with torch.set_grad_enabled(training):
        for padded, _lengths, mask, ids, labels in loader:
            padded = padded.to(device)
            mask = mask.to(device)
            labels = labels.to(device)
            logits = model(padded, mask)
            loss = criterion(logits, labels)

            if optimizer is not None:
                optimizer.zero_grad()
                loss.backward()
                nn.utils.clip_grad_norm_(model.parameters(), 1.0)
                optimizer.step()

            total_loss += loss.item() * len(labels)
            probabilities = torch.sigmoid(logits).detach().cpu().numpy()
            predictions = (probabilities >= 0.5).astype(int)
            y_true.extend(labels.detach().cpu().numpy().astype(int).tolist())
            y_pred.extend(predictions.tolist())
            y_prob.extend(probabilities.astype(float).tolist())
            sample_ids.extend(ids)

    average_loss = total_loss / max(len(loader.dataset), 1)
    return average_loss, y_true, y_pred, y_prob, sample_ids


def _metrics(
    y_true: list[int], y_pred: list[int], y_prob: list[float]
) -> dict[str, float | int | list[list[int]] | None]:
    precision, recall, f1, support = precision_recall_fscore_support(
        y_true, y_pred, labels=[0, 1], zero_division=0
    )
    result: dict[str, float | int | list[list[int]] | None] = {
        "accuracy": float(accuracy_score(y_true, y_pred)),
        "macro_f1": float(f1_score(y_true, y_pred, average="macro", zero_division=0)),
        "normal_precision": float(precision[0]),
        "normal_recall": float(recall[0]),
        "normal_f1": float(f1[0]),
        "normal_support": int(support[0]),
        "cheat_precision": float(precision[1]),
        "cheat_recall": float(recall[1]),
        "cheat_f1": float(f1[1]),
        "cheat_support": int(support[1]),
        "confusion_matrix": confusion_matrix(
            y_true, y_pred, labels=[0, 1]
        ).astype(int).tolist(),
    }
    result["roc_auc"] = (
        float(roc_auc_score(y_true, y_prob))
        if len(set(y_true)) == 2
        else None
    )
    return result


def _read_index(index_path: Path) -> dict[str, dict[str, str]]:
    with index_path.open(encoding="utf8", newline="") as handle:
        return {row["id"]: row for row in csv.DictReader(handle)}


def _required_training_inputs() -> dict:
    for path in (SPLITS_PATH, TRAIN_INDEX_PATH, TEST_INDEX_PATH):
        if not path.is_file():
            raise SystemExit(
                f"[ERROR] Thieu {path}. Chay build_sequences va make_splits truoc."
            )
    with SPLITS_PATH.open(encoding="utf8") as handle:
        splits = json.load(handle)
    if splits.get("sources", {}).get("external_test") != "pastetrace":
        raise SystemExit("[ERROR] splits.json khong khai bao PasteTrace la external test.")
    return splits


def cmd_train(args: argparse.Namespace) -> None:
    from src.models.mamba_dataset import (
        SequenceDataset,
        build_scaler_from_ids,
        collate_fn,
    )

    splits = _required_training_inputs()
    train_all = bool(getattr(args, "train_all", False))
    if train_all:
        train_ids = list(_read_index(TRAIN_INDEX_PATH))
        val_ids: list[str] = []
    else:
        train_ids = list(splits.get("train", []))
        val_ids = list(splits.get("val", []))
    if not train_ids or (not train_all and not val_ids):
        raise SystemExit("[ERROR] Train/validation data dang rong.")

    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    print(f"Device: {device}")
    if device.type == "cpu":
        print("[WARNING] Mamba tren CPU rat cham; nen chay bang GPU CUDA.")

    scaler = build_scaler_from_ids(train_ids, str(TRAIN_SEQ_DIR))
    Path(MODEL_DIR).mkdir(parents=True, exist_ok=True)
    scaler.save(os.path.join(MODEL_DIR, "scaler.json"))

    train_dataset = SequenceDataset(
        train_ids, str(TRAIN_SEQ_DIR), scaler=scaler, max_len=args.max_len
    )
    val_dataset = (
        None
        if train_all
        else SequenceDataset(
            val_ids, str(TRAIN_SEQ_DIR), scaler=scaler, max_len=args.max_len
        )
    )
    train_loader = DataLoader(
        train_dataset,
        batch_size=args.batch_size,
        shuffle=True,
        collate_fn=collate_fn,
    )
    val_loader = (
        None
        if val_dataset is None
        else DataLoader(
            val_dataset,
            batch_size=args.batch_size,
            shuffle=False,
            collate_fn=collate_fn,
        )
    )

    train_labels = np.array(
        [int(item["label"].item()) for item in train_dataset], dtype=int
    )
    positives = int(train_labels.sum())
    negatives = int(len(train_labels) - positives)
    pos_weight = torch.tensor(
        [negatives / max(positives, 1)], dtype=torch.float32, device=device
    )

    n_features = int(train_dataset[0]["seq"].shape[1])
    try:
        model = MambaClassifier(
            n_features, args.d_model, args.n_layers, args.dropout
        ).to(device)
    except RuntimeError as exc:
        raise SystemExit(f"[ERROR] {exc}") from exc
    criterion = nn.BCEWithLogitsLoss(pos_weight=pos_weight)
    optimizer = torch.optim.AdamW(
        model.parameters(), lr=args.lr, weight_decay=args.weight_decay
    )

    if train_all:
        print(
            f"TaskTracker train-all={len(train_dataset)} "
            f"(cheat={positives}, normal={negatives})"
        )
        print("Validation disabled; model se chay du so epoch da chon.")
    else:
        print(
            f"TaskTracker train={len(train_dataset)}, val={len(val_dataset)} "
            f"(train cheat={positives}, normal={negatives})"
        )
    print("PasteTrace khong duoc dung trong buoc train nay.")
    if train_all:
        print(f"{'Epoch':>5} {'TrainLoss':>10}")
    else:
        print(f"{'Epoch':>5} {'TrainLoss':>10} {'ValLoss':>10} {'ValMacroF1':>11}")

    model_path = os.path.join(MODEL_DIR, "mamba.pt")
    best_f1 = -1.0
    best_loss = float("inf")
    best_epoch = 0
    stale_epochs = 0

    for epoch in range(1, args.epochs + 1):
        train_loss, *_ = _run_epoch(
            model, train_loader, device, criterion, optimizer
        )
        if train_all:
            print(f"{epoch:5d} {train_loss:10.4f}")
            continue

        assert val_loader is not None
        val_loss, val_true, val_pred, val_prob, _ = _run_epoch(
            model, val_loader, device, criterion
        )
        val_f1 = float(_metrics(val_true, val_pred, val_prob)["macro_f1"])
        print(f"{epoch:5d} {train_loss:10.4f} {val_loss:10.4f} {val_f1:11.4f}")

        improved = val_f1 > best_f1 + 1e-6 or (
            abs(val_f1 - best_f1) <= 1e-6 and val_loss < best_loss
        )
        if improved:
            torch.save(model.state_dict(), model_path)
            best_f1 = val_f1
            best_loss = val_loss
            best_epoch = epoch
            stale_epochs = 0
        else:
            stale_epochs += 1
            if stale_epochs >= args.patience:
                print(f"Early stopping tai epoch {epoch}.")
                break

    if train_all:
        torch.save(model.state_dict(), model_path)
        best_epoch = args.epochs
        best_f1 = None
        best_loss = None

    majority_class = int(positives >= negatives)
    config = {
        "n_features": n_features,
        "feature_names": train_dataset.records[0].get("feature_names", None),
        "d_model": args.d_model,
        "n_layers": args.n_layers,
        "dropout": args.dropout,
        "max_len": args.max_len,
        "best_epoch": best_epoch,
        "best_val_macro_f1": best_f1,
        "best_val_loss": best_loss,
        "training_mode": "all_tasktracker" if train_all else "train_val",
        "n_train_samples": len(train_dataset),
        "n_val_samples": 0 if val_dataset is None else len(val_dataset),
        "train_source": "tasktracker",
        "test_source": "pastetrace",
        "majority_class_from_train": majority_class,
    }
    # SequenceDataset intentionally stores only model inputs, so keep names explicit.
    from src.data.build_sequences import FEATURE_NAMES

    config["feature_names"] = FEATURE_NAMES
    with open(os.path.join(MODEL_DIR, "config.json"), "w", encoding="utf8") as handle:
        json.dump(config, handle, indent=2, ensure_ascii=False)
    if train_all:
        print(f"Final model saved -> {model_path} (epoch={best_epoch})")
    else:
        print(f"Best model saved -> {model_path} (epoch={best_epoch})")


def _load_model_and_scaler(device: torch.device):
    from src.models.mamba_dataset import SequenceScaler

    paths = {
        "model": Path(MODEL_DIR) / "mamba.pt",
        "config": Path(MODEL_DIR) / "config.json",
        "scaler": Path(MODEL_DIR) / "scaler.json",
    }
    for path in paths.values():
        if not path.is_file():
            raise SystemExit(f"[ERROR] Thieu {path}. Hay train model truoc.")
    with paths["config"].open(encoding="utf8") as handle:
        config = json.load(handle)
    if config.get("train_source") != "tasktracker" or config.get(
        "test_source"
    ) != "pastetrace":
        raise SystemExit("[ERROR] Model hien tai khong thuoc pipeline TaskTracker -> PasteTrace.")
    scaler = SequenceScaler.load(str(paths["scaler"]))
    try:
        model = MambaClassifier(
            config["n_features"],
            config["d_model"],
            config["n_layers"],
            config["dropout"],
        )
    except RuntimeError as exc:
        raise SystemExit(f"[ERROR] {exc}") from exc
    state = torch.load(paths["model"], map_location=device)
    model.load_state_dict(state)
    model.to(device).eval()
    return model, scaler, config


def cmd_test(_args: argparse.Namespace) -> None:
    from src.models.mamba_dataset import SequenceDataset, collate_fn

    splits = _required_training_inputs()
    test_ids = list(splits.get("external_test", []))
    if not test_ids:
        raise SystemExit("[ERROR] PasteTrace external test split dang rong.")

    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    model, scaler, config = _load_model_and_scaler(device)
    test_dataset = SequenceDataset(
        test_ids,
        str(TEST_SEQ_DIR),
        scaler=scaler,
        max_len=int(config["max_len"]),
    )
    test_loader = DataLoader(
        test_dataset,
        batch_size=BATCH_SIZE,
        shuffle=False,
        collate_fn=collate_fn,
    )
    criterion = nn.BCEWithLogitsLoss()
    test_loss, y_true, y_pred, y_prob, ordered_ids = _run_epoch(
        model, test_loader, device, criterion
    )
    metrics = _metrics(y_true, y_pred, y_prob)
    metrics["loss"] = float(test_loss)
    metrics["n_samples"] = len(y_true)

    majority_class = int(config["majority_class_from_train"])
    majority_pred = [majority_class] * len(y_true)
    majority_prob = [float(majority_class)] * len(y_true)
    baseline = _metrics(y_true, majority_pred, majority_prob)

    index = _read_index(TEST_INDEX_PATH)
    predictions = []
    for sample_id, truth, pred, probability in zip(
        ordered_ids, y_true, y_pred, y_prob
    ):
        predictions.append(
            {
                "id": sample_id,
                "session_id": index.get(sample_id, {}).get("session_id", sample_id),
                "true_label": truth,
                "predicted_label": pred,
                "cheat_probability": probability,
            }
        )

    RESULTS_DIR.mkdir(parents=True, exist_ok=True)
    result = {
        "train_source": "tasktracker",
        "test_source": "pastetrace",
        "mamba": metrics,
        "majority_baseline": baseline,
        "predictions": predictions,
    }
    result_path = RESULTS_DIR / "mamba_metrics.json"
    with result_path.open("w", encoding="utf8") as handle:
        json.dump(result, handle, indent=2, ensure_ascii=False, allow_nan=False)

    csv_path = RESULTS_DIR / "mamba_predictions.csv"
    with csv_path.open("w", encoding="utf8", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=list(predictions[0]))
        writer.writeheader()
        writer.writerows(predictions)

    print(f"External test: PasteTrace ({len(y_true)} sessions)")
    print(f"Accuracy : {metrics['accuracy']:.4f}")
    print(f"Macro F1 : {metrics['macro_f1']:.4f}")
    print(f"Cheat F1 : {metrics['cheat_f1']:.4f}")
    print(f"Normal F1: {metrics['normal_f1']:.4f}")
    print(f"Results  : {result_path}")


def cmd_predict(args: argparse.Namespace) -> dict:
    from src.data.build_sequences import extract_normalized_sequence

    input_path = Path(args.input)
    if not input_path.is_file() or input_path.suffix.lower() != ".json":
        raise SystemExit("[ERROR] predict can duong dan toi mot JSON normalized.")
    with input_path.open(encoding="utf8", errors="ignore") as handle:
        record = json.load(handle)
    sequence, _ = extract_normalized_sequence(record)
    if not sequence:
        raise SystemExit("[ERROR] JSON khong co event type/paste/cut hop le.")

    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    model, scaler, config = _load_model_and_scaler(device)
    scaled = scaler.transform(sequence[: int(config["max_len"])])
    tensor = torch.tensor(scaled, dtype=torch.float32).unsqueeze(0).to(device)
    mask = torch.ones(1, tensor.shape[1], dtype=torch.bool, device=device)
    with torch.no_grad():
        probability = float(torch.sigmoid(model(tensor, mask)).item())
    label = int(probability >= 0.5)
    label_name = "CHEAT" if label else "NORMAL"
    print(
        f"Prediction: {label_name} "
        f"(prob={probability:.4f}, events={len(scaled)})"
    )
    return {"label": label, "label_name": label_name, "prob": probability}


def main() -> None:
    parser = argparse.ArgumentParser(description="TaskTracker -> Mamba -> PasteTrace")
    subparsers = parser.add_subparsers(dest="command", required=True)

    train_parser = subparsers.add_parser("train", help="Train/validate on TaskTracker")
    train_parser.add_argument("--d-model", type=int, default=D_MODEL)
    train_parser.add_argument("--n-layers", type=int, default=N_LAYERS)
    train_parser.add_argument("--dropout", type=float, default=DROPOUT)
    train_parser.add_argument("--epochs", type=int, default=EPOCHS)
    train_parser.add_argument("--lr", type=float, default=LR)
    train_parser.add_argument("--weight-decay", type=float, default=WEIGHT_DECAY)
    train_parser.add_argument("--patience", type=int, default=PATIENCE)
    train_parser.add_argument("--batch-size", type=int, default=BATCH_SIZE)
    train_parser.add_argument("--max-len", type=int, default=MAX_LEN)
    train_parser.add_argument(
        "--train-all",
        action="store_true",
        help="Train on all TaskTracker sessions; disable validation/early stopping",
    )

    subparsers.add_parser("test", help="Evaluate frozen model on PasteTrace")
    predict_parser = subparsers.add_parser("predict", help="Predict one normalized JSON")
    predict_parser.add_argument("input")

    args = parser.parse_args()
    if args.command == "train":
        cmd_train(args)
    elif args.command == "test":
        cmd_test(args)
    else:
        cmd_predict(args)


if __name__ == "__main__":
    main()
