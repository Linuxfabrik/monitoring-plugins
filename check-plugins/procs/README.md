# Check procs

## Overview

Prints the number of currently running processes and warns on metrics like process counts, process memory usage or CPU usage. You may filter the process list by process name, arguments and/or user name using regular expressions.

Hints:

* CPU usage: The `--warning-cpu-percent` and `--critical-cpu-percent` thresholds compare the aggregated CPU usage of all matching processes against the given threshold. This requires at least two consecutive check runs for the delta calculation. A value of 100% equals one fully utilized CPU core. On multi-core systems, values above 100% are possible.
* Memory: The `--top` table reports per-process memory fields from psutil's `memory_info()`. Note the differences in memory counting between tools such as `top`, `htop`, `glances`, `GNOME System Monitor` and others. The way memory is counted also changes between different Linux kernel versions. The following fields are available (all values in bytes):

Portable (all platforms):

| Field | Description |
|----|----|
| rss | Resident Set Size. The non-swapped physical memory a process has used. On UNIX matches the `top` RES column. On Windows maps to `WorkingSetSize`. |
| vms | Virtual Memory Size. The total amount of virtual memory used by the process. On UNIX matches the `top` VIRT column. On Windows maps to `PrivateUsage` (private committed pages only), which differs from the UNIX definition. |

Linux:

| Field | Description |
|----|----|
| data | Aka DRS (Data Resident Set). Covers the data and stack segments combined (from `/proc/<pid>/statm`). Matches `top`'s DATA column. |
| shared | Shared memory that could be shared with other processes (shared libraries, memory-mapped files). Counted even if no other process is currently mapping it. Matches `top`'s SHR column. |
| text | Aka TRS (Text Resident Set). Resident memory devoted to executable code. This memory is read-only and typically shared across all processes running the same binary. Matches `top`'s CODE column. |

Windows:

| Field | Description |
|----|----|
| nonpaged_pool | Current nonpaged pool usage. Kernel memory used for objects that must remain in physical memory. |
| num_page_faults | The number of page faults. |
| pagefile | The Commit Charge value for this process (same as `vms`). |
| paged_pool | Current paged pool usage. Kernel memory used for objects created by the process that can be paged to disk. |
| peak_nonpaged_pool | Peak nonpaged pool usage. |
| peak_paged_pool | Peak paged pool usage. |
| peak_pagefile | Peak Commit Charge during the lifetime of this process. |
| peak_wset | Peak working set size (same as peak RSS). |
| private | Same as `vms`. |
| wset | Current working set size (same as `rss`). |


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/procs> |
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

Prints the number of currently running processes and warns on metrics like
process counts, process memory usage or CPU usage. You may filter the process
list by process name, arguments and/or user name using regular expressions.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --argument ARGUMENT   Filter: Search only for processes where the command
                        line matches ARGUMENT as a regular expression (case-
                        insensitive). Example: `--argument="--
                        config.*production"`
  --command COMMAND     Filter: Search only for processes whose name matches
                        COMMAND as a regular expression (case-insensitive).
                        Example: `--command="^(apache|httpd)"`
  -c, --critical CRIT   Threshold for the number of processes. Type: None or
                        Range. Default: None
  --critical-age CRIT_AGE
                        Threshold for age of the process, in seconds. Type:
                        None or Range. Default: None
  --critical-cpu-percent CRIT_CPU_PERCENT
                        Threshold for CPU usage of all matching processes, in
                        percent. Requires two consecutive check runs to
                        calculate. A value of 100% equals one fully utilized
                        CPU core. Type: None or Range. Default: None
  --critical-mem CRIT_MEM
                        Threshold for memory usage, in bytes. Type: None or
                        Range. Default: None
  --critical-mem-percent CRIT_MEM_PERCENT
                        Threshold for memory usage, in percent. Type: None or
                        Range. Default: None
  --lengthy             Extended reporting.
  --no-kthreads         Filter: Only scan for non kernel threads (works on
                        Linux only). Default: False
  --status {dead,disk-sleep,idle,locked,parked,running,sleeping,stopped,suspended,tracing-stop,waiting,wake-kill,waking,zombie}
                        Filter: Search only for processes that have a specific
                        status. Default: None
  --top TOP             List the top N processes using the most CPU time.
                        Processes with zero CPU time are excluded from the
                        table. Use `--top=0` to disable this feature. Default:
                        5
  --username USERNAME   Filter: Search only for processes whose user name
                        matches USERNAME as a regular expression (case-
                        insensitive). Example: `--username="^(apache|www-
                        data)$"`
  -w, --warning WARN    Threshold for the number of processes. Type: None or
                        Range. Default: None
  --warning-age WARN_AGE
                        Threshold for age of the process, in seconds. Type:
                        None or Range. Default: None
  --warning-cpu-percent WARN_CPU_PERCENT
                        Threshold for CPU usage of all matching processes, in
                        percent. Requires two consecutive check runs to
                        calculate. A value of 100% equals one fully utilized
                        CPU core. Type: None or Range. Default: None
  --warning-mem WARN_MEM
                        Threshold for memory usage, in bytes. Type: None or
                        Range. Default: None
  --warning-mem-percent WARN_MEM_PERCENT
                        Threshold for memory usage, in percent. Type: None or
                        Range. Default: None
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

* WARN or CRIT depending on your parameters, or if no process can be found.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| procs | Number | Number of procs found matching the filter criteria |
| procs_age | Continous Counter | Age of the oldest proc found in seconds |
| procs_cpu_percent | Percentage | Aggregated CPU usage of all matching processes (only when using `--warning-cpu-percent` or `--critical-cpu-percent`) |
| procs_dead | Number | Number of dead procs |
| procs_mem | Bytes | RAM usage of procs found |
| procs_mem_percent | Percentage | RAM usage of procs found |
| procs_running | Number | Number of procs in running state |
| procs_sleeping | Number | Number of procs in idle or interruptible sleep state |
| procs_stopped | Number | Number of procs stopped by debugger during the tracing or by job control signal |
| procs_uninterruptible | Number | Number of procs in uninterruptible state |
| procs_zombies | Number | Number of zombie processes |


## Troubleshooting

How to get process names? Some process names in Python's psutil do not match the ones from `ps aux`. To get a list with all processes, their names and details from a Python point of view, do:

```python
(echo "import psutil"; echo "processes = psutil.process_iter()"; echo "for process in processes: print(process)") | python
```


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
