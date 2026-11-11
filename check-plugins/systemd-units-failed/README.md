# Check systemd-units-failed


## Overview

Checks for failed systemd units by running `systemctl --state=failed`. Reports any unit that is in a failed active state or failed sub state, and says why each unit failed: the exit status or the signal of its main process, a timeout, a start limit or the OOM killer. With read access to the systemd journal, the check also shows the last three log lines of each failed unit, which usually name the actual error.

When no unit is currently failed, the plugin reads the current boot's journal for the most recent system unit-failed event and appends it to the output, so the admin sees how long the host has been clean since the last reboot and which unit last broke.

**Data Collection:**

* Executes `systemctl --state=failed --no-pager --no-legend`
* For the failed units, executes `systemctl show --property=Result,ExecMainCode,ExecMainStatus` once, which needs no privileges. Exit statuses from 200 on are set by systemd itself and carry systemd's name (`203/EXEC`: the executable was not found, `217/USER`: the user does not exist), see [systemd.exec(5)](https://www.freedesktop.org/software/systemd/man/latest/systemd.exec.html#Process%20Exit%20Codes)
* For the first five failed units, executes `journalctl --boot=0 --output=cat --lines=3 _SYSTEMD_UNIT=<unit>`, which shows what the unit's own processes logged, without systemd's messages about the unit. All calls together get 5 seconds. Reading the system journal needs root, sudo or the `systemd-journal` group; without, the check names the `journalctl` command to run instead
* When everything is OK, additionally runs `journalctl --output=short-unix --boot=0 _PID=1 --grep="Failed with result"` and picks the last matching line client-side, to read the most recent system-scope unit-failed event of the current boot. Scoping to `--boot=0` keeps the call fast regardless of total journal size. If `journalctl` is unavailable, takes longer than 5 seconds, returns nothing, or its entry cannot be parsed, the suffix is silently omitted
* Units can be excluded from the check via `--ignore`, which supports glob patterns according to Python's `fnmatch` module (e.g. `--ignore="sshd@*.service"`). A pattern matches the unit name as systemd writes it (`dev-disk-by\x2duuid-0a1b2c3d.swap`) as well as its readable form (`dev-disk-by-uuid-0a1b2c3d.swap`), in the list of failed units and in the journal alike


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
                            [--no-perfdata]

Checks for failed systemd units. Alerts when any unit is in a failed state,
and says why each unit failed, for example the exit status or the signal that
killed it. With read access to the systemd journal, also shows the last log
lines of each failed unit. Specific units can be excluded from the check via
--ignore with glob patterns. When no unit is currently failed, reports the
most recent system unit-failed event from the current boot's journal so
operators see at a glance how long the host has been clean since the last
reboot.

options:
  -h, --help       show this help message and exit
  -V, --version    show program's version number and exit
  --always-ok      Always returns OK.
  --ignore IGNORE  Unit name to exclude from the check. Supports glob patterns
                   according to
                   https://docs.python.org/3/library/fnmatch.html. Case-
                   sensitive. Can be specified multiple times. Example:
                   `--ignore=dhcpd.service`.
  --no-perfdata    Suppress the performance data section from the output. The
                   status message and the exit code are unaffected, so
                   alerting keeps working while trending data is dropped.

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/systemd-units-failed/
```


## Usage Examples

```bash
./systemd-units-failed --ignore=openipmi.service --ignore=dhcpd.service
```

```bash
./systemd-units-failed --ignore=sshd@*.service
```

Output (something is failing, with read access to the journal):

```text
1 failed unit: httpd.service (exited with status 1)

unit          ! load   ! active ! sub    ! description
--------------+--------+--------+--------+-----------------------
httpd.service ! loaded ! failed ! failed ! The Apache HTTP Server

Last log lines of httpd.service:
httpd.service: Referenced but unset environment variable evaluates to an empty string: OPTIONS
AH00526: Syntax error on line 359 of /etc/httpd/conf/httpd.conf:
Invalid command 'ServerNmae', perhaps misspelled or defined by a module not included in the server configuration

Show the log with `sudo journalctl --boot=0 --unit=httpd.service`
```

Output (something is failing, without read access to the journal):

```text
1 failed unit: httpd.service (exited with status 1)

unit          ! load   ! active ! sub    ! description
--------------+--------+--------+--------+-----------------------
httpd.service ! loaded ! failed ! failed ! The Apache HTTP Server

Show the log with `sudo journalctl --boot=0 --unit=httpd.service`
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

### No last log lines, only `Show the log with sudo journalctl ...`

The account running the check may not read the system journal. Either run the command by hand, or let the check show the last log lines itself by adding the account to the `systemd-journal` group, which may read the whole journal:

```bash
sudo usermod --append --groups systemd-journal icinga
```

The group takes effect after a restart of the monitoring agent (`sudo systemctl restart icinga2`). The last log lines are missing too when the units logged nothing themselves, for example after a timeout; `journalctl --unit` then still shows systemd's messages about them. The command always follows the output and names every failed unit, since the last log lines are only a first hint and cover the first five units at most.

### Resetting a failed unit

If you cannot fix the underlying issue and simply want to reset the status of a failed unit:

```bash
systemctl reset-failed ipmievd.service
```


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
