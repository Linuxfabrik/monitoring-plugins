# Check systemd-units-failed


## Overview

Checks for failed systemd units by running `systemctl --state=failed`. Reports any unit that is in a failed active state or failed sub state.

**Data Collection:**

* Executes `systemctl --state=failed --no-pager --no-legend`
* Units can be excluded from the check via `--ignore`, which supports glob patterns according to Python's `fnmatch` module (e.g. `--ignore "sshd@*.service"`)

**Compatibility:**

* Linux


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/systemd-units-failed> |
| Nagios/Icinga Check Name              | `check_systemd_units_failed` |
| Check Interval Recommendation         | Every minute |
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
```

```bash
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

* OK if no units are in a failed state.
* WARN if at least one unit has a failed active state or failed sub state.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| systemd-units-failed | Number | Number of failed units |


## Troubleshooting

If you cannot fix the underlying issue and simply want to reset the status of a failed unit:

```bash
systemctl reset-failed ipmievd.service
```


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
