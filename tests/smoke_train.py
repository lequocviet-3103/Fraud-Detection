"""Offline smoke test of the fixed Mamba training loop.

Mocks mamba_ssm so we don't need a GPU build, but exercises:
  - data loading
  - stratified train/val split
  - scaler fit
  - full train loop with validation + early stopping + best-checkpoint restore
"""
import sys
import types

import torch
import torch.nn as nn

# Mock mamba_ssm before importing the model
mock = types.ModuleType("mamba_ssm")


class _IdentityMamba(nn.Module):
    """Tiny non-Mamba stand-in: a single linear + residual. Not state-of-the-art
    but lets us verify the training loop runs end-to-end on CPU."""

    def __init__(self, d_model=64, d_state=16, d_conv=4, expand=2):
        super().__init__()
        self.proj = nn.Linear(d_model, d_model)

    def forward(self, x):
        return self.proj(x) + x


mock.Mamba = _IdentityMamba
sys.modules["mamba_ssm"] = mock

torch.manual_seed(0)

import os, sys  # noqa: E402
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))
from src.models.mamba_model import cmd_train  # noqa: E402

import argparse  # noqa: E402

args = argparse.Namespace(
    d_model=32,
    n_layers=1,
    dropout=0.1,
    epochs=10,
    lr=1e-3,
    weight_decay=0.01,
    patience=4,
    batch_size=8,
    max_len=2000,
)

cmd_train(args)