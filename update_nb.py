import json

with open("notebooks/mamba_colab.ipynb", "r", encoding="utf-8") as f:
    nb = json.load(f)

# 1. Update pipeline markdown in Cell 1
nb["cells"][0]["source"] = [
    "# PasteTrace — Mamba Behavioral Sequence Model\n",
    "\n",
    "**Yêu cầu:** Vào `Runtime → Change runtime type → T4 GPU` trước khi chạy.\n",
    "\n",
    "Dataset: **205 sinh viên tổng hợp** trong `test_new_cohort/` (đã có sẵn trong repo — không cần upload Drive).\n",
    "\n",
    "## Pipeline\n",
    "```\n",
    "Bước 0  Setup   (kiểm tra GPU, cài thư viện, clone repo)\n",
    "Bước 1  Build   (meta.json → chuỗi sự kiện, data/train_sequences/)\n",
    "Bước 2  Train   (Mamba model, lưu models/mamba/mamba.pt)\n",
    "Bước 3  Lưu     (download mamba.pt về máy hoặc lên Drive)\n",
    "Bước 4  Predict (chạy inference trên thư mục tests/)\n",
    "```"
]

# Filtering cells
new_cells = []
for cell in nb["cells"]:
    src = "".join(cell.get("source", []))
    
    # Remove Make Splits
    if "Bước 2 — Make Splits" in src:
        continue
    if "src.data.make_splits" in src:
        continue
        
    # Update Train markdown
    if "Bước 3 — Train" in src:
        cell["source"] = [
            "## Bước 2 — Train\n",
            "\n",
            "Train model trên toàn bộ dataset."
        ]
        new_cells.append(cell)
        continue
        
    # Remove LOO
    if "Cell B: LOO (Leave-One-Out)" in src:
        continue
        
    # Remove Test
    if "Bước 4 — Test" in src:
        continue
    if "src.models.mamba_model test" in src:
        continue
        
    # Update Lưu markdown
    if "Bước 5 — Lưu model" in src:
        cell["source"] = [
            "## Bước 3 — Lưu model"
        ]
        
    # Update error handling
    if "Lỗi thường gặp" in src:
        # Inject predict cells here
        new_cells.append({
            "cell_type": "markdown",
            "metadata": {},
            "source": [
                "---\n",
                "## Bước 4 — Predict trên tập tests/\n",
                "\n",
                "Chạy model để đưa ra dự đoán (Normal/Cheat) trên bộ dữ liệu `tests/`."
            ]
        })
        new_cells.append({
            "cell_type": "code",
            "execution_count": None,
            "metadata": {},
            "outputs": [],
            "source": [
                "!python predict_tests.py tests"
            ]
        })
        
        cell["source"] = [
            "---\n",
            "## Lỗi thường gặp\n",
            "\n",
            "| Lỗi | Fix |\n",
            "|-----|-----|\n",
            "| `RuntimeError: GPU chua bat` | Runtime → Change runtime type → T4 GPU |\n",
            "| `Getting requirements to build wheel` | Dùng `--no-build-isolation` (Bước 0b đã sửa) |\n",
            "| `mamba_ssm not found` | Chạy lại Bước 0b |\n",
            "| `sequences_index.csv not found` | Chạy Bước 1 |\n",
            "| `test_new_cohort/ not found` | Chạy lại Bước 0c (git pull) |\n",
            "| Session bị reset sau 12h | Chạy lại Bước 0a → 0c, load model từ Drive (cell cuối) |"
        ]
        
    new_cells.append(cell)
    
nb["cells"] = new_cells

with open("notebooks/mamba_colab.ipynb", "w", encoding="utf-8") as f:
    json.dump(nb, f, indent=1)
