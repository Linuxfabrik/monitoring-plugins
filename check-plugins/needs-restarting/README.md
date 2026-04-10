# Check needs-restarting


## Overview

Checks for processes that were started before they or one of their dependencies were updated. Useful for detecting servers that have been patched but not yet rebooted. Requires root or sudo.

**Important Notes:**

* Red Hat-based distributions (RHEL, CentOS, Fedora, etc.)
* Debian-based distributions (Debian, Ubuntu, etc.)
* May take more than 10 seconds on Red Hat to execute

**Data Collection:**

* On Red Hat: Uses the `needs-restarting` command. First checks `needs-restarting --reboothint` (return code 1 means reboot required), then `needs-restarting` for a process list of updated services.
* On Debian: Uses `needrestart -b` if available, which reports kernel status and services needing restart. Falls back to checking `/var/run/reboot-required`.


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/needs-restarting> |
| Nagios/Icinga Check Name              | `check_needs_restarting` |
| Check Interval Recommendation         | Every day |
| Can be called without parameters      | Yes |
| Runs on                               | Linux |
| Compiled for Windows                  | No |
| Requirements                          | RHEL: `needs-restarting`, Debian: None, optional `needrestart` |


## Help

```text
usage: needs-restarting [-h] [-V]

Checks for processes that were started before they or one of their
dependencies were updated. Returns WARN if a full system reboot is required or
if individual services need a restart. Useful for detecting servers that have
been patched but not yet rebooted. Requires root or sudo.

options:
  -h, --help     show this help message and exit
  -V, --version  show program's version number and exit
```


## Usage Examples

```bash
./needs-restarting
```

Output on Red Hat:

```text
Found 17 running processes that have been updated and may need a restart:
1595 : /usr/lib/systemd/systemd-udevd
1483 : sshd: root@pts/1
1223 : qmgr -l -t unix -u
1222 : pickup -l -t unix -u
...
```

Output on Debian:

```text
A system reboot may be required. Running Kernel 4.19.0-20-amd64 != Installed Kernel 5.10.0-13-amd64 (version upgrade pending). Found 3 running processes that have been updated and may need a restart:
* dbus.service
* getty@tty1.service
* systemd-logind.service
```


## States

* OK if no system or service restart is needed.
* WARN if a system reboot is required.
* WARN if services need a restart.
* UNKNOWN if the OS is not supported.


## Perfdata / Metrics

There is no perfdata.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
