"""Predict fraud labels for a folder of student sessions.

Supports two event schemas:
  - tests/ schema  : {"events": [{"type","text","t","paste_source"}, ...], "label": 0/1}
  - test_new_cohort schema: {"History": [{"L","E","t/T","N"}, ...]} + agrigation.csv

Schema is auto-detected per meta.json by checking for the "events" key.
"""
import argparse
import json
import math
import os
import sys

import torch

from src.models.mamba_model import MambaClassifier, MODEL_DIR
from src.models.mamba_dataset import SequenceScaler


# ── Schema adapters ────────────────────────────────────────────────────────────

def _paste_source_tests(note: str | None):
    """Parse paste_source string from tests/ schema into one-hot."""
    n = (note or "").lower()
    if "external" in n or "noncoded" in n:
        return 1.0, 0.0, 0.0
    if any(kw in n for kw in ("same", "internal", "project")):
        return 0.0, 1.0, 0.0
    return 0.0, 0.0, 1.0  # unknown / other


def extract_sequence_tests(meta_path: str) -> tuple[list[list[float]], bool]:
    """Extract [n_events x 8] feature matrix from tests/ schema meta.json.

    Returns (seq, time_available).  time_available is True when delta-time > 0
    between at least one pair of consecutive events.
    """
    with open(meta_path, encoding="utf8", errors="ignore") as f:
        data = json.load(f)

    events = data.get("events", [])
    ground_truth = data.get("label", None)  # may be absent

    seq = []
    prev_ms = None
    time_available = False

    for ev in events:
        ev_type = (ev.get("type") or "").lower()

        is_type = 1.0 if ev_type == "type" else 0.0
        is_paste = 1.0 if ev_type == "paste" else 0.0
        is_cut = 1.0 if ev_type in ("cut", "delete") else 0.0

        text = ev.get("text") or ""
        log_len = math.log1p(len(text))

        if ev_type == "paste":
            src_e, src_s, src_o = _paste_source_tests(ev.get("paste_source"))
        else:
            src_e, src_s, src_o = 0.0, 0.0, 0.0

        # t is in seconds (float) in tests/ schema
        t_raw = ev.get("t")
        if t_raw is not None:
            try:
                ts_ms = int(float(t_raw) * 1000)
                if prev_ms is not None:
                    delta = max(0.0, float(ts_ms - prev_ms))
                    if delta > 0:
                        time_available = True
                else:
                    delta = 0.0
                prev_ms = ts_ms
            except (TypeError, ValueError):
                delta = 0.0
        else:
            delta = 0.0

        seq.append([is_type, is_paste, is_cut, log_len, src_e, src_s, src_o, delta])

    return seq, time_available


# ── Main predictor ─────────────────────────────────────────────────────────────

def predict_folder(tests_dir: str, threshold: float = 0.0):
    model_pt = os.path.join(MODEL_DIR, "mamba.pt")
    cfg_path = os.path.join(MODEL_DIR, "config.json")
    scaler_path = os.path.join(MODEL_DIR, "scaler.json")

    for p in [model_pt, cfg_path, scaler_path]:
        if not os.path.isfile(p):
            print(f"[ERROR] Missing {p}. Run training first: python -m src.models.mamba_model train")
            return

    with open(cfg_path, encoding="utf8") as f:
        cfg = json.load(f)

    scaler = SequenceScaler.load(scaler_path)
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

    model = MambaClassifier(
        cfg["n_features"], cfg["d_model"], cfg["n_layers"], cfg["dropout"]
    )
    model.load_state_dict(torch.load(model_pt, map_location=device, weights_only=True))
    model.to(device).eval()

    results = []
    skipped = []

    student_files = []
    for root, _dirs, files in os.walk(tests_dir):
        for f in files:
            if f == "meta.json":
                student_files.append((root, f, "meta"))
            elif f.endswith(".json") and f not in ("smoke_train.py",):
                student_files.append((root, f, "session"))

    seen_sessions = set()
    for root, f, kind in student_files:
        path = os.path.join(root, f)
        rel = os.path.relpath(root, tests_dir).replace(os.sep, "/")

        # Auto-detect schema
        try:
            with open(path, encoding="utf8", errors="ignore") as fh:
                sample = json.load(fh)
        except Exception:
            skipped.append(f"{rel}/{f}: failed to read json")
            continue

        if not isinstance(sample, dict) or "events" not in sample:
            skipped.append(f"{rel}/{f}: not a session (no 'events')")
            continue

        schema = "tests" if isinstance(sample.get("events"), list) else "cohort"
        if schema != "tests":
            skipped.append(f"{rel}/{f}: cohort schema not supported in predict mode")
            continue

        # de-dupe by session_id (prefer meta.json when both exist)
        sid = sample.get("session_id") or f"{rel}/{f}"
        if sid in seen_sessions:
            continue
        seen_sessions.add(sid)

        seq, time_ok = extract_sequence_tests(path)

        if not seq:
            skipped.append(f"{rel}/{f}: no events extracted")
            continue

        seq_trimmed = seq[: cfg["max_len"]]
        seq_scaled = scaler.transform(seq_trimmed)
        seq_t = torch.tensor(seq_scaled, dtype=torch.float32).unsqueeze(0).to(device)
        mask = torch.ones(1, seq_t.shape[1], dtype=torch.bool).to(device)

        with torch.no_grad():
            logit = model(seq_t, mask)
            logit_val = float(logit.item())
            prob = torch.sigmoid(logit).item()

        pred = 1 if prob >= threshold else 0
        label_name = "Cheat" if pred == 1 else "Normal"
        ground_truth = sample.get("label")

        display = sid.replace(os.sep, "/")
        results.append({
            "path": display,
            "pred": pred,
            "pred_label": label_name,
            "prob": prob,
            "logit": logit_val,
            "ground_truth": ground_truth,
            "n_events": len(seq),
            "time_ok": time_ok,
        })

    if skipped:
        print(f"[SKIPPED] {len(skipped)} file(s):")
        for s in skipped:
            print(f"  - {s}")
        print()

    results.sort(key=lambda x: x["path"])

    # ── Distribution summary (Kaggle-cell compatible format) ─────────────────
    n_total = len(results)
    n_cheat = sum(1 for r in results if r["pred"] == 1)
    n_normal = n_total - n_cheat
    has_gt = any(r["ground_truth"] is not None for r in results)

    print("=" * 70)
    print("PREDICTION DISTRIBUTION")
    print("=" * 70)
    print(f"CHEAT:  {n_cheat}")
    print(f"NORMAL: {n_normal}")
    print(f"Total:  {n_total}")

    if has_gt:
        correct = sum(1 for r in results if r["pred"] == r["ground_truth"])
        print(f"Accuracy: {correct}/{n_total} = {correct/n_total:.1%}")

    print("\nPREDICTIONS:")
    for r in results:
        label = "CHEAT" if r["pred"] == 1 else "NORMAL"
        path = r["path"]
        suffix = ""
        if r["ground_truth"] is not None:
            gt_name = "CHEAT" if r["ground_truth"] == 1 else "NORMAL"
            match = "OK" if r["pred"] == r["ground_truth"] else "MISS"
            suffix = f"   [gt={gt_name} {match}  prob={r['prob']:.3f} logit={r['logit']:+.2f}]"
        else:
            suffix = f"   [prob={r['prob']:.3f} logit={r['logit']:+.2f}]"
        print(f"  {label:6} -> {path}{suffix}")
    print()

    return results


# ── CLI entry point ────────────────────────────────────────────────────────────

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Predict fraud labels for tests/ folder")
    parser.add_argument("dir", nargs="?", default="tests", help="Folder to scan (default: tests)")
    parser.add_argument("--threshold", type=float, default=0.5)
    args = parser.parse_args()

    if not os.path.isdir(args.dir):
        print(f"[ERROR] Directory not found: {args.dir}")
        sys.exit(1)

    predict_folder(args.dir, threshold=args.threshold)
