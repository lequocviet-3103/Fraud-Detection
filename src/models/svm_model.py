"""TF-IDF + SVM baseline for cheating detection on Processing (.pde) source code."""
import os

import joblib
import pandas as pd
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.model_selection import LeaveOneOut
from sklearn.svm import SVC

DATASET_PATH = os.path.join("data", "dataset.csv")
MODEL_DIR = os.path.join("models", "svm")


def evaluate_loo(X, y):
    """Leave-one-out CV: with only 18 labeled samples, a single train/test
    split is not statistically meaningful, so every sample takes a turn as
    the held-out test point."""
    loo = LeaveOneOut()
    correct = 0
    for train_idx, test_idx in loo.split(X):
        vectorizer = TfidfVectorizer(max_features=5000)
        X_train = vectorizer.fit_transform(X.iloc[train_idx])
        X_test = vectorizer.transform(X.iloc[test_idx])
        model = SVC(kernel="linear", class_weight="balanced", probability=True)
        model.fit(X_train, y.iloc[train_idx])
        pred = model.predict(X_test)[0]
        correct += int(pred == y.iloc[test_idx].values[0])
    return correct / len(X)


def main():
    df = pd.read_csv(DATASET_PATH)
    X, y = df["code"], df["label"]

    acc = evaluate_loo(X, y)
    print(f"Leave-one-out accuracy: {acc:.3f} (n={len(df)})")

    vectorizer = TfidfVectorizer(max_features=5000)
    X_vec = vectorizer.fit_transform(X)
    model = SVC(kernel="linear", class_weight="balanced", probability=True)
    model.fit(X_vec, y)

    os.makedirs(MODEL_DIR, exist_ok=True)
    joblib.dump(model, os.path.join(MODEL_DIR, "svm.pkl"))
    joblib.dump(vectorizer, os.path.join(MODEL_DIR, "vectorizer.pkl"))
    print(f"Saved final model to {MODEL_DIR}")


if __name__ == "__main__":
    main()
