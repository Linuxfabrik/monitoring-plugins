# Check procs

## Overview

Monitors running processes and alerts on process count, aggregated memory usage, or aggregated CPU usage. Processes can be filtered by name, command-line arguments, and user name using regular expressions. Optionally lists the top processes by CPU time and memory usage.

**Data Collection:**

* Uses `psutil.process_iter()` to iterate over all running processes
* Collects per-process data: name, status, memory_info, cpu_times, create_time, cmdline, username (depending on which filters and features are enabled)
* `--argument`, `--command`, and `--username` use Python regular expressions (case-insensitive)
* The `--top` table aggregates processes by name and shows the top N by cumulative CPU time
* CPU usage (`--warning-cpu-percent`/`--critical-cpu-percent`) requires a local SQLite database for delta calculation between runs. A value of 100% equals one fully utilized CPU core. On multi-core systems, values above 100% are possible.
* Supports extended reporting via `--lengthy`, which adds all platform-specific `memory_info()` fields to the `--top` table

**Important Notes:**

* Some process names in psutil do not match the ones from `ps aux`. Use the troubleshooting section below to get the correct process names.
* Memory fields vary by platform. On Linux: rss, vms, shared, text, lib, data, dirty. On Windows: rss, vms, num_page_faults, peak_rss, peak_paged_pool, paged_pool, peak_nonpaged_pool, nonpaged_pool, peak_vms, private. Fields not available on the current platform are automatically omitted.

**Compatibility:**

* Cross-platform: Linux and Windows


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/procs> |
| Nagios/Icinga Check Name              | `check_procs` |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | Yes |
| 3rd Party Python modules              | `psutil` |
| Uses SQLite DBs                       | `$TEMP/linuxfabrik-monitoring-plugins-procs.db` (only when using `--warning-cpu-percent` or `--critical-cpu-percent`) |


## Help

```text
usage: procs [-h] [-V] [--always-ok] [--argument ARGUMENT] [--command COMMAND]
             [-c CRIT] [--critical-age CRIT_AGE]
             [--critical-cpu-percent CRIT_CPU_PERCENT]
             [--critical-mem CRIT_MEM]
             [--critical-mem-percent CRIT_MEM_PERCENT] [--lengthy]
             [--no-kthreads]
             [--status {dead,disk-sleep,idle,locked,parked,running,sleeping,stopped,suspended,tracing-stop,waiting,wake-kill,waking,zombie}]
             [--top TOP] [--username USERNAME] [-w WARN]
             [--warning-age WARN_AGE] [--warning-cpu-percent WARN_CPU_PERCENT]
             [--warning-mem WARN_MEM] [--warning-mem-percent WARN_MEM_PERCENT]

Monitors running processes and alerts on process count, aggregated memory
usage, or aggregated CPU usage. Processes can be filtered by name, command-
line arguments, and user name using regular expressions. Optionally lists the
top processes by CPU time and memory usage. Supports extended reporting via
--lengthy.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --argument ARGUMENT   Filter by command line arguments using a regular
                        expression (case-insensitive). Example: `--argument="
                        --config.*production"`
  --command COMMAND     Filter by process name using a regular expression
                        (case-insensitive). Example:
                        `--command="^(apache|httpd)"`
  -c, --critical CRIT   CRIT threshold for the number of matching processes.
                        Default: None
  --critical-age CRIT_AGE
                        CRIT threshold for age of the oldest matching process,
                        in seconds. Default: None
  --critical-cpu-percent CRIT_CPU_PERCENT
                        CRIT threshold for aggregated CPU usage of all
                        matching processes, in percent. Requires two
                        consecutive check runs to calculate. 100% equals one
                        fully utilized CPU core. Default: None
  --critical-mem CRIT_MEM
                        CRIT threshold for aggregated memory usage, in bytes.
                        Default: None
  --critical-mem-percent CRIT_MEM_PERCENT
                        CRIT threshold for aggregated memory usage, in
                        percent. Default: None
  --lengthy             Extended reporting.
  --no-kthreads         Exclude kernel threads from the scan (Linux only).
  --status {dead,disk-sleep,idle,locked,parked,running,sleeping,stopped,suspended,tracing-stop,waiting,wake-kill,waking,zombie}
                        Filter by process status. Default: None
  --top TOP             Number of top processes by CPU time to display.
                        Processes with zero CPU time are excluded. Use
                        `--top=0` to disable. Default: 5
  --username USERNAME   Filter by user name using a regular expression (case-
                        insensitive). Example: `--username="^(apache|www-
                        data)$"`
  -w, --warning WARN    WARN threshold for the number of matching processes.
                        Default: None
  --warning-age WARN_AGE
                        WARN threshold for age of the oldest matching process,
                        in seconds. Default: None
  --warning-cpu-percent WARN_CPU_PERCENT
                        WARN threshold for aggregated CPU usage of all
                        matching processes, in percent. Requires two
                        consecutive check runs to calculate. 100% equals one
                        fully utilized CPU core. Default: None
  --warning-mem WARN_MEM
                        WARN threshold for aggregated memory usage, in bytes.
                        Default: None
  --warning-mem-percent WARN_MEM_PERCENT
                        WARN threshold for aggregated memory usage, in
                        percent. Default: None
```


## Usage Examples

```bash
./procs
```

Output:

```text
582 procs using 17.2GiB RAM (55.6%), 581 sleeping, 1 zombie (1x xdg-open), up 1W 1D

Name               ! CPU Total ! RSS      ! Status
-------------------+-----------+----------+------------
firefox            ! 6h 34m    ! 980.4MiB ! 1x sleeping
gnome-shell        ! 5h 49m    ! 692.2MiB ! 1x sleeping
WebExtensions      ! 3h 14m    ! 1.8GiB   ! 1x sleeping
rocketchat-desktop ! 2h 9m     ! 739.5MiB ! 9x sleeping
claude             ! 1h 7m     ! 2.3GiB   ! 5x sleeping
```

With `--lengthy`, the table includes all platform-specific `memory_info()` fields from the installed psutil version (fields that are not available are automatically omitted):

```bash
./procs --lengthy
```

Output (Linux, psutil 7.x):

```text
575 procs using 18.1GiB RAM (58.7%), 574 sleeping, 1 zombie (1x xdg-open), up 1W 1D

Name          ! CPU User ! CPU System ! CPU Total ! RSS      ! VMS     ! Shared   ! Text     ! Lib  ! Data     ! Dirty ! Status
--------------+----------+------------+-----------+----------+---------+----------+----------+------+----------+-------+------------
firefox       ! 5h 15m   ! 1h 19m     ! 6h 35m    ! 978.1MiB ! 21.1GiB ! 229.1MiB ! 300.0KiB ! 0.0B ! 1.6GiB   ! 0.0B  ! 1x sleeping
gnome-shell   ! 4h 13m   ! 1h 36m     ! 5h 50m    ! 693.2MiB ! 7.3GiB  ! 122.4MiB ! 12.0KiB  ! 0.0B ! 931.9MiB ! 0.0B  ! 1x sleeping
WebExtensions ! 2h 59m   ! 15m 40s    ! 3h 14m    ! 1.8GiB   ! 9.9GiB  ! 105.2MiB ! 300.0KiB ! 0.0B ! 3.1GiB   ! 0.0B  ! 1x sleeping
```

Other examples:

```bash
./procs --no-kthreads --always-ok

# warn if there are less than two or more than 100 httpd processes
./procs --command='^httpd' --warning=2:100 --critical=1:150

# warn if a "duplicity" backup process runs longer than 8 hours or uses more than 50% RAM
./procs --command='^duplicity' --warning-age=28800 --warning-mem-percent=50

# warn if at least 1 zombie process exists
./procs --status=zombie --warning=0

# count Firefox processes (Firefox's process name is "Web Content")
./procs --command='(?i)web content'

# warn if httpd uses more than 200% CPU (2 fully utilized cores)
./procs --command='^httpd' --warning-cpu-percent=200

# match multiple process names using regex
./procs --command='^(apache|httpd|nginx)'
```

## States

* OK if all metrics are within the configured thresholds.
* WARN or CRIT if the number of matching processes is outside the `--warning`/`--critical` range.
* WARN or CRIT if aggregated memory usage exceeds the configured thresholds.
* WARN or CRIT if aggregated CPU usage exceeds the configured thresholds (requires two consecutive runs).
* WARN or CRIT if the oldest matching process age exceeds the configured thresholds.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| procs | Number | Number of processes found matching the filter criteria. |
| procs_age | Continous Counter | Age of the oldest process found, in seconds. |
| procs_cpu_percent | Percentage | Aggregated CPU usage of all matching processes (only when using `--warning-cpu-percent` or `--critical-cpu-percent`). |
| procs_dead | Number | Number of dead processes. |
| procs_mem | Bytes | Aggregated RSS memory usage of matching processes. |
| procs_mem_percent | Percentage | Aggregated RSS memory usage, in percent. |
| procs_running | Number | Number of processes in running state. |
| procs_sleeping | Number | Number of processes in idle or interruptible sleep state. |
| procs_stopped | Number | Number of processes stopped by debugger during tracing or by job control signal. |
| procs_uninterruptible | Number | Number of processes in uninterruptible state. |
| procs_zombies | Number | Number of zombie processes. |


## Troubleshooting

`Python module "psutil" is not installed.`
Install `psutil`: `pip install psutil` or `dnf install python3-psutil`.

How to get process names? Some process names in Python's psutil do not match the ones from `ps aux`. To get a list with all processes, their names and details from a Python point of view, do:

```python
(echo "import psutil"; echo "processes = psutil.process_iter()"; echo "for process in processes: print(process)") | python
```


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
