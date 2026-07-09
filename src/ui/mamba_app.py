"""Streamlit dashboard for Mamba behavioral sequence model.

Tabs:
  1. Data — Build sequences + make splits
  2. Train — Train Mamba model, live log
  3. Evaluate — Test metrics + confusion matrix + per-student report
  4. Predict — Upload folder / meta.json for single-student inference
"""
import json
import os
import subprocess
import sys
import threading
import time

import numpy as np
import pandas as pd
import streamlit as st

PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

SEQ_DIR     = os.path.join(PROJECT_ROOT, "data", "train_sequences")
INDEX_PATH  = os.path.join(PROJECT_ROOT, "data", "sequences_index.csv")
SPLITS_PATH = os.path.join(PROJECT_ROOT, "data", "splits.json")
MODEL_DIR   = os.path.join(PROJECT_ROOT, "models", "mamba")
RESULTS_DIR = os.path.join(PROJECT_ROOT, "results")

CASE_STUDY_ROOT = os.path.join(
    PROJECT_ROOT, "PasteTrace-release", "PasteTrace-release",
    "case studies", "sp2023", "pre-processed"
)

st.set_page_config(
    page_title="PasteTrace — Mamba Model",
    page_icon="🧬",
    layout="wide",
)

# ── CSS ──────────────────────────────────────────────────────────────────────
st.markdown("""
<style>
.metric-card {
    background: var(--background-secondary-color, #f0f2f6);
    border-radius: 10px;
    padding: 16px 20px;
    margin: 6px 0;
}
.card-cheat  { border-left: 5px solid #e53935; }
.card-normal { border-left: 5px solid #43a047; }
.card-info   { border-left: 5px solid #1976d2; }
.log-box {
    background: #111;
    color: #0f0;
    font-family: monospace;
    font-size: 12px;
    padding: 12px;
    border-radius: 8px;
    max-height: 380px;
    overflow-y: auto;
    white-space: pre-wrap;
}
</style>
""", unsafe_allow_html=True)

st.title("🧬 Mamba Behavioral Sequence Classifier")
st.caption("Phân tích chuỗi sự kiện bàn phím (T/P/C) qua thời gian để phát hiện gian lận")


# ── Helpers ───────────────────────────────────────────────────────────────────
def _run_cmd(args: list[str]) -> tuple[str, int]:
    """Run a subprocess and return (stdout+stderr combined, returncode)."""
    env = os.environ.copy()
    env["PYTHONPATH"] = PROJECT_ROOT
    result = subprocess.run(
        [sys.executable] + args,
        capture_output=True, text=True, cwd=PROJECT_ROOT, env=env
    )
    return (result.stdout + result.stderr).strip(), result.returncode


def _file_exists(*parts) -> bool:
    return os.path.isfile(os.path.join(*parts))


def _load_json(path: str) -> dict | None:
    try:
        with open(path, encoding="utf8") as f:
            return json.load(f)
    except Exception:
        return None


def _open_folder_dialog() -> str | None:
    try:
        import tkinter as tk
        from tkinter import filedialog
        tk_root = tk.Tk()
        tk_root.withdraw()
        tk_root.wm_attributes("-topmost", 1)
        folder = filedialog.askdirectory(title="Chon thu muc du lieu PasteTrace (pre-processed)")
        tk_root.destroy()
        return os.path.normpath(folder) if folder else None
    except Exception:
        return None


def _status_badge(ok: bool, label_ok: str = "OK", label_no: str = "Missing") -> str:
    if ok:
        return f'<span style="color:#43a047;font-weight:bold">✔ {label_ok}</span>'
    return f'<span style="color:#e53935;font-weight:bold">✘ {label_no}</span>'


# ── Sidebar status ────────────────────────────────────────────────────────────
with st.sidebar:
    st.header("Trang thai Pipeline")

    idx_ok      = _file_exists(INDEX_PATH)
    splits_ok   = _file_exists(SPLITS_PATH)
    model_ok    = _file_exists(MODEL_DIR, "mamba.pt")
    results_ok  = _file_exists(RESULTS_DIR, "mamba_metrics.json")

    st.markdown(f"**1. Sequences** {_status_badge(idx_ok)}", unsafe_allow_html=True)
    st.markdown(f"**2. Splits**    {_status_badge(splits_ok)}", unsafe_allow_html=True)
    st.markdown(f"**3. Model**     {_status_badge(model_ok)}", unsafe_allow_html=True)
    st.markdown(f"**4. Results**   {_status_badge(results_ok)}", unsafe_allow_html=True)

    if model_ok:
        cfg = _load_json(os.path.join(MODEL_DIR, "config.json")) or {}
        st.divider()
        st.caption(f"d_model={cfg.get('d_model','?')}  layers={cfg.get('n_layers','?')}")
        st.caption(f"Best epoch={cfg.get('best_epoch','?')}  val_F1={cfg.get('best_val_f1', 0):.3f}")

    st.divider()
    gpu_ok = False
    try:
        import torch
        gpu_ok = torch.cuda.is_available()
    except Exception:
        pass
    st.markdown(
        f"**GPU** {_status_badge(gpu_ok, 'CUDA Available', 'CPU only (slow)')}",
        unsafe_allow_html=True
    )
    if not gpu_ok:
        st.warning("Mamba yeu cau GPU NVIDIA. Chay tren CPU se rat cham.")

# ── Tabs ──────────────────────────────────────────────────────────────────────
tab_data, tab_train, tab_eval, tab_predict = st.tabs([
    "📁 Data & Splits", "🏋️ Train", "📊 Evaluate", "🔍 Predict"
])


# ════════════════════════════════════════════════════════════════════════════
# TAB 1 — Data
# ════════════════════════════════════════════════════════════════════════════
with tab_data:
    st.subheader("Buoc 1 — Build Sequences")
    st.markdown(
        "Doc `meta.json` cua tung sinh vien, trich chuoi su kien **T/P/C** "
        "(bo qua L=O scaffold), luu vao `data/train_sequences/`."
    )

    col_dir, col_btn = st.columns([3, 1])
    with col_dir:
        default_dir = CASE_STUDY_ROOT if os.path.isdir(CASE_STUDY_ROOT) else ""
        data_dir = st.text_input("Thu muc pre-processed", value=default_dir, key="seq_data_dir")
    with col_btn:
        st.write("")
        st.write("")
        if st.button("📁 Chon folder", key="browse_seq"):
            chosen = _open_folder_dialog()
            if chosen:
                st.session_state["seq_data_dir"] = chosen
                st.rerun()

    min_events = st.number_input("Min events per student", min_value=1, value=3, step=1)

    if st.button("▶ Build Sequences", type="primary", key="run_seq"):
        with st.spinner("Dang xu ly meta.json..."):
            cmd = ["-m", "src.data.build_sequences",
                   "--data-dir", data_dir,
                   "--min-events", str(int(min_events))]
            out, rc = _run_cmd(cmd)
        if rc == 0:
            st.success("Sequences built successfully!")
        else:
            st.error("Loi khi build sequences")
        st.code(out, language="text")

    if idx_ok:
        df_idx = pd.read_csv(INDEX_PATH)
        st.divider()
        st.markdown("**Sequences Index**")
        col1, col2, col3 = st.columns(3)
        col1.metric("Tong sinh vien", len(df_idx))
        col2.metric("Cheat (label=1)", int((df_idx["label"] == 1).sum()))
        col3.metric("Normal (label=0)", int((df_idx["label"] == 0).sum()))

        with st.expander("Xem bang sequences_index"):
            st.dataframe(df_idx[["id", "case", "student", "label", "n_events", "time_available"]])

        import plotly.express as px
        fig_len = px.histogram(df_idx, x="n_events", color=df_idx["label"].map({0: "Normal", 1: "Cheat"}),
                               barmode="overlay", title="Phan bo do dai chuoi",
                               color_discrete_map={"Cheat": "#e53935", "Normal": "#43a047"})
        st.plotly_chart(fig_len, use_container_width=True)

    st.divider()
    st.subheader("Buoc 2 — Make Splits (train / val / test)")
    st.markdown("Chia stratified, co dinh seed, dung chung cho moi model.")

    if not idx_ok:
        st.warning("Can build sequences truoc (buoc 1).")
    else:
        c1, c2, c3, c4 = st.columns(4)
        train_r = c1.number_input("Train", 0.1, 0.9, 0.7, 0.05, key="split_train")
        val_r   = c2.number_input("Val",   0.05, 0.5, 0.15, 0.05, key="split_val")
        test_r  = c3.number_input("Test",  0.05, 0.5, 0.15, 0.05, key="split_test")
        seed    = c4.number_input("Seed",  value=42, step=1, key="split_seed")

        total_r = train_r + val_r + test_r
        if abs(total_r - 1.0) > 0.01:
            st.warning(f"Tong ratio = {total_r:.2f}, nen = 1.0")

        if st.button("▶ Make Splits", type="primary", key="run_splits"):
            with st.spinner("Dang chia dataset..."):
                cmd = ["-m", "src.data.make_splits",
                       "--train", str(train_r),
                       "--val",   str(val_r),
                       "--test",  str(test_r),
                       "--seed",  str(int(seed))]
                out, rc = _run_cmd(cmd)
            if rc == 0:
                st.success("Splits created!")
            else:
                st.error("Loi khi tao splits")
            st.code(out, language="text")

        if splits_ok:
            sp = _load_json(SPLITS_PATH)
            if sp:
                st.markdown("**Splits hien tai:**")
                c = sp.get("counts", {})
                cols = st.columns(3)
                for i, split_name in enumerate(["train", "val", "test"]):
                    sc = c.get(split_name, {})
                    cols[i].metric(
                        split_name.upper(),
                        sc.get("total", "?"),
                        f"cheat={sc.get('cheat','?')} normal={sc.get('normal','?')}"
                    )


# ════════════════════════════════════════════════════════════════════════════
# TAB 2 — Train
# ════════════════════════════════════════════════════════════════════════════
with tab_train:
    st.subheader("Train Mamba Model")

    if not splits_ok and not idx_ok:
        st.warning("Can hoan thanh tab Data truoc.")
        st.stop()

    col_l, col_r = st.columns(2)
    with col_l:
        st.markdown("**Kien truc**")
        d_model  = st.selectbox("d_model",  [32, 64, 128], index=1)
        n_layers = st.selectbox("n_layers", [1, 2, 3, 4],   index=1)
        dropout  = st.slider("Dropout", 0.0, 0.5, 0.2, 0.05)
        max_len  = st.number_input("Max sequence length", 100, 5000, 1000, 100)

    with col_r:
        st.markdown("**Huan luyen**")
        epochs    = st.number_input("Max epochs", 10, 500, 80, 10)
        lr        = st.select_slider("Learning rate", [1e-4, 5e-4, 1e-3, 2e-3, 5e-3], value=1e-3)
        patience  = st.number_input("Early stop patience", 3, 50, 10, 1)
        batch_sz  = st.selectbox("Batch size", [4, 8, 16, 32], index=1)
        loo_mode  = st.checkbox("LOO mode (dataset qua nho)", value=False)

    if loo_mode:
        st.info(
            "LOO: train lai model N lan (1 fold/student). Rat cham nhung valid cho dataset nho. "
            "Khong can splits.json."
        )

    if st.button("🚀 Bat dau Train", type="primary", key="run_train"):
        cmd_base = ["-m", "src.models.mamba_model", "train",
                    "--d-model",    str(d_model),
                    "--n-layers",   str(n_layers),
                    "--dropout",    str(dropout),
                    "--epochs",     str(int(epochs)),
                    "--lr",         str(lr),
                    "--patience",   str(int(patience)),
                    "--batch-size", str(batch_sz),
                    "--max-len",    str(int(max_len))]
        if loo_mode:
            cmd_base.append("--loo")

        log_box = st.empty()
        st.session_state["train_log"] = ""

        with st.spinner("Training... (xem log bên dưới)"):
            env = os.environ.copy()
            env["PYTHONPATH"] = PROJECT_ROOT
            proc = subprocess.Popen(
                [sys.executable] + cmd_base,
                stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                text=True, cwd=PROJECT_ROOT, env=env
            )
            log_lines = []
            for line in proc.stdout:
                log_lines.append(line.rstrip())
                log_box.markdown(
                    f'<div class="log-box">{"<br>".join(log_lines[-60:])}</div>',
                    unsafe_allow_html=True
                )
            proc.wait()

        if proc.returncode == 0:
            st.success("Training complete! Model saved -> models/mamba/mamba.pt")
        else:
            st.error("Training failed — check log above.")

        st.rerun()


# ════════════════════════════════════════════════════════════════════════════
# TAB 3 — Evaluate
# ════════════════════════════════════════════════════════════════════════════
with tab_eval:
    st.subheader("Danh gia mo hinh")

    if not model_ok:
        st.warning("Chua co model da train. Vao tab Train truoc.")
    else:
        col_a, col_b = st.columns([1, 2])
        with col_a:
            if st.button("▶ Chay Test Set", type="primary", key="run_test"):
                with st.spinner("Evaluating on held-out test set..."):
                    out, rc = _run_cmd(["-m", "src.models.mamba_model", "test"])
                if rc == 0:
                    st.success("Done!")
                else:
                    st.error("Loi khi test")
                st.code(out, language="text")
                st.rerun()

        with col_b:
            st.caption(
                "⚠️ Test set chi chay 1 lan cuoi. Khong dung ket qua test de chinh hyperparameter."
            )

        if results_ok:
            res = _load_json(os.path.join(RESULTS_DIR, "mamba_metrics.json"))
            if res:
                m = res.get("mamba", {})
                mb = res.get("majority_baseline", {})

                st.divider()
                st.markdown("### Ket qua Test Set")
                c1, c2, c3, c4 = st.columns(4)
                c1.metric("Accuracy",  f"{m.get('accuracy', 0):.3f}",
                          delta=f"{m.get('accuracy',0) - mb.get('accuracy',0):+.3f} vs baseline")
                c2.metric("Macro F1",  f"{m.get('macro_f1', 0):.3f}")
                c3.metric("Cheat F1",  f"{m.get('cheat_f1', 0):.3f}")
                c4.metric("Normal F1", f"{m.get('normal_f1', 0):.3f}")

                st.divider()
                col_met, col_cm = st.columns(2)

                with col_met:
                    st.markdown("**Chi tiet theo lop**")
                    rows = []
                    for cls in ["cheat", "normal"]:
                        rows.append({
                            "Class": cls.capitalize(),
                            "Precision": f"{m.get(f'{cls}_precision', 0):.3f}",
                            "Recall":    f"{m.get(f'{cls}_recall', 0):.3f}",
                            "F1":        f"{m.get(f'{cls}_f1', 0):.3f}",
                        })
                    st.table(pd.DataFrame(rows).set_index("Class"))

                with col_cm:
                    st.markdown("**Confusion Matrix**")
                    import plotly.figure_factory as ff
                    cm = m.get("confusion", [[0, 0], [0, 0]])
                    fig_cm = ff.create_annotated_heatmap(
                        z=cm,
                        x=["Pred Normal", "Pred Cheat"],
                        y=["True Normal", "True Cheat"],
                        colorscale="Blues",
                        showscale=True,
                    )
                    fig_cm.update_layout(margin=dict(t=10, b=10))
                    st.plotly_chart(fig_cm, use_container_width=True)

                # Per-student predictions
                preds = res.get("predictions", [])
                if preds:
                    st.divider()
                    st.markdown("### Du doan tung sinh vien (Test Set)")
                    import plotly.express as px
                    df_pred = pd.DataFrame(preds)
                    df_pred["correct"] = df_pred["true"] == df_pred["pred"]
                    df_pred["label_name"] = df_pred["true"].map({1: "Cheat", 0: "Normal"})
                    df_pred["pred_name"]  = df_pred["pred"].map({1: "Cheat", 0: "Normal"})

                    fig_prob = px.bar(
                        df_pred.sort_values("prob", ascending=False),
                        x="id", y="prob",
                        color="label_name",
                        color_discrete_map={"Cheat": "#e53935", "Normal": "#43a047"},
                        title="Xac suat gian lan (Test Set)",
                        labels={"prob": "P(cheat)", "id": "Student", "label_name": "Nhan thuc"},
                    )
                    fig_prob.add_hline(y=0.5, line_dash="dash", line_color="gray")
                    st.plotly_chart(fig_prob, use_container_width=True)

                    # Cards per student
                    for _, row in df_pred.iterrows():
                        cls = "card-cheat" if row["pred"] == 1 else "card-normal"
                        correct_str = "✓ Correct" if row["correct"] else "✗ Wrong"
                        st.markdown(
                            f'<div class="metric-card {cls}">'
                            f'<b>{row["id"]}</b> &nbsp;|&nbsp; '
                            f'True: {row["label_name"]} &nbsp;|&nbsp; '
                            f'Pred: {row["pred_name"]} &nbsp;|&nbsp; '
                            f'P(cheat)={row["prob"]:.3f} &nbsp;|&nbsp; {correct_str}'
                            f'</div>',
                            unsafe_allow_html=True
                        )


# ════════════════════════════════════════════════════════════════════════════
# TAB 4 — Predict
# ════════════════════════════════════════════════════════════════════════════
with tab_predict:
    st.subheader("Du doan sinh vien moi")
    st.markdown(
        "Chon thu muc sinh vien (chua `meta.json`) hoac folder case de du doan "
        "xac suat gian lan ma khong can nhan."
    )

    if not model_ok:
        st.warning("Chua co model. Vao tab Train truoc.")
    else:
        col_p, col_pb = st.columns([3, 1])
        with col_p:
            pred_path = st.text_input("Duong dan meta.json hoac folder sinh vien", key="pred_path")
        with col_pb:
            st.write("")
            st.write("")
            if st.button("📁 Chon", key="browse_pred"):
                chosen = _open_folder_dialog()
                if chosen:
                    st.session_state["pred_path"] = chosen
                    st.rerun()

        pred_path_val = st.session_state.get("pred_path", pred_path)

        if pred_path_val and st.button("🔍 Predict", type="primary", key="run_pred"):
            with st.spinner("Dang du doan..."):
                out, rc = _run_cmd(["-m", "src.models.mamba_model", "predict", pred_path_val])
            st.code(out, language="text")
            if rc == 0:
                # Parse result from output
                for line in out.split("\n"):
                    if "Prediction:" in line:
                        label_name = "CHEAT" if "CHEAT" in line else "NORMAL"
                        try:
                            prob = float(line.split("prob=")[1].split(",")[0].strip(")"))
                        except Exception:
                            prob = 0.5
                        color = "#e53935" if label_name == "CHEAT" else "#43a047"
                        st.markdown(
                            f'<div class="metric-card" style="border-left:5px solid {color};font-size:1.2em">'
                            f'<b>Ket qua: {label_name}</b> &nbsp; | &nbsp; '
                            f'Xac suat gian lan: <b>{prob:.1%}</b>'
                            f'</div>',
                            unsafe_allow_html=True
                        )

        st.divider()
        st.markdown("**Du doan nhieu sinh vien tu folder**")
        st.markdown(
            "Neu folder co nhieu subfolder sinh vien, he thong se chay tung subfolder "
            "va hien thi bang tong hop."
        )

        batch_dir = st.text_input("Folder chua cac subfolder sinh vien", key="batch_dir")
        c_bb, _ = st.columns([1, 4])
        with c_bb:
            if st.button("📁 Chon folder", key="browse_batch"):
                chosen = _open_folder_dialog()
                if chosen:
                    st.session_state["batch_dir"] = chosen
                    st.rerun()

        batch_dir_val = st.session_state.get("batch_dir", batch_dir)

        if batch_dir_val and st.button("🔍 Batch Predict", type="primary", key="run_batch"):
            if not os.path.isdir(batch_dir_val):
                st.error("Khong tim thay folder.")
            else:
                subdirs = sorted(
                    d for d in os.listdir(batch_dir_val)
                    if os.path.isdir(os.path.join(batch_dir_val, d))
                )
                if not subdirs:
                    st.warning("Khong co subfolder sinh vien.")
                else:
                    results = []
                    prog = st.progress(0)
                    for i, student in enumerate(subdirs):
                        sdir = os.path.join(batch_dir_val, student)
                        out, rc = _run_cmd(["-m", "src.models.mamba_model", "predict", sdir])
                        prob, label_name = 0.5, "ERROR"
                        for line in out.split("\n"):
                            if "Prediction:" in line:
                                label_name = "CHEAT" if "CHEAT" in line else "NORMAL"
                                try:
                                    prob = float(line.split("prob=")[1].split(",")[0].strip(")"))
                                except Exception:
                                    pass
                        results.append({"Student": student, "Prediction": label_name, "P(cheat)": prob})
                        prog.progress((i + 1) / len(subdirs))

                    df_batch = pd.DataFrame(results).sort_values("P(cheat)", ascending=False)
                    st.dataframe(df_batch, use_container_width=True)

                    import plotly.express as px
                    fig = px.bar(
                        df_batch, x="Student", y="P(cheat)",
                        color="Prediction",
                        color_discrete_map={"CHEAT": "#e53935", "NORMAL": "#43a047"},
                        title="Xac suat gian lan — Batch Predict",
                    )
                    fig.add_hline(y=0.5, line_dash="dash", line_color="gray")
                    st.plotly_chart(fig, use_container_width=True)
