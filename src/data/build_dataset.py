"""Build a labeled dataset.csv from PasteTrace ground-truth aggregation files.

Ground truth comes from `agrigation.csv` (the "Cheated" column, filled in by
a human grader), NOT from whether a submission appears under the `MOSS/`
folder -- MOSS only records *detected matches*, many of which are annotated
as false flags in the aggregation notes.
"""
import csv
import os

CASE_STUDY_ROOT = os.path.join(
    "PasteTrace-release", "PasteTrace-release", "case studies", "sp2023", "pre-processed"
)
OUTPUT_PATH = os.path.join("data", "dataset.csv")

CASES = ["111", "211"]


def load_labels(case_dir):
    """Return {student: 0/1} from agrigation.csv, dropping ambiguous '?'/'*' rows."""
    agg_path = os.path.join(case_dir, "agrigation.csv")
    labels = {}
    with open(agg_path, encoding="utf8", errors="ignore") as f:
        reader = csv.DictReader(f)
        for row in reader:
            student = row.get("Student", "").strip()
            if not student:
                continue
            cheated = (row.get("Cheated") or "").strip()
            if cheated == "X":
                labels[student] = 1
            elif cheated == "":
                labels[student] = 0
            # '?' and '*' are ambiguous -> excluded entirely
    return labels


def collect_code(student_dir):
    """Concatenate all .pde files found under a student's submission folder."""
    chunks = []
    for root, _dirs, files in os.walk(student_dir):
        for name in sorted(files):
            if name.lower().endswith(".pde"):
                path = os.path.join(root, name)
                with open(path, encoding="utf8", errors="ignore") as f:
                    chunks.append(f.read())
    return "\n\n".join(chunks)


def main():
    rows = []
    for case in CASES:
        case_dir = os.path.join(CASE_STUDY_ROOT, case)
        labels = load_labels(case_dir)
        for student, label in labels.items():
            student_dir = os.path.join(case_dir, student)
            if not os.path.isdir(student_dir):
                continue
            code = collect_code(student_dir)
            if not code.strip():
                continue
            rows.append({"case": case, "student": student, "code": code, "label": label})

    os.makedirs(os.path.dirname(OUTPUT_PATH), exist_ok=True)
    with open(OUTPUT_PATH, "w", encoding="utf8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=["case", "student", "code", "label"])
        writer.writeheader()
        writer.writerows(rows)

    n_pos = sum(r["label"] for r in rows)
    print(f"Wrote {len(rows)} samples to {OUTPUT_PATH} ({n_pos} cheating, {len(rows) - n_pos} normal)")


if __name__ == "__main__":
    main()
