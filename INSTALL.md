# How to install the Linuxfabrik Monitoring Plugins Collection

| Platform | Install | When | Installation Instructions |
|----|----|----|----|
| Linux     | rpm/deb package (**recommended**) | Want to use OS package manager and have distro that uses rpm/deb package formats | See <https://repo.linuxfabrik.ch/monitoring-plugins/> |
| Linux     | zip | Don't want to use OS package manager or have distro that uses package formats other than rpm/deb and can't run Python 3.9+ | See *Installation on Linux* in this document |
| Linux     | Source Code | Want to use the latest development version and Python 3.9+ available | See *Run from Source* in this document |
| Windows   | Binaries from msi (**recommended**) | Want to use OS package manager | Get the 'signed-packaged' msi file from [Linuxfabrik's Download Server](https://download.linuxfabrik.ch/monitoring-plugins/) and run it. Note: Icinga2 Agent is required. |
| Windows   | Binaries from zip | Don't want to use OS package manager | Get the 'signed-compiled' zip file from [Linuxfabrik's Download Server](https://download.linuxfabrik.ch/monitoring-plugins/) and unpack it to a folder of your choice, usually `C:\Program Files\icinga2\sbin\linuxfabrik` |
| Windows   | Source Code | Want to use the latest development version and Python 3.9+ available | See *Run from Source* in this document |
| Any       | Using Ansible | Want to automate the installation process | See the [LFOps Ansible Role linuxfabrik.lfops.monitoring_plugins](https://github.com/Linuxfabrik/lfops/tree/main/roles/monitoring_plugins) |


## Installation on Linux

You will need to install Python 3.9+ on the remote host and set it as the default. Get the zip file from [Linuxfabrik's Download Server](https://download.linuxfabrik.ch/monitoring-plugins/) and unpack it to a folder of your choice, usually `/usr/lib64/nagios/plugins`

On Linux, some check plugins require `sudo`-permissions to run. To do this, we provide `sudoers` files for various operating system families in [monitoring-plugins/assets/sudoers](https://github.com/Linuxfabrik/monitoring-plugins/tree/main/assets/sudoers), for example [RedHat.sudoers](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/assets/sudoers/RedHat.sudoers). The file name is compatible to [ansible_facts\['os_family'\]](https://github.com/ansible/ansible/blob/37ae2435878b7dd76b812328878be620a93a30c9/lib/ansible/module_utils/facts.py#L267). You need to place this file in `/etc/sudoers.d/` on the target host.

Currently available:

* [Debian.sudoers](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/assets/sudoers/Debian.sudoers): for Debian, Raspbian, Ubuntu (and maybe more)
* [RedHat.sudoers](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/assets/sudoers/RedHat.sudoers): for Alma, Amazon, Ascendos, CentOS, CloudLinux, Fedora, OEL, OracleLinux, OVS, PSBM, RedHat, Rocky Linux, Scientific, SLC, XenServer (and maybe more)


## Run from Source

Below, we describe an example installation method on Linux only.

You will need to install Python 3.9+ on the remote host and set it as the default.

Clone the monitoring check plugins from the Linuxfabrik Git repository to your local machine or deployment host:

```bash
# https://github.com/Linuxfabrik/monitoring-plugins/releases
release=1.2.3
```

```bash
git clone https://github.com/Linuxfabrik/monitoring-plugins.git
cd monitoring-plugins
git checkout tags/$release
cd ..
```

Copy one or more of the Python check plugins to the `/usr/lib64/nagios/plugins` directory. For example, you can do this by following these steps on your deployment host:

```bash
plugin_source_dir=/path/to/monitoring-plugins/check-plugins
remote_user=root
remote_host=192.0.2.74
remote_target_dir=/usr/lib64/nagios/plugins
```

```bash
ssh $remote_user@$remote_host "sudo mkdir -p $remote_target_dir/lib"
for dir in $(find $plugin_source_dir -maxdepth 1 -type d); do
    file=$(basename $dir)
    rsync \
        --archive \
        --progress \
        --human-readable \
        --rsync-path='sudo rsync' \
        $dir/$file \
        $remote_user@$remote_host:/usr/lib64/nagios/plugins/${file}
done
scp $plugin_source_dir/../requirements.txt $remote_user@$remote_host:/tmp
```

Once installation/copying is complete, the directory on the remote host should resemble the following:

```text
/usr/lib64/nagios/plugins
├── about-me
├── apache-httpd-status
├── apache-httpd-version
├── ...
└── xml
```

Wherever possible, we try to avoid dependencies on third-party OS or Python libraries. If we need to use additional libraries for various reasons, such as [psutil](https://psutil.readthedocs.io/en/latest/), we stick with the official versions. The easiest way to install them is using your package manager (rpm or pip, for example, depending on your environment). On the remote machine, this may involve switching to the "icinga" user.

```bash
sudo -u icinga python3 -m pip install --user --upgrade pip
sudo -u icinga python3 -m pip install --user --requirement /tmp/requirements.txt --require-hashes
```

To make SELinux happy on RHEL and compatible systems, run:

```bash
restorecon -Fvr /usr/lib64/nagios
setsebool -P nagios_run_sudo on
```
