#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
set +u
source /opt/ros/jazzy/setup.bash
set -u
cd "$PX4_DIR"
exec make px4_sitl gz_x500_mono_cam
