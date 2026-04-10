# Check journald-usage

## Overview

Checks the current disk usage of all systemd journal files (archived and active combined) and alerts when journal disk usage exceeds a configurable threshold.

**Important Notes:**

* From `man journald.conf`: `SystemMaxUse=` and `RuntimeMaxUse=` control how much disk space the journal may use at most. `SystemKeepFree=` and `RuntimeKeepFree=` control how much disk space systemd-journald shall leave free for other uses. systemd-journald respects both limits and uses the smaller of the two values. The defaults are 10% and 15% of the file system size, capped to 4G each. Only archived files are deleted during vacuuming, so actual usage may exceed the configured limits.


**Data Collection:**

* Executes `journalctl --disk-usage` to obtain the total disk usage of all archived and active journal files
* Reads the effective journald configuration via `systemd-analyze cat-config systemd/journald.conf` to report the current `SystemMaxUse` and `SystemKeepFree` values
* Requires root or sudo privileges to access journal data

**Compatibility:**

* Linux


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/journald-usage> |
| Nagios/Icinga Check Name              | `check_journald_usage` |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |


## Help

```text
usage: journald-usage [-h] [-V] [--always-ok] [--test TEST] [-w WARN]

Checks the current disk usage of all systemd journal files (archived and
active combined). Alerts when journal disk usage exceeds the configured
thresholds. Requires root or sudo.

options:
  -h, --help          show this help message and exit
  -V, --version       show program's version number and exit
  --always-ok         Always returns OK.
  --test TEST         For unit tests. Needs "path-to-stdout-file,path-to-
                      stderr-file,expected-retc".
  -w, --warning WARN  WARN threshold in GiB. Default: >= 6
```


## Usage Examples

```bash
./journald-usage --warning=500
```

Output:

```text
3.0GiB used [WARNING] (sum of all archived and active journal files; SystemMaxUse=595M SystemKeepFree=1388M).
Configure `SystemMaxUse` and `SystemKeepFree` in `/etc/systemd/journald.conf/`, or remove the oldest archived
journal files by using `journalctl --vacuum-size=`, `--vacuum-time=` and/or `--vacuum-files=`.
```


## States

* OK if the total journal disk usage is below `--warning` (default: 6 GiB).
* WARN if the total journal disk usage is >= `--warning` (default: 6 GiB).
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| journald-usage | Bytes | Total size of all archived and active journal files. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
