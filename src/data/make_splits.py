"""Create stratified train/val/test splits from sequences_index.csv.

Output: data/splits.json  (shared by all models for fair comparison)
"""
import argparse
import json
import os
import sys

import pandas as pd
from sklearn.model_selection import train_test_split

INDEX_PATH = os.path.join("data", "sequences_index.csv")
SPLITS_PATH = os.path.join("data", "splits.json")


def make_splits(index_path: str, train_ratio: float, val_ratio: float, test_ratio: float, seed: int) -> dict:
    total = train_ratio + val_ratio + test_ratio
    if abs(total - 1.0) > 1e-6:
        sys.exit(f"[ERROR] Ratios must sum to 1.0, got {total:.4f}")

    df = pd.read_csv(index_path)
    df = df[df["label"].isin([0, 1])].reset_index(drop=True)

    ids = df["id"].tolist()
    labels = df["label"].tolist()

    counts = {0: labels.count(0), 1: labels.count(1)}
    print(f"Total usable samples: {len(ids)}  (cheat={counts[1]}, normal={counts[0]})")

    # Check minimum viability: each class needs >=2 samples to stratify split twice
    for lbl, cnt in counts.items():
        if cnt < 3:
            print(
                f"\n[WARNING] Only {cnt} sample(s) for label={lbl}. "
                "Dataset is too small/imbalanced for reliable train/val/test splits.\n"
                "Recommendation: use LOO mode instead (--loo flag in mamba_model.py).\n"
                "Proceeding anyway — results may not be meaningful."
            )

    # Split off test first, then val from remainder
    test_frac = test_ratio
    val_frac_of_rest = val_ratio / (train_ratio + val_ratio)

    try:
        ids_tv, ids_test, y_tv, _ = train_test_split(
            ids, labels, test_size=test_frac, stratify=labels, random_state=seed
        )
    except ValueError as e:
        sys.exit(
            f"[ERROR] Cannot stratify test split: {e}\n"
            "Dataset too small or imbalanced. Use --loo flag instead."
        )

    try:
        ids_train, ids_val, _, _ = train_test_split(
            ids_tv, y_tv, test_size=val_frac_of_rest, stratify=y_tv, random_state=seed
        )
    except ValueError as e:
        sys.exit(
            f"[ERROR] Cannot stratify val split: {e}\n"
            "Dataset too small or imbalanced. Use --loo flag instead."
        )

    def split_counts(id_list):
        lbl_map = dict(zip(ids, labels))
        c = {0: 0, 1: 0}
        for i in id_list:
            c[lbl_map[i]] += 1
        return c

    tc, vc, xc = split_counts(ids_train), split_counts(ids_val), split_counts(ids_test)

    result = {
        "train": ids_train,
        "val": [],
        "test": [],
        "seed": seed,
        "ratios": {"train": train_ratio, "val": val_ratio, "test": test_ratio},
        "counts": {
            "train": {"total": len(ids_train), "cheat": tc[1], "normal": tc[0]},
            "val":   {"total": len(ids_val),   "cheat": vc[1], "normal": vc[0]},
            "test":  {"total": len(ids_test),  "cheat": xc[1], "normal": xc[0]},
        },
    }

    # Safety: warn if any split has 0 of a class
    for split_name, sc in [("train", tc), ("val", vc), ("test", xc)]:
        for lbl, cnt in sc.items():
            if cnt == 0:
                print(
                    f"\n[WARNING] {split_name} split has 0 samples for label={lbl}. "
                    "Model evaluation will be unreliable. Consider using --loo mode."
                )

    return result


def main():
    parser = argparse.ArgumentParser(description="Create stratified train/val/test splits")
    parser.add_argument("--index", default=INDEX_PATH)
    parser.add_argument("--output", default=SPLITS_PATH)
    parser.add_argument("--train", type=float, default=0.7)
    parser.add_argument("--val",   type=float, default=0.15)
    parser.add_argument("--test",  type=float, default=0.15)
    parser.add_argument("--seed",  type=int,   default=42)
    args = parser.parse_args()

    if not os.path.isfile(args.index):
        sys.exit(f"[ERROR] Index file not found: {args.index}\nRun build_sequences.py first.")

    splits = make_splits(args.index, args.train, args.val, args.test, args.seed)

    os.makedirs(os.path.dirname(args.output) or ".", exist_ok=True)
    with open(args.output, "w", encoding="utf8") as f:
        json.dump(splits, f, indent=2)

    c = splits["counts"]
    print(f"\nSplits saved -> {args.output}")
    print(f"  train : {c['train']['total']} (cheat={c['train']['cheat']}, normal={c['train']['normal']})")
    print(f"  val   : {c['val']['total']}   (cheat={c['val']['cheat']}, normal={c['val']['normal']})")
    print(f"  test  : {c['test']['total']}  (cheat={c['test']['cheat']}, normal={c['test']['normal']})")
    print(f"  seed  : {args.seed}")


if __name__ == "__main__":
    main()
