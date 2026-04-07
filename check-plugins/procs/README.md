# Check procs

## Overview

Prints the number of currently running processes and warns on metrics like process counts, process memory usage or CPU usage. You may filter the process list by process name, arguments and/or user name using regular expressions.

Hints:

* Memory: We count RSS, also known as 'Resident Set Size' or 'Res'. This is the amount of physical memory that a process has used that has not been swapped out. In UNIX, it matches the 'RES' column in 'top'. Note the differences in memory counting between tools such as 'top', 'htop', 'glances', 'GNOME System Monitor' and others. The way memory is counted also changes between different Linux kernel versions. On Windows, this is an alias for the wset field, matching the 'Mem Usage' column in taskmgr.exe.
* CPU usage: The `--warning-cpu-percent` and `--critical-cpu-percent` thresholds compare the aggregated CPU usage of all matching processes against the given threshold. This requires at least two consecutive check runs for the delta calculation. A value of 100% equals one fully utilized CPU core. On multi-core systems, values above 100% are possible.


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
             [--critical-mem-percent CRIT_MEM_PERCENT] [--no-kthreads]
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
  --no-kthreads         Filter: Only scan for non kernel threads (works on
                        Linux only). Default: False
  --status {dead,disk-sleep,idle,locked,parked,running,sleeping,stopped,suspended,tracing-stop,waiting,wake-kill,waking,zombie}
                        Filter: Search only for processes that have a specific
                        status. Default: None
  --top TOP             List the top N processes using the most CPU time.
                        Processes where all instances are sleeping are
                        excluded from the table. Use `--top=0` to disable this
                        feature. Default: 5
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
564 procs using 16.9GiB RAM (54.7%), 1 uninterruptible (1x kworker/u36:0+i915_flip), 1 running (1x isolated web co), 561 sleeping, 1 zombie (1x xdg-open), up 1W 1D

Name             ! CPU User ! CPU System ! CPU Total ! Status
-----------------+----------+------------+-----------+-----------------------------
isolated web co  ! 1h 24m   ! 12m 30s    ! 1h 37m    ! 1x running
kworker/u36:0+i9 !          ! 5s         ! 5s        ! 1x disk-sleep
xdg-open         !          !            !           ! 1x zombie
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
