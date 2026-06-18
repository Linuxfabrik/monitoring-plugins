# Check systemd-units-failed


## Overview

Checks for failed systemd units by running `systemctl --state=failed`. Reports any unit that is in a failed active state or failed sub state.

When no unit is currently failed, the plugin reads the current boot's journal for the most recent system unit-failed event and appends it to the output, so the admin sees how long the host has been clean since the last reboot and which unit last broke.

**Data Collection:**

* Executes `systemctl --state=failed --no-pager --no-legend`
* When everything is OK, additionally runs `journalctl --output=short-unix --boot=0 _PID=1 --grep="Failed with result"` and picks the last matching line client-side, to read the most recent system-scope unit-failed event of the current boot. Scoping to `--boot=0` keeps the call fast regardless of total journal size. If `journalctl` is unavailable, returns nothing, or its entry cannot be parsed, the suffix is silently omitted
* Units can be excluded from the check via `--ignore`, which supports glob patterns according to Python's `fnmatch` module (e.g. `--ignore "sshd@*.service"`)


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/systemd-units-failed> |
| Nagios/Icinga Check Name              | `check_systemd_units_failed` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Runs on                               | Linux |
| Compiled for Windows                  | No |


## Help

```text
usage: systemd-units-failed [-h] [-V] [--always-ok] [--ignore IGNORE]
                            [--test TEST]

Checks for failed systemd units. Alerts when any unit is in a failed state.
Specific units can be excluded from the check via --ignore with regular
expressions. When no unit is currently failed, reports the most recent system
unit-failed event from the current boot's journal so operators see at a glance
how long the host has been clean since the last reboot.

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

Output (something is failing):

```text
1 failed unit: ipmievd.service

unit            ! load   ! active ! sub    ! description
----------------+--------+--------+--------+----------------
ipmievd.service ! loaded ! failed ! failed ! Ipmievd Daemon
```

Output (currently clean, with last failure surfaced from the journal):

```text
Everything is ok. Last failed: `ipmievd.service` with message "Failed with result 'exit-code'" at 2026-04-30 12:01:53 (1W 2D ago)
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

### Resetting a failed unit

If you cannot fix the underlying issue and simply want to reset the status of a failed unit:

```bash
systemctl reset-failed ipmievd.service
```


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
