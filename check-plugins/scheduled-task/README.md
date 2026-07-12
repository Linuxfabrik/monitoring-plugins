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
Traceback (most recent call last):
  File "/home/markusfrei/git/linuxfabrik/github/monitoring-plugins/check-plugins/scheduled-task/scheduled-task", line 117, in 'module'
    main()
    ~~~~^^
  File "/home/markusfrei/git/linuxfabrik/github/monitoring-plugins/check-plugins/scheduled-task/scheduled-task", line 86, in main
    args = parse_args()
  File "/home/markusfrei/git/linuxfabrik/github/monitoring-plugins/check-plugins/scheduled-task/scheduled-task", line 44, in parse_args
    help=lib.args.help('--always-ok'),
         ^^^^^^^^
AttributeError: module 'lib' has no attribute 'args'
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
