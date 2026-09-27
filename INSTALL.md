# Installing the Linuxfabrik Monitoring Plugins Collection

The recommended path is the one-liner installer on both Linux and Windows. For rollouts across many hosts, use [Ansible](#ansible-lfops).


## Linux

The plugins need Python 3.9 or newer. The packages bring their own venv built against the system Python. They always go to `/usr/lib64/nagios/plugins`, even where the distribution's Nagios package uses `/usr/lib/nagios/plugins`. This keeps sudoers rules and Icinga Director command definitions portable (see [icingaweb2-module-director#2123](https://github.com/Icinga/icingaweb2-module-director/issues/2123)).


### One-Liner: Package Repository (recommended)

For most hosts, with access to the internet or to a mirror server. Registers the signed Linuxfabrik package repository and installs the package. Upgrades then come with `dnf upgrade`, `zypper update` or `apt upgrade`. Supported: Debian 11-13, RHEL 8-10 and compatibles, SLE 15 SP5+ and 16, openSUSE Leap, Ubuntu 22.04-26.04.

```bash
curl -fsSL https://repo.linuxfabrik.ch/install-monitoring-plugins | sudo bash
```

`-fsSL` is short for `--fail --silent --show-error --location`: curl aborts on an HTTP error instead of piping the error page into `bash`, prints nothing but errors, and follows redirects.


### One-Liner: Source Zip

For hosts that need a released version but may not use the RPM or DEB packages. Installs a released source zip from the [download server](https://download.linuxfabrik.ch/monitoring-plugins/) into a self-contained venv. Preferred over the GitHub source: the zip is sha256- and GPG-verified, carries exactly the library the release was tested with, and does not depend on GitHub, so it can be mirrored or copied to hosts without internet access. `latest` is the newest release, `<version>-<iteration>` pins one. Not managed by the package manager, so upgrades mean re-running it.

```bash
curl -fsSL https://repo.linuxfabrik.ch/install-monitoring-plugins | sudo bash -s -- --zip --version=latest
curl -fsSL https://repo.linuxfabrik.ch/install-monitoring-plugins | sudo bash -s -- --zip --version=<version>-<iteration>
```


### One-Liner: Source from GitHub

For hosts that need a fix or plugin that is not yet released, and can reach GitHub. Installs the current `main` (or a branch or tag with `--ref`) into a self-contained venv. Not managed by the package manager, so upgrades mean re-running it.

```bash
curl -fsSL https://repo.linuxfabrik.ch/install-monitoring-plugins | sudo bash -s -- --source
curl -fsSL https://repo.linuxfabrik.ch/install-monitoring-plugins | sudo bash -s -- --source --ref=<branch-or-tag>
```


### One-Liner: Options

* `--help`: shows all options.
* `--plugin-dir=DIR`: installs somewhere other than `/usr/lib64/nagios/plugins`.
* `--python=python3.12`: interpreter for the `--source` and `--zip` venv. Needed where the system `python3` is older than 3.9 (RHEL 8, SLE 15) and no newer one is found automatically.
* `--ref=<branch-or-tag>`: picks what `--source` installs. A release tag such as `v8.0.0` comes with the library release it was tested with, a branch with the library's `main`.
* `--uninstall`: reverses any of the installs above.

To read the script before running it as root:

```bash
curl -fsSL https://repo.linuxfabrik.ch/install-monitoring-plugins --output install-monitoring-plugins
curl -fsSL https://repo.linuxfabrik.ch/install-monitoring-plugins.sha256 | sha256sum --check
less install-monitoring-plugins
sudo bash install-monitoring-plugins
```


### Package Repository, Manual Setup

For hosts whose repositories are managed by hand or by other tooling. What the one-liner does in its default mode. If you run Icinga Director, pin the package version before upgrading, so the Director configuration and the plugins stay in sync.

Debian 11, 12, 13:

```bash
sudo mkdir -p /etc/apt/keyrings
sudo curl -fsSL https://repo.linuxfabrik.ch/linuxfabrik.key --output /etc/apt/keyrings/linuxfabrik.asc
source /etc/os-release
echo "deb [signed-by=/etc/apt/keyrings/linuxfabrik.asc] \
https://repo.linuxfabrik.ch/monitoring-plugins/debian/ $VERSION_CODENAME-release main" \
    | sudo tee /etc/apt/sources.list.d/linuxfabrik-monitoring-plugins.list
sudo apt update
sudo apt install linuxfabrik-monitoring-plugins
```

RHEL 8, 9, 10 (Rocky, AlmaLinux, CentOS Stream, Oracle Linux):

```bash
sudo rpm --import https://repo.linuxfabrik.ch/linuxfabrik.key
sudo curl -fsSL https://repo.linuxfabrik.ch/monitoring-plugins/rhel/linuxfabrik-monitoring-plugins-release.repo \
    --output /etc/yum.repos.d/linuxfabrik-monitoring-plugins.repo
sudo dnf install linuxfabrik-monitoring-plugins-selinux
```

The `-selinux` sub-package pulls in the base package and loads the SELinux policy module (see [SELinux](#selinux)). Install `linuxfabrik-monitoring-plugins` instead if SELinux is permissive or disabled.

SLE 15 SP5+, SLE 16, openSUSE Leap:

```bash
sudo rpm --import https://repo.linuxfabrik.ch/linuxfabrik.key
sudo zypper addrepo https://repo.linuxfabrik.ch/monitoring-plugins/sle/linuxfabrik-monitoring-plugins-release.repo
sudo zypper install linuxfabrik-monitoring-plugins
```

Ubuntu 22.04, 24.04, 26.04:

```bash
sudo mkdir -p /etc/apt/keyrings
sudo curl -fsSL https://repo.linuxfabrik.ch/linuxfabrik.key --output /etc/apt/keyrings/linuxfabrik.asc
source /etc/os-release
echo "deb [signed-by=/etc/apt/keyrings/linuxfabrik.asc] \
https://repo.linuxfabrik.ch/monitoring-plugins/ubuntu/ $VERSION_CODENAME-release main" \
    | sudo tee /etc/apt/sources.list.d/linuxfabrik-monitoring-plugins.list
sudo apt update
sudo apt install linuxfabrik-monitoring-plugins
```


### Source, Manual Setup

For hosts that may not pipe a script into `bash` or cannot reach the internet. What the one-liner does with `--source` or `--zip`. Plugins and library go into the plugin directory, the Python dependencies into a root-owned venv under `/usr/lib64/linuxfabrik-monitoring-plugins/venv`, the same layout the packages use.

Never install the dependencies with `pip install --user` into the monitoring user's home. Some plugins run as root through sudo, so anything the monitoring user can write is a way to run code as root.

Start with `umask 022`. On a host hardened to `umask 027` or `077`, the monitoring user otherwise cannot read the result and every check fails with a permission error:

```bash
umask 022
```

**Step 1a: Get the source zip from the download server (preferred).** It contains the plugins already flattened, plus the matching library and all lockfiles. The `.sha256` file always names the versioned zip, so the check below compares the hash only:

```bash
release=latest
curl -fsSL --remote-name https://download.linuxfabrik.ch/monitoring-plugins/lfmp-${release}.source.noarch.zip
curl -fsSL --remote-name https://download.linuxfabrik.ch/monitoring-plugins/lfmp-${release}.source.noarch.zip.sha256
echo "$(cut -d ' ' -f 1 lfmp-${release}.source.noarch.zip.sha256)  lfmp-${release}.source.noarch.zip" \
    | sha256sum --check
unzip -q lfmp-${release}.source.noarch.zip
src=linuxfabrik-monitoring-plugins
libsrc=${src}/lib
find ${src} -maxdepth 1 -type f ! -name '*.md' > plugins.txt
find ${src}/assets -maxdepth 1 -type f > assets.txt
```

**Step 1b: Or get the source from GitHub.** Both repositories are needed, because the library lives in a separate one. They are versioned independently, so a tag has to be picked per repository; `main` works for both.

```bash
curl -fsSL https://github.com/Linuxfabrik/monitoring-plugins/archive/main.zip --output monitoring-plugins.zip
curl -fsSL https://github.com/Linuxfabrik/lib/archive/main.zip --output lib.zip
unzip -q monitoring-plugins.zip && mv monitoring-plugins-*/ monitoring-plugins
unzip -q lib.zip && mv lib-*/ lib
src=monitoring-plugins
libsrc=lib
for dir in ${src}/check-plugins/*/ ${src}/event-plugins/*/ ${src}/notification-plugins/*/; do
    name=$(basename "${dir}")
    [ -f "${dir}${name}" ] && echo "${dir}${name}"
done > plugins.txt
find ${src}/check-plugins ${src}/event-plugins ${src}/notification-plugins \
    -mindepth 3 -type f -path '*/assets/*' -not -path '*/example/assets/*' > assets.txt
```

**Step 2: Install plugins, plugin assets and library.** Some plugins read data files from `assets/` next to them, for example the rootkit signatures of `scanrootkit`.

```bash
sudo mkdir -p /usr/lib64/nagios/plugins/assets /usr/lib64/nagios/plugins/lib
while read -r f; do
    sudo install -m 0755 "${f}" "/usr/lib64/nagios/plugins/$(basename "${f}")"
done < plugins.txt
while read -r f; do
    sudo install -m 0644 "${f}" /usr/lib64/nagios/plugins/assets/
done < assets.txt
sudo install -m 0644 ${libsrc}/*.py ${libsrc}/LICENSE /usr/lib64/nagios/plugins/lib/
```

**Step 3: Install the Python dependencies.** Pick the lockfile that matches the host Python:

```bash
PY_TAG="py$(python3 -c 'import sys; print(f"{sys.version_info.major}{sys.version_info.minor}")')"
VENV=/usr/lib64/linuxfabrik-monitoring-plugins/venv
sudo python3 -m venv ${VENV}
sudo ${VENV}/bin/python3 -m pip install --upgrade pip
sudo ${VENV}/bin/python3 -m pip install \
    --requirement ${src}/lockfiles/${PY_TAG}/requirements.txt --require-hashes
# GitHub source only: the library from `main` can be ahead of the released one
[ -f ${libsrc}/lockfiles/${PY_TAG}/requirements.txt ] && sudo ${VENV}/bin/python3 -m pip install \
    --requirement ${libsrc}/lockfiles/${PY_TAG}/requirements.txt --require-hashes
sudo ${VENV}/bin/python3 -m pip uninstall --yes linuxfabrik-lib
```

The two lockfiles pin some shared packages to different versions, so they need separate `pip` calls. The lockfile also pulls in the released library as `linuxfabrik-lib`. It is removed again so that the copy next to the plugins is the only one Python can find.

On RHEL 8 and SLE 15, `python3` is 3.6. Install a newer Python (`sudo dnf install python3.12`) and use it instead of `python3` above. On Python 3.9, the `py39` lockfile is frozen on package versions that still support 3.9, so it misses upstream security updates; prefer a newer Python where the distribution offers one (Debian 11 does not).

**Step 4: Point the plugins at the venv and hand everything to root.**

```bash
while read -r f; do
    sudo sed -i "1s|^#!.*python3.*|#!${VENV}/bin/python3|" "/usr/lib64/nagios/plugins/$(basename "${f}")"
done < plugins.txt
sudo chown -R root:root /usr/lib64/nagios/plugins/lib /usr/lib64/linuxfabrik-monitoring-plugins
sudo chmod -R u=rwX,go=rX /usr/lib64/nagios/plugins/lib /usr/lib64/linuxfabrik-monitoring-plugins
```

The plugin directory also holds the distribution's own plugins, some of them setuid root. Never run a recursive `chmod` or a `sed -i` across the whole directory, both clear the setuid bit. The loops above therefore touch only the plugins from `plugins.txt`.

**Step 5: Post-install.** Install [sudoers](#sudoers), [bash completion](#bash-completion) and, on RHEL, the [SELinux](#selinux) module from `${src}/assets/`. Then check that the monitoring user can run a plugin:

```bash
sudo -u icinga /usr/lib64/nagios/plugins/load
```


### Post-Install


#### Sudoers

Some plugins need root privileges (reading `dmesg`, running `smartctl`, reading journald, etc.). The packages and the one-liner install the drop-ins; a manual install copies them from [assets/sudoers/](https://github.com/Linuxfabrik/monitoring-plugins/tree/main/assets/sudoers). The file names match [ansible_facts\['os_family'\]](https://github.com/ansible/ansible/blob/37ae2435878b7dd76b812328878be620a93a30c9/lib/ansible/module_utils/facts.py#L267):

* [Debian.sudoers](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/assets/sudoers/Debian.sudoers): Debian, Raspbian, Ubuntu.
* [RedHat.sudoers](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/assets/sudoers/RedHat.sudoers): Alma, Amazon, CentOS, CloudLinux, Fedora, Oracle Linux, RedHat, Rocky, Scientific.

```bash
sudo install -m 0440 ${src}/assets/sudoers/RedHat.sudoers /etc/sudoers.d/linuxfabrik-monitoring-plugins
sudo visudo --check
```

Each has a `*-logging.sudoers` companion with the `Defaults` that keep the plugin calls out of the authentication log (otherwise five log entries per check). Install it as a second drop-in whose name carries no dot, for example `/etc/sudoers.d/linuxfabrik-monitoring-plugins-logging`; sudo skips files in `/etc/sudoers.d` whose name contains a `.` or ends in `~`. Install it only with the classic sudo from sudo.ws: sudo-rs (the default on Ubuntu 26.04) warns about each of these settings on every `sudo` call. `sudo --version` shows which one a host runs. The packages and the one-liner handle this automatically.

To pass proxy settings through sudo from Icinga, preserve them explicitly:

```text
Defaults env_keep += "http_proxy https_proxy"
```


#### Bash Completion

The packages and the one-liner install `/etc/bash_completion.d/linuxfabrik-monitoring-plugins`. It completes the options of every plugin, and the allowed values of options with a fixed set of them:

```bash
/usr/lib64/nagios/plugins/systemd-unit --severity=<TAB>
```

It reads each plugin's `--help` once per shell session, needs the distribution's `bash-completion` package and becomes active in the next shell. Plugins named like a system tool (`ping`, `uptime`, `users`, `service`, `dmesg` and a few more) complete on the full path only, so the tool's own completion keeps working.

Manual install:

```bash
sudo install -m 0644 ${src}/assets/bash-completion/linuxfabrik-monitoring-plugins.bash \
    /etc/bash_completion.d/linuxfabrik-monitoring-plugins
```

Set `LFMP_PLUGIN_DIR` before the file is read to complete plugins in a different directory. In zsh:

```bash
autoload -U bashcompinit && bashcompinit
source /etc/bash_completion.d/linuxfabrik-monitoring-plugins
```


#### SELinux

On RHEL 8, 9 and 10, the `linuxfabrik-monitoring-plugins-selinux` sub-package and the one-liner (in all modes) load a policy module with the rules the plugins need in enforcing mode. Manual install:

```bash
sudo semodule --install ${src}/assets/selinux/linuxfabrik-monitoring-plugins.cil
sudo restorecon -Fvr /usr/lib64/nagios /usr/lib64/linuxfabrik-monitoring-plugins
sudo setsebool -P nagios_run_sudo on
```

The module is CIL, so no policy compiler is needed on the host. It does not label anything: the distribution's policy puts everything below `/usr/lib64/nagios/plugins` into `nagios_unconfined_plugin_exec_t`, so plugins run as the deliberately unconfined `nagios_unconfined_plugin_t`.

RHEL 10 ships no nagios policy, so those types and the `nagios_run_sudo` boolean do not exist, plugin files are labelled `lib_t`, and the last two commands above do nothing. The module still loads without the rule that depends on the nagios types. Plugins then run in the caller's domain, typically `unconfined_service_t`; running all plugins from an Icinga agent on Rocky 10 in enforcing mode produced no denial. Adding a nagios policy such as EPEL's `nagios-selinux` activates the labels and the remaining rule after a `restorecon -Rv /usr/lib64/nagios/plugins`.


## Windows

The MSI and the ZIP ship the plugins compiled to native executables with [Nuitka](https://nuitka.net/), so they need no Python. Releases are on the [download server](https://download.linuxfabrik.ch/monitoring-plugins/): `lfmp-latest.*` is the newest release, `lfmp-<version>-<iteration>.*` pins one. The plugins go to `C:\Program Files\ICINGA2\sbin\linuxfabrik\`. The MSI and every EXE, DLL and PYD in the MSI and the ZIP carry an Authenticode signature by the [SignPath Foundation](https://signpath.org), free code signing provided by [SignPath.io](https://signpath.io). Bundled runtime files additionally keep their vendor's signature (Python Software Foundation, Microsoft).


### One-Liner: MSI (recommended)

For most hosts, with access to the internet. Downloads the signed MSI, verifies its Authenticode signature and installs it silently. Run in an **elevated** PowerShell:

```powershell
& ([scriptblock]::Create((irm https://repo.linuxfabrik.ch/install-monitoring-plugins.ps1)))
& ([scriptblock]::Create((irm https://repo.linuxfabrik.ch/install-monitoring-plugins.ps1))) -Version <version>-<iteration>
```

On Windows Server 2016, Windows PowerShell offers no TLS 1.2 by default, and every one-liner on this page fails with "Could not create SSL/TLS secure channel" before the installer starts. Enable TLS 1.2 in the same PowerShell first:

```powershell
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
```


### One-Liner: Source from GitHub

For hosts that need a fix or plugin that is not yet in a released MSI. Installs the current `main` (or a branch or tag with `-Ref`) into a venv below `-TargetDir`. Requires Python 3.13 (the version the Windows lockfile targets), no elevation and no git client:

```powershell
& ([scriptblock]::Create((irm https://repo.linuxfabrik.ch/install-monitoring-plugins.ps1))) -Source -TargetDir C:\path\to\workdir
```

Run the plugins with the venv's Python:

```powershell
& "C:\path\to\workdir\.venv\Scripts\python.exe" "C:\path\to\workdir\monitoring-plugins\check-plugins\cpu-usage\cpu-usage"
```


### One-Liner: Options

* `-DryRun`: prints every action without executing it.
* `-Jea`: after the MSI, sets up the JEA endpoint through which the Icinga 2 agent runs `procs`, `scheduled-task` and `updates` with the rights they need. Restarts WinRM. See [Windows Plugins](PLUGINS-WINDOWS.md).
* `-Ref <branch-or-tag>`: picks what `-Source` installs. A release tag such as `v8.0.0` comes with the library release it was tested with, a branch with the library's `main`.
* `-Version <version>-<iteration>`: pins a release (MSI).

To read the script before running it:

```powershell
irm https://repo.linuxfabrik.ch/install-monitoring-plugins.ps1 -OutFile install-monitoring-plugins.ps1
irm https://repo.linuxfabrik.ch/install-monitoring-plugins.ps1.sha256 -OutFile install-monitoring-plugins.ps1.sha256
$expected = (Get-Content install-monitoring-plugins.ps1.sha256).Split(' ')[0]
if ((Get-FileHash install-monitoring-plugins.ps1 -Algorithm SHA256).Hash -eq $expected) { 'OK' } else { throw 'checksum mismatch' }
Get-Content install-monitoring-plugins.ps1 | more
.\install-monitoring-plugins.ps1
```


### MSI, Manual Download

For hosts without internet access, or where software is rolled out by a software distribution tool. Download `lfmp-latest.signed-packaged.windows.x86_64.zip` (or a pinned release) from the [download server](https://download.linuxfabrik.ch/monitoring-plugins/), extract it and run the MSI inside:

```powershell
msiexec /i linuxfabrik-monitoring-plugins.msi /qn
```

If the Icinga 2 agent service is running, the MSI stops and restarts it so files in use are replaced cleanly. The MSI also installs without an Icinga 2 agent.


### ZIP, Manual Download

For hosts where no MSI may be installed. Single-file EXEs without an installer. Download `lfmp-latest.signed-compiled.windows.x86_64.zip` (or a pinned release) from the [download server](https://download.linuxfabrik.ch/monitoring-plugins/) and extract it:

```powershell
Expand-Archive lfmp-latest.signed-compiled.windows.x86_64.zip -DestinationPath 'C:\Program Files\ICINGA2\sbin\linuxfabrik' -Force
```


### Source, Manual Setup

For hosts that may not pipe a script into PowerShell. What the `-Source` one-liner does. Requires Python 3.13:

```powershell
Invoke-WebRequest https://github.com/Linuxfabrik/monitoring-plugins/archive/main.zip -OutFile monitoring-plugins.zip -UseBasicParsing
Invoke-WebRequest https://github.com/Linuxfabrik/lib/archive/main.zip -OutFile lib.zip -UseBasicParsing
Expand-Archive monitoring-plugins.zip -DestinationPath . -Force
Expand-Archive lib.zip -DestinationPath . -Force
python -m venv .venv
.venv\Scripts\python.exe -m pip install --upgrade pip
.venv\Scripts\python.exe -m pip install --requirement monitoring-plugins-main\lockfiles\py313-windows\requirements.txt --require-hashes
.venv\Scripts\python.exe -m pip install --editable lib-main
```

The plugins are the files `monitoring-plugins-main\check-plugins\<name>\<name>`, run with `.venv\Scripts\python.exe`. The last step replaces the released library from the lockfile with the one from GitHub.


### Post-Install


#### Icinga Agent and JEA

The Icinga 2 agent runs as `NetworkService` by default. `procs`, `scheduled-task` and `updates` need more rights than that account has for part of what they do, `updates` for example fails with `0x80070005 (E_ACCESSDENIED)`. [Windows Plugins](PLUGINS-WINDOWS.md) shows how to grant them those rights through a JEA endpoint, without running the agent as `LocalSystem`.

Environment variables set in Icinga Director do not reach Windows agents. Configure proxy and other variables in `/etc/icinga2/icinga2.conf` on the master (`env.http_proxy`, `env.https_proxy`, ...).


## Any Platform


### Ansible (LFOps)

For fleet-wide rollouts on Linux and Windows, use the [linuxfabrik.lfops.monitoring_plugins](https://github.com/Linuxfabrik/lfops/tree/main/roles/monitoring_plugins) role. It registers the repository, installs and version-locks the package, restarts the Icinga 2 service on Windows while plugins are replaced, and can deploy custom plugins from your inventory.

Put the hosts into the `lfops_monitoring_plugins` inventory group, then run:

```bash
ansible-playbook linuxfabrik.lfops.monitoring_plugins \
  --inventory path/to/inventory \
  --limit myhost
```

Or through the LFOps Execution Environment (a container image, no local Ansible needed):

```bash
ansible-navigator run linuxfabrik.lfops.monitoring_plugins \
  --inventory path/to/inventory \
  --limit myhost
```


## Next Steps

* Icinga integration and Director Basket import: see [ICINGA.md](ICINGA.md).
* Grafana dashboards and panels: see [GRAFANA.md](GRAFANA.md).
* Plugin groups with shared setup (Keycloak, MySQL, Rocket.Chat, WildFly): see the corresponding `PLUGINS-*.md` files at the repository root.
