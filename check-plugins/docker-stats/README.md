# Check docker-stats

## Overview

This check prints cpu and memory statistics for all running Docker containers, using the [docker stats](https://docs.docker.com/engine/reference/commandline/stats/) command. Container CPU usage is divided by the available number of CPU cores ("normalized"). For Podman, use the [podman-stats](https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/podman-stats) check instead.

Hints:

* Plugin execution may take up to 10 seconds.
* Since `docker stats` only returns byte-level data in a human-readable format (e.g. *4.82GB*), calculating network I/O (`RX bps`, `TX bps`) and block I/O (`BlockIn/s`, `BlockOut/s`) is imprecise. Therefore, these values are not used at all.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/docker-stats> |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |
| Handles Periods                       | Yes |
| Uses SQLite DBs                       | `$TEMP/linuxfabrik-monitoring-plugins-docker-stats.db` |


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
Everything is ok.

Container                 ! CPU % ! Mem % 
--------------------------+-------+-------
myconti_app-logger_1      ! 0.0   ! 0.0   
myconti_backend-core_1    ! 0.1   ! 33.9  
myconti_ds_1              ! 0.0   ! 11.42
```


## States

* CRIT on `docker info` or `docker stats` return codes != 0
* WARN if any container cpu usage is above the warning cpu threshold during the last n checks (default: 5)
* CRIT if any container cpu usage is above the critical cpu threshold during the last n checks (default: 5)
* WARN or CRIT if any container memory usage is above the memory thresholds

CPU usage is normalized by dividing by the number of host CPUs, so 100% means all host CPUs are fully utilized. On an 8-core system, a container using one core at full capacity would show 12.5%. Memory usage is relative to the container's memory limit if one is set, otherwise relative to the total host memory.


## Perfdata / Metrics

| Name       | Type   | Description                  |
|------------|--------|------------------------------|
| containers_running | Number | Number of running containers |
| cpu        | Number | Number of Host CPUs          |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
