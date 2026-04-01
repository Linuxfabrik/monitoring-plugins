# Check file-ownership

## Overview

Checks the ownership (owner and group) of a list of files against expected values. The default file list covers most files defined in the CIS Security Benchmarks for RHEL, Debian, Ubuntu and Fedora, plus several application-specific paths. Files that do not exist on the system are silently skipped.

Alerting Logic:

* WARN if any file's owner or group does not match the expected value.

Data Collection:

* Uses `os.stat()` to read file ownership directly, without shelling out to external commands.
* Resolves numeric UIDs/GIDs to names. If a UID/GID has no corresponding name, the numeric value is displayed.

Compatibility:

* Linux only. Not compiled for Windows.
* Depending on the file and user (e.g. running as `icinga`), sudo (sudoers) may be needed.

Important Notes:

* `--filename` entries are merged with the default file list. If the same path appears in both, the user-supplied entry wins. Use `--no-default-files` to skip the defaults entirely.
* The following CIS-recommended files are excluded from the defaults because their ownership differs across RHEL, Debian, Ubuntu and SLES: `/etc/gshadow`, `/etc/gshadow-`, `/etc/shadow`, `/etc/shadow-`. To check these, add them via `--filename` with suitable values.

Default files checked:

* /boot/grub/grub.cfg: root:root
* /boot/grub/grub.conf: root:root
* /boot/grub2/grub.cfg: root:root
* /boot/grub2/grubenv: root:root
* /boot/grub2/user.cfg: root:root
* /etc/anacrontab: root:root
* /etc/at.allow: root:root
* /etc/cron.allow: root:root
* /etc/cron.d: root:root
* /etc/cron.daily: root:root
* /etc/cron.hourly: root:root
* /etc/cron.monthly: root:root
* /etc/cron.weekly: root:root
* /etc/crontab: root:root
* /etc/default/grub: root:root
* /etc/fstab: root:root
* /etc/graylog/certs: graylog:graylog
* /etc/group: root:root
* /etc/group-: root:root
* /etc/hosts: root:root
* /etc/hosts.allow: root:root
* /etc/hosts.deny: root:root
* /etc/issue: root:root
* /etc/issue.net: root:root
* /etc/login.defs: root:root
* /etc/logrotate.conf: root:root
* /etc/logrotate.d: root:root
* /etc/loolwsd/loolwsd.xml: lool:lool
* /etc/motd: root:root
* /etc/named.conf: root:named
* /etc/pam.d: root:root
* /etc/passwd: root:root
* /etc/passwd-: root:root
* /etc/profile: root:root
* /etc/rsyslog.conf: root:root
* /etc/security/access.conf: root:root
* /etc/security/limits.conf: root:root
* /etc/shells: root:root
* /etc/ssh/ssh_config: root:root
* /etc/ssh/sshd_config: root:root
* /etc/sssd/sssd.conf: root:root
* /etc/sudoers: root:root
* /etc/sudoers.d: root:root
* /etc/sysctl.conf: root:root
* /etc/sysctl.d: root:root
* /etc/systemd/coredump.conf: root:root
* /etc/systemd/journald.conf: root:root
* /etc/systemd/logind.conf: root:root
* /etc/systemd/system.conf: root:root
* /home/ovirt: vdsm:kvm
* /tmp: root:root
* /tmp/linuxfabrik-monitoring-plugins-sqlite.db: icinga:icinga
* /var/hnet: hnet:hnet
* /var/lib/unbound/root.key: unbound:unbound
* /var/run/openldap: ldap:ldap


## Fact Sheet

| Fact | Value |
|----|------|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/file-ownership> |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |


## Help

```text
usage: file-ownership [-h] [-V] [--filename FILES] [--no-default-files]

Checks the ownership (owner and group, both have to be names) of a list of
files.

options:
  -h, --help          show this help message and exit
  -V, --version       show program's version number and exit
  --filename FILES    File to be checked, in the format `owner:group,path`
                      (repeatable). User-supplied entries are merged with the
                      default file list. If the same path appears in both, the
                      user-supplied entry wins.
  --no-default-files  Do not check the default file list, only check files
                      specified via `--filename`.
```


## Usage Examples

Using default file list:

```bash
./file-ownership
```

Output:

```text
Everything is ok.

Path                       ! Expected        ! Found
---------------------------+-----------------+----------------
/etc/anacrontab            ! root:root       ! root:root
/etc/cron.d                ! root:root       ! root:root
/etc/crontab               ! root:root       ! root:root
/etc/default/grub          ! root:root       ! root:root
/etc/fstab                 ! root:root       ! root:root
...
```

Adding files to the defaults (merged, user entry wins on duplicate paths):

```bash
./file-ownership --filename root:root,/etc/shadow --filename root:root,/etc/shadow-
```

Checking only specific files (no defaults):

```bash
./file-ownership --no-default-files --filename root:root,/etc/passwd --filename root:root,/etc/shadow
```


## States

* WARN if ownership does not match expected values.


## Perfdata / Metrics

There is no perfdata.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
