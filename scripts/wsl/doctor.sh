#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
echo "Kernel: $(uname -r)"
echo "WSLg display: ${DISPLAY:-unset}; Wayland: ${WAYLAND_DISPLAY:-unset}"
command -v nvidia-smi >/dev/null && nvidia-smi || true
[[ -f /opt/ros/jazzy/setup.bash ]] || { echo "ROS missing; run setup."; exit 1; }
set +u
source /opt/ros/jazzy/setup.bash
set -u
gz sim --versions
ros2 pkg prefix ros_gz_bridge
"$ROOT/.venv/bin/python" -c 'import torch, ultralytics, mavsdk, cv2, numpy; print("CUDA available:", torch.cuda.is_available()); print("NumPy:", numpy.__version__)'
echo "Discovery only; this does not verify camera, flight, or inference."
