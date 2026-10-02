#!/usr/bin/env bash
set -euo pipefail

PX4_DIR="${PX4_DIR:-$HOME/PX4-Autopilot}"
PX4_REF="${PX4_REF:-main}"

sudo apt update
sudo apt install -y git

if [[ ! -d "$PX4_DIR/.git" ]]; then
  git clone https://github.com/PX4/PX4-Autopilot.git --recursive "$PX4_DIR"
else
  git -C "$PX4_DIR" fetch --all --tags
  git -C "$PX4_DIR" submodule update --init --recursive
fi

git -C "$PX4_DIR" checkout "$PX4_REF"
git -C "$PX4_DIR" submodule update --init --recursive

# PX4's supported Ubuntu setup installs the SITL/Gazebo development dependencies.
bash "$PX4_DIR/Tools/setup/ubuntu.sh" --no-nuttx

echo 'PX4 dependencies installed.'
echo 'WSL should be restarted before the first build if the PX4 setup script requests it.'
echo "Then test: cd $PX4_DIR && make px4_sitl gz_x500"
