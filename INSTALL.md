# Installing the Linuxfabrik Monitoring Plugins Collection

Pick the path that matches your platform. On Linux, prefer the package repository. On
Windows, prefer the MSI installer. Everything else (source tarball, Git checkout) is for
corner cases such as air-gapped hosts or testing a development build.

Supported Python: 3.9 or newer. The RPM and DEB packages depend on the system Python, so
the plugins run on every currently supported RHEL, SLE, Debian and Ubuntu release
out of the box. On Windows, the MSI and ZIP ship plugins pre-compiled to native
executables with [Nuitka](https://nuitka.net/) (a Python-to-C ahead-of-time compiler),
so no separate Python installation is required.


## Linux


### Package Repository (recommended)

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

Tested on: Debian 11 (bullseye), Debian 12 (bookworm), Debian 13 (trixie).


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

Tested on: Rocky 8, Rocky 9, Rocky 10.


#### SLE 15, SLE 16 and openSUSE Leap

```bash
sudo zypper addrepo https://repo.linuxfabrik.ch/monitoring-plugins/sle/linuxfabrik-monitoring-plugins-release.repo
sudo zypper install linuxfabrik-monitoring-plugins
```

SLE 15 requires at least Service Pack 5 (openSUSE Leap 15.5 or SLES 15 SP5).

Tested on: SLE 15.5.


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

Tested on: Ubuntu 20.04 (focal), Ubuntu 22.04 (jammy), Ubuntu 24.04 (noble).


### Ansible (LFOps)

For fleet-wide rollouts, pinned versions, and downtime scheduling, use the
[linuxfabrik.lfops.monitoring_plugins](https://github.com/Linuxfabrik/lfops/tree/main/roles/monitoring_plugins)
role. It registers the Linuxfabrik repository, installs the package, enables version
lock and, on Windows, stops and restarts the Icinga 2 service while plugins are being
replaced. It can also deploy custom plugins from your inventory.


### Source Tarball

Use this path if a host cannot reach `repo.linuxfabrik.ch` directly or must stay on a
frozen plugin version. You still need Python 3.9 or newer on the target.

Download `lfmp-<version>-<iteration>.source.noarch.zip` from the
[download server](https://download.linuxfabrik.ch/monitoring-plugins/) and extract it
into the standard plugin directory:

```bash
release=2.2.1-1
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
files. The `requirements.txt` at the root of the extracted tree pins all Python
dependencies; you still have to run `pip` against it once, as the user that will run
the plugins (`icinga` on RHEL, `nagios` on Debian/Ubuntu):

```bash
sudo -u icinga python3 -m pip install --user --upgrade pip
sudo -u icinga python3 -m pip install --user \
    --requirement /usr/lib64/nagios/plugins/requirements.txt --require-hashes
```


### From Git (Development)

Use this for testing a branch, verifying a bug fix before it is released, or running
against the current `main`. Not recommended for production.

```bash
release=2.2.1
git clone https://github.com/Linuxfabrik/monitoring-plugins.git
cd monitoring-plugins
git checkout "tags/${release}"
```

Copy the plugins to the remote host. The following runs on your deployment machine and
syncs every plugin directory via `rsync`:

```bash
plugin_source_dir=/path/to/monitoring-plugins/check-plugins
remote_user=root
remote_host=192.0.2.74
remote_target_dir=/usr/lib64/nagios/plugins

ssh "${remote_user}@${remote_host}" "sudo mkdir -p ${remote_target_dir}/lib"
for dir in $(find "${plugin_source_dir}" -maxdepth 1 -type d); do
    file=$(basename "${dir}")
    rsync \
        --archive \
        --progress \
        --human-readable \
        --rsync-path='sudo rsync' \
        "${dir}/${file}" \
        "${remote_user}@${remote_host}:${remote_target_dir}/${file}"
done
scp "${plugin_source_dir}/../requirements.txt" "${remote_user}@${remote_host}:/tmp"
```

Once complete, the remote directory looks like this:

```text
/usr/lib64/nagios/plugins
├── about-me
├── apache-httpd-status
├── apache-httpd-version
├── ...
└── xml
```

Install the Python dependencies for the user that runs the plugins (`icinga` on RHEL,
`nagios` on Debian/Ubuntu):

```bash
sudo -u icinga python3 -m pip install --user --upgrade pip
sudo -u icinga python3 -m pip install --user \
    --requirement /tmp/requirements.txt --require-hashes
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
appropriate sudoers drop-in in `/etc/sudoers.d/` (it is part of the package). Source
tarball and Git installs must add it manually.

When you call plugins with sudo from Icinga, also preserve the proxy environment
variables you care about, for example:

```text
Defaults env_keep += "http_proxy https_proxy"
```


#### SELinux

On RHEL and derivatives, the `linuxfabrik-monitoring-plugins-selinux` sub-package
installs a dedicated SELinux policy module and labels the plugin files correctly. No
extra steps are required.

For the source tarball and Git installs, apply the minimal settings manually:

```bash
sudo restorecon -Fvr /usr/lib64/nagios
sudo setsebool -P nagios_run_sudo on
```


## Windows


### MSI Installer (recommended)

1. Download `lfmp-<version>-<iteration>.signed-packaged.windows.<arch>.zip` from the
   [download server](https://download.linuxfabrik.ch/monitoring-plugins/).
   `x86_64` is for Intel/AMD, `aarch64` is for ARM.
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


### ZIP Archive

If you cannot or do not want to run an MSI, download
`lfmp-<version>-<iteration>.signed-compiled.windows.<arch>.zip` from the
[download server](https://download.linuxfabrik.ch/monitoring-plugins/) and extract it
to a folder of your choice. The conventional location is
`C:\Program Files\ICINGA2\sbin\linuxfabrik\`. Plugins are single-file EXEs; no Python
installation is required.


### From Source (Python 3.9+)

On Windows, running the `.py` files directly requires a local Python 3.9 or newer
installation and the dependencies from `requirements-windows.txt`. Clone the repository
and point the Icinga 2 agent at the `.py` files:

```powershell
git clone https://github.com/Linuxfabrik/monitoring-plugins.git `
    "C:\Program Files\ICINGA2\sbin\linuxfabrik"
python -m pip install --upgrade pip
python -m pip install --requirement `
    "C:\Program Files\ICINGA2\sbin\linuxfabrik\requirements-windows.txt" --require-hashes
```


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
