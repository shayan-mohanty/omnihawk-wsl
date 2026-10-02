#!/usr/bin/env bash
set -euo pipefail

VENV="${OMNIHAWK_VENV:-$HOME/omnihawk-venv}"

sudo apt update
sudo apt install -y python3-venv python3-pip python3-dev
python3 -m venv "$VENV"
source "$VENV/bin/activate"
python -m pip install --upgrade pip setuptools wheel

# Portable Python dependencies. PyTorch GPU selection is handled separately so
# this script never installs a Jetson/ARM wheel on x86-64 WSL.
python -m pip install mavsdk ultralytics

python - <<'PY'
import mavsdk
import ultralytics
print('MAVSDK import: OK')
print('Ultralytics import: OK')
PY

echo "Python environment ready at $VENV"
echo "Activate with: source $VENV/bin/activate"
