# Check podman-stats


## Overview

Reports CPU and memory usage for all running Podman containers. CPU usage is normalized by dividing by the number of available host CPU cores, so 100% means all host CPUs are fully utilized. For Docker, use the [docker-stats](https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/docker-stats) check instead.

**Important Notes:**

* Podman runs rootless by default. Without `sudo`, the check only sees containers of the executing user. To monitor containers across all users, run the check via `sudo` (the Icinga Director basket and sudoers file are pre-configured for this).
* Plugin execution may take up to 10 seconds.
* Since `podman stats` only returns byte-level data in a human-readable format (e.g. *221.2kB*), calculating network I/O and block I/O is imprecise. Therefore, these values are only reported as aggregate perfdata.
* Memory usage is relative to the container's memory limit if one is set, otherwise relative to the total host memory.

**Data Collection:**

* Executes `podman info --format json` to get host CPU count, image count, and total memory
* Executes `podman stats --no-stream --format '{{json .}}'` to get per-container statistics
* CPU usage is divided by the number of host CPU cores ("normalized"). On an 8-core system, a container using one core at full capacity would show 12.5%.
* Uses a local SQLite database for CPU trend tracking across runs
* Container names are shortened after the replica number by default (use `--full-name` for the full name)

**Compatibility:**

* Cross-platform


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/podman-stats> |
| Nagios/Icinga Check Name              | `check_podman_stats` |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |
| Handles Periods                       | Yes |
| Uses SQLite DBs                       | `$TEMP/linuxfabrik-monitoring-plugins-podman-stats.db` |


## Help

```text
usage: podman-stats [-h] [-V] [--always-ok] [--count COUNT]
                    [--critical-cpu CRIT_CPU] [--critical-mem CRIT_MEM]
                    [--full-name] [--test TEST] [--warning-cpu WARN_CPU]
                    [--warning-mem WARN_MEM]

Reports CPU and memory usage for all running Podman containers. CPU usage is
normalized by dividing by the number of available host CPU cores. CPU alerts
only trigger after the threshold has been exceeded for a configurable number
of consecutive check runs (default: 5), suppressing short spikes. Memory
alerts trigger immediately. Uses a local SQLite database for CPU trend
tracking across runs. For Docker, use the docker-stats check instead. Requires
root or sudo.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --count COUNT         Number of consecutive checks the threshold must be
                        exceeded before alerting. Default: 5
  --critical-cpu CRIT_CPU
                        CRIT threshold for CPU usage, in percent. Default: >=
                        90
  --critical-mem CRIT_MEM
                        CRIT threshold for memory usage, in percent. Default:
                        >= 95
  --full-name           Use the full container name instead of shortening it
                        after the replica number. Example:
                        `traefik_traefik.2.1idw12p2yqp`
  --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                        stderr-file,expected-retc".
  --warning-cpu WARN_CPU
                        WARN threshold for CPU usage, in percent. Default: >=
                        80
  --warning-mem WARN_MEM
                        WARN threshold for memory usage, in percent. Default:
                        >= 90
```


## Usage Examples

```bash
./podman-stats --count 5 --warning-cpu 70 --critical-cpu 90 --warning-mem 90 --critical-mem 95
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

* OK if all container CPU and memory usage are below the thresholds.
* WARN if any container CPU usage is above `--warning-cpu` (default: 80%) during the last `--count` checks (default: 5).
* WARN if any container memory usage is above `--warning-mem` (default: 90%).
* CRIT if any container CPU usage is above `--critical-cpu` (default: 90%) during the last `--count` checks (default: 5).
* CRIT if any container memory usage is above `--critical-mem` (default: 95%).
* CRIT on `podman info` or `podman stats` return codes != 0.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name               | Type   | Description                                              |
|--------------------|--------|----------------------------------------------------------|
| block_input        | Bytes  | Total data read from block device across all containers.  |
| block_output       | Bytes  | Total data written to block device across all containers. |
| containers_running | Number | Number of running containers.                             |
| cpu                | Number | Number of host CPUs.                                      |
| images             | Number | Number of images.                                         |
| net_rx             | Bytes  | Total network bytes received across all containers.       |
| net_tx             | Bytes  | Total network bytes transmitted across all containers.    |
| ram                | Bytes  | Total host memory.                                        |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
