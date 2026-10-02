#!/usr/bin/env bash
set -euo pipefail

VENV="${OMNIHAWK_VENV:-$HOME/omnihawk-venv}"
source "$VENV/bin/activate"

if ! command -v nvidia-smi >/dev/null 2>&1; then
  echo 'No NVIDIA GPU is visible inside WSL.' >&2
  exit 1
fi

nvidia-smi

python - <<'PY'
try:
    import torch
except ImportError:
    raise SystemExit('PyTorch is not installed in the OmniHawk venv. Install an x86-64 WSL-compatible PyTorch build before GPU validation.')
print('PyTorch:', torch.__version__)
print('CUDA available:', torch.cuda.is_available())
if torch.cuda.is_available():
    print('GPU:', torch.cuda.get_device_name(0))
else:
    raise SystemExit('PyTorch is installed but CUDA is not available to it.')
PY

echo 'YOLO/PyTorch GPU path is available.'
