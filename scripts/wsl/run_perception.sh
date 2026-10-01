#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
[[ $# -ge 1 ]] || { echo "Usage: bash scripts/wsl/run_perception.sh /gazebo/image/topic [cpu|0]"; exit 1; }
set +u
source /opt/ros/jazzy/setup.bash
source "$ROOT/.venv/bin/activate"
source "$ROOT/ros2_ws/install/setup.bash"
set -u
export PYTHONPATH="$ROOT/.venv/lib/python$(python -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')/site-packages:${PYTHONPATH:-}"
cd "$ROOT/models"
exec ros2 launch omnihawk_perception tier1_bringup.launch.py gz_camera_topic:="$1" model_path:="$ROOT/models/yolov8n.pt" device:="${2:-cpu}"
