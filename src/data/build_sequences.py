"""Build Mamba event sequences from the normalized datasets.

The data roles are intentionally fixed by default:

* ``tasktracker/`` is the training/validation dataset.
* ``pastetrace/`` is the external test dataset.

Both folders must contain ``normalized/labels.csv`` and one JSON file per
session.  No data from the external test set is used while fitting the scaler
or the model.
"""

from __future__ import annotations

import argparse
import csv
import json
import math
import os
from pathlib import Path


TRAIN_DATA_ROOT = "tasktracker"
TEST_DATA_ROOT = "pastetrace"
MAMBA_DATA_DIR = Path("data") / "mamba"
TRAIN_OUTPUT_DIR = MAMBA_DATA_DIR / "train_sequences"
TEST_OUTPUT_DIR = MAMBA_DATA_DIR / "test_sequences"
TRAIN_INDEX_PATH = MAMBA_DATA_DIR / "train_index.csv"
TEST_INDEX_PATH = MAMBA_DATA_DIR / "test_index.csv"

FEATURE_NAMES = [
    "is_type",
    "is_paste",
    "is_cut",
    "log_len",
    "src_external",
    "src_own",
    "src_same_machine",
    "src_unknown",
    "delta_time",
]


def _normalized_dir(data_root: str | os.PathLike[str]) -> Path:
    """Return the directory that directly contains labels.csv and JSON files."""
    root = Path(data_root)
    nested = root / "normalized"
    if (nested / "labels.csv").is_file():
        return nested
    if (root / "labels.csv").is_file():
        return root
    raise FileNotFoundError(
        f"Khong tim thay labels.csv trong '{root}' hoac '{nested}'."
    )


def _load_labels(normalized_dir: Path, subset: str = "all") -> dict[str, int]:
    labels: dict[str, int] = {}
    with (normalized_dir / "labels.csv").open(
        encoding="utf8", errors="ignore", newline=""
    ) as handle:
        for row in csv.DictReader(handle):
            session_id = (row.get("session_id") or "").strip()
            raw_label = (row.get("label") or "").strip()
            if not session_id or raw_label not in {"0", "1"}:
                continue
            if subset == "original16" and (
                row.get("in_original_16") or ""
            ).strip().lower() != "yes":
                continue
            labels[session_id] = int(raw_label)
    return labels


def _load_sessions(normalized_dir: Path) -> dict[str, tuple[Path, dict]]:
    sessions: dict[str, tuple[Path, dict]] = {}
    for path in sorted(normalized_dir.glob("*.json")):
        try:
            with path.open(encoding="utf8", errors="ignore") as handle:
                record = json.load(handle)
        except (OSError, json.JSONDecodeError):
            continue
        session_id = str(record.get("session_id") or "").strip()
        if session_id:
            sessions[session_id] = (path, record)
    return sessions


def extract_normalized_sequence(record: dict) -> tuple[list[list[float]], bool]:
    """Convert one normalized session record into the nine Mamba features."""
    sequence: list[list[float]] = []
    previous_time: float | None = None
    time_available = False

    events = record.get("events")
    if not isinstance(events, list):
        return sequence, time_available

    for event in events:
        if not isinstance(event, dict):
            continue
        event_type = str(event.get("type") or "").strip().lower()
        if event_type not in {"type", "paste", "cut"}:
            continue

        text = event.get("text")
        if not isinstance(text, str):
            text = "" if text is None else str(text)

        source = str(event.get("paste_source") or "").strip().lower()
        src_external = float(event_type == "paste" and source == "external")
        src_own = float(event_type == "paste" and source == "own")
        src_same_machine = float(
            event_type == "paste" and source == "same_machine"
        )
        src_unknown = float(
            event_type == "paste"
            and source not in {"external", "own", "same_machine"}
        )

        try:
            current_time = float(event.get("t"))
            if not math.isfinite(current_time):
                current_time = None
        except (TypeError, ValueError):
            current_time = None

        delta_time = 0.0
        if current_time is not None and previous_time is not None:
            delta_time = max(0.0, current_time - previous_time)
            time_available = True
        if current_time is not None:
            previous_time = current_time

        sequence.append(
            [
                float(event_type == "type"),
                float(event_type == "paste"),
                float(event_type == "cut"),
                math.log1p(len(text)),
                src_external,
                src_own,
                src_same_machine,
                src_unknown,
                delta_time,
            ]
        )

    return sequence, time_available


def _safe_id(dataset_name: str, source_path: Path) -> str:
    return f"{dataset_name}_{source_path.stem}"


def build_dataset_sequences(
    data_root: str | os.PathLike[str],
    output_dir: str | os.PathLike[str],
    index_path: str | os.PathLike[str],
    dataset_name: str,
    min_events: int = 1,
    subset: str = "all",
) -> list[dict]:
    """Build one dataset and return its index rows."""
    normalized_dir = _normalized_dir(data_root)
    labels = _load_labels(normalized_dir, subset=subset)
    sessions = _load_sessions(normalized_dir)
    out_dir = Path(output_dir)
    out_dir.mkdir(parents=True, exist_ok=True)

    rows: list[dict] = []
    skipped: list[str] = []
    current_files: set[str] = set()

    for session_id, label in sorted(labels.items()):
        loaded = sessions.get(session_id)
        if loaded is None:
            skipped.append(f"{session_id}: khong tim thay JSON")
            continue
        source_path, record = loaded
        sequence, time_available = extract_normalized_sequence(record)
        if len(sequence) < min_events:
            skipped.append(
                f"{session_id}: chi co {len(sequence)} event (< {min_events})"
            )
            continue

        sample_id = _safe_id(dataset_name, source_path)
        output_path = out_dir / f"{sample_id}.json"
        output_record = {
            "id": sample_id,
            "session_id": session_id,
            "dataset": dataset_name,
            "source": record.get("source", dataset_name),
            "label": label,
            "n_events": len(sequence),
            "time_available": time_available,
            "feature_names": FEATURE_NAMES,
            "seq": sequence,
        }
        with output_path.open("w", encoding="utf8") as handle:
            json.dump(output_record, handle, ensure_ascii=False)
        current_files.add(output_path.name)
        rows.append(
            {
                "id": sample_id,
                "session_id": session_id,
                "dataset": dataset_name,
                "label": label,
                "n_events": len(sequence),
                "time_available": time_available,
                "path": output_path.as_posix(),
            }
        )

    # Dedicated generated directories are safe to clean after a successful build.
    for old_path in out_dir.glob("*.json"):
        if old_path.name not in current_files:
            old_path.unlink()

    index = Path(index_path)
    index.parent.mkdir(parents=True, exist_ok=True)
    with index.open("w", encoding="utf8", newline="") as handle:
        writer = csv.DictWriter(
            handle,
            fieldnames=[
                "id",
                "session_id",
                "dataset",
                "label",
                "n_events",
                "time_available",
                "path",
            ],
        )
        writer.writeheader()
        writer.writerows(rows)

    n_cheat = sum(row["label"] == 1 for row in rows)
    n_normal = sum(row["label"] == 0 for row in rows)
    lengths = sorted(row["n_events"] for row in rows)
    print(f"\n[{dataset_name}] {len(rows)} sequences -> {out_dir}")
    print(f"  Labels: cheat={n_cheat}, normal={n_normal}")
    if lengths:
        print(
            f"  Events: min={lengths[0]}, median={lengths[len(lengths) // 2]}, "
            f"max={lengths[-1]}"
        )
    if skipped:
        print(f"  Skipped: {len(skipped)}")
        for reason in skipped[:20]:
            print(f"    - {reason}")
        if len(skipped) > 20:
            print(f"    ... va {len(skipped) - 20} session khac")
    return rows


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Build TaskTracker train sequences and PasteTrace test sequences"
    )
    parser.add_argument("--train-dir", default=TRAIN_DATA_ROOT)
    parser.add_argument("--test-dir", default=TEST_DATA_ROOT)
    parser.add_argument("--output-root", default=str(MAMBA_DATA_DIR))
    parser.add_argument("--min-events", type=int, default=1)
    parser.add_argument(
        "--test-subset", choices=("all", "original16"), default="all"
    )
    args = parser.parse_args()

    output_root = Path(args.output_root)
    train_rows = build_dataset_sequences(
        args.train_dir,
        output_root / "train_sequences",
        output_root / "train_index.csv",
        dataset_name="tasktracker",
        min_events=args.min_events,
    )
    test_rows = build_dataset_sequences(
        args.test_dir,
        output_root / "test_sequences",
        output_root / "test_index.csv",
        dataset_name="pastetrace",
        min_events=args.min_events,
        subset=args.test_subset,
    )

    if not train_rows:
        raise SystemExit("[ERROR] TaskTracker khong co sequence hop le de train.")
    if not test_rows:
        raise SystemExit("[ERROR] PasteTrace khong co sequence hop le de test.")
    print("\nDa chuan bi xong: TaskTracker=train, PasteTrace=external test.")


if __name__ == "__main__":
    main()
