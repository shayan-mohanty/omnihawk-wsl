# OmniHawk Windows / WSL2

PC development port of the OmniHawk simulation and perception stack.
Target: Windows 11 + WSL2 + Ubuntu 24.04 x86-64, ROS 2 Jazzy, Gazebo Harmonic,
PX4 v1.16.0 SITL, MAVSDK, and Ultralytics YOLO.

The Jetson deployment stays in [omnihawk-jetson](https://github.com/shayan-mohanty/omnihawk-jetson).
This repo uses desktop Python packages and .pt models. It does not install JetPack or copy Jetson TensorRT engines.
CPU inference is the default; NVIDIA CUDA inference is optional after GPU validation.
Isaac Sim is a separate future integration, not installed by these scripts.

## Windows preparation

In your regular PowerShell terminal:

```powershell
wsl --list --verbose
```

If Ubuntu 24.04 is absent, run in Administrator PowerShell:

```powershell
wsl --install -d Ubuntu-24.04
```

Restart if requested. Open Ubuntu 24.04 and create your Linux account.
Confirm its WSL VERSION is 2. If needed: `wsl --set-version Ubuntu-24.04 2`.
Install a current Windows graphics driver and keep WSL updated via `wsl --update`.

## Open the correct Linux terminal

In Windows PowerShell (prompt starts with `PS C:\\`), run:

```powershell
wsl -d Ubuntu-24.04
```

This switches the same terminal tab into Ubuntu. A prompt like
`youruser@PC:~# OmniHawk Windows / WSL2

PC development port of the OmniHawk simulation and perception stack.
Target: Windows 11 + WSL2 + Ubuntu 24.04 x86-64, ROS 2 Jazzy, Gazebo Harmonic,
PX4 v1.16.0 SITL, MAVSDK, and Ultralytics YOLO.

The Jetson deployment stays in [omnihawk-jetson](https://github.com/shayan-mohanty/omnihawk-jetson).
This repo uses desktop Python packages and .pt models. It does not install JetPack or copy Jetson TensorRT engines.
CPU inference is the default; NVIDIA CUDA inference is optional after GPU validation.
Isaac Sim is a separate future integration, not installed by these scripts.

## Windows preparation

In your regular PowerShell terminal:

```powershell
wsl --list --verbose
```

If Ubuntu 24.04 is absent, run in Administrator PowerShell:

```powershell
wsl --install -d Ubuntu-24.04
```

Restart if requested. Open Ubuntu 24.04 and create your Linux account.
Confirm its WSL VERSION is 2. If needed: `wsl --set-version Ubuntu-24.04 2`.
Install a current Windows graphics driver and keep WSL updated via `wsl --update`.

 means subsequent commands run in Linux.
Run the following **inside Ubuntu**:

```bash
cat /etc/os-release
whoami
```

Confirm VERSION_ID is 24.04. Use this named distribution every time: plain
`wsl` opens whichever distribution is default, which may be another Ubuntu.
Each distribution and Linux user has separate packages and GitHub credentials.
“Stopped” in the WSL list simply means the distribution is not running.
Use `exit` to return from Ubuntu to PowerShell.

## Sign in to GitHub inside Ubuntu

Run each command separately and stop if one fails:

```bash
sudo apt update
sudo apt install -y git gh
gh auth status
```

If already logged in to the account that has repository access, skip login.
Otherwise run:

```bash
gh auth login --hostname github.com --git-protocol https --web
```

Select GitHub.com, HTTPS, Yes to authenticate Git, and Login with a web browser
if prompted. Keep this terminal command running. Enter the newly displayed
one-time code at https://github.com/login/device in your Windows browser,
then complete authorization. If Ubuntu cannot open a browser, opening that
URL manually is enough. Wait for the terminal to confirm “Logged in as…”.

If login times out, start a new login and use its new code promptly.
Browser approval alone does not prove the terminal saved the login.
Confirm with:

```bash
gh auth status
gh auth setup-git
```

Closing a terminal after a successful login preserves it for that Linux user
in that distribution. If `gh` is missing or login disappears in a new tab,
check the distribution and `whoami` before authenticating again.
GitHub account passwords do not work at Git's HTTPS password prompt.
If cloning asks for a username despite this setup, press Ctrl+C and verify
`gh auth status`; typing commands at a Username prompt treats them as usernames.
Keep tokens and one-time sign-in codes private.

## Linux basics and password recovery

- `cd ~` moves to your Linux home folder; `~` means your home.
- `ls` lists files in the current folder.
- `cat FILE` displays a file's contents.
- `sudo` runs a command with administrator privileges.
- `apt update` refreshes package lists; `apt install` installs software.
- Password entry shows no characters or asterisks; this is normal.

If you forget your Linux sudo password, open **Windows PowerShell** and run:

```powershell
wsl -d Ubuntu-24.04 -u root
```

Then run **inside the root Linux terminal**:

```bash
ls /home
passwd YOUR_USERNAME
exit
```

Replace YOUR_USERNAME with your own Linux username from /home, enter a new
password twice, and return to your regular Ubuntu account.
This changes your Linux password, not your GitHub password.
[Microsoft WSL recovery guide](https://learn.microsoft.com/en-us/windows/wsl/setup/environment).

## Put the project on the Linux filesystem

After completing GitHub sign-in above, run these in Ubuntu:

```bash
git clone --branch wsl-development-stack https://github.com/shayan-mohanty/omnihawk-wsl.git ~/omnihawk-wsl
cd ~/omnihawk-wsl
bash scripts/wsl/01_setup.sh
bash scripts/wsl/03_download_model.sh
bash scripts/wsl/doctor.sh
```

If using the provided local snapshot instead, copy it from Windows into
`~/omnihawk-wsl` before running setup. Do not build under `/mnt/c`.
Setup needs sudo and internet, downloads substantial dependencies, and compiles PX4.
Existing PX4 checkouts at other refs are rejected without switching them.
PX4's upstream setup script installs Python build dependencies using its own
`--break-system-packages` behavior on Ubuntu 24.04; application dependencies live in .venv.
Python dependencies have version ranges pending a verified installation lock.

## Run

Terminal 1 in Ubuntu:

```bash
cd ~/omnihawk-wsl
bash scripts/wsl/run_sim.sh
```

Terminal 2: discover the actual camera image topic (do not guess a topic):

```bash
source /opt/ros/jazzy/setup.bash
gz topic -l
# Confirm a candidate topic has gz.msgs.Image:
gz topic -i -t /actual/image/topic
cd ~/omnihawk-wsl
bash scripts/wsl/run_perception.sh /actual/image/topic
```

Terminal 3, view images and detections:

```bash
source /opt/ros/jazzy/setup.bash
ros2 run rqt_image_view rqt_image_view
# Select /camera/annotated
ros2 topic echo /camera/detections --once
```

Optional square flight, only with PX4 SITL:

```bash
cd ~/omnihawk-wsl
.venv/bin/python scripts/wsl/fly_pattern.py --sitl
```

The flight script connects to UDP 14540, arms, takes off, flies four legs and lands.
The flag is a user confirmation, not automatic hardware detection.
Optional CUDA: check `doctor.sh` reports CUDA available, then pass `0` as the
second argument to `run_perception.sh`. TensorRT export would need a new local
engine built for this PC; it is not part of baseline setup.

## Development

Edit this repo through a WSL-aware editor on Windows, keeping sources in
`~/omnihawk-wsl`. Rebuild ROS after package changes:
`bash scripts/wsl/02_build.sh`.
The camera subscriber uses sensor-data QoS; launch parameters carry explicit types.
ROS console scripts install under the package's lib directory via setup.cfg.

## Validation status

Python syntax and package XML checked on Windows; Bash checks are provided in GitHub Actions. Installation and end-to-end execution
are not yet verified. The current Codex execution session cannot access WSL
(`Wsl/EnumerateDistros/Service/E_ACCESSDENIED`).
Verification remaining: dependency install, PX4 build, WSLg rendering, camera
bridge, YOLO inference, and MAVSDK square flight.
Run doctor and then the three-terminal workflow; do not treat a successful setup
message alone as end-to-end validation.

## Provenance and references

Perception and flight sources are adapted from omnihawk-jetson commit
3129113736c523438a1eccace06227f8a1e5b5ae; inherited package attribution is retained.
No new repository license is asserted.
PX4 v1.16.0 includes the 4010_gz_x500_mono_cam airframe and uses Gazebo Harmonic.

- [PX4 WSL setup](https://docs.px4.io/main/en/dev_setup/dev_env_windows_wsl)
- [Gazebo / ROS version pairing](https://gazebosim.org/docs/harmonic/ros_installation/)
- [ROS 2 Jazzy installation](https://docs.ros.org/en/jazzy/Installation/Ubuntu-Install-Debs.html)
