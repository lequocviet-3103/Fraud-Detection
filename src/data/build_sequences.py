"""Extract behavioral event sequences from meta.json files.

Each student -> [n_events x 8] feature matrix saved as JSON.
Features per event: is_type, is_paste, is_cut, log_len, src_external, src_same, src_other, delta_time
Skips L="O" (scaffold code) and any other non-{T,P,C} events.
"""
import argparse
import base64
import csv
import json
import math
import os
import struct

CASE_STUDY_ROOT = "test_new_cohort"
OUTPUT_DIR = os.path.join("data", "train_sequences")
INDEX_PATH = os.path.join("data", "sequences_index.csv")
FEATURE_NAMES = ["is_type", "is_paste", "is_cut", "log_len", "src_external", "src_same", "src_other", "delta_time"]


def _decode_time(t_val):
    """Decode PasteTrace base64-encoded long timestamp -> ms (int). Returns None on failure."""
    if not t_val:
        return None
    try:
        raw = base64.b64decode(t_val + "==")
        if len(raw) >= 8:
            return struct.unpack(">q", raw[:8])[0]
    except Exception:
        pass
    try:
        return int(t_val)
    except Exception:
        return None


def _paste_source(note: str):
    """Return (src_external, src_same, src_other) one-hot from paste note N."""
    n = (note or "").lower()
    if "noncoded source" in n:
        return 1, 0, 0
    if any(kw in n for kw in ("same machine", "same creator", "internal paste", "paste from project")):
        return 0, 1, 0
    if "uuid" in n or "paste" in n:
        return 0, 0, 1
    return 0, 0, 1  # unknown paste origin -> other


def extract_sequence(meta_paths: list[str]) -> tuple[list[list[float]], bool]:
    """Return (seq, time_available) from one or more meta.json paths."""
    all_events = []
    for path in meta_paths:
        try:
            with open(path, encoding="utf8", errors="ignore") as f:
                data = json.load(f)
            all_events.extend(data.get("History", []))
        except Exception:
            pass

    seq = []
    prev_ts = None
    time_available = False

    for ev in all_events:
        L = ev.get("L", "")
        if L not in ("T", "P", "C"):
            continue  # skip L="O" scaffold and others

        is_type = 1.0 if L == "T" else 0.0
        is_paste = 1.0 if L == "P" else 0.0
        is_cut = 1.0 if L == "C" else 0.0

        text = ev.get("E", "")
        log_len = math.log1p(len(text))

        if L == "P":
            src_e, src_s, src_o = _paste_source(ev.get("N", ""))
        else:
            src_e, src_s, src_o = 0.0, 0.0, 0.0

        ts = _decode_time(ev.get("T"))
        if ts is not None and prev_ts is not None:
            delta = max(0.0, float(ts - prev_ts))
            time_available = True
        else:
            delta = 0.0
        if ts is not None:
            prev_ts = ts

        seq.append([is_type, is_paste, is_cut, log_len, float(src_e), float(src_s), float(src_o), delta])

    return seq, time_available


def _find_meta_jsons(student_dir: str) -> list[str]:
    paths = []
    for root, _, files in os.walk(student_dir):
        for name in files:
            if name == "meta.json":
                paths.append(os.path.join(root, name))
    return paths


def _load_labels(case_dir: str) -> dict[str, int]:
    agg_path = os.path.join(case_dir, "agrigation.csv")
    labels = {}
    with open(agg_path, encoding="utf8", errors="ignore") as f:
        for row in csv.DictReader(f):
            student = row.get("Student", "").strip()
            if not student:
                continue
            cheated = (row.get("Cheated") or "").strip()
            if cheated == "X":
                labels[student] = 1
            elif cheated == "":
                labels[student] = 0
            # ? and * -> excluded
    return labels


def main():
    parser = argparse.ArgumentParser(description="Build behavioral event sequences from PasteTrace meta.json")
    parser.add_argument("--data-dir", default=None, help="Path to pre-processed folder")
    parser.add_argument("--output-dir", default=OUTPUT_DIR)
    parser.add_argument("--min-events", type=int, default=3, help="Drop students with fewer events")
    args = parser.parse_args()

    data_root = args.data_dir or CASE_STUDY_ROOT
    out_dir = args.output_dir
    os.makedirs(out_dir, exist_ok=True)

    cases = sorted(
        d for d in os.listdir(data_root)
        if os.path.isdir(os.path.join(data_root, d)) and d not in ("RawData",)
        and os.path.isfile(os.path.join(data_root, d, "agrigation.csv"))
    )
    if not cases:
        print(f"[ERROR] No case folders with agrigation.csv found in: {data_root}")
        return

    index_rows = []
    skipped = []
    lengths = []
    label_counts = {0: 0, 1: 0}
    time_ok_count = 0

    for case in cases:
        case_dir = os.path.join(data_root, case)
        labels = _load_labels(case_dir)

        for student, label in sorted(labels.items()):
            student_dir = os.path.join(case_dir, student)
            if not os.path.isdir(student_dir):
                skipped.append(f"{case}/{student}: directory not found")
                continue

            meta_paths = _find_meta_jsons(student_dir)
            if not meta_paths:
                skipped.append(f"{case}/{student}: no meta.json (excluded)")
                continue

            seq, time_available = extract_sequence(meta_paths)

            if len(seq) < args.min_events:
                skipped.append(f"{case}/{student}: only {len(seq)} events < min_events={args.min_events}")
                continue

            record = {
                "case": case,
                "student": student,
                "label": label,
                "n_events": len(seq),
                "time_available": time_available,
                "feature_names": FEATURE_NAMES,
                "seq": seq,
            }
            out_name = f"{case}_{student}.json"
            out_path = os.path.join(out_dir, out_name)
            with open(out_path, "w", encoding="utf8") as f:
                json.dump(record, f)

            index_rows.append({
                "id": f"{case}_{student}",
                "case": case,
                "student": student,
                "label": label,
                "n_events": len(seq),
                "time_available": time_available,
                "path": out_path,
            })
            lengths.append(len(seq))
            label_counts[label] = label_counts.get(label, 0) + 1
            if time_available:
                time_ok_count += 1

    with open(INDEX_PATH, "w", encoding="utf8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=["id", "case", "student", "label", "n_events", "time_available", "path"])
        writer.writeheader()
        writer.writerows(index_rows)

    total = len(index_rows)
    print(f"\nBuilt {total} sequences -> {out_dir}")
    print(f"  Labels : cheat={label_counts.get(1,0)}, normal={label_counts.get(0,0)}")
    if lengths:
        lengths.sort()
        med = lengths[len(lengths)//2]
        print(f"  Events : min={lengths[0]}, median={med}, max={lengths[-1]}")
    print(f"  Time field available in {time_ok_count}/{total} students")
    print(f"  Features: {FEATURE_NAMES}")

    if skipped:
        print(f"\nSkipped ({len(skipped)}):")
        for s in skipped:
            print(f"  {s}")


if __name__ == "__main__":
    main()
