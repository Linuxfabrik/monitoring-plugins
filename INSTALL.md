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

Get the zip file from [Linuxfabrik's Download Server](https://download.linuxfabrik.ch/monitoring-plugins/) and unpack it to a folder of your choice, usually `/usr/lib64/nagios/plugins`

On Linux, some check plugins require `sudo`-permissions to run. To do this, we provide `sudoers` files for various operating system families in `monitoring-plugins/assets/sudoers`, for example `RedHat.sudoers`. The file name is compatible to [ansible_facts\['os_family'\]](https://github.com/ansible/ansible/blob/37ae2435878b7dd76b812328878be620a93a30c9/lib/ansible/module_utils/facts.py#L267). You need to place this file in `/etc/sudoers.d/` on the target host.

Currently available:

* `Debian.sudoers`: for Debian, Raspbian, Ubuntu
* `RedHat.sudoers`: for Alma, Amazon, Ascendos, CentOS, CloudLinux, Fedora, OEL, OracleLinux, OVS, PSBM, RedHat, Rocky Linux, Scientific, SLC, XenServer
* `Suse.sudoers`: for openSUSE, SLED, SLES, SLES_SAP, SuSE


## Run from Source

If you run the Linuxfabrik check plugins directly from source (which is no problem at all), you need to install Python 3.9+ on the remote host, and make it default. We describe one way to do so (on Linux). Do whatever you have to do to get to this.

Clone the monitoring check plugins from Linuxfabrik's Git repository to your local machine or deployment host:

```bash
# https://github.com/Linuxfabrik/monitoring-plugins/releases
release=1.2.3.4
```

```bash
git clone https://github.com/Linuxfabrik/monitoring-plugins.git
cd monitoring-plugins
git checkout tags/$release
cd ..
```

Copy some or all Python check plugins to `/usr/lib64/nagios/plugins`, for example by doing the following on your deployment host:

```bash
plugin_source_dir=/path/to/monitoring-plugins/check-plugins
remote_user=root
remote_host=192.0.2.74
remote_target_dir=/usr/lib64/nagios/plugins

ssh $remote_user@$remote_host "sudo mkdir -p $remote_target_dir/lib"
for dir in $(find $plugin_source_dir -maxdepth 1 -type d); do
    file=$(basename $dir)
    rsync --archive --progress --human-readable --rsync-path='sudo rsync' $dir/$file $remote_user@$remote_host:/usr/lib64/nagios/plugins/${file}
done
scp $plugin_source_dir/../requirements.txt $remote_user@$remote_host:/tmp
```

After installing/copying, the directory on the remote host should look like this:

```text
/path/to/plugins (normally /usr/lib64/nagios/plugins)
├── about-me
├── apache-httpd-status
├── apache-httpd-version
├── ...
└── xml
```

We try to avoid dependencies on 3rd party OS- or Python-libraries wherever possible. If we need to use additional libraries for various reasons (for example [psutil](https://psutil.readthedocs.io/en/latest/)), we stick with official versions. The easiest way is to install them using your package manager, pip or whatever (depends on your environment). On the remote machine, for example including switching to the user "icinga":

```bash
sudo -u icinga python3 -m pip install --user --upgrade pip
sudo -u icinga python3 -m pip install --user --requirement /tmp/requirements.txt --require-hashes
```

On RHEL and compatible, to make SELinux happy run:

```bash
restorecon -Fvr /usr/lib64/nagios
setsebool -P nagios_run_sudo on
```
