#!/usr/bin/env bash
set -euo pipefail

echo '=== OmniHawk WSL verification ==='

if ! grep -qi microsoft /proc/version; then
  echo 'ERROR: This installer is for WSL2 only.' >&2
  exit 1
fi

if [[ "$(uname -m)" != "x86_64" ]]; then
  echo "ERROR: Expected x86_64, found $(uname -m)." >&2
  exit 1
fi

. /etc/os-release
if [[ "${VERSION_ID:-}" != "22.04" ]]; then
  echo "ERROR: Expected Ubuntu 22.04, found ${PRETTY_NAME:-unknown}." >&2
  exit 1
fi

echo "OS: $PRETTY_NAME"
echo "Kernel: $(uname -r)"
echo "Architecture: $(uname -m)"
echo "Init: $(ps -p 1 -o comm= | xargs)"
echo "Home: $HOME"

if [[ "$PWD" == /mnt/* ]]; then
  echo 'WARNING: Repository is on a Windows-mounted drive. Keep OmniHawk under the WSL filesystem (for example ~/omnihawk-wsl).'
fi

if command -v nvidia-smi >/dev/null 2>&1; then
  echo 'NVIDIA GPU visible in WSL:'
  nvidia-smi --query-gpu=name,memory.total,driver_version --format=csv,noheader || true
else
  echo 'NVIDIA GPU not visible. PX4/ROS can still work, but GPU YOLO acceleration will not be available.'
fi

echo 'Verification complete.'
