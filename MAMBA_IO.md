# Mamba input/output contract

## Scope

Mamba uses TaskTracker only. All 470 sessions are assigned exactly once to the
shared grouped split files:

```text
data/splits/tasktracker/train.csv
data/splits/tasktracker/validation.csv
data/splits/tasktracker/test.csv
```

The participant-specific suffix of `session_id` is the grouping key. Sessions
with the same key cannot cross splits. The supplied seed-42 split contains 326
train, 71 validation, and 73 test sessions. Small deviations from exact 70/15/15
are expected because participant groups cannot be divided.

TaskTracker labels are weak behavioral-risk labels:

- `0`: normal-like trace.
- `1`: risky/paste-like trace.

They must not be described as confirmed evidence of cheating.

## Input

Canonical normalized input:

```text
data/normalized/tasktracker/
├── labels.csv
└── <session_id>.json
```

The legacy `tasktracker/normalized/` folder is accepted automatically. Raw data
is not read by Mamba. Each event becomes seven ordered features:

| Feature | Meaning |
|---|---|
| `is_type` | Event is typing |
| `is_paste` | Event is paste |
| `is_cut` | Event is cut/delete |
| `log_len` | `log(1 + event text length)` |
| `paste_log_len` | Paste length only; zero for other events |
| `is_large_paste` | Paste has at least 128 characters |
| `log_delta_time` | `log(1 + seconds since previous event)` |

The label is returned separately by the dataset and is never part of an input
event vector. Scaler statistics are fit from the train split only.

## Training and evaluation

1. Train weights on `train.csv`.
2. Select checkpoint and decision threshold on `validation.csv`. The default
   rule maximizes positive-class F1, with balanced accuracy as the tie-breaker.
3. Freeze weights, scaler, and threshold.
4. Evaluate once on `test.csv`.

## Required outputs

Mamba writes model-specific outputs below `results/mamba/` to avoid overwriting
the other branch:

```text
results/mamba/predictions.csv
results/mamba/metrics.json
```

The first four prediction columns are the shared schema:

```csv
session_id,true_label,risk_score,pred_label
```

Mamba adds audit fields: `threshold`, `correct`, `n_events`, `n_events_used`,
`sequence_truncated`, `evidence_status`, event-type counts, character counts,
largest paste size, and session duration. `risk_score` is the sigmoid model
decision score in `[0,1]`; it is not a calibrated probability.

`metrics.json` contains every shared comparison field: `n_test_sessions`,
`threshold`, `precision`, `recall`, `f1`, `auc`, `balanced_accuracy`, `tp`, `tn`,
`fp`, `fn`, `train_runtime_sec`, and `inference_runtime_sec`. Mamba additionally
records architecture, input features, test loss, normal-class metrics, selected
epoch, validation F1, label warning, and the split manifest.

## Mamba-specific trace outputs

```text
results/mamba/training_history.csv
results/mamba/validation_predictions.csv
models/mamba/mamba.pt
models/mamba/scaler.json
models/mamba/config.json
```

- `training_history.csv`: train loss, validation loss/F1, learning rate, and the
  threshold considered at every epoch.
- `validation_predictions.csv`: evidence that threshold selection used only the
  validation split.
- `config.json`: architecture, selected threshold, runtime, weak-label type,
  seed, and exact split manifest needed for reproducibility.
