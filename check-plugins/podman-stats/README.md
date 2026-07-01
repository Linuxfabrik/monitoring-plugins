# Check podman-stats


## Overview

Reports CPU and memory usage for all running Podman containers. CPU usage is normalized by dividing by the number of available host CPU cores, so 100% means all host CPUs are fully utilized. For Docker, use the [docker-stats](https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/docker-stats) check instead.

**Important Notes:**

* Memory usage is relative to the container's memory limit if one is set, otherwise relative to the total host memory.
* Containers can be selected or excluded by name with `--match` / `--ignore` (Python regular expressions, matched against the full name); `--no-match-severity` sets the state when nothing matches (default: ok).
* Per-container CPU and memory perfdata are most useful for long-lived containers with stable names (e.g. `traefik_traefik.2`, named systemd-managed services). For ever-changing workloads (e.g. GitLab runner jobs, CI builders), the per-container labels churn between check runs and are useless for trending. The aggregate perfdata is the right signal there.
* Plugin execution may take up to 10 seconds.
* Podman runs rootless by default, and every user keeps their containers in their own storage. Running the check as root (via `sudo`) reports on root's own Podman, not on the rootless containers of other users. To report on a rootless user's containers, pass `--user=<name>`: the check then runs podman as that user. Every line of output names the inspected user, so an empty result against root's storage is obvious.
* Since `podman stats` only returns byte-level data in a human-readable format (e.g. *221.2kB*), calculating network I/O and block I/O is imprecise. Therefore, these values are only reported as aggregate perfdata.

**Data Collection:**

* Executes `podman info --format json` to get host CPU count, image count, and total memory
* Executes `podman stats --no-stream --format '{{json .}}'` to get per-container statistics
* CPU usage is divided by the number of host CPU cores ("normalized"). On an 8-core system, a container using one core at full capacity would show 12.5%.
* Uses a local SQLite database for CPU trend tracking across runs
* Container names are shortened after the replica number by default (use `--full-name` for the full name)


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/podman-stats> |
| Nagios/Icinga Check Name              | `check_podman_stats` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| Handles Periods                       | Yes |
| Uses SQLite DBs                       | `$TEMP/linuxfabrik-monitoring-plugins-podman-stats.db` |


## Help

```text
usage: podman-stats [-h] [-V] [--always-ok] [--count COUNT]
                    [--critical-cpu CRIT_CPU] [--critical-mem CRIT_MEM]
                    [--full-name] [--ignore IGNORE] [--match MATCH]
                    [--no-match-severity {ok,warn,crit,unknown}] [--user USER]
                    [--warning-cpu WARN_CPU] [--warning-mem WARN_MEM]

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
                        given, a container must match `--match` AND not match
                        `--ignore` to be checked (include first, exclude
                        second). Example: `--match="^traefik$"` to pin the
                        check to one specific container. Example:
                        `--match="(?i)^web"` (case-insensitive) to check every
                        web container. Default: None
  --no-match-severity {ok,warn,crit,unknown}
                        State to report when no item matches the filters and
                        nothing is checked. Default: ok
  --user USER           Report on the rootless containers of this user instead
                        of those visible to the executing user. Podman keeps
                        each user's rootless containers in that user's own
                        storage, so root (the monitoring user runs the check
                        via sudo) does not see them. With --user, the check
                        runs podman as that user. Requires the right to `sudo
                        -u <user>` (root has this by default). Example:
                        `--user=rocketchat`. Default: None
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
* The state reported when no container matches the `--match` / `--ignore` filters (or none are running) is configurable via `--no-match-severity` (default: ok).
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

One CPU and one memory metric is emitted per running container, plus the aggregate metrics below. See the Important Notes for when per-container metrics are and aren't useful.

| Name | Type | Description |
|----|----|----|
| `<container>_cpu_usage` | Percentage | Per-container CPU usage, normalized by host CPU count.                            |
| `<container>_mem_usage` | Percentage | Per-container memory usage, relative to the container memory limit or host memory. |
| block_input             | Bytes      | Total data read from block device across all containers.                          |
| block_output            | Bytes      | Total data written to block device across all containers.                         |
| containers_running      | Number     | Number of running containers.                                                     |
| cpu                     | Number     | Number of host CPUs.                                                              |
| images                  | Number     | Number of images.                                                                 |
| net_rx                  | Bytes      | Total network bytes received across all containers.                               |
| net_tx                  | Bytes      | Total network bytes transmitted across all containers.                            |
| ram                     | Bytes      | Total host memory.                                                                |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
