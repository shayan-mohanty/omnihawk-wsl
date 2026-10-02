#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
sudo apt-get update
sudo apt-get install -y curl gnupg software-properties-common locales git python3-venv python3-pip
sudo locale-gen en_US.UTF-8
export LANG=en_US.UTF-8
sudo add-apt-repository -y universe
# Use the upstream ROS apt-source package (includes repository signing keys).
ROS_APT_VERSION="$(curl -fsSL https://api.github.com/repos/ros-infrastructure/ros-apt-source/releases/latest | python3 -c 'import json,sys; print(json.load(sys.stdin)["tag_name"])')"
ROS_DEB="$(mktemp --suffix=.deb)"
trap 'rm -f "$ROS_DEB"' EXIT
curl -fL "https://github.com/ros-infrastructure/ros-apt-source/releases/download/${ROS_APT_VERSION}/ros2-apt-source_${ROS_APT_VERSION}.noble_all.deb" -o "$ROS_DEB"
sudo dpkg -i "$ROS_DEB"
sudo apt-get update
sudo apt-get install -y ros-jazzy-ros-base ros-jazzy-ros-gz ros-jazzy-cv-bridge ros-jazzy-vision-msgs ros-jazzy-rqt-image-view python3-colcon-common-extensions python3-rosdep python3-opencv
mkdir -p "$ROOT/external"
if [[ ! -d "$PX4_DIR/.git" ]]; then
  git clone --branch v1.16.0 --recursive https://github.com/PX4/PX4-Autopilot.git "$PX4_DIR"
fi
[[ "$(git -C "$PX4_DIR" describe --tags --exact-match)" == v1.16.0 ]] || { echo "PX4 must be at v1.16.0; existing checkout was not changed."; exit 1; }
git -C "$PX4_DIR" submodule update --init --recursive
bash "$PX4_DIR/Tools/setup/ubuntu.sh" --no-nuttx
python3 -m venv --system-site-packages "$ROOT/.venv"
"$ROOT/.venv/bin/python" -m pip install -r "$ROOT/requirements.txt"
# PX4 setup installs its Python dependencies separately; ROS uses system Python.
make -C "$PX4_DIR" px4_sitl_default
bash "$ROOT/scripts/wsl/02_build.sh"
echo "Setup complete. Run bash scripts/wsl/run_sim.sh"
