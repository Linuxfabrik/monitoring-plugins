# Check borgbackup


## Overview

Checks the status of the last borgbackup run by parsing the borg logfile. Alerts on non-zero return codes from the create or prune steps, and warns if the last successful backup is older than a configurable threshold (default: 24 hours). Also detects active borg mounts in /proc/mounts. Requires root or sudo.

**Important Notes:**

* The logfile must contain lines in the format `start: YYYY-MM-DD HH:MM:SS`, `end: YYYY-MM-DD HH:MM:SS`, `create_retc: N`, `prune_retc: N`
* Borg return code 1 (warning) is treated as OK by the check; return codes >= 2 trigger alerts
* If the logfile is missing or incomplete (any of the four fields not found), the check exits with UNKNOWN
* Active `borgfs` mounts are reported as WARN immediately, before evaluating the logfile

**Data Collection:**

* Parses `/var/log/borg/borg.log` for four fields: `start`, `end`, `create_retc`, and `prune_retc`
* Checks `/proc/mounts` for active `borgfs` mounts
* Calculates the time since the last backup started and the backup duration


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/borgbackup> |
| Nagios/Icinga Check Name              | `check_borgbackup` |
| Check Interval Recommendation         | Every day |
| Can be called without parameters      | Yes |
| Runs on                               | Linux |
| Compiled for Windows                  | No |


## Help

```text
usage: borgbackup [-h] [-V] [-c CRIT] [-w WARN]

Checks the status of the last borgbackup run by parsing the borg logfile.
Alerts on non-zero return codes from the create or prune steps, and warns if
the last successful backup is older than a configurable threshold (default: 24
hours). Also detects active borg mounts in /proc/mounts. Requires root or
sudo.

options:
  -h, --help           show this help message and exit
  -V, --version        show program's version number and exit
  -c, --critical CRIT  CRIT threshold for the time since the last backup
                       started, in hours. Default: None
  -w, --warning WARN   WARN threshold for the time since the last backup
                       started, in hours. Default: 24
```


## Usage Examples

```bash
./borgbackup
```

Output:

```text
Last Backup started 2021-06-02 23:05:07, ended 2021-06-02 23:05:43, took 36s.
* Create retc: 0, State: 
* Prune retc: 0, State:
```


## States

* OK if the last backup completed successfully (return codes < 2) and is within the time threshold.
* WARN if active `borgfs` mounts are detected.
* WARN if `create_retc` or `prune_retc` is >= 2.
* WARN if the last backup started more than `--warning` hours ago (default: 24).
* CRIT if the last backup started more than `--critical` hours ago (default: None).
* UNKNOWN if the logfile `/var/log/borg/borg.log` is not found, empty, or missing expected fields.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| create_retc | Number | Return code of the borg create step (0 = success, 1 = warning, >= 2 = error). |
| duration | Seconds | Duration of the backup run (end - start). |
| prune_retc | Number | Return code of the borg prune step (0 = success, 1 = warning, >= 2 = error). |


## Troubleshooting

`Could not find all expected values in the logfile.`  
If either `starttime`, `endtime`, `create_retc` or `prune_retc` is missing from the logfile, the backup has failed in some way. Check the borg logs for details.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
