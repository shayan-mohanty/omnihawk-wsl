# OmniHawk on Windows with WSL2

Follow this guide in order to install and run PX4 + Gazebo camera simulation,
ROS 2, YOLO object detection, and a MAVSDK flight test on your Windows PC.

**Target:** Windows 11, WSL2, Ubuntu 24.04 x86-64, ROS 2 Jazzy,
Gazebo Harmonic, PX4 v1.16.0. CPU inference is the starting point.

**Status:** setup is prepared; full installation and simulation are still being
tested on the PC. Syntax checks passed, which does not verify the full system.
Windows code is on the `wsl-development-stack` branch in [draft PR #1](https://github.com/shayan-mohanty/omnihawk-wsl/pull/1).
Jetson setup is separate in [omnihawk-jetson](https://github.com/shayan-mohanty/omnihawk-jetson).
Isaac Sim is not installed by this guide.

## How to follow this guide

Run commands **one at a time**. Wait for each installation command to finish.
If a command fails, stop and save its error before continuing.
Copy only the contents of code blocks, not a terminal prompt or Markdown link.

You do not need to open script files to run them. Enter the project folder, then
use `bash scripts/wsl/FILE.sh`. The path tells Bash which file to execute.

| Terminal prompt | Where you are | Commands used here |
|---|---|---|
| `PS C:\\Users\\you>` | Windows PowerShell | `wsl ...` |
| `youruser@PC:~$` | Ubuntu Linux | `cd`, `sudo apt`, `git`, `bash` |
| `root@PC:...#` | Linux administrator | Password recovery only |

Running `wsl -d Ubuntu-24.04` in PowerShell switches that same tab into Linux.
Run all later Bash commands there. Use `exit` to return to PowerShell.

## 1. Install or check Ubuntu — Windows PowerShell

Open PowerShell from the Windows Start menu:

```powershell
wsl --list --verbose
```

Check that `Ubuntu-24.04` exists and its VERSION is `2`.
“Stopped” just means it is not currently running. Docker may stay stopped.
If Ubuntu-24.04 is already installed with VERSION 2, skip installation.

Otherwise, open **Administrator PowerShell** and run:

```powershell
wsl --install -d Ubuntu-24.04
```

Restart Windows if requested. Open Ubuntu-24.04 and create a Linux username and
password. This account is separate from your Windows and GitHub accounts.
If the installed distribution is VERSION 1, convert it in PowerShell:

```powershell
wsl --set-version Ubuntu-24.04 2
```

Keep WSL and your Windows graphics driver current. To update WSL in PowerShell:

```powershell
wsl --update
```

## 2. Open the correct Ubuntu — start in Windows PowerShell

```powershell
wsl -d Ubuntu-24.04
```

**You are now in Linux.** Run:

```bash
cat /etc/os-release
whoami
cd ~
```

Confirm `VERSION_ID="24.04"`. `whoami` prints your Linux account.
`cd ~` enters your Linux home folder.

Always open this named distribution: plain `wsl` may open another Ubuntu.
Each distribution and user has its own installed tools and saved GitHub login.

## 3. Install Git and sign in — Ubuntu, home folder

```bash
sudo apt update
sudo apt install -y git gh
gh auth status
```

`apt update` refreshes the software list. The next command installs Git and
GitHub CLI (`gh`). `sudo` requests administrator permission.
Linux password typing is invisible, including asterisks.

If `gh auth status` confirms the account with access to this private repo is
logged in, skip the next login command. Otherwise:

```bash
gh auth login --hostname github.com --git-protocol https --web
```

Choose GitHub.com, HTTPS, Yes to authenticate Git, and Login with a web browser
if prompted. Keep the Ubuntu command running. Open
[github.com/login/device](https://github.com/login/device) in your Windows
browser, enter the new one-time code, and complete authorization.
A failure to open the browser automatically is okay: open the URL manually.
Wait until Ubuntu says “Logged in as…”, then run:

```bash
gh auth status
gh auth setup-git
```

The last command lets Git use your saved sign-in. A successful login survives
closing the terminal for this Linux account and distribution.
Keep codes and tokens private. See troubleshooting below if login times out.

## 4. Download the project and enter its folder — Ubuntu

**First installation only:**

```bash
git clone --branch wsl-development-stack https://github.com/shayan-mohanty/omnihawk-wsl.git ~/omnihawk-wsl
cd ~/omnihawk-wsl
ls
```

Git downloads our code into your Linux home. `cd` enters that folder.
`ls` should show `README.md`, `requirements.txt`, `ros2_ws`, and `scripts`.

**If you already cloned the project, do not clone again.** Instead:

```bash
cd ~/omnihawk-wsl
git branch --show-current
git pull --ff-only
```

Confirm the branch is `wsl-development-stack`. Pull downloads later changes.
“Already up to date” means you have the latest files.
The flag is spelled `--ff-only`, with one hyphen between `ff` and `only`.
If a different branch appears or pull fails, stop and resolve it first.

Keep the project on the Linux filesystem under `~/omnihawk-wsl`, not
`/mnt/c`. If using a local snapshot, copy it into your Linux home first.

## 5. Install the stack — Ubuntu, project folder

```bash
cd ~/omnihawk-wsl
bash scripts/wsl/01_setup.sh
```

`bash` executes `01_setup.sh` inside the project's `scripts/wsl` folder.
This script checks Ubuntu/WSL compatibility, installs basic tools, adds the
ROS package source, installs ROS and vision tools, downloads PX4 v1.16.0,
runs PX4's installer including Gazebo Harmonic, creates our Python environment,
installs requirements, and builds PX4.

**It also runs `02_build.sh` automatically.** That script builds the ROS
perception package from `ros2_ws/src`.
You do not need to run step 02 separately during the first setup.

Expect substantial downloads and compilation. Wait until the script returns
to your `$` prompt. On success it prints `Setup complete...`.
Although that message suggests running simulation, finish steps 6 and 7 first.
If it fails or never reaches that message, stop and save the last 20–30 lines.

## 6. Download the YOLO model — Ubuntu, project folder

Only after step 5 succeeds:

```bash
bash scripts/wsl/03_download_model.sh
```

Downloads `yolov8n.pt` into the generated `models` folder.
This file contains the trained detection model; it is separate from our source code.
Wait for the command to return without an error.

## 7. Check installation — Ubuntu, project folder

```bash
bash scripts/wsl/doctor.sh
```

Checks ROS bridge availability, Gazebo version, Python imports, display settings,
and CUDA availability. Resolve errors before continuing.
`CUDA available: False` is acceptable for the CPU baseline.
A successful doctor check does not prove camera inference or flight works.

**Installation order:**

```text
01_setup.sh
  └─ automatically runs 02_build.sh
03_download_model.sh
doctor.sh
then start the simulation below
```

## 8. Start PX4 and Gazebo — Ubuntu terminal 1

In this terminal:

```bash
cd ~/omnihawk-wsl
bash scripts/wsl/run_sim.sh
```

Starts the camera-equipped X500 simulation. The wrapper enters
`external/PX4-Autopilot` and runs `make px4_sitl gz_x500_mono_cam`.
Leave terminal 1 running. Wait for PX4 and Gazebo to start before continuing.

## 9. Find the camera and start YOLO — Ubuntu terminal 2

Open a second PowerShell tab, then enter Linux:

```powershell
wsl -d Ubuntu-24.04
```

Now run inside that Ubuntu terminal:

```bash
cd ~/omnihawk-wsl
source /opt/ros/jazzy/setup.bash
gz topic -l
```

`source` loads ROS settings into this terminal. `gz topic -l` lists Gazebo
data topics. Find the camera's image topic and copy its full name.

The following commands contain a **placeholder**: replace
`/actual/image/topic` with the real name from the list. Do not type it literally.

```bash
gz topic -i -t /actual/image/topic
```

Confirm the topic type is `gz.msgs.Image`, then:

```bash
bash scripts/wsl/run_perception.sh /actual/image/topic
```

Starts the Gazebo-to-ROS camera bridge and YOLO on CPU. It loads the ROS
workspace, Python environment, and model automatically.
Leave terminal 2 running. The ROS image topic is `/camera`; YOLO publishes
`/camera/detections` and `/camera/annotated`.

## 10. View the camera — Ubuntu terminal 3

Open another PowerShell tab and run:

```powershell
wsl -d Ubuntu-24.04
```

Inside Ubuntu:

```bash
cd ~/omnihawk-wsl
source /opt/ros/jazzy/setup.bash
ros2 run rqt_image_view rqt_image_view
```

Select `/camera/annotated` in the viewer. Keep it open.
No objects detected can be normal if the scene contains no recognizable objects.

To inspect detection messages while keeping the viewer open, use a **fourth
Ubuntu terminal**, load ROS, and run:

```bash
source /opt/ros/jazzy/setup.bash
ros2 topic echo /camera/detections --once
```

The viewer command occupies terminal 3, so the echo command cannot run there
until the viewer exits.

## 11. Optional square flight — another Ubuntu terminal

Keep simulation running. Open another Ubuntu terminal as in step 9, then:

```bash
cd ~/omnihawk-wsl
.venv/bin/python scripts/wsl/fly_pattern.py --sitl
```

Uses our Python environment to connect to PX4 over UDP 14540, wait for position,
arm, take off, fly four legs, and land. Run only when connected to simulation.
`--sitl` confirms your intent; it does not detect real hardware automatically.
Wait for the flight script to report `Landed`.

## After first installation

Every new Linux terminal starts with its own environment. Use
`wsl -d Ubuntu-24.04` to enter Linux and `cd ~/omnihawk-wsl` to enter the repo.
To use the project again, repeat steps 8–10; model download and full installation
are not needed every time.

To get code updates, use `git pull --ff-only` in the project folder.
After changing or updating the ROS package, rebuild it:

```bash
bash scripts/wsl/02_build.sh
```

For normal shutdown after flight has landed, press Ctrl+C in the perception and
simulation terminals and close the viewer. Stop the programs before updating
or rebuilding. Keep the project in a WSL-aware editor on the Linux filesystem.

Optional NVIDIA inference: after doctor reports CUDA available, pass `0` as the
second argument to `run_perception.sh`. TensorRT engines must be built for this
PC; Jetson engines are not reused.

## Folder and file map

Paths below are relative to `~/omnihawk-wsl`.
Folders marked generated appear after installation and are excluded from Git.

| Folder/file | Purpose | Run it manually? |
|---|---|---|
| `README.md` | This ordered guide | Read it |
| `scripts/windows/check-wsl.ps1` | Displays WSL installation/version | Optional Windows helper before step 1 |
| `scripts/windows/install-wsl.ps1` | Installs Ubuntu-24.04 through WSL | Optional Administrator PowerShell helper instead of the install command |
| `scripts/wsl/common.sh` | Shared paths and compatibility checks | No; other scripts load it |
| `scripts/wsl/01_setup.sh` | Installs and builds the stack | Step 5 |
| `scripts/wsl/02_build.sh` | Builds ROS workspace | Automatic in 01; manual for later rebuilds |
| `scripts/wsl/03_download_model.sh` | Downloads YOLO weights | Step 6 |
| `scripts/wsl/doctor.sh` | Checks installed tools | Step 7 |
| `scripts/wsl/run_sim.sh` | Starts PX4 and Gazebo | Step 8 |
| `scripts/wsl/run_perception.sh` | Starts camera bridge and detection | Step 9 |
| `scripts/wsl/fly_pattern.py` | MAVSDK square-flight test | Optional step 11 |
| `ros2_ws/src/omnihawk_perception/` | ROS package source, launch configuration, and packaging | Built by 02; launched by run_perception |
| `requirements.txt` | Python dependency version ranges | 01 installs it automatically |
| `external/PX4-Autopilot/` (generated) | Downloaded upstream PX4 source and simulation resources | Wrapper scripts handle it |
| `.venv/` (generated) | Project Python environment | Wrapper scripts use it |
| `models/yolov8n.pt` (generated) | Downloaded YOLO weights | Perception loads it |
| `ros2_ws/build`, `install`, `log` (generated) | ROS build outputs and logs | Do not run directly |
| `.github/workflows/` | Automated source syntax checks on GitHub | GitHub runs them |
| `.gitignore`, `.gitattributes` | Git file exclusions and line endings | Do not run |

PX4 and Gazebo are upstream dependencies downloaded during setup; this repo
contains our installation, launch, perception, and flight code.

## Troubleshooting

### Forgotten Linux password

From **Windows PowerShell**:

```powershell
wsl -d Ubuntu-24.04 -u root
```

Inside that root Linux terminal:

```bash
ls /home
passwd YOUR_USERNAME
exit
```

Replace YOUR_USERNAME with your actual Linux username, set a new password,
then return to your normal Ubuntu account and retry sudo.
[Microsoft recovery instructions](https://learn.microsoft.com/en-us/windows/wsl/setup/environment).

### GitHub login or clone failed

- If a login code expires, generate a new code and complete browser authorization promptly.
  Keep the original terminal login command running until it confirms completion.
- `gh auth status` verifies the saved login; browser approval alone is insufficient.
- GitHub account passwords do not work at Git's HTTPS password prompt.
  Press Ctrl+C to cancel cloning, then check login and run `gh auth setup-git`.
- If `gh` is missing in a new terminal, confirm you opened Ubuntu-24.04 and check
  `whoami`; packages and credentials belong to a specific distribution and user.
- If the destination folder already exists, inspect it instead of cloning over
  it or deleting it. A successful existing clone can be updated with git pull.

### Installation failed

Stop before the next step. Save the command and last 20–30 output lines.
Do not assume an error is harmless merely because an earlier package installed.
Existing PX4 checkouts at other refs are rejected without changing them.
PX4's upstream installer uses `--break-system-packages` for its own Python build
dependencies on Ubuntu 24.04. Our application packages live in .venv with system
ROS packages accessible. Exact Python versions remain to be pinned after validation.

## Validation and provenance

Checks passed for source syntax and package XML. Verification remaining:
dependency installation, PX4 build, WSLg rendering, camera bridge, YOLO inference,
and MAVSDK flight. Doctor alone does not verify these.
The Codex execution session previously returned WSL E_ACCESSDENIED; PC validation
is being performed from the user's Ubuntu terminal.

Perception and flight sources are adapted from omnihawk-jetson commit
3129113736c523438a1eccace06227f8a1e5b5ae, retaining inherited package attribution.
No new repository license is asserted. PX4 v1.16.0 contains the
4010_gz_x500_mono_cam airframe.

- [PX4 WSL setup](https://docs.px4.io/main/en/dev_setup/dev_env_windows_wsl)
- [Gazebo / ROS version pairing](https://gazebosim.org/docs/harmonic/ros_installation/)
- [ROS 2 Jazzy installation](https://docs.ros.org/en/jazzy/Installation/Ubuntu-Install-Debs.html)
- [GitHub CLI login](https://cli.github.com/manual/gh_auth_login)
