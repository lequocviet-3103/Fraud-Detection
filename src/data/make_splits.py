"""Create TaskTracker train/validation splits for the Mamba pipeline.

PasteTrace is an external test set and is never split or mixed into training.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path

import pandas as pd
from sklearn.model_selection import train_test_split


TRAIN_INDEX_PATH = Path("data") / "mamba" / "train_index.csv"
TEST_INDEX_PATH = Path("data") / "mamba" / "test_index.csv"
SPLITS_PATH = Path("data") / "mamba" / "splits.json"


def _class_counts(labels: list[int]) -> dict[str, int]:
    return {
        "total": len(labels),
        "cheat": labels.count(1),
        "normal": labels.count(0),
    }


def make_splits(
    train_index_path: str | Path,
    test_index_path: str | Path,
    val_ratio: float,
    seed: int,
) -> dict:
    if not 0.0 < val_ratio < 1.0:
        raise ValueError(f"val_ratio phai nam trong (0, 1), nhan duoc {val_ratio}")

    train_df = pd.read_csv(train_index_path)
    train_df = train_df[train_df["label"].isin([0, 1])].reset_index(drop=True)
    if train_df.empty:
        raise ValueError("TaskTracker index khong co mau hop le.")

    ids = train_df["id"].astype(str).tolist()
    labels = train_df["label"].astype(int).tolist()
    counts = _class_counts(labels)
    if min(counts["cheat"], counts["normal"]) < 2:
        raise ValueError(
            "Moi lop TaskTracker can it nhat 2 mau de chia train/validation."
        )

    train_ids, val_ids, train_labels, val_labels = train_test_split(
        ids,
        labels,
        test_size=val_ratio,
        stratify=labels,
        random_state=seed,
    )

    test_df = pd.read_csv(test_index_path)
    test_df = test_df[test_df["label"].isin([0, 1])].reset_index(drop=True)
    test_ids = test_df["id"].astype(str).tolist()
    test_labels = test_df["label"].astype(int).tolist()

    return {
        "train": train_ids,
        "val": val_ids,
        "external_test": test_ids,
        "seed": seed,
        "val_ratio": val_ratio,
        "sources": {
            "train": "tasktracker",
            "val": "tasktracker",
            "external_test": "pastetrace",
        },
        "counts": {
            "train": _class_counts([int(v) for v in train_labels]),
            "val": _class_counts([int(v) for v in val_labels]),
            "external_test": _class_counts(test_labels),
        },
    }


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Split TaskTracker into train/val; keep PasteTrace as external test"
    )
    parser.add_argument("--train-index", default=str(TRAIN_INDEX_PATH))
    parser.add_argument("--test-index", default=str(TEST_INDEX_PATH))
    parser.add_argument("--output", default=str(SPLITS_PATH))
    parser.add_argument("--val", type=float, default=0.15)
    parser.add_argument("--seed", type=int, default=42)
    args = parser.parse_args()

    for path in (args.train_index, args.test_index):
        if not Path(path).is_file():
            raise SystemExit(
                f"[ERROR] Khong tim thay {path}. Hay chay build_sequences truoc."
            )

    try:
        splits = make_splits(
            args.train_index, args.test_index, val_ratio=args.val, seed=args.seed
        )
    except ValueError as exc:
        raise SystemExit(f"[ERROR] {exc}") from exc

    output = Path(args.output)
    output.parent.mkdir(parents=True, exist_ok=True)
    with output.open("w", encoding="utf8") as handle:
        json.dump(splits, handle, indent=2, ensure_ascii=False)

    print(f"Splits saved -> {output}")
    for name in ("train", "val", "external_test"):
        count = splits["counts"][name]
        print(
            f"  {name:13}: {count['total']} "
            f"(cheat={count['cheat']}, normal={count['normal']})"
        )
    print("  External test remains PasteTrace only.")


if __name__ == "__main__":
    main()
