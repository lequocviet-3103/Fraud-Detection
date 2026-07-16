"""Create shared, participant-grouped TaskTracker train/validation/test splits."""

from __future__ import annotations

import argparse
import csv
import json
from pathlib import Path

import numpy as np
import pandas as pd
from sklearn.model_selection import GroupShuffleSplit


INDEX_PATH = Path("data") / "mamba" / "index.csv"
SPLIT_DIR = Path("data") / "splits" / "tasktracker"


def _counts(frame: pd.DataFrame) -> dict[str, int]:
    labels = frame["label"].astype(int)
    return {
        "sessions": int(len(frame)),
        "risk_1": int((labels == 1).sum()),
        "normal_0": int((labels == 0).sum()),
        "groups": int(frame["group_id"].nunique()),
    }


def _candidate_score(
    frames: dict[str, pd.DataFrame],
    ratios: dict[str, float],
    total: int,
    global_positive_rate: float,
) -> float:
    score = 0.0
    for name, frame in frames.items():
        expected = ratios[name] * total
        score += abs(len(frame) - expected) / max(total, 1)
        positive_rate = float(frame["label"].mean())
        score += 0.5 * abs(positive_rate - global_positive_rate)
    return score


def make_grouped_splits(
    frame: pd.DataFrame,
    train_ratio: float,
    validation_ratio: float,
    test_ratio: float,
    seed: int,
    search_iterations: int,
) -> dict[str, pd.DataFrame]:
    ratios = {
        "train": train_ratio,
        "validation": validation_ratio,
        "test": test_ratio,
    }
    if any(value <= 0 for value in ratios.values()) or not np.isclose(sum(ratios.values()), 1.0):
        raise ValueError("train/validation/test ratios must be positive and sum to 1")
    if frame.empty or frame["label"].nunique() != 2:
        raise ValueError("TaskTracker must contain both labels 0 and 1")
    if frame["group_id"].isna().any() or (frame["group_id"].astype(str).str.len() == 0).any():
        raise ValueError("Every session must have a non-empty group_id")

    indices = np.arange(len(frame))
    groups = frame["group_id"].astype(str).to_numpy()
    labels = frame["label"].astype(int).to_numpy()
    validation_within_remainder = validation_ratio / (train_ratio + validation_ratio)
    best: dict[str, pd.DataFrame] | None = None
    best_score = float("inf")

    for attempt in range(max(search_iterations, 1)):
        outer = GroupShuffleSplit(
            n_splits=1,
            test_size=test_ratio,
            random_state=seed + attempt,
        )
        remainder_idx, test_idx = next(outer.split(indices, labels, groups))
        inner = GroupShuffleSplit(
            n_splits=1,
            test_size=validation_within_remainder,
            random_state=seed + 100_000 + attempt,
        )
        train_local, validation_local = next(
            inner.split(
                remainder_idx,
                labels[remainder_idx],
                groups[remainder_idx],
            )
        )
        candidate = {
            "train": frame.iloc[remainder_idx[train_local]].copy(),
            "validation": frame.iloc[remainder_idx[validation_local]].copy(),
            "test": frame.iloc[test_idx].copy(),
        }
        if any(part["label"].nunique() != 2 for part in candidate.values()):
            continue
        score = _candidate_score(
            candidate,
            ratios,
            len(frame),
            float(frame["label"].mean()),
        )
        if score < best_score:
            best = candidate
            best_score = score

    if best is None:
        raise ValueError("Could not create grouped splits containing both labels")
    return best


def _write_session_ids(path: Path, frame: pd.DataFrame) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf8", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=["session_id"])
        writer.writeheader()
        for session_id in sorted(frame["session_id"].astype(str)):
            writer.writerow({"session_id": session_id})


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Split all TaskTracker sessions 70/15/15 without participant leakage"
    )
    parser.add_argument("--index", default=str(INDEX_PATH))
    parser.add_argument("--output-dir", default=str(SPLIT_DIR))
    parser.add_argument("--train", type=float, default=0.70)
    parser.add_argument("--validation", type=float, default=0.15)
    parser.add_argument("--test", type=float, default=0.15)
    parser.add_argument("--seed", type=int, default=42)
    parser.add_argument("--search-iterations", type=int, default=1000)
    args = parser.parse_args()

    index_path = Path(args.index)
    if not index_path.is_file():
        raise SystemExit(f"[ERROR] Missing {index_path}; run build_sequences first.")
    frame = pd.read_csv(index_path)
    required = {"session_id", "label", "group_id"}
    missing = required - set(frame.columns)
    if missing:
        raise SystemExit(f"[ERROR] Index is missing columns: {sorted(missing)}")
    frame = frame[frame["label"].isin([0, 1])].reset_index(drop=True)

    try:
        splits = make_grouped_splits(
            frame,
            args.train,
            args.validation,
            args.test,
            args.seed,
            args.search_iterations,
        )
    except ValueError as exc:
        raise SystemExit(f"[ERROR] {exc}") from exc

    output_dir = Path(args.output_dir)
    for name, part in splits.items():
        _write_session_ids(output_dir / f"{name}.csv", part)

    group_sets = {
        name: set(part["group_id"].astype(str)) for name, part in splits.items()
    }
    overlap = (
        (group_sets["train"] & group_sets["validation"])
        | (group_sets["train"] & group_sets["test"])
        | (group_sets["validation"] & group_sets["test"])
    )
    if overlap:
        raise SystemExit("[ERROR] Participant leakage detected after splitting.")

    manifest = {
        "dataset": "tasktracker",
        "label_type": "weak_behavioral_risk",
        "seed": args.seed,
        "strategy": "group_shuffle_search",
        "group_definition": "participant-specific suffix in normalized session_id",
        "ratios_requested": {
            "train": args.train,
            "validation": args.validation,
            "test": args.test,
        },
        "counts": {name: _counts(part) for name, part in splits.items()},
        "participant_overlap_count": 0,
        "total_sessions": int(sum(len(part) for part in splits.values())),
    }
    output_dir.mkdir(parents=True, exist_ok=True)
    with (output_dir / "manifest.json").open("w", encoding="utf8") as handle:
        json.dump(manifest, handle, indent=2, ensure_ascii=False)

    print(f"Shared TaskTracker splits -> {output_dir}")
    for name in ("train", "validation", "test"):
        count = manifest["counts"][name]
        print(
            f"  {name:10}: {count['sessions']} sessions, {count['groups']} groups "
            f"(risk=1: {count['risk_1']}, normal=0: {count['normal_0']})"
        )
    print("  Participant overlap: 0")


if __name__ == "__main__":
    main()
