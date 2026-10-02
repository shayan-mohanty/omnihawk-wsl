#!/usr/bin/env bash
set -euo pipefail

. /etc/os-release
[[ "${VERSION_ID:-}" == "22.04" ]] || { echo 'Ubuntu 22.04 is required.' >&2; exit 1; }

sudo apt update
sudo apt install -y locales software-properties-common curl gnupg lsb-release
sudo locale-gen en_US en_US.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
export LANG=en_US.UTF-8
sudo add-apt-repository universe -y

sudo curl -fsSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo "$UBUNTU_CODENAME") main" | sudo tee /etc/apt/sources.list.d/ros2.list >/dev/null

sudo apt update
sudo apt install -y ros-humble-desktop ros-dev-tools python3-colcon-common-extensions python3-rosdep ros-humble-ros-gzharmonic

if [[ ! -e /etc/ros/rosdep/sources.list.d/20-default.list ]]; then
  sudo rosdep init
fi
rosdep update

echo 'ROS 2 Humble + Gazebo Harmonic bridge installed.'
echo 'Run: source /opt/ros/humble/setup.bash'
