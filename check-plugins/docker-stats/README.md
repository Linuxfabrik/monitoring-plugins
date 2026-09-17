# Check docker-stats


## Overview

Reports CPU and memory usage for all running Docker containers. CPU usage is normalized by dividing by the number of available host CPU cores, so 100% means all host CPUs are fully utilized. Alerts when the CPU usage of a container has been outside its threshold for a configurable number of consecutive check runs (default: 5), suppressing short spikes, and immediately when its memory usage is outside its threshold. For Podman, use the [podman-stats](https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/podman-stats) check instead. Requires root or sudo.

**Important Notes:**

* Memory usage is relative to the container's memory limit if one is set, otherwise relative to the total host memory.
* Containers can be selected or excluded by name with `--match` / `--ignore` (Python regular expressions, matched against the full name); `--no-match-severity` sets the state when nothing matches (default: ok).
* Per-container CPU and memory perfdata are most useful for long-lived containers with stable names (e.g. `traefik_traefik.2`, named systemd-managed services). For ever-changing workloads (e.g. GitLab runner jobs, CI builders), the per-container labels churn between check runs and are useless for trending. The aggregate perfdata is the right signal there.
* `--timeout` covers all Docker commands of a run together, so the check ends in time however long each of them takes. `docker stats --no-stream` alone takes one to two seconds, because the daemon samples every container twice, one second apart, and the client waits up to two seconds for each.

**Data Collection:**

* Executes `docker info --format '{{json .}}'` to determine the number of host CPU cores
* Executes `docker stats --no-stream --format '{{json .}}'` to get a one-shot snapshot of CPU and memory usage for all running containers
* CPU usage is divided by the number of host CPU cores ("normalized"). On an 8-core system, a container using one core at full capacity would show 12.5%.
* Uses a local SQLite database for the CPU trend across runs. Containers that no longer exist are removed from it, whatever `--match` and `--ignore` select, so several services with different filters can share it.
* Container names are shortened after the replica number by default (use `--full-name` for the full name)
* `docker stats` reports network and block I/O only in a human-readable format (e.g. "4.82GB"), which is too imprecise to derive rates from, so they are not reported


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/docker-stats> |
| Nagios/Icinga Check Name              | `check_docker_stats` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No (runs with Python interpreter) |
| Handles Periods                       | Yes (alerts only after `--count` consecutive threshold violations) |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-docker-stats.db` |


## Help

```text
usage: docker-stats [-h] [-V] [--always-ok] [--count COUNT]
                    [--critical-cpu CRIT_CPU] [--critical-mem CRIT_MEM]
                    [--full-name] [--ignore IGNORE] [--match MATCH]
                    [--no-match-severity {ok,warn,crit,unknown}]
                    [--no-perfdata] [--timeout TIMEOUT]
                    [--warning-cpu WARN_CPU] [--warning-mem WARN_MEM]

Reports CPU and memory usage for all running Docker containers. CPU usage is
normalized by dividing by the number of available host CPU cores, so 100%
means all host CPUs are fully utilized. Alerts when the CPU usage of a
container has been outside its threshold for a configurable number of
consecutive check runs (default: 5), suppressing short spikes, and immediately
when its memory usage is outside its threshold. For Podman, use the
podman-stats check instead. Requires root or sudo.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --count COUNT         Number of consecutive checks the threshold must be
                        exceeded before alerting. Default: 5
  --critical-cpu CRIT_CPU
                        CRIT threshold for CPU usage, in percent. Supports
                        Nagios ranges. Default: 90
  --critical-mem CRIT_MEM
                        CRIT threshold for memory usage, in percent. Supports
                        Nagios ranges. Default: 95
  --full-name           Use the full container name, for example
                        `traefik_traefik.2.1idw12p2yqp`. Without this flag,
                        the name is shortened after the replica number.
  --ignore IGNORE       Ignore containers whose name matches this Python
                        regular expression. Matched against the full container
                        name, even when the displayed name is shortened (see
                        --full-name). Case-sensitive by default; use `(?i)`
                        for case-insensitive matching. Can be specified
                        multiple times. Example: `--ignore="^k8s_"` to skip
                        Kubernetes pod infrastructure containers. Example:
                        `--ignore="(?i)test"` (case-insensitive) to skip any
                        container with "test" in its name. Default: None
  --match MATCH         Only check containers whose name matches this Python
                        regular expression. Matched against the full container
                        name, even when the displayed name is shortened (see
                        --full-name). Case-sensitive by default; use `(?i)`
                        for case-insensitive matching. Can be specified
                        multiple times. If both `--match` and `--ignore` are
                        given, an item must match `--match` AND not match
                        `--ignore` to be reported (include first, exclude
                        second). Example: `--match="^traefik$"` to pin the
                        check to one specific container. Example:
                        `--match="(?i)^web"` (case-insensitive) to check every
                        web container. Default: None
  --no-match-severity {ok,warn,crit,unknown}
                        State to report when no item matches the filters and
                        nothing is checked. Default: ok
  --no-perfdata         Suppress the performance data section from the output.
                        The status message and the exit code are unaffected,
                        so alerting keeps working while trending data is
                        dropped.
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
  --warning-cpu WARN_CPU
                        WARN threshold for CPU usage, in percent. Supports
                        Nagios ranges. Default: 80
  --warning-mem WARN_MEM
                        WARN threshold for memory usage, in percent. Supports
                        Nagios ranges. Default: 90

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/docker-stats/
```


## Usage Examples

```bash
./docker-stats --count=5 --warning-cpu=70 --critical-cpu=90 --warning-mem=90 --critical-mem=95
```

Output:

```text
Everything is ok. 3 containers checked.

Container              ! CPU % ! Mem %
-----------------------+-------+------
myconti_app-logger_1   ! 0.0   ! 0.0
myconti_backend-core_1 ! 12.4  ! 33.9
myconti_ds_1           ! 3.1   ! 11.4
```

Alert on a worker container that stays idle for ten runs (WARN below 5% CPU, CRIT below 1%), and on memory usage outside 10% to 90% (CRIT outside 5% to 95%):

```bash
./docker-stats --count=10 --warning-cpu=5: --critical-cpu=1: --warning-mem=10:90 --critical-mem=5:95
```

Output (after ten runs):

```text
"myconti_app-logger_1" cpu 0.0% [CRITICAL], "myconti_app-logger_1" memory 0.0% [CRITICAL], "myconti_ds_1" cpu 3.1% [WARNING]

Container              ! CPU %          ! Mem %
-----------------------+----------------+---------------
myconti_app-logger_1   ! 0.0 [CRITICAL] ! 0.0 [CRITICAL]
myconti_backend-core_1 ! 12.4           ! 33.9
myconti_ds_1           ! 3.1 [WARNING]  ! 11.4
```


## States

* OK if the CPU and memory usage of every container is within its thresholds.
* WARN if the CPU usage of a container has been outside `--warning-cpu` (default: 80, i.e. above 80%) for the last `--count` runs (default: 5).
* CRIT if the CPU usage of a container has been outside `--critical-cpu` (default: 90) for the last `--count` runs.
* WARN if the memory usage of a container is outside `--warning-mem` (default: 90).
* CRIT if the memory usage of a container is outside `--critical-mem` (default: 95).
* All four thresholds support Nagios ranges.
* WARN if the Docker commands do not finish within `--timeout` (default: 8 seconds).
* CRIT if `docker info` or `docker stats` returns a non-zero exit code.
* UNKNOWN if the check may not talk to the container engine. The engine is answering, this check is only not allowed to ask, so it says nothing about it and names the sudoers file instead.
* UNKNOWN on a threshold that is not a valid Nagios range.
* The state reported when no container matches the `--match` / `--ignore` filters (or none are running) is configurable via `--no-match-severity` (default: ok).
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

One CPU and one memory metric is emitted per running container, plus the aggregate metrics below. See the Important Notes for when per-container metrics are and aren't useful.

| Name | Type | Description |
|----|----|----|
| `<container>_cpu_usage` | Percentage | Per-container CPU usage, normalized by host CPU count.                             |
| `<container>_mem_usage` | Percentage | Per-container memory usage, relative to the container memory limit or host memory. |
| containers_running      | Number     | Number of running containers.                                                      |
| cpu                     | Number     | Number of host CPUs.                                                               |


## Troubleshooting

### Timeout while running a Docker command

``Timeout after 8s while running `docker stats --no-stream --format {{json .}}`.``

The container engine did not answer within `--timeout`. `docker stats` has to query every running container, so a host running many containers, or an engine busy with other work, can take longer than usual. Run the command from the message by hand to see how long it takes, and raise `--timeout` accordingly. Keep it below the timeout of the monitoring system for the check command.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
