# Check docker-stats


## Overview

Reports CPU and memory usage for all running Docker containers. CPU usage is normalized by dividing by the number of available host CPU cores. CPU alerts only trigger after the threshold has been exceeded for a configurable number of consecutive check runs (default: 5), suppressing short spikes. Memory alerts trigger immediately. Uses a local SQLite database for CPU trend tracking across runs. For Podman, use the podman-stats check instead. Requires root or sudo.

**Important Notes:**

* Plugin execution may take up to 10 seconds due to `docker stats --no-stream`
* Container names are shortened after the replica number by default (e.g. `traefik_traefik.2`). Use `--full-name` to show the full container name

**Data Collection:**

* Executes `docker info` to determine the number of host CPU cores
* Executes `docker stats --no-stream` to get a one-shot snapshot of CPU and memory usage for all running containers
* CPU usage is divided by the number of host CPUs, so 100% means all host CPUs are fully utilized. On an 8-core system, a container using one core at full capacity shows 12.5%
* Memory usage is relative to the container's memory limit if one is set, otherwise relative to the total host memory
* Stores per-container CPU usage values in a local SQLite database to track trends across consecutive runs
* Since `docker stats` only returns byte-level data in a human-readable format (e.g. "4.82GB"), network I/O and block I/O values are not used due to imprecision


## Fact Sheet

| Fact | Value |
|----|----| 
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/docker-stats> |
| Nagios/Icinga Check Name              | `check_docker_stats` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| Handles Periods                       | Yes |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-docker-stats.db` |


## Help

```text
usage: docker-stats [-h] [-V] [--always-ok] [--count COUNT]
                    [--critical-cpu CRIT_CPU] [--critical-mem CRIT_MEM]
                    [--full-name] [--test TEST] [--warning-cpu WARN_CPU]
                    [--warning-mem WARN_MEM]

Reports CPU and memory usage for all running Docker containers. CPU usage is
normalized by dividing by the number of available host CPU cores. CPU alerts
only trigger after the threshold has been exceeded for a configurable number
of consecutive check runs (default: 5), suppressing short spikes. Memory
alerts trigger immediately. Uses a local SQLite database for CPU trend
tracking across runs. For Podman, use the podman-stats check instead. Requires
root or sudo.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --count COUNT         Number of consecutive checks the threshold must be
                        exceeded before alerting. Default: 5
  --critical-cpu CRIT_CPU
                        CRIT threshold for CPU usage in percent. Default: >=
                        90
  --critical-mem CRIT_MEM
                        CRIT threshold for memory usage in percent. Default:
                        95
  --full-name           Use the full container name, for example
                        `traefik_traefik.2.1idw12p2yqp`. Without this flag,
                        the name is shortened after the replica number.
  --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                        stderr-file,expected-retc".
  --warning-cpu WARN_CPU
                        WARN threshold for CPU usage in percent. Default: >=
                        80
  --warning-mem WARN_MEM
                        WARN threshold for memory usage in percent. Default:
                        90
```


## Usage Examples

```bash
./docker-stats --count 5 --warning-cpu 70 --critical-cpu 90 --warning-mem 90 --critical-mem 95
```

Output:

```text
Everything is ok, 3 containers checked.

Container                 ! CPU % ! Mem % 
--------------------------+-------+-------
myconti_app-logger_1      ! 0.0   ! 0.0   
myconti_backend-core_1    ! 0.1   ! 33.9  
myconti_ds_1              ! 0.0   ! 11.42
```


## States

* OK if all container CPU and memory usage values are below the thresholds.
* WARN if any container CPU usage is >= `--warning-cpu` (default: 80%) for `--count` (default: 5) consecutive runs.
* CRIT if any container CPU usage is >= `--critical-cpu` (default: 90%) for `--count` (default: 5) consecutive runs.
* WARN if any container memory usage is >= `--warning-mem` (default: 90%).
* CRIT if any container memory usage is >= `--critical-mem` (default: 95%).
* CRIT if `docker info` or `docker stats` returns a non-zero exit code.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| containers_running | Number | Number of running containers. |
| cpu | Number | Number of host CPUs. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
