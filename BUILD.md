# Building and Packaging the Linuxfabrik Monitoring Plugins

Target audience: the release manager who cuts the next Linuxfabrik Monitoring
Plugins release, and contributors who need to reproduce a build locally.

Outputs per release:

* Windows (ZIP of compiled plugins, and a signed MSI) for x86_64 only.
  Published to <https://download.linuxfabrik.ch/monitoring-plugins/>.
* Source-only zip for all operating systems. Published to the download
  server as well.

The RPM and DEB packages for Linux are built in
[Linuxfabrik/packaging](https://github.com/Linuxfabrik/packaging) and
published to the Linuxfabrik repository at <https://repo.linuxfabrik.ch/>.
Their build recipes and the supported distributions are documented there.

The Windows build is manually triggered via GitHub Actions
`workflow_dispatch`. There is no automatic build on push or tag.


## Overview

| Platform | Arch    | GitHub workflow                  | Runner             | Outputs                | Signed            |
| -------- | ------- | -------------------------------- | ------------------ | ---------------------- | ----------------- |
| Windows  | x86_64  | `lf-build-windows-x86_64.yml`    | `windows-2025`     | `.zip`, `.msi`         | yes (SignPath.io) |

Windows aarch64 is not built today.


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
│   ├── verify-version.sh                # checkout must contain vLFMP_VERSION
│   └── compile-one.sh                   # python3 -m nuitka --standalone
├── SignPath submit-signing-request      # signs the compiled ZIP
├── create-wxs.sh                        # emits lfmp.wxs
├── wix.exe build                        # .wxs -> .msi
└── SignPath submit-signing-request      # signs the MSI
```

Workflow inputs: `compile-plugins` (optional, space-separated allowlist;
empty means all plugins), `version`, `package-iteration`.

`compile-multiple.sh` runs `verify-version.sh` first, so a checkout that
predates or diverges from the `vLFMP_VERSION` tag fails the build instead of
compiling outdated code under a newer version label. Set
`LFMP_SKIP_VERSION_CHECK=1` to bypass this for an intentional build of an
untagged development checkout.


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
* `python3 -m pip install --require-hashes --requirement lockfiles/py313-windows/requirements.txt`
  from the monitoring-plugins repository root. The `pyXX` directory under
  `lockfiles/` matches the Python version the Windows build is pinned to
  (3.13 today).
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
build. It runs `verify-version.sh` first, so export `LFMP_VERSION` (with the
matching `vLFMP_VERSION` tag reachable from HEAD) or prefix the call with
`LFMP_SKIP_VERSION_CHECK=1`. The MSI and the signing steps have no local
fallback, so stop there.


## Appendix: Packaging Decisions


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


### Why Python 3.13 (Not 3.14) on Windows

Nuitka 4.0 (current stable) lists Python 3.14 as experimental and explicitly
not production-ready. Official support covers Python 3.4 through 3.13. We
build with `--standalone --msvc=latest`, both paths where partial 3.14 support
in Nuitka tends to surface first. Until Nuitka declares 3.14 stable, the
Windows workflow stays pinned to 3.13.

This has no security impact: `actions/setup-python@v6` resolves
`python-version: '3.13'` to the latest 3.13.x patch release at build time,
so each release picks up the bundled OpenSSL update from upstream CPython.
