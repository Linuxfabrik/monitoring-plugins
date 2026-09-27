# Check scheduled-task


## Overview

Checks the state of a Windows Scheduled Task and the result of its last run. Alerts when the task is not in one of the expected states, or when its last run failed, for example because the program returned a non-zero exit code, could not be started, or was stopped for running too long. Works regardless of the display language of the host.

**Important Notes:**

* The account the monitoring agent runs as has to be allowed to see the task. `NT AUTHORITY\NetworkService`, which the Icinga 2 MSI package uses by default, does not see tasks that an administrator created in a folder of their own; the check then reports the task as not found. Running the agent as `LocalSystem` sees every task.
* The Icinga 2 agent for Windows hands the arguments to the plugin in the ANSI code page of the host, so a task path with characters outside of ASCII (for example `Prüfung`) does not arrive intact and is reported as not found.
* A disabled task keeps the result of its last run from before it was disabled. The check does not evaluate that result.

**Data Collection:**

* Reads the state and the result of the last run of every task from the Windows Task Scheduler through PowerShell, and picks the task given by `--task`. The task path is compared case-insensitively.
* The state and the result are numbers, not the translated texts that `schtasks` prints, so the check works on every display language.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/scheduled-task> |
| Nagios/Icinga Check Name              | `check_scheduled_task` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | No (`--task` is required) |
| Runs on                               | Windows |
| Compiled for Windows                  | Yes |
| Requirements                          | PowerShell (ships with Windows) |


## Help

```text
usage: scheduled-task [-h] [-V] [--always-ok] [--severity {warn,crit}]
                      [--status {Disabled,Queued,Ready,Running,Unknown}]
                      --task TASK [--timeout TIMEOUT]

Checks the state of a Windows Scheduled Task and the result of its last run.
Alerts when the task is not in one of the expected states, or when its last
run failed, for example because the program returned a non-zero exit code,
could not be started, or was stopped for running too long. Works regardless of
the display language of the host.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --severity {warn,crit}
                        Severity when the task is not in an expected state or
                        its last run failed. Default: warn
  --status {Disabled,Queued,Ready,Running,Unknown}
                        Expected task state. Can be specified multiple times.
                        Default: Ready, Running
  --task TASK           Path of the Windows scheduled task to check, its
                        folder followed by its name, as the Task Scheduler
                        shows it. Case-insensitive. Example:
                        `--task=\Microsoft\Windows\Defrag\ScheduledDefrag`.
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/scheduled-task/
```


## Usage Examples

```bash
scheduled-task.exe --task='\Microsoft\Windows\Defrag\ScheduledDefrag'
```

Output:

```text
\Microsoft\Windows\Defrag\ScheduledDefrag is Ready, last run 2026-09-27 02:53:12 succeeded
```

A task whose program returned exit code 1:

```text
\Backup\Nightly is Ready, last run 2026-09-27 02:00:00 returned 0x1 [WARNING]
```

A task that has to stay disabled:

```bash
scheduled-task.exe --task='\Microsoft\Windows\Defrag\ScheduledDefrag' --status=Disabled --severity=crit
```

Output:

```text
\Microsoft\Windows\Defrag\ScheduledDefrag is Ready [CRITICAL], but supposed to be Disabled, last run 2026-09-27 02:53:12 succeeded
```


## States

* OK if the task is in one of the states given by `--status` (default: Ready, Running) and its last run succeeded, it is running right now, or it has not run yet.
* WARN (default) or CRIT (depending on `--severity`) if the task is in another state.
* WARN (default) or CRIT (depending on `--severity`) if the last run failed: the program returned an exit code other than 0, could not be started, or was stopped by a user or by the execution time limit. Not evaluated for a disabled task.
* WARN on a timeout while listing the scheduled tasks.
* UNKNOWN if the task is not found, or if the Task Scheduler cannot be queried.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

There is no perfdata.


## Troubleshooting

### A task that exists is reported as not found

The account the monitoring agent runs as cannot see the task. See the Important Notes above: run the agent as `LocalSystem`, or grant its account read access to the task. A task path with characters outside of ASCII is reported as not found as well, because it does not reach the plugin intact.

### `returned 0x1`

The program the task starts returned exit code 1. What that means is up to the program; its documentation or its log says more. `schtasks /query /tn "<task>" /v /fo list` shows the command line the task runs.

### `returned 0x41306`

The last run was stopped before it finished, either by a user or because it exceeded the execution time limit of the task ("Stop the task if it runs longer than" on the Settings tab). Check the history of the task in the Task Scheduler, and raise the limit if the task legitimately needs more time.

### `returned 0x80070002`

The program the task starts does not exist ("The system cannot find the file specified"). Check the path in the action of the task. Other codes starting with `0x8007` are Windows error codes as well: `0x80070005` means access denied, for example.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
