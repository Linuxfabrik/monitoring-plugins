# Building and Packaging the Linuxfabrik Monitoring Plugins

Target audience: the release manager who cuts the next Linuxfabrik Monitoring
Plugins release, and contributors who need to reproduce a build locally.

Outputs per release:

* Linux (RPM and DEB) for x86_64 and aarch64, unsigned. Published to
  <https://repo.linuxfabrik.ch/monitoring-plugins/>.
* Windows (ZIP of compiled plugins, and a signed MSI) for x86_64 only.
  Published to <https://download.linuxfabrik.ch/monitoring-plugins/>.
* Source-only zip for all operating systems. Published to the download
  server as well.

All three platform builds are manually triggered via GitHub Actions
`workflow_dispatch`. There is no automatic build on push or tag.


## Overview

| Platform | Arch    | GitHub workflow                  | Runner             | Outputs                | Signed            |
| -------- | ------- | -------------------------------- | ------------------ | ---------------------- | ----------------- |
| Linux    | x86_64  | `lf-build-linux-x86_64.yml`      | `ubuntu-24.04`     | `.rpm`, `.deb`         | no                |
| Linux    | aarch64 | `lf-build-linux-aarch64.yml`     | `ubuntu-24.04-arm` | `.rpm`, `.deb`         | no                |
| Windows  | x86_64  | `lf-build-windows-x86_64.yml`    | `windows-2025`     | `.zip`, `.msi`         | yes (SignPath.io) |

Windows aarch64 is not built today.


## Linux Packages


### How it is built on GitHub

The two Linux workflows run the same build chain on different runner types.
Each one loops over a matrix of target distributions and builds one podman
container per distro, then produces the native `.rpm` or `.deb` inside that
container:

```text
lf-build-linux-x86_64.yml  /  lf-build-linux-aarch64.yml
├── debug.sh                            # env dump
├── install-podman.sh                   # installs podman on the runner
└── matrix-package.sh                   # one container per target distro
    └── create-package.sh               # branches on $LFMP_TARGET_DISTRO
        ├── create-src-tarball.sh       # upstream source archive
        ├── create-vendor-tarball.sh    # pinned third-party deps
        ├── create-deb.sh               # Debian/Ubuntu target
        └── create-rpm.sh               # RHEL/SLE target
```

Every workflow run takes three inputs: `target-distros` (space-separated list;
default is every supported distribution), `version` (e.g. `2.2.1`),
`package-iteration` (e.g. `1`).

The shared `monitoring-plugins` source tarball and `vendor.tar.gz` (pip-downloaded,
hash-pinned third-party wheels) are produced once per workflow run.
`create-rpm.sh` and `create-deb.sh` then build a venv under
`/usr/lib64/linuxfabrik-monitoring-plugins/venv/` inside the container and
rewrite plugin shebangs to point at that venv's `python`, so the final
package is self-contained.


### Reproducing a Release Build Locally

For cutting a release by hand or for debugging a specific distro build, use
an **Ubuntu 24.04 LTS** host. This matches the `ubuntu-24.04` GitHub runner
one-to-one, which is the environment the build scripts are tested against.
`build/install-podman.sh` uses `apt` to install podman, so other Linux
families fail there without manual adjustments. Building the packages
themselves is distro-agnostic (every package is produced inside its own
target container), but the orchestrating host should match.

Set the same environment variables the workflow uses and call
`matrix-package.sh` directly:

```bash
cat > env-file << 'EOF'
# User input on GitHub:
export LFMP_ARCH=x86_64                                   # or "aarch64" on ARM64
export LFMP_VERSION=2.2.1
export LFMP_PACKAGE_ITERATION=1
export LFMP_TARGET_DISTROS="debian13 rocky10"             # subset of the supported list

# Constants (absolute paths):
export LFMP_DIR_REPOS=/tmp/lfmp/repos
export LFMP_DIR_REPO_MP=$LFMP_DIR_REPOS/monitoring-plugins
export LFMP_DIR_PACKAGED=/tmp/lfmp/packaged
mkdir -p $LFMP_DIR_REPOS $LFMP_DIR_PACKAGED
EOF

source env-file
```

Supported `LFMP_TARGET_DISTROS` values: `debian11 debian12 debian13 rocky8
rocky9 rocky10 sle15 sle16 ubuntu2004 ubuntu2204 ubuntu2404 ubuntu2604`.

Clone the repository and run the build:

```bash
git clone https://github.com/Linuxfabrik/monitoring-plugins.git $LFMP_DIR_REPO_MP
bash $LFMP_DIR_REPO_MP/build/install-podman.sh
bash $LFMP_DIR_REPO_MP/build/matrix-package.sh
```

From each container's perspective, the Python source code is at
`/repos/monitoring-plugins`.

After the build, the packages directory looks like this:

```text
$LFMP_DIR_PACKAGED
├── debian13/
│   └── linuxfabrik-monitoring-plugins_2.2.1-1_amd64.deb
└── rocky10/
    ├── linuxfabrik-monitoring-plugins-2.2.1-1.el10.x86_64.rpm
    └── linuxfabrik-monitoring-plugins-selinux-2.2.1-1.el10.x86_64.rpm
```


## Windows Binaries and MSI

Windows is built on a single GitHub-hosted `windows-2025` runner with Python
3.13. Every plugin that carries a `.windows` marker file is compiled with
Nuitka (`--standalone`, `--msvc=latest`) into its own directory. The results
are packaged twice: once as a ZIP of the compiled trees, once as an MSI that
installs them under `C:\Program Files\ICINGA2\sbin\linuxfabrik\`. Both
artifacts are signed by SignPath before they leave the runner.


### How it is built on GitHub

```text
lf-build-windows-x86_64.yml
├── debug.sh                             # env dump
├── compile-multiple.sh                  # loops plugins, calls compile-one.sh
│   └── compile-one.sh                   # python3 -m nuitka --standalone
├── SignPath submit-signing-request      # signs the compiled ZIP
├── create-wxs.sh                        # emits lfmp.wxs
├── wix.exe build                        # .wxs -> .msi
└── SignPath submit-signing-request      # signs the MSI
```

Workflow inputs: `compile-plugins` (optional, space-separated allowlist;
empty means all plugins), `version`, `package-iteration`.


### Code Signing

Free code signing is provided by [SignPath.io](https://signpath.io) under
the open-source program, with a certificate issued by the
[SignPath Foundation](https://signpath.org) (thank you).

Signed files are `.dll`, `.exe`, `.pyd` and `.msi`. Two SignPath
`artifact-configuration-slug`s are used:

* `compiled`: the ZIP of Nuitka-built plugin directories.
* `packaged`: the final MSI.

Both use the `release-signing` policy. The SignPath project is
`monitoring-plugins` under organization-id
`35067665-5434-42c5-9fa2-4c750069f161`. The workflow waits for SignPath to
return each signed artifact before proceeding.


### Reproducing a Release Build Locally

Compiling a single plugin on a Windows developer box is supported. Producing
the final MSI locally is not: the workflow drives SignPath, and signing
requires the Linuxfabrik project credentials.

Prerequisites:

* **Git Bash** (the `build/*.sh` scripts assume bash).
* **Python 3.13**, on `PATH` as `python3`.
* **Visual Studio 2022 Build Tools** (supplies MSVC, required by Nuitka
  `--msvc=latest`).
* `python3 -m pip install --upgrade ordered-set Nuitka`.
* `python3 -m pip install --require-hashes --requirement requirements-windows.txt`
  from the monitoring-plugins repository root.
* The plugin must carry a `.windows` marker file. Plugins without it are
  skipped by `compile-one.sh`.

To compile one plugin:

```bash
export LFMP_DIR_REPOS=/c/Users/<you>/lfmp/repos
export LFMP_DIR_COMPILED=/c/Users/<you>/lfmp/compiled
mkdir -p "$LFMP_DIR_COMPILED"
git clone https://github.com/Linuxfabrik/monitoring-plugins.git "$LFMP_DIR_REPOS/monitoring-plugins"

bash "$LFMP_DIR_REPOS/monitoring-plugins/build/compile-one.sh" check-plugins cpu-usage
# result: $LFMP_DIR_COMPILED/check-plugins/cpu-usage/ (unsigned)
```

For a full dry run of the compilation step, call
`compile-multiple.sh` instead; it loops over every plugin the workflow would
build. The MSI and the signing steps have no local fallback, so stop there.


## Appendix: Packaging Decisions


### Why Rocky Linux Instead of Red Hat UBI

According to [Types of container images](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html/building_running_and_managing_containers/assembly_types-of-container-images_building-running-and-managing-containers#assembly_types-of-container-images_building-running-and-managing-containers),
Red Hat Universal Base Images (UBI) are built from a subset of RHEL content.
EPEL is installable because a subset of the CRB repo ships with UBI. If we
need anything outside that subset, we have to buy a subscription or run the
container on a subscribed host. Rocky Linux avoids that constraint and
matches upstream RHEL closely enough for our purposes.


### Why `docker.io/rockylinux/rockylinux` Instead of `docker.io/library/rockylinux`

`docker.io/library/rockylinux` is not updated regularly: the Docker Official
Images program has technical constraints that prevent Rocky Linux from
publishing there. The project-maintained repository at
[docker.io/rockylinux/rockylinux](https://hub.docker.com/r/rockylinux/rockylinux)
is the current source of truth.


### Distro Build Targets

| Target OS    | Build container                                |
| ------------ | ---------------------------------------------- |
| Debian 11    | `docker.io/library/debian:11`                  |
| Debian 12    | `docker.io/library/debian:12`                  |
| Debian 13    | `docker.io/library/debian:13`                  |
| RHEL 8       | `docker.io/rockylinux/rockylinux:8`            |
| RHEL 9       | `docker.io/rockylinux/rockylinux:9`            |
| RHEL 10      | `docker.io/rockylinux/rockylinux:10`           |
| SLE 15       | `registry.suse.com/suse/sle15:15.5`            |
| SLE 16       | `registry.suse.com/bci/bci-base:16.0`          |
| Ubuntu 20.04 | `docker.io/library/ubuntu:20.04`               |
| Ubuntu 22.04 | `docker.io/library/ubuntu:22.04`               |
| Ubuntu 24.04 | `docker.io/library/ubuntu:24.04`               |
| Ubuntu 26.04 | `docker.io/library/ubuntu:26.04`               |

The SLE 15 package requires at least openSUSE Leap 15.5 or SLES 15 Service
Pack 5 on the target host.


### Why Nuitka Instead of PyInstaller (Windows)

Benchmark, December 2024, compiling `disk-usage` with each tool and running
it 500 times:

| Platform    | Python | Build tool        | Mode           | Size (MB) | 500 runs (s) | VirusTotal |
| ----------- | ------ | ----------------- | -------------- | --------- | ------------ | ---------- |
| Rocky 8     | 3.9    | Nuitka            | `--standalone` | 19.7      | 15.706       |            |
| Rocky 8     | 3.9    | PyInstaller       | `--onedir`     | 13.7      | 19.392       |            |
| Rocky 8     | 3.9    | Nuitka            | `--onefile`    |  7.9      | 33.339       |            |
| Rocky 8     | 3.9    | PyInstaller       | `--onefile`    |  6.4      | 45.838       |            |
| WinSrv 2022 | 3.12   | Nuitka (msvc)     | `--standalone` | 22.3      | 31.560       |  2/71      |
| WinSrv 2022 | 3.12   | Nuitka (gcc)      | `--standalone` | 23.4      | 29.570       |  4/72      |
| WinSrv 2022 | 3.12   | PyInstaller       | `--onedir`     | 16.7      | 51.476       | 13/71      |
| WinSrv 2022 | 3.12   | Nuitka (msvc)     | `--onefile`    |  6.67     | 253.006      | 15/72      |
| WinSrv 2022 | 3.12   | Nuitka (gcc)      | `--onefile`    |  6.83     | 243.167      | 24/71      |
| WinSrv 2022 | 3.12   | PyInstaller       | `--onefile`    | 17.1      | 462.180      |  7/72      |

Takeaways:

* **Nuitka `--standalone` is the fastest runtime option on both platforms**
  (1.2x-1.7x over PyInstaller `--onedir`), at the cost of 30-45% more
  on-disk size.
* **Onefile builds pay a per-run self-extraction tax** that makes them 3x
  to 10x slower than their onedir counterparts. For a plugin that runs
  every 10-60 seconds, this is disqualifying.
* **On Windows, Nuitka `--standalone` with MSVC has the lowest Windows
  Defender / VirusTotal false-positive rate** we measured (2/71). gcc is
  close behind (4/72). Onefile builds are flagged noticeably more often.

The benchmark has not been re-run against Python 3.13 (our current build
target); ratios there may have shifted.


