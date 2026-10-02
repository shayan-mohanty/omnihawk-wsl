#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
WS="$REPO_ROOT/ros2_ws"

[[ -d "$WS/src" ]] || { echo "ROS workspace not present yet: $WS/src" >&2; echo 'Bring the reviewed portable OmniHawk ROS package into this repo before running step 06.' >&2; exit 1; }

source /opt/ros/humble/setup.bash
cd "$WS"
rosdep install --from-paths src --ignore-src -r -y
colcon build --symlink-install

echo "Build complete. Run: source $WS/install/setup.bash"
