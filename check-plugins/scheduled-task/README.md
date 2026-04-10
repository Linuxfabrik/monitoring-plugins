# Check scheduled-task


## Overview

Checks the status of a Windows Scheduled Task. Alerts when the task is not in the expected status.

**Data Collection:**

* Executes `schtasks /query /fo csv /nh` to list all scheduled tasks and their statuses
* Matches the specified task name exactly


## Fact Sheet

| Fact | Value |
|----|---|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/scheduled-task> |
| Nagios/Icinga Check Name              | `check_scheduled_task` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | No (`--task` is required) |
| Runs on                               | Windows |
| Compiled for Windows                  | Yes |
| 3rd Party Python modules              | `psutil` |


## Help

```text
usage: scheduled-task [-h] [-V] [--severity {warn,crit}]
                      [--status {Disabled,Queued,Ready,Running,Unknown}]
                      --task TASK

Checks the status and last result of a Windows Scheduled Task. Alerts when the
task has failed or returned a non-zero exit code.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --severity {warn,crit}
                        Severity when the task is not in the expected status.
                        Default: warn
  --status {Disabled,Queued,Ready,Running,Unknown}
                        Expected task status. Can be specified multiple times.
                        Default: ['Ready', 'Running']
  --task TASK           Name of the Windows scheduled task to check.
```


## Usage Examples

```bash
scheduled-task.exe --task \Microsoft\Windows\DiskCleanup\SilentCleanup --status Disabled --severity crit
```

Output:

```text
\Microsoft\Windows\DiskCleanup\SilentCleanup is Ready
```


## States

* OK if the task is in one of the expected statuses.
* WARN (default) or CRIT (depending on `--severity`) if the task is not in the expected status.
* UNKNOWN if the specified scheduled task is not found.


## Perfdata / Metrics

There is no perfdata.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
