"""One-time deterministic initialization of the fixed TaskTracker split CSVs.

This script is not called by training or by the Kaggle notebook. It creates the
research split once; normal pipeline runs only validate and consume the files.
"""

from __future__ import annotations

import argparse
import csv
import hashlib
import json
import random
from collections import defaultdict
from pathlib import Path


INDEX_PATH = Path("data") / "mamba" / "index.csv"
OUTPUT_DIR = Path("data") / "splits" / "tasktracker"
TARGETS = {
    "test": {"sessions": 69, "risk_1": 15, "normal_0": 54},
    "validation": {"sessions": 70, "risk_1": 15, "normal_0": 55},
    "train": {"sessions": 331, "risk_1": 73, "normal_0": 258},
}


def _choose_exact(
    groups: list[tuple[str, int, int]],
    target_sessions: int,
    target_risk: int,
    seed: int,
) -> tuple[str, ...] | None:
    ordered = list(groups)
    random.Random(seed).shuffle(ordered)
    states: dict[tuple[int, int], tuple[str, ...]] = {(0, 0): ()}
    for group_id, n_sessions, n_risk in ordered:
        for (sessions, risk), selected in list(states.items())[::-1]:
            key = (sessions + n_sessions, risk + n_risk)
            if (
                key[0] <= target_sessions
                and key[1] <= target_risk
                and key not in states
            ):
                states[key] = selected + (group_id,)
    return states.get((target_sessions, target_risk))


def _sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def _write_split(path: Path, session_ids: list[str]) -> None:
    with path.open("w", encoding="utf8", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=["session_id"])
        writer.writeheader()
        for session_id in sorted(session_ids):
            writer.writerow({"session_id": session_id})


def main() -> None:
    parser = argparse.ArgumentParser(description="Initialize fixed TaskTracker group splits")
    parser.add_argument("--index", default=str(INDEX_PATH))
    parser.add_argument("--output-dir", default=str(OUTPUT_DIR))
    parser.add_argument("--seed", type=int, default=42)
    args = parser.parse_args()

    with Path(args.index).open(encoding="utf8", newline="") as handle:
        rows = list(csv.DictReader(handle))
    if len(rows) != 470:
        raise SystemExit(f"[ERROR] Expected 470 indexed sessions, found {len(rows)}")

    grouped: dict[str, list[dict[str, str]]] = defaultdict(list)
    for row in rows:
        grouped[row["group_id"]].append(row)
    group_stats = [
        (group_id, len(members), sum(int(row["label"]) for row in members))
        for group_id, members in grouped.items()
    ]

    selected_test = selected_validation = None
    for attempt in range(1000):
        selected_test = _choose_exact(
            group_stats,
            TARGETS["test"]["sessions"],
            TARGETS["test"]["risk_1"],
            args.seed + attempt * 2,
        )
        if selected_test is None:
            continue
        test_groups = set(selected_test)
        remaining = [group for group in group_stats if group[0] not in test_groups]
        selected_validation = _choose_exact(
            remaining,
            TARGETS["validation"]["sessions"],
            TARGETS["validation"]["risk_1"],
            args.seed + attempt * 2 + 1,
        )
        if selected_validation is not None:
            break
    if selected_test is None or selected_validation is None:
        raise SystemExit("[ERROR] Could not satisfy the exact grouped split targets")

    test_groups = set(selected_test)
    validation_groups = set(selected_validation)
    split_rows = {
        "test": [row for row in rows if row["group_id"] in test_groups],
        "validation": [row for row in rows if row["group_id"] in validation_groups],
        "train": [
            row
            for row in rows
            if row["group_id"] not in test_groups | validation_groups
        ],
    }

    output_dir = Path(args.output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)
    counts = {}
    for name, members in split_rows.items():
        labels = [int(row["label"]) for row in members]
        counts[name] = {
            "sessions": len(members),
            "risk_1": labels.count(1),
            "normal_0": labels.count(0),
            "groups": len({row["group_id"] for row in members}),
        }
        expected = TARGETS[name]
        actual = {key: counts[name][key] for key in expected}
        if actual != expected:
            raise SystemExit(f"[ERROR] {name} mismatch: expected {expected}, got {actual}")
        _write_split(output_dir / f"{name}.csv", [row["session_id"] for row in members])

    manifest = {
        "dataset": "tasktracker",
        "label_type": "weak_behavioral_risk",
        "random_state": args.seed,
        "strategy": "exact grouped subset dynamic programming",
        "group_key": "participant-specific group_id from data/mamba/index.csv",
        "counts": counts,
        "participant_overlap_count": 0,
        "total_sessions": sum(value["sessions"] for value in counts.values()),
        "split_sha256": {
            name: _sha256(output_dir / f"{name}.csv")
            for name in ("train", "validation", "test")
        },
    }
    with (output_dir / "manifest.json").open("w", encoding="utf8") as handle:
        json.dump(manifest, handle, indent=2, ensure_ascii=False)

    print(f"Fixed TaskTracker splits initialized -> {output_dir}")
    print(json.dumps(counts, indent=2))
    print("Participant overlap: 0")


if __name__ == "__main__":
    main()
