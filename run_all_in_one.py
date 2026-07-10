"""Run everything end-to-end: build sequences → train → predict on tests/.

Usage:
    python run_all_in_one.py                       # default config
    python run_all_in_one.py --no-pos-weight      # no class weighting
    python run_all_in_one.py --dry-run            # just show what would happen

Requires GPU (Mamba). On Kaggle/Colab this runs out of the box.
On Windows local with CPU: WARNING printed but script continues.
"""
import argparse
import json
import os
import shutil
import subprocess
import sys
import time


def run(cmd: list[str], desc: str, env=None, check=True):
    print(f"\n{'='*70}")
    print(f">>> {desc}")
    print(f"    {' '.join(str(c) for c in cmd)}")
    print("=" * 70)
    t0 = time.time()
    result = subprocess.run(cmd, env=env)
    elapsed = time.time() - t0
    print(f"[{elapsed:.1f}s] {desc} → exit={result.returncode}")
    if check and result.returncode != 0:
        sys.exit(f"[ERROR] {desc} failed with code {result.returncode}")
    return result


def main():
    parser = argparse.ArgumentParser(description="End-to-end: build → train → predict")
    parser.add_argument("--dry-run", action="store_true", help="Print commands without running")
    parser.add_argument("--no-pos-weight", action="store_true")
    parser.add_argument("--label-smoothing", type=float, default=0.05)
    parser.add_argument("--weight-decay", type=float, default=0.05)
    parser.add_argument("--dropout", type=float, default=0.2)
    parser.add_argument("--epochs", type=int, default=80)
    parser.add_argument("--patience", type=int, default=10)
    parser.add_argument("--val-frac", type=float, default=0.15)
    parser.add_argument("--max-len", type=int, default=1000)
    args = parser.parse_args()

    is_kaggle = os.path.exists("/kaggle")
    python = "python" if not is_kaggle else "python"

    def cmd_with_defaults(base_cmd):
        c = [python, *base_cmd]
        if args.dry_run:
            c = ["echo"] + c[1:]
        return c

    # ── 1. Clean old artifacts ──────────────────────────────────────────────
    model_dir = os.path.join("models", "mamba")
    if not args.dry_run and os.path.isdir(model_dir):
        print(f"\n[Cleaning] Removing old model dir: {model_dir}")
        shutil.rmtree(model_dir)

    # ── 2. Build sequences from train cohort ─────────────────────────────────
    run(
        cmd_with_defaults([
            "-m", "src.data.build_sequences",
            "--data-dir", "test_new_cohort",
            "--output-dir", "data/train_sequences",
            "--min-events", "3",
        ]),
        "Step 1: Extract sequences from test_new_cohort",
    )

    # ── 3. Train Mamba model ─────────────────────────────────────────────────
    train_cmd = [
        "-m", "src.models.mamba_model", "train",
        "--train-data-dir", "test_new_cohort",
        "--epochs", str(args.epochs),
        "--patience", str(args.patience),
        "--val-frac", str(args.val_frac),
        "--label-smoothing", str(args.label_smoothing),
        "--weight-decay", str(args.weight_decay),
        "--dropout", str(args.dropout),
        "--max-len", str(args.max_len),
    ]
    if args.no_pos_weight:
        train_cmd.append("--no-pos-weight")
    run(cmd_with_defaults(train_cmd), "Step 2: Train Mamba model")

    # ── 4. Predict on tests/ ─────────────────────────────────────────────────
    run(
        cmd_with_defaults(["predict_tests.py", "tests"]),
        "Step 3: Predict on tests/",
    )

    print(f"\n{'='*70}")
    print("DONE. Model saved in models/mamba/ — run predict_tests.py again anytime.")
    print("=" * 70)


if __name__ == "__main__":
    main()
