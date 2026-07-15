"""Streamlit dashboard for the TaskTracker -> Mamba -> PasteTrace pipeline."""

from __future__ import annotations

import json
import os
import subprocess
import sys
from pathlib import Path

import pandas as pd
import streamlit as st


PROJECT_ROOT = Path(__file__).resolve().parents[2]
MAMBA_DATA_DIR = PROJECT_ROOT / "data" / "mamba"
TRAIN_INDEX = MAMBA_DATA_DIR / "train_index.csv"
TEST_INDEX = MAMBA_DATA_DIR / "test_index.csv"
SPLITS_PATH = MAMBA_DATA_DIR / "splits.json"
MODEL_DIR = PROJECT_ROOT / "models" / "mamba"
RESULTS_PATH = PROJECT_ROOT / "results" / "mamba_metrics.json"
TASKTRACKER_DIR = PROJECT_ROOT / "tasktracker"
PASTETRACE_DIR = PROJECT_ROOT / "pastetrace"


st.set_page_config(page_title="Mamba Fraud Detection", page_icon="🧬", layout="wide")
st.title("🧬 Mamba Behavioral Sequence Classifier")
st.caption("Train/validation: TaskTracker | External test: PasteTrace")


def run_command(arguments: list[str]) -> tuple[str, int]:
    environment = os.environ.copy()
    environment["PYTHONPATH"] = str(PROJECT_ROOT)
    result = subprocess.run(
        [sys.executable, *arguments],
        cwd=PROJECT_ROOT,
        env=environment,
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
    )
    return (result.stdout + result.stderr).strip(), result.returncode


def load_json(path: Path) -> dict:
    try:
        with path.open(encoding="utf8") as handle:
            return json.load(handle)
    except (OSError, json.JSONDecodeError):
        return {}


with st.sidebar:
    st.header("Pipeline status")
    status = {
        "TaskTracker sequences": TRAIN_INDEX.is_file(),
        "PasteTrace sequences": TEST_INDEX.is_file(),
        "Train/val split": SPLITS_PATH.is_file(),
        "Mamba model": (MODEL_DIR / "mamba.pt").is_file(),
        "External test result": RESULTS_PATH.is_file(),
    }
    for label, available in status.items():
        st.write(f"{'✅' if available else '⬜'} {label}")
    try:
        import torch

        st.write(f"{'✅' if torch.cuda.is_available() else '⚠️'} CUDA GPU")
    except ImportError:
        st.write("⚠️ PyTorch unavailable")


data_tab, train_tab, test_tab, predict_tab = st.tabs(
    ["1. Prepare data", "2. Train", "3. Test PasteTrace", "4. Predict one"]
)


with data_tab:
    st.subheader("Build normalized event sequences")
    st.info(
        "Data roles are fixed: tasktracker is used for train/validation; "
        "pastetrace is used only as the external test set."
    )
    col_train, col_test = st.columns(2)
    train_dir = col_train.text_input("TaskTracker folder", str(TASKTRACKER_DIR))
    test_dir = col_test.text_input("PasteTrace folder", str(PASTETRACE_DIR))
    min_events = st.number_input("Minimum events", min_value=1, value=1, step=1)

    if st.button("Build both datasets", type="primary"):
        output, return_code = run_command(
            [
                "-m",
                "src.data.build_sequences",
                "--train-dir",
                train_dir,
                "--test-dir",
                test_dir,
                "--min-events",
                str(int(min_events)),
            ]
        )
        st.code(output, language="text")
        if return_code == 0:
            st.success("Sequences built successfully.")
        else:
            st.error("Sequence build failed.")

    if TRAIN_INDEX.is_file() and TEST_INDEX.is_file():
        train_frame = pd.read_csv(TRAIN_INDEX)
        test_frame = pd.read_csv(TEST_INDEX)
        col1, col2 = st.columns(2)
        with col1:
            st.markdown("#### TaskTracker (train/validation)")
            st.metric("Sessions", len(train_frame))
            st.write(train_frame.groupby("label").size().rename("count"))
        with col2:
            st.markdown("#### PasteTrace (external test)")
            st.metric("Sessions", len(test_frame))
            st.write(test_frame.groupby("label").size().rename("count"))

        st.divider()
        st.subheader("Create TaskTracker train/validation split")
        validation_ratio = st.slider("Validation ratio", 0.05, 0.40, 0.15, 0.05)
        seed = st.number_input("Random seed", value=42, step=1)
        if st.button("Create split"):
            output, return_code = run_command(
                [
                    "-m",
                    "src.data.make_splits",
                    "--val",
                    str(validation_ratio),
                    "--seed",
                    str(int(seed)),
                ]
            )
            st.code(output, language="text")
            if return_code == 0:
                st.success("Split created. PasteTrace remains untouched.")
            else:
                st.error("Split failed.")

    if SPLITS_PATH.is_file():
        splits = load_json(SPLITS_PATH)
        st.json({"sources": splits.get("sources"), "counts": splits.get("counts")})


with train_tab:
    st.subheader("Train Mamba on TaskTracker")
    st.warning("Mamba training is intended for an NVIDIA CUDA environment.")
    col1, col2, col3 = st.columns(3)
    d_model = col1.selectbox("d_model", [32, 64, 128], index=1)
    n_layers = col2.selectbox("layers", [1, 2, 3, 4], index=1)
    dropout = col3.slider("dropout", 0.0, 0.5, 0.2, 0.05)
    col4, col5, col6 = st.columns(3)
    epochs = col4.number_input("epochs", 1, 500, 80)
    batch_size = col5.selectbox("batch size", [4, 8, 16, 32], index=1)
    patience = col6.number_input("early-stop patience", 1, 50, 10)
    train_all = st.checkbox(
        "Train all TaskTracker sessions (no validation/early stopping)", value=False
    )

    if not SPLITS_PATH.is_file():
        st.info("Prepare data and create the split first.")
    elif st.button("Train Mamba", type="primary"):
        train_command = [
                "-m",
                "src.models.mamba_model",
                "train",
                "--d-model",
                str(d_model),
                "--n-layers",
                str(n_layers),
                "--dropout",
                str(dropout),
                "--epochs",
                str(int(epochs)),
                "--batch-size",
                str(batch_size),
                "--patience",
                str(int(patience)),
            ]
        if train_all:
            train_command.append("--train-all")
        output, return_code = run_command(train_command)
        st.code(output, language="text")
        if return_code == 0:
            st.success("Best validation checkpoint saved.")
        else:
            st.error("Training failed.")

    config = load_json(MODEL_DIR / "config.json")
    if config:
        st.json(config)


with test_tab:
    st.subheader("Evaluate the frozen model on PasteTrace")
    st.caption(
        "This command never fits the scaler, updates weights, or changes "
        "hyperparameters using PasteTrace."
    )
    if not (MODEL_DIR / "mamba.pt").is_file():
        st.info("Train the model first.")
    elif st.button("Run external test", type="primary"):
        output, return_code = run_command(
            ["-m", "src.models.mamba_model", "test"]
        )
        st.code(output, language="text")
        if return_code == 0:
            st.success("PasteTrace evaluation completed.")
        else:
            st.error("Evaluation failed.")

    results = load_json(RESULTS_PATH)
    if results:
        metrics = results.get("mamba", {})
        c1, c2, c3, c4 = st.columns(4)
        c1.metric("Accuracy", f"{metrics.get('accuracy', 0):.3f}")
        c2.metric("Macro F1", f"{metrics.get('macro_f1', 0):.3f}")
        c3.metric("Cheat F1", f"{metrics.get('cheat_f1', 0):.3f}")
        c4.metric("Normal F1", f"{metrics.get('normal_f1', 0):.3f}")
        st.dataframe(pd.DataFrame(results.get("predictions", [])))


with predict_tab:
    st.subheader("Predict one normalized session JSON")
    default_json = PASTETRACE_DIR / "normalized" / "111_A.json"
    input_path = st.text_input("Normalized JSON", str(default_json))
    if st.button("Predict"):
        output, return_code = run_command(
            ["-m", "src.models.mamba_model", "predict", input_path]
        )
        st.code(output, language="text")
        if return_code != 0:
            st.error("Prediction failed.")
