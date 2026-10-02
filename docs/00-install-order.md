# OmniHawk WSL Installation Order

This repository is the **Windows + WSL2 x86-64** environment. It is deliberately separate from `omnihawk-jetson`; never copy JetPack/ARM64 wheels or Jetson setup commands into these scripts.

## Target

- Windows 10/11 with WSL2
- Ubuntu 22.04 inside WSL
- x86-64
- ROS 2 Humble
- PX4 SITL + Gazebo Harmonic
- MAVSDK
- Ultralytics YOLO
- Optional NVIDIA GPU acceleration when the host GPU is exposed to WSL

## Run order

```bash
cd ~/omnihawk-wsl
bash scripts/wsl/01_verify_wsl.sh
bash scripts/wsl/02_install_ros2_humble.sh
bash scripts/wsl/03_build_px4_sitl.sh
bash scripts/wsl/04_install_python_deps.sh
bash scripts/wsl/05_verify_yolo_gpu.sh
bash scripts/wsl/06_build_ros_workspace.sh
```

Do not skip ahead merely because a dependency appears to exist already. Each script is also a reproducibility check.

### Step 01
Verifies WSL2, Ubuntu 22.04, x86-64, filesystem location, and NVIDIA visibility.

### Step 02
Installs ROS 2 Humble and the Gazebo Harmonic ROS bridge. PX4's current ROS 2 documentation specifically uses Humble on Ubuntu 22.04 and `ros-humble-ros-gzharmonic` for Gazebo Harmonic.

### Step 03
Clones PX4 into the WSL-native home filesystem and runs PX4's own supported Ubuntu dependency installer. PX4 officially supports WSL2 and warns against developing from `/mnt/c/...` because of performance/permission issues.

### Step 04
Creates a WSL x86-64 Python virtual environment and installs portable MAVSDK/Ultralytics dependencies. It deliberately contains no Jetson PyTorch wheel.

### Step 05
Validates the NVIDIA/PyTorch CUDA path. It does not pretend a CUDA-enabled PyTorch build is correct until it is actually installed and tested on the host.

### Step 06
Builds the ROS workspace once the reviewed portable ROS package has been added to this repository.

## Validation rule

A component is not marked verified merely because its install command completed. We test each layer on the actual WSL environment and then record fixes in GitHub.
