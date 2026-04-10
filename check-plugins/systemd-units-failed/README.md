# Check systemd-units-failed

## Overview

This plugin warns on any `systemd` unit file which is in a failed state (whether active state or sub state).


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/systemd-units-failed> |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |


## Help

```text
usage: systemd-units-failed [-h] [-V] [--always-ok] [--ignore IGNORE]
                            [--test TEST]

Checks for failed systemd units. Alerts when any unit is in a failed state.
Specific units can be excluded from the check via --ignore with regular
expressions.

options:
  -h, --help       show this help message and exit
  -V, --version    show program's version number and exit
  --always-ok      Always returns OK.
  --ignore IGNORE  Unit name to exclude from the check. Can be specified
                   multiple times. Supports glob patterns according to
                   https://docs.python.org/3/library/fnmatch.html. Example:
                   `--ignore "dhcpd.service"`. Default: []
  --test TEST      For unit tests. Needs "path-to-stdout-file,path-to-stderr-
                   file,expected-retc".
```


## Usage Examples

```bash
./systemd-units-failed --ignore=openipmi.service --ignore=dhcpd.service
./systemd-units-failed --ignore=sshd@*.service
```

Output:

```text
1 failed unit: ipmievd.service

unit            ! load   ! active ! sub    ! description
----------------+--------+--------+--------+----------------
ipmievd.service ! loaded ! failed ! failed ! Ipmievd Daemon
```


## States

* WARN if at least one unit has a failed active state or failed sub state.


## Perfdata / Metrics

* systemd-units-failed: Number of failed units


## Troubleshooting

If you can't do anything and simply want to reset the status of a failed unit, do this:

```bash
systemctl reset-failed ipmievd.service
```


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
