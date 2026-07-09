import os
import sys
import json
import torch

from src.models.mamba_model import MambaClassifier, MODEL_DIR
from src.models.mamba_dataset import SequenceScaler
from src.data.build_sequences import extract_sequence

def predict_folder(tests_dir):
    model_pt = os.path.join(MODEL_DIR, "mamba.pt")
    cfg_path = os.path.join(MODEL_DIR, "config.json")
    scaler_path = os.path.join(MODEL_DIR, "scaler.json")

    for p in [model_pt, cfg_path, scaler_path]:
        if not os.path.isfile(p):
            print(f"[ERROR] Missing {p}. Run 'train' first.")
            return

    with open(cfg_path, encoding="utf8") as f:
        cfg = json.load(f)

    scaler = SequenceScaler.load(scaler_path)
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    
    # Load model
    model = MambaClassifier(cfg["n_features"], cfg["d_model"], cfg["n_layers"], cfg["dropout"])
    model.load_state_dict(torch.load(model_pt, map_location=device))
    model.to(device).eval()

    results = []
    
    # Walk the directory to find all meta.json
    for root, _, files in os.walk(tests_dir):
        if "meta.json" in files:
            meta_path = os.path.join(root, "meta.json")
            # Calculate the relative path from the tests_dir (e.g., 111/A)
            rel_path = os.path.relpath(root, tests_dir)
            rel_path = rel_path.replace("\\", "/") # Normalize slashes
            
            # 1. Build sequences from meta.json
            seq, _ = extract_sequence([meta_path])
            if not seq:
                continue

            # 2. Scale sequences using the trained scaler
            seq_scaled = scaler.transform(seq[:cfg["max_len"]])
            seq_t = torch.tensor(seq_scaled, dtype=torch.float32).unsqueeze(0)
            mask = torch.ones(1, seq_t.shape[1], dtype=torch.bool)

            # 3. Predict with loaded Mamba model
            with torch.no_grad():
                logit = model(seq_t.to(device), mask.to(device))
                prob = torch.sigmoid(logit).item()

            label = 1 if prob >= 0.5 else 0
            label_name = "Cheat" if label == 1 else "Normal"
            
            results.append({
                "path": rel_path,
                "label": label_name,
                "prob": prob
            })

    # Output formatting
    results.sort(key=lambda x: x["path"])
    
    for i, res in enumerate(results):
        print(f"{res['path']}\n")
        print(f"Prediction : {res['label']}")
        print(f"Probability: {res['prob']:.2f}")
        
        if i < len(results) - 1:
            print("\n-------------------\n")

if __name__ == "__main__":
    if len(sys.argv) > 1:
        tests_dir = sys.argv[1]
    else:
        tests_dir = "tests"
        
    if not os.path.isdir(tests_dir):
        print(f"[ERROR] Directory '{tests_dir}' does not exist.")
    else:
        predict_folder(tests_dir)
