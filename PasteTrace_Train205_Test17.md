# PasteTrace — Mamba Behavioral Sequence Model (Train 205, Test 17 New)

**Yêu cầu:** Vào `Runtime → Change runtime type → T4 GPU` trước khi chạy.

Dataset: 
- **Train: 205 sinh viên** trong `test_new_cohort/` (đã có sẵn trong repo)
- **Test: 17 sinh viên mới** trong `tests/` (chỉ code.pde + meta.json)

## Pipeline
```
Bước 0  Setup   (kiểm tra GPU, cài thư viện, clone repo)
Bước 1  Build   (meta.json → chuỗi sự kiện, data/sequences/)
Bước 2  Splits  (train 205 / val 0 / test 0)  ← SỬA: 100% TRAIN
Bước 3  Train   (Mamba model, lưu models/mamba/mamba.pt)
Bước 4  Test    (predict 17 hs mới — không có đánh nhãn)  ← SỬA: PREDICT
Bước 5  Lưu     (download mamba.pt về máy)
```

## Bước 0a — Kiểm tra GPU
```python
import torch
print('CUDA available:', torch.cuda.is_available())
if torch.cuda.is_available():
    print('GPU:', torch.cuda.get_device_name(0))
    print('VRAM:', round(torch.cuda.get_device_properties(0).total_memory / 1e9, 1), 'GB')
else:
    print('⚠️ GPU not enabled. Enable in Notebook Settings → GPU')
```

## Bước 0b — Cài thư viện Mamba (~3 phút lần đầu)
```python
import os
import subprocess
import importlib.util
import torch

print("="*60)
print("Torch :", torch.__version__)
print("CUDA  :", torch.version.cuda)
print("="*60)

if importlib.util.find_spec("mamba_ssm") is None:

    print("\nInstalling build dependencies...")
    subprocess.run(
        ["apt-get", "update", "-qq"],
        check=True,
        capture_output=True
    )
    subprocess.run(
        ["apt-get", "install", "-y", "-qq", 
         "build-essential"],
        check=True,
        capture_output=True
    )

    print("Installing Python build tools...")
    subprocess.run(
        [
            "pip","install","-q","--upgrade",
            "pip", "setuptools", "wheel", "ninja",
            "packaging", "pybind11", "cmake"
        ],
        check=True
    )

    print("\nInstalling causal-conv1d...")
    result = subprocess.run(
        ["pip","install","-q","causal-conv1d>=1.1.0"],
        capture_output=True,
        text=True
    )
    
    if result.returncode != 0:
        print("⚠️  causal-conv1d build failed, trying pre-built wheel...")
        subprocess.run(
            ["pip","install","-q","--no-build-isolation","causal-conv1d"],
            check=True
        )

    print("\nInstalling mamba-ssm...")
    result = subprocess.run(
        ["pip","install","-q","mamba-ssm>=0.1"],
        capture_output=True,
        text=True
    )
    
    if result.returncode != 0:
        print("⚠️  mamba-ssm build failed, trying pre-built wheel...")
        subprocess.run(
            ["pip","install","-q","--no-build-isolation","mamba-ssm"],
            check=True
        )

print("\nInstalling other packages...")
subprocess.run(
    [
        "pip","install","-q",
        "pandas",
        "scikit-learn",
        "plotly"
    ],
    check=True
)

# Kiểm tra import
try:
    from mamba_ssm import Mamba
    print("\n✓ SUCCESS! All dependencies installed")
except ImportError as e:
    print(f"\n✗ ERROR: {e}")
    raise
```

## Bước 0c — Clone repo từ GitHub
```python
import sys

REPO_URL = 'https://github.com/lequocviet-3103/Fraud-Detection.git'
REPO_DIR = '/kaggle/working/Fraud-Detection'

if not os.path.exists(REPO_DIR):
    !git clone {REPO_URL} {REPO_DIR}
else:
    print('Repo da co, pull update...')
    !git -C {REPO_DIR} pull

os.chdir(REPO_DIR)
sys.path.insert(0, REPO_DIR)
print('Working dir:', os.getcwd())
!ls
```

## Bước 0d — Kiểm tra data
```python
DATA_DIR = 'test_new_cohort'
if os.path.isdir(DATA_DIR):
    cases = sorted([d for d in os.listdir(DATA_DIR)
                    if os.path.isdir(os.path.join(DATA_DIR, d))])
    total = 0
    for c in cases:
        students = [s for s in os.listdir(os.path.join(DATA_DIR, c))
                    if os.path.isdir(os.path.join(DATA_DIR, c, s))]
        print(f'  {c}: {len(students)} students')
        total += len(students)
    print(f'\nOK — {total} students total in {len(cases)} cases')
else:
    print('CANH BAO: Khong tim thay test_new_cohort/. Chay lai Buoc 0c (git pull).')
```

## PHẦN CHUẨN BỊ: Tách History từ .pde thành meta.json
```python
import json
import re

print("="*70)
print("STEP 0: EXTRACTING HISTORY FROM .pde FILES")
print("="*70)

def extract_history_from_pde(pde_file_path):
    """Tách History từ file .pde"""
    try:
        with open(pde_file_path, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
        
        match = re.search(r'//\|Do not modify this line\|\{(.+)\}', content)
        if not match:
            return None
        
        json_str = "{" + match.group(1) + "}"
        data = json.loads(json_str)
        history = data.get('History', [])
        
        if not history:
            return None
        
        return {"History": history}
    
    except Exception as e:
        return None

# Scan test folder
TEST_FOLDER = 'tests'
extracted_count = 0

if os.path.isdir(TEST_FOLDER):
    for root, dirs, files in os.walk(TEST_FOLDER):
        for file in files:
            if file.endswith('.pde'):
                pde_path = os.path.join(root, file)
                meta_path = os.path.join(root, 'meta.json')
                
                meta_data = extract_history_from_pde(pde_path)
                if meta_data:
                    with open(meta_path, 'w', encoding='utf-8') as f:
                        json.dump(meta_data, f, indent=2)
                    print(f"✓ Created {meta_path}")
                    extracted_count += 1

    print(f"✓ Extracted {extracted_count} meta.json files\n")
else:
    print(f"⚠️  {TEST_FOLDER}/ not found\n")
```

## Bước 1 — Build Sequences
```python
!python -m src.data.build_sequences --data-dir test_new_cohort --min-events 3

import pandas as pd
df = pd.read_csv('data/sequences_index.csv')
print(df[['id','label','n_events','time_available']].to_string())
print(f'\nTong: {len(df)} sinh vien | cheat={sum(df.label==1)} | normal={sum(df.label==0)}')
print(f'Events: min={df.n_events.min()}  median={df.n_events.median():.0f}  max={df.n_events.max()}')
```

## Bước 2 — Make Splits (SỬA: 100% TRAIN)
```python
# SỬA: Train 100%, Val 0%, Test 0%
!python -m src.data.make_splits --train 1.0 --val 0.0 --test 0.0 --seed 42

import json
with open('data/splits.json') as f:
    sp = json.load(f)

print("\nSplits created:")
for s in ['train', 'val', 'test']:
    c = sp['counts'][s]
    total = c.get('total', 0)
    if total > 0:
        print(f"  {s:6}: {c['total']:3d} samples  (cheat={c['cheat']}, normal={c['normal']})")
    else:
        print(f"  {s:6}: (empty)")
```

## Bước 3 — Train (Giữ nguyên)
```python
!python -m src.models.mamba_model train \
    --d-model 64 --n-layers 2 --dropout 0.2 \
    --epochs 80 --lr 1e-3 --patience 10 \
    --batch-size 8 --max-len 1000

print("\n" + "="*60)
print("Checking model files after training...")
print("="*60)

# Kiem tra model files
import os
for fname in ['mamba.pt', 'config.json', 'scaler.json']:
    p = f'models/mamba/{fname}'
    if os.path.isfile(p):
        size_kb = os.path.getsize(p) / 1024
        print(f'✓ OK     {p}  ({size_kb:.1f} KB)')
    else:
        print(f'✗ MISSING  {p}')
```

## Bước 4 — Predict 17 hs mới (SỬA: PREDICT thay vì TEST)
```python
print("\n" + "="*70)
print("STEP 4: PREDICT ON 17 NEW STUDENTS")
print("="*70)

predictions_list = []
test_count = 0

TEST_FOLDER = 'tests'

if os.path.isdir(TEST_FOLDER):
    for root, dirs, files in os.walk(TEST_FOLDER):
        if 'meta.json' in files:
            student_path = root
            student_name = os.path.relpath(student_path, TEST_FOLDER)
            
            test_count += 1
            print(f"\n[{test_count}] Predicting: {student_name}")
            print("-" * 60)
            
            # Chạy predict
            result = !python -m src.models.mamba_model predict {student_path}
            output_text = '\n'.join(result)
            print(output_text)
            
            predictions_list.append({
                'student': student_name,
                'output': output_text
            })

    print("\n" + "="*70)
    print("PREDICTIONS SUMMARY")
    print("="*70)
    
    results_summary = {
        'n_tested': test_count,
        'predictions': predictions_list,
        'timestamp': pd.Timestamp.now().isoformat()
    }
    
    os.makedirs('results', exist_ok=True)
    with open('results/test_17_predictions.json', 'w') as f:
        json.dump(results_summary, f, indent=2)
    
    print(f"\n✓ Tested {test_count} students")
    print(f"✓ Results saved to: results/test_17_predictions.json\n")
    
    for i, pred in enumerate(predictions_list, 1):
        print(f"  [{i}] {pred['student']}")
else:
    print(f"\n⚠️  {TEST_FOLDER}/ not found!")
```

## Bước 5 — Lưu model (Giữ nguyên)
```python
import zipfile

with zipfile.ZipFile('/kaggle/working/mamba_trained.zip', 'w') as z:
    for f in ['models/mamba/mamba.pt', 'models/mamba/config.json',
              'models/mamba/scaler.json', 'results/test_17_predictions.json']:
        if os.path.isfile(f):
            z.write(f)
            print(f'Added {f}')

print('✓ Saved to /kaggle/working/mamba_trained.zip')
print('File co the download tu Kaggle Output tab')

import shutil

SAVE_DIR = '/kaggle/working/trained_models'
os.makedirs(SAVE_DIR, exist_ok=True)

for src in ['models/mamba/mamba.pt', 'models/mamba/config.json',
            'models/mamba/scaler.json', 'results/test_17_predictions.json']:
    if os.path.isfile(src):
        shutil.copy2(src, SAVE_DIR)
        print(f'Saved {os.path.basename(src)} -> /kaggle/working')

print(f'\n✓ Model saved in: {SAVE_DIR}')
print('Download từ Kaggle Output tab')
```

---

## Lần sau — Load model từ Kaggle Dataset
```python
import shutil

# Nếu bạn upload output thành Kaggle Dataset, thay "your-dataset-name"
KAGGLE_MODEL = '/kaggle/input/your-dataset-name/trained_models'

os.makedirs('models/mamba', exist_ok=True)

for fname in ['mamba.pt', 'config.json', 'scaler.json']:
    try:
        shutil.copy2(f'{KAGGLE_MODEL}/{fname}', f'models/mamba/{fname}')
        print(f'✓ Loaded {fname}')
    except FileNotFoundError:
        print(f'✗ Not found: {fname}')

# Predict sinh vien moi
STUDENT_FOLDER = 'tests/111/A'  # Thay path của sinh viên cần predict
!python -m src.models.mamba_model predict {STUDENT_FOLDER}
```

---

## Những chỗ SỬA so với cũ

| Bước | Cũ | Mới | Lý do |
|------|-----|-----|-------|
| **Bước 0d** | apt-get cuda-toolkit | Bỏ cuda-toolkit | Kaggle đã có CUDA |
| **Phần chuẩn bị** | N/A | Thêm tách history từ .pde | Test data chỉ có .pde |
| **Bước 2** | `--train 0.7 --val 0.15 --test 0.15` | `--train 1.0 --val 0.0 --test 0.0` | Train toàn bộ 205 hs |
| **Bước 4** | `!python -m ... test` | `!python -m ... predict` | Predict 17 hs mới |
| **Results** | `mamba_metrics.json` | `test_17_predictions.json` | Lưu dự đoán 17 hs |

---

## Lỗi thường gặp

| Lỗi | Fix |
|-----|-----|
| `RuntimeError: GPU chua bat` | Runtime → Change runtime type → T4 GPU |
| `mamba_ssm not found` | Chạy lại Bước 0b |
| `sequences_index.csv not found` | Chạy Bước 1 |
| `test_new_cohort/ not found` | Chạy lại Bước 0c (git pull) |
| `tests/ not found` | Upload folder tests/ lên Kaggle |
| `meta.json not found in tests/` | Chạy phần "Tách History từ .pde" |
