# Check scheduled-task

## Overview

Checks the status of a Windows scheduled task.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/scheduled-task> |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | No |
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
                        Default: warn.
  --status {Disabled,Queued,Ready,Running,Unknown}
                        Expected task status. Can be specified multiple times.
                        Default: ['Ready', 'Running'].
  --task TASK           Name of the Windows scheduled task to check.
```


## Usage Examples

```bash
scheduled-task.exe --task \Microsoft\Windows\DiskCleanup\SilentCleanup --status Disabled  --severity crit
```

Output:

```text
\Microsoft\Windows\DiskCleanup\SilentCleanup is Ready
```


## States

* WARN if result does not match the expected status.
* CRIT only if configured as such.


## Perfdata / Metrics

There is no perfdata.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
