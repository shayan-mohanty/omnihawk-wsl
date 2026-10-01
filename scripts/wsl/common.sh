#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
. /etc/os-release
[[ "${ID:-}" == ubuntu && "${VERSION_ID:-}" == 24.04 && "$(uname -m)" == x86_64 ]] || { echo "Requires Ubuntu 24.04 x86_64."; exit 1; }
grep -qi microsoft /proc/sys/kernel/osrelease || { echo "Requires WSL2."; exit 1; }
[[ "$(pwd -P)" != /mnt/* && "$ROOT" != /mnt/* ]] || { echo "Copy this repo to ~/omnihawk-wsl on the Linux filesystem first."; exit 1; }
PX4_DIR="$ROOT/external/PX4-Autopilot"
