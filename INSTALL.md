# Installing the Linuxfabrik Monitoring Plugins Collection

Pick the path that matches your platform. On Linux, the one-liner installer is the fastest
way and the recommended path. On Windows, prefer the MSI installer. The source paths (the
signed source zip, a GitHub source download, or the installer's `--source` / `-Source` mode)
are the supported way to run the **latest state** of the plugins on a production host, for
example when a fix or a plugin is not yet part of a released package or MSI. They also cover
air-gapped hosts and version-pinned setups. Manual repository setup is the underlying
detail behind the one-liner.

For rollouts across many hosts, on Linux and Windows alike, use the LFOps Ansible role; see
[Any Operating System](#any-operating-system) below.

Supported Python: 3.9 or newer. The RPM and DEB packages depend on the system Python, so
the plugins run on every currently supported RHEL, SLE, Debian and Ubuntu release
out of the box. On Windows, the MSI and ZIP ship plugins pre-compiled to native
executables with [Nuitka](https://nuitka.net/) (a Python-to-C ahead-of-time compiler),
so no separate Python installation is required.


## Any Operating System


### Ansible (LFOps)

For fleet-wide rollouts, pinned versions, and downtime scheduling on both Linux and Windows,
use the
[linuxfabrik.lfops.monitoring_plugins](https://github.com/Linuxfabrik/lfops/tree/main/roles/monitoring_plugins)
role. It registers the Linuxfabrik repository, installs the package, enables version
lock and, on Windows, stops and restarts the Icinga 2 service while plugins are being
replaced. It can also deploy custom plugins from your inventory.

Put the target hosts into the `lfops_monitoring_plugins` inventory group, then run the LFOps
playbook. With a local Ansible installation:

```bash
ansible-playbook linuxfabrik.lfops.monitoring_plugins \
  --inventory path/to/inventory \
  --limit myhost
```

Or through the LFOps Execution Environment (a container image, no local Ansible or Python
dependencies needed) with `ansible-navigator`:

```bash
ansible-navigator run linuxfabrik.lfops.monitoring_plugins \
  --inventory path/to/inventory \
  --limit myhost
```


## Linux


### One-Liner Installer (recommended)

The quickest way to install on any supported Linux distribution. The script reads
`/etc/os-release`, registers the signed Linuxfabrik package repository and installs the
package with the system package manager:

```bash
curl -fsSL https://repo.linuxfabrik.ch/install-monitoring-plugins | sudo bash
```

To review the script before running it as root, download it, verify it against the
published checksum, read it, then run it:

```bash
curl -fsSL https://repo.linuxfabrik.ch/install-monitoring-plugins -o install-monitoring-plugins
curl -fsSL https://repo.linuxfabrik.ch/install-monitoring-plugins.sha256 | sha256sum --check
less install-monitoring-plugins
sudo bash install-monitoring-plugins
```

The same script can also install without the package repository, into a self-contained venv
(the layout the RPM and DEB packages use), instead of registering the repository. There are
two such modes.

`--source` installs the source from GitHub, which carries the newest development state (the
current `main`, or a branch or tag via `--ref`), so it can be ahead of any release. No git
client or package manager needed:

```bash
curl -fsSL https://repo.linuxfabrik.ch/install-monitoring-plugins | sudo bash -s -- --source
```

`--zip` installs the source too, but from the download server, which only carries released
versions (not the newest development state). The zip is sha256- and GPG-verified. Use
`--version=latest` for the newest release, or pin an exact `<version>-<iteration>`:

```bash
curl -fsSL https://repo.linuxfabrik.ch/install-monitoring-plugins | sudo bash -s -- --zip --version=latest
curl -fsSL https://repo.linuxfabrik.ch/install-monitoring-plugins | sudo bash -s -- --zip --version=<version>-<iteration>
```

Add `--uninstall` to reverse any of these, or `--help` for all options (`--package`,
`--plugin-dir`, `--python`, `--ref`, ...). On a host whose system `python3` is older than
3.9 (for example RHEL 8 or SLE, which default to Python 3.6), the source and zip paths
print how to re-run against a newer interpreter with `--python`.

The sections below document the manual equivalents and the platform-specific details.


### Package Repository (manual setup)

The Linuxfabrik package repository ships signed `.rpm` and `.deb` packages that include
the plugins and their Python dependencies in a venv, managed by your system package
manager. Installing via the package manager is the fastest way to get started, supports
clean upgrades, and (on RHEL) ships an optional SELinux policy as a separate sub-package.

Once the repository is registered, keep the plugins current with your usual package
manager commands (`dnf upgrade`, `zypper update`, `apt upgrade`). If you run Icinga
Director, pin the version before upgrading plugins, so the Icinga Director configuration
and the plugins stay in sync. The
[LFOps Ansible role](https://github.com/Linuxfabrik/lfops/tree/main/roles/monitoring_plugins)
does that automatically.


#### Debian 11, 12, 13

```bash
sudo mkdir -p /etc/apt/keyrings
sudo wget https://repo.linuxfabrik.ch/linuxfabrik.key \
    --output-document=/etc/apt/keyrings/linuxfabrik.asc
source /etc/os-release
echo "deb [signed-by=/etc/apt/keyrings/linuxfabrik.asc] \
https://repo.linuxfabrik.ch/monitoring-plugins/debian/ $VERSION_CODENAME-release main" \
    | sudo tee /etc/apt/sources.list.d/linuxfabrik-monitoring-plugins.list
sudo apt update
sudo apt install linuxfabrik-monitoring-plugins
```


#### RHEL 8, 9, 10 (Rocky, AlmaLinux, CentOS Stream, Oracle Linux)

```bash
sudo rpm --import https://repo.linuxfabrik.ch/linuxfabrik.key
sudo dnf install wget
sudo wget https://repo.linuxfabrik.ch/monitoring-plugins/rhel/linuxfabrik-monitoring-plugins-release.repo \
    --output-document=/etc/yum.repos.d/linuxfabrik-monitoring-plugins-release.repo
sudo dnf install linuxfabrik-monitoring-plugins-selinux
```

The `linuxfabrik-monitoring-plugins-selinux` sub-package pulls in the base package via
`Recommends` and installs the SELinux policy module so the plugins run under a confined
domain without manual `semanage`/`setsebool` tuning. Install just
`linuxfabrik-monitoring-plugins` instead if SELinux is permissive or disabled.


#### SLE 15, SLE 16 and openSUSE Leap

```bash
sudo zypper addrepo https://repo.linuxfabrik.ch/monitoring-plugins/sle/linuxfabrik-monitoring-plugins-release.repo
sudo zypper install linuxfabrik-monitoring-plugins
```

SLE 15 requires at least Service Pack 5 (openSUSE Leap 15.5 or SLES 15 SP5).


#### Ubuntu 20.04, 22.04, 24.04, 26.04

```bash
sudo mkdir -p /etc/apt/keyrings
sudo wget https://repo.linuxfabrik.ch/linuxfabrik.key \
    --output-document=/etc/apt/keyrings/linuxfabrik.asc
source /etc/os-release
echo "deb [signed-by=/etc/apt/keyrings/linuxfabrik.asc] \
https://repo.linuxfabrik.ch/monitoring-plugins/ubuntu/ $VERSION_CODENAME-release main" \
    | sudo tee /etc/apt/sources.list.d/linuxfabrik-monitoring-plugins.list
sudo apt update
sudo apt install linuxfabrik-monitoring-plugins
```


### Source (latest, air-gapped, or pinned)

Use this path to run the latest state of the plugins (a fix or plugin not yet in a released
package), on a host that cannot reach `repo.linuxfabrik.ch` directly, or on one that must
stay on a frozen plugin version. You still need Python 3.9 or newer on the target. The
one-liner installer automates everything below via `--zip` (sha256- and GPG-verified); the
manual steps here are the underlying detail.

Download the source zip from the
[download server](https://download.linuxfabrik.ch/monitoring-plugins/) and extract it into
the standard plugin directory. Use `release=latest` for the newest release, or pin an exact
`<version>-<iteration>` (for example `release=2.2.1-1`) for a reproducible rollout:

```bash
release=latest
wget https://download.linuxfabrik.ch/monitoring-plugins/lfmp-${release}.source.noarch.zip
sudo unzip -d /usr/lib64/nagios/plugins lfmp-${release}.source.noarch.zip
sudo chmod -R +x /usr/lib64/nagios/plugins
```

On all Linux distributions we use `/usr/lib64/nagios/plugins` as the install path, even
where the system Nagios package uses `/usr/lib/nagios/plugins`. This keeps sudoers rules
and Icinga Director command definitions portable (see
[icingaweb2-module-director#2123](https://github.com/Icinga/icingaweb2-module-director/issues/2123)).

Unlike the RPM and DEB packages (which ship a pre-built venv under
`/usr/lib64/linuxfabrik-monitoring-plugins/venv/`), the source zip only carries source
files. The repository ships one hash-pinned lockfile per supported Python LTS under
`lockfiles/pyXX/requirements.txt` (`py39` ... `py314`). Pick the file that matches the
Python on the target host and run `pip` against it once, as the user that will run the
plugins (`icinga` on RHEL, `nagios` on Debian/Ubuntu):

```bash
PY_TAG="py$(python3 -c 'import sys; print(f"{sys.version_info.major}{sys.version_info.minor}")')"
sudo -u icinga python3 -m pip install --user --upgrade pip
sudo -u icinga python3 -m pip install --user \
    --requirement /usr/lib64/nagios/plugins/lockfiles/${PY_TAG}/requirements.txt --require-hashes
```


#### Escaping the py39 freeze

The `lockfiles/py39/requirements.txt` is frozen on package versions that still support
Python 3.9 (RHEL 8, Debian 11). Over 2025/2026, most upstream packages dropped Python
3.9, so security-relevant updates for `urllib3`, `requests` and friends only ship in
versions that require Python >= 3.10.

This freeze only affects the source-zip and GitHub source paths described above. The
**RPM package on RHEL 8 is built against Python 3.9 by design** (`BuildRequires:
python39`, `Requires: python39`) and stays on the frozen py39 lockfile regardless of
what else is installed on the host.

##### RHEL 8

The AppStream offers `python3.11` and `python3.12` as regular RPMs alongside the system
`python3.9`. A source install can run the plugins against the newer interpreter
and pick the matching lockfile, getting all upstream security updates:

```bash
sudo dnf install python3.12 python3.12-pip
sudo -u icinga python3.12 -m pip install --user --upgrade pip
sudo -u icinga python3.12 -m pip install --user \
    --requirement /usr/lib64/nagios/plugins/lockfiles/py312/requirements.txt --require-hashes
```

Point the Icinga 2 agent at `python3.12` instead of `python3` when launching the
plugins (for example via a wrapper, or by editing the shebang of installed plugins to
`#!/usr/bin/env python3.12`).

##### Debian 11

No comparable escape hatch. `bullseye-backports` is archived since the LTS transition,
so no newer Python ships through official channels. The only routes off Python 3.9
are an in-place upgrade to Debian 12 (Python 3.11) or Debian 13 (Python 3.13), or a
self-compiled Python (pyenv) without distro package support.


### Latest from GitHub (no git client)

Use this to run the current `main` or a specific tag (a fix or plugin not yet in a released
package). No git client is needed on the target. Pin a tag for a reproducible rollout; track
`main` for the very latest. Unlike the packaged installs, plugins deployed this way are not
managed by the system package manager, so upgrades are a manual re-run.

**One-liner (recommended).** The `--source` mode downloads the monitoring-plugins and lib
source zips straight from GitHub, flattens the plugins into the plugin directory and installs
lib and the Python dependencies. Add `--ref` to pick a branch or tag:

```bash
curl -fsSL https://repo.linuxfabrik.ch/install-monitoring-plugins | sudo bash -s -- --source
curl -fsSL https://repo.linuxfabrik.ch/install-monitoring-plugins | sudo bash -s -- --source --ref=<tag>
```

On a host whose system `python3` is older than 3.9, add `--python=python3.12` (see
[One-Liner Installer](#one-liner-installer-recommended)).

**Manual GitHub zip.** If the host may not pipe a script to `bash`, download the archive zips
yourself. GitHub serves any branch or tag at `/archive/<ref>.zip`. Fetch both repositories,
because `lib` lives in a separate repo:

```bash
ref=main   # or a release tag, e.g. 2.2.1
curl -fsSL -o monitoring-plugins.zip https://github.com/Linuxfabrik/monitoring-plugins/archive/${ref}.zip
curl -fsSL -o lib.zip https://github.com/Linuxfabrik/lib/archive/${ref}.zip
unzip -q monitoring-plugins.zip
unzip -q lib.zip
```

The archives keep the repository layout, so flatten the plugins into the plugin directory
(each executable sits one level deep under `check-plugins/<name>/<name>` and
`notification-plugins/<name>/<name>`) and copy the `lib` modules alongside them:

```bash
sudo mkdir -p /usr/lib64/nagios/plugins/lib
for dir in monitoring-plugins-${ref}/check-plugins/*/ monitoring-plugins-${ref}/notification-plugins/*/; do
    name=$(basename "${dir}")
    [ -f "${dir}${name}" ] && sudo install -m 0755 "${dir}${name}" "/usr/lib64/nagios/plugins/${name}"
done
sudo cp -a lib-${ref}/. /usr/lib64/nagios/plugins/lib/
sudo rm -rf /usr/lib64/nagios/plugins/lib/tests /usr/lib64/nagios/plugins/lib/lockfiles
```

Then install the Python dependencies for the user that runs the plugins (`icinga` on RHEL,
`nagios` on Debian/Ubuntu), using the lockfile from the extracted tree that matches the host
Python:

```bash
PY_TAG="py$(python3 -c 'import sys; print(f"{sys.version_info.major}{sys.version_info.minor}")')"
sudo -u icinga python3 -m pip install --user --upgrade pip
sudo -u icinga python3 -m pip install --user \
    --requirement monitoring-plugins-${ref}/lockfiles/${PY_TAG}/requirements.txt --require-hashes
```


### Post-Install (Linux)


#### Sudoers

Some check plugins need root privileges (reading `dmesg`, running `smartctl`, reading
journald, etc.). We ship `sudoers` drop-ins for each supported OS family in
[assets/sudoers/](https://github.com/Linuxfabrik/monitoring-plugins/tree/main/assets/sudoers).
The file names match
[ansible_facts\['os_family'\]](https://github.com/ansible/ansible/blob/37ae2435878b7dd76b812328878be620a93a30c9/lib/ansible/module_utils/facts.py#L267).
Install the file for your family into `/etc/sudoers.d/` on every monitored host:

* [Debian.sudoers](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/assets/sudoers/Debian.sudoers):
  Debian, Raspbian, Ubuntu.
* [RedHat.sudoers](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/assets/sudoers/RedHat.sudoers):
  Alma, Amazon, CentOS, CloudLinux, Fedora, Oracle Linux, RedHat, Rocky, Scientific.

When the Linuxfabrik RPM or DEB package is installed, you will already find the
appropriate sudoers drop-in in `/etc/sudoers.d/` (it is part of the package). Source-zip and
GitHub source installs must add it manually.

When you call plugins with sudo from Icinga, also preserve the proxy environment
variables you care about, for example:

```text
Defaults env_keep += "http_proxy https_proxy"
```


#### SELinux

On RHEL and derivatives, the `linuxfabrik-monitoring-plugins-selinux` sub-package
installs a dedicated SELinux policy module and labels the plugin files correctly. No
extra steps are required.

For the source-zip and GitHub source installs, apply the minimal settings manually:

```bash
sudo restorecon -Fvr /usr/lib64/nagios
sudo setsebool -P nagios_run_sudo on
```


## Windows


### MSI Installer (recommended)

1. Download `lfmp-latest.signed-packaged.windows.x86_64.zip` from the
   [download server](https://download.linuxfabrik.ch/monitoring-plugins/) for the newest
   release, or `lfmp-<version>-<iteration>.signed-packaged.windows.x86_64.zip` to pin an
   exact release. Only an x86_64 Windows build is published.
2. Extract the zip. Inside you find a signed MSI.
3. Run the MSI (double-click or `msiexec /i lfmp-*.msi /qn`).

The MSI installs to `C:\Program Files\ICINGA2\sbin\linuxfabrik\`. If the Icinga 2 agent
service is detected on the host, the MSI stops and restarts it automatically so plugin
files in use are replaced cleanly. Since v2.3, the MSI no longer requires a pre-existing
Icinga 2 agent; it can be installed stand-alone for testing or with other monitoring
agents.

All binaries and the MSI are signed; free code signing is provided by
[SignPath.io](https://signpath.io) with a certificate issued by the
[SignPath Foundation](https://signpath.org).


### One-Liner Installer (PowerShell)

The scriptable way to install on Windows, the counterpart of the Linux one-liner. By default
it downloads the signed MSI, verifies its Authenticode signature and installs it silently.
Run this default path in an **elevated** PowerShell, since the MSI writes to
`C:\Program Files` (the `-Source` path below needs no elevation):

```powershell
& ([scriptblock]::Create((irm https://repo.linuxfabrik.ch/install-monitoring-plugins.ps1)))
```

This installs the latest release. Pass `-Version <version>-<iteration>` to pin an exact
release for a reproducible rollout (see the download server for the available releases):

```powershell
& ([scriptblock]::Create((irm https://repo.linuxfabrik.ch/install-monitoring-plugins.ps1))) -Version <version>-<iteration>
```

To review the script before running it, download it, verify it against the published
checksum and read it:

```powershell
irm https://repo.linuxfabrik.ch/install-monitoring-plugins.ps1 -OutFile install-monitoring-plugins.ps1
irm https://repo.linuxfabrik.ch/install-monitoring-plugins.ps1.sha256 -OutFile install-monitoring-plugins.ps1.sha256
(Get-FileHash install-monitoring-plugins.ps1 -Algorithm SHA256).Hash   # compare against the .sha256
Get-Content install-monitoring-plugins.ps1 | more
```

Run it (latest release, or add `-Version <version>-<iteration>` to pin):

```powershell
.\install-monitoring-plugins.ps1
```

The same script can also install the latest source from GitHub instead of the MSI, into a
Python 3.13 virtual environment. This is the supported way to run the latest state on
Windows (a fix or plugin not yet in a released MSI); pass `-Ref <tag>` for a pinned,
reproducible rollout. It downloads the monitoring-plugins and lib source zips, creates the
venv and installs the plugin dependencies into it (this path needs Python 3.13, and requires
neither git nor an elevated shell):

```powershell
.\install-monitoring-plugins.ps1 -Source -TargetDir C:\path\to\workdir
```

Add `-DryRun` to print every action without executing it, or `-Ref <branch-or-tag>` to
install a specific version. Run the plugins with the virtual environment's Python, for example:

```powershell
& "<TargetDir>\.venv\Scripts\python.exe" "<TargetDir>\monitoring-plugins\check-plugins\cpu-usage\cpu-usage"
```

The sections below document the manual equivalents and the platform-specific details.


### ZIP Archive

If you cannot or do not want to run an MSI, download
`lfmp-latest.signed-compiled.windows.x86_64.zip` (or a pinned
`lfmp-<version>-<iteration>.signed-compiled.windows.x86_64.zip`) from the
[download server](https://download.linuxfabrik.ch/monitoring-plugins/) and extract it
to a folder of your choice. The conventional location is
`C:\Program Files\ICINGA2\sbin\linuxfabrik\`. Plugins are single-file EXEs; no Python
installation is required.


### Source (latest)

Run the latest state from GitHub by executing the `.py` files directly. This needs a local
Python 3.13 and the dependencies from `lockfiles/py313-windows/requirements.txt` (the
lockfile matches the version the Windows binary build is pinned to; see `BUILD.md`). No git
client is required.

**One-liner (recommended).** The PowerShell installer's `-Source` mode downloads the
monitoring-plugins and lib source zips from GitHub into a Python 3.13 virtual environment and
wires up `lib`; see [One-Liner Installer (PowerShell)](#one-liner-installer-powershell)
above. Add `-Ref <tag>` for a pinned rollout.

**Manual GitHub zip.** Download the archive zips yourself. GitHub serves any branch or tag at
`/archive/<ref>.zip`. Fetch both repositories, because `lib` lives in a separate repo:

```powershell
$ref = 'main'   # or a release tag, e.g. 2.2.1
Invoke-WebRequest "https://github.com/Linuxfabrik/monitoring-plugins/archive/$ref.zip" `
    -OutFile monitoring-plugins.zip -UseBasicParsing
Invoke-WebRequest "https://github.com/Linuxfabrik/lib/archive/$ref.zip" `
    -OutFile lib.zip -UseBasicParsing
Expand-Archive monitoring-plugins.zip -DestinationPath . -Force
Expand-Archive lib.zip -DestinationPath . -Force
```

The plugins are the `.py` files under `monitoring-plugins-$ref\check-plugins\<name>\<name>`.
Copy the extracted `lib-$ref` modules into a `lib` folder next to the plugins so `import lib`
resolves, then install the dependencies with a local Python 3.13:

```powershell
python -m pip install --upgrade pip
python -m pip install --requirement `
    "monitoring-plugins-$ref\lockfiles\py313-windows\requirements.txt" --require-hashes
```

**Signed zip.** For an air-gapped or reproducible install, the
`lfmp-latest.source.noarch.zip` (or a pinned `lfmp-<version>-<iteration>.source.noarch.zip`)
from the [download server](https://download.linuxfabrik.ch/monitoring-plugins/) works on
Windows too:
it is architecture-independent, already flattened, and bundles `lib` and every lockfile
(including `py313-windows`). Download and sha256-verify it as shown under
[Linux > Source](#source-latest-air-gapped-or-pinned), extract it to
`C:\Program Files\ICINGA2\sbin\linuxfabrik\`, then install the `py313-windows` dependencies
as above. Unlike on Linux, the PowerShell one-liner does not automate this signed-zip path.


### Post-Install (Windows)


#### Icinga Agent and JEA Profile

The Icinga for Windows agent runs as `Network Service` by default. Some plugins fail
with `0x80070005 (E_ACCESSDENIED)` under that account. The supported fix is to enable
the
[JEA profile for Icinga for Windows](https://icinga.com/docs/icinga-for-windows/latest/doc/130-JEA/01-JEA-Profiles/);
see
[Installing JEA for Icinga for Windows](https://icinga.com/docs/icinga-for-windows/latest/doc/130-JEA/02-Installation/)
for the enrollment steps.

Keep in mind that environment variables set in Icinga Director do not propagate to
Windows agents. Proxy and other environment variables must be configured in
`/etc/icinga2/icinga2.conf` on the master (`env.http_proxy`, `env.https_proxy`, ...).


## Next Steps

* Icinga integration and Director Basket import: see [ICINGA.md](ICINGA.md).
* Grafana dashboards and panels: see [GRAFANA.md](GRAFANA.md).
* Plugin groups with shared setup (Keycloak, MySQL, Rocket.Chat, WildFly): see
  the corresponding `PLUGINS-*.md` files at the repository root.
