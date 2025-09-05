# Compile and Package the Linuxfabrik Monitoring Plugins

On Linux (RHEL, Debian) the Linuxfabrik Monitoring Plugins are packaged directly as Python source code including required dependencies in the native package formats. The Linux packages therefore depend on the system Python installation.

For Windows we compile and package (= "build") using Nuitka on GitHub runners. Compiling the Linuxfabrik Monitoring Plugins allows you to completely avoid a separate Python installation on target systems.

With this manual, plugin packages can be created on GitHub runners (Linux, Windows) or a self-hosted Ubuntu VM (which is compatible to the GitHub runner; for Linux only).


## Call Graphs

The two call graphs show how the [build scripts](https://github.com/Linuxfabrik/monitoring-plugins/tree/main/build) are wired together when they're driven by the GitHub runner workflows and how you'd stitch them together on a standalone Ubuntu host.

```text
GitHub Runners
├── Linux Workflow (lf-build-linux-*.yml)
│   ├── debug.sh                            # just dumps env & uname
│   ├── install-podman.sh                   # install Podman locally
│   └── matrix-package.sh                   # builds a container per target-distro
│       └── create-package.sh               # branches on $LFMP_TARGET_DISTRO
│           ├── create-src-tarball.sh       # upstream source archive
│           ├── create-vendor-tarball.sh    # 3rd-party deps
│           ├── create-deb.sh               # for Debian/Ubuntu distros
│           └── create-rpm.sh               # for RHEL distros
└── Windows Workflow (lf-build-windows-x86_64.yml)
    ├── compile-multiple.sh
    │   └── compile-one.sh
    ├── create-wxs.sh
    └── wix.exe build                       # produces the .msi from the .wxs

Standalone Ubuntu
├── install-podman.sh
└── matrix-package.sh
    └── create-package.sh
        ├── create-src-tarball.sh
        ├── create-vendor-tarball.sh
        ├── create-deb.sh
        └── create-rpm.sh
```


## Build for Linux

The following steps describe the **manual package building process on an Ubuntu 24.04 LTS host**. The same steps have been automated using GitHub actions. See the [.github/workflows](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/.github/workflows/) as well as the [build](https://github.com/Linuxfabrik/monitoring-plugins/tree/main/build) folder for details.

To be able to perform the same steps on a local Ubuntu host as well as on a GitHub runner, we decided to minimize the use of GitHub actions for the Linux build process (and therefore use some build scripts), and maximize the use of GitHub actions on Windows. The build scripts are written in bash and make heavy use of environment variables to be compliant with the GitHub runners.

To build on Linux, first set environment variables for (absolute) paths, versions etc.:

```bash
cat > env-file << 'EOF'
# ---
# User input on GitHub:
export LFMP_ARCH=x86_64                                   # or "aarch64" if running on ARM64
export LFMP_VERSION=1.4.0
export LFMP_PACKAGE_ITERATION=7
export LFMP_TARGET_DISTROS="debian13 rocky10"              # "debian11 debian12 debian13 rocky8 rocky9 rocky10 ubuntu2004 ubuntu2204 ubuntu2404"

# ---
# Constants
# use absolute paths here
export LFMP_DIR_REPOS=/tmp/lfmp/repos
export LFMP_DIR_REPO_MP=$LFMP_DIR_REPOS/monitoring-plugins
export LFMP_DIR_PACKAGED=/tmp/lfmp/packaged
mkdir -p $LFMP_DIR_REPOS
mkdir -p $LFMP_DIR_PACKAGED
EOF
```

```bash
source env-file
```

The paths and their meanings:

* repos: the source code / git repositories
* packaged: contains the built packages

Clone the Linuxfabrik Monitoring Plugins from GitHub:

```bash
git clone https://github.com/Linuxfabrik/monitoring-plugins.git $LFMP_DIR_REPO_MP
```

Install podman:

```bash
bash $LFMP_DIR_REPO_MP/build/install-podman.sh
```

From the containers perspective, every container assumes:

* Python source code is located at `/repos/monitoring-plugins`.

For each distro package the plugins including assets:

```bash
bash $LFMP_DIR_REPO_MP/build/matrix-package.sh
```

After that, the packages directory should look like this:

```text
$LFMP_DIR_PACKAGED
├── debian12/
│   └── linuxfabrik-monitoring-plugins_1.4.0-7_amd64.deb
└── rocky9/
    ├── linuxfabrik-monitoring-plugins-1.4.0-7.el9.x86_64.rpm
    └── linuxfabrik-monitoring-plugins-selinux-1.4.0-7.el9.x86_64.rpm
```


## Build for Windows

Packaging for Windows means creating both a zip and an msi file, both of which can be downloaded from <https://download.linuxfabrik.ch/monitoring-plugins/>. Both files are created automatically using the GitHub Actions workflow [Linuxfabrik: Build Windows](https://github.com/Linuxfabrik/monitoring-plugins/actions/workflows/lf-build-windows.yml).

To create the msi file, we use the most recent [WiX Toolset](https://wixtoolset.org/docs/intro/).

Code signing policy:

* Free code signing on Windows provided by [SignPath.io](https://signpath.io), certificate by [SignPath Foundation](https://signpath.org) (thank you for your support!).
* .dll, .exe, .pyd and .msi files are signed.


## Compiling/Packaging - Good to Know

### Platforms

rpm and deb OS packages  
For Red Hat Package Manager (rpm) and Debian-based package files (deb), we build the packages using native packaging tools.

Packaging platform for .rpm and .deb files:

```text
Target OS     ! Packaged on
--------------+-------------------------------------
Debian 11     ! docker.io/library/debian:11
Debian 12     ! docker.io/library/debian:12
Debian 13     ! docker.io/library/debian:13
RHEL 8        ! docker.io/rockylinux/rockylinux:8
RHEL 9        ! docker.io/rockylinux/rockylinux:9
RHEL 10       ! docker.io/rockylinux/rockylinux:10
Ubuntu 20.04  ! docker.io/library/ubuntu:20.04
Ubuntu 22.04  ! docker.io/library/ubuntu:22.04
Ubuntu 24.04  ! docker.io/library/ubuntu:24.04
```

> [!NOTE]
> Why Rocky instead of RHEL's "ubi" container images? According to [Types of container images](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html/building_running_and_managing_containers/assembly_types-of-container-images_building-running-and-managing-containers#assembly_types-of-container-images_building-running-and-managing-containers), Red Hat Universal Base images ("ubi") are built from a subset of the normal Red Hat Enterprise Linux content, so you have access to free dnf repositories for adding and updating software. A subset of the CRB repo is also available, and that's why EPEL is installable. If you need more packages, you will need to purchase a (developer) subscription or run the container on a subscribed host.

> [!NOTE]
> Why `docker.io/rockylinux/rockylinux` instead of `docker.io/library/rockylinux`?  
> `docker.io/library/rockylinux` is currently not updated: "The Docker team curates the Official Images program, and there are currently some technical constraints preventing Rocky Linux from publishing updates here. For the most up-to-date container images, please refer to [the Rocky Linux Docker Hub repository](https://hub.docker.com/r/rockylinux/rockylinux) for now." (from https://hub.docker.com/_/rockylinux#important-note)

Windows Binaries  
Binaries for Windows are compiled on Windows Server 2025 using MSVC 14.


### pyinstaller vs. Nuitka

Why Nuitka? We compiled `disk-usage` - once with `pyinstaller` and once with Nuitka. The results led us to set Nuitka as the standard compiler (sorted by runtime as of 2024-12-23):

```text
! Platform    ! Py   ! Compiler    ! Type    ! Option1       ! Option2       ! Size in MB ! 500 runs (sec) ! VirusTotal !
! ----------- ! ---- ! ----------- ! ------- ! ------------- ! ------------- ! ---------- ! -------------- ! ---------- !
! Rocky 8     !  3.9 ! nuitka      ! mfiles  ! --standalone  !               ! 19.7       !  15.706        !            !
! Rocky 8     !  3.9 ! pyinstaller ! mfiles  ! --onedir      ! --noupx       ! 13.7       !  19.392        !            !
! WinSrv 2022 ! 3.12 ! nuitka+gcc  ! mfiles  ! --standalone  !               ! 23.4       !  29.570        !  4/72      !
! WinSrv 2022 ! 3.12 ! nuitka+msvc ! mfiles  ! --standalone  !               ! 22.3       !  31.560        !  2/71      !
! Rocky 8     !  3.9 ! nuitka      ! onefile ! --onefile     ! --standalone  !  7.9       !  33.339        !            !
! Rocky 8     !  3.9 ! pyinstaller ! onefile ! --onefile     ! --noupx       !  6.4       !  45.838        !            !
! WinSrv 2022 ! 3.12 ! pyinstaller ! mfiles  ! --onedir      !               ! 16.7       !  51.476        ! 13/71      !
! WinSrv 2022 ! 3.12 ! nuitka+gcc  ! onefile ! --onefile     ! --standalone  !  6.83      ! 243.167        ! 24/71      !
! WinSrv 2022 ! 3.12 ! nuitka+msvc ! onefile ! --onefile     ! --standalone  !  6.67      ! 253.006        ! 15/72      !
! WinSrv 2022 ! 3.12 ! pyinstaller ! onefile ! --onefile     !               ! 17.1       ! 462.180        !  7/72      !
```

One-file compilation:

* Plugin will be slower (execution results in higher cpu load), but small.
* Each plugin can be updated separately.
* Best choice where size matters.

Multiple-files compilation:

* Plugin will be fast (3x compared to one file), but big.
* You can't update just one plugin, you have to update all of them at once.

On Windows, using Nuitka in onedir mode, a typical plugin will be 30MB plus 34MB of shared global libs, while in onefile mode it will be 16MB. 100 plugins result in 3.0 GB (onedir) versus 1.6 GB (onefile). We prefer speed over file size, especially on Windows, where plugins compiled with Nuitka in onedir mode are also likely to be killed by Windows Defender with a false positive Trojan:Win32 report. On Windows, gcc vs. msvc really makes no difference.
