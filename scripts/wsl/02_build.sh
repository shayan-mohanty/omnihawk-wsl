#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
set +u
source /opt/ros/jazzy/setup.bash
set -u
cd "$ROOT/ros2_ws"
/usr/bin/python3 -m colcon build --symlink-install
