# Check podman-stats


## Overview

Reports CPU and memory usage for all running Podman containers. CPU usage is normalized by dividing by the number of available host CPU cores, so 100% means all host CPUs are fully utilized. Alerts when the CPU usage of a container has been outside its threshold for a configurable number of consecutive check runs (default: 5), suppressing short spikes, and immediately when its memory usage is outside its threshold. For Docker, use the [docker-stats](https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/docker-stats) check instead. Requires root or sudo.

**Important Notes:**

* Memory usage is relative to the container's memory limit if one is set, otherwise relative to the total host memory.
* Containers can be selected or excluded by name with `--match` / `--ignore` (Python regular expressions, matched against the full name); `--no-match-severity` sets the state when nothing matches (default: ok).
* Per-container CPU and memory perfdata are most useful for long-lived containers with stable names (e.g. `traefik_traefik.2`, named systemd-managed services). For ever-changing workloads (e.g. GitLab runner jobs, CI builders), the per-container labels churn between check runs and are useless for trending. The aggregate perfdata is the right signal there.
* `--timeout` covers all Podman commands of a run together, so the check ends in time however long each of them takes. The shipped Director template allows 15 seconds.
* Podman runs rootless by default, and every user keeps their containers in their own storage. Running the check as root (via `sudo`) reports on root's own Podman, not on the rootless containers of other users. To report on a rootless user's containers, pass `--user=<name>`: the check then runs podman as that user. Every line of output names the inspected user, so an empty result against root's storage is obvious. The Podman Service Set in the Icinga Director creates its services without `--user`. Set it on the service of every host whose containers belong to a rootless user, otherwise a tagged host reports "No containers to check" while the containers are running.
* Block and network I/O are reported as aggregate perfdata only, as bytes per second across all containers since the previous check run. The first run after a container started has no previous sample, so it reports no CPU value and adds nothing to the I/O rates yet.
* Containers sharing a network namespace (the members of a pod including its infra container, or a container started with `--network container:<name>`) all see the same traffic. It is counted once. A container on `--network host` or `--network none` has no network statistics of its own and adds nothing to the network rates; traffic on the host network belongs to the host.

**Data Collection:**

* Executes `podman info --format json` to get host CPU count, image count, and total memory
* Executes `podman ps --ns --format json` to find out which containers share a network namespace
* Executes `podman stats --no-stream --format '{{json .}}'` to get per-container statistics
* CPU usage is divided by the number of host CPU cores ("normalized"). On an 8-core system, a container using one core at full capacity would show 12.5%.
* Uses a local SQLite database for the CPU trend and for the CPU and I/O rates across runs. Containers that no longer exist are removed from it, whatever `--match` and `--ignore` select, so several services with different filters can share it.
* Container names are shortened after the replica number by default (use `--full-name` for the full name)


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/podman-stats> |
| Nagios/Icinga Check Name              | `check_podman_stats` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No (runs with Python interpreter) |
| Handles Periods                       | Yes (alerts only after `--count` consecutive threshold violations) |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-podman-stats.db`, or `$TEMP/linuxfabrik-monitoring-plugins-podman-stats-<user>.db` with `--user` |


## Help

```text
usage: podman-stats [-h] [-V] [--always-ok] [--count COUNT]
                    [--critical-cpu CRIT_CPU] [--critical-mem CRIT_MEM]
                    [--full-name] [--ignore IGNORE] [--match MATCH]
                    [--no-match-severity {ok,warn,crit,unknown}]
                    [--no-perfdata] [--timeout TIMEOUT] [--user USER]
                    [--warning-cpu WARN_CPU] [--warning-mem WARN_MEM]

Reports CPU and memory usage for all running Podman containers. CPU usage is
normalized by dividing by the number of available host CPU cores, so 100%
means all host CPUs are fully utilized. Alerts when the CPU usage of a
container has been outside its threshold for a configurable number of
consecutive check runs (default: 5), suppressing short spikes, and immediately
when its memory usage is outside its threshold. For Docker, use the
docker-stats check instead. Requires root or sudo.

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
  --user USER           Report on the rootless containers of this user instead
                        of those visible to the executing user. Podman keeps
                        each user's rootless containers in that user's own
                        storage, so root (the monitoring user runs the check
                        via sudo) does not see them. With --user, the check
                        runs podman as that user. Requires the right to `sudo
                        -u <user>` (root has this by default). Example:
                        `--user=rocketchat`. Default: None
  --warning-cpu WARN_CPU
                        WARN threshold for CPU usage, in percent. Supports
                        Nagios ranges. Default: 80
  --warning-mem WARN_MEM
                        WARN threshold for memory usage, in percent. Supports
                        Nagios ranges. Default: 90

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/podman-stats/
```


## Usage Examples

```bash
./podman-stats --count=5 --warning-cpu=70 --critical-cpu=90 --warning-mem=90 --critical-mem=95
```

Output:

```text
Everything is ok. 3 containers checked (user: `root`).

Container              ! CPU % ! Mem %
-----------------------+-------+------
myconti_app-logger_1   ! 0.0   ! 0.0
myconti_backend-core_1 ! 12.4  ! 33.9
myconti_ds_1           ! 3.1   ! 11.4
```

Alert on a worker container that stays idle for ten runs (WARN below 5% CPU, CRIT below 1%), and on memory usage outside 10% to 90% (CRIT outside 5% to 95%):

```bash
./podman-stats --count=10 --warning-cpu=5: --critical-cpu=1: --warning-mem=10:90 --critical-mem=5:95
```

Output (after ten runs):

```text
"myconti_app-logger_1" cpu 0.0% [CRITICAL], "myconti_app-logger_1" memory 0.0% [CRITICAL], "myconti_ds_1" cpu 3.1% [WARNING] (user: `root`)

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
* WARN if the Podman commands do not finish within `--timeout` (default: 8 seconds).
* CRIT if `podman info`, `podman ps` or `podman stats` returns a non-zero exit code.
* UNKNOWN if the check may not talk to the container engine. The engine is answering, this check is only not allowed to ask, so it says nothing about it and names the sudoers file instead.
* UNKNOWN on a threshold that is not a valid Nagios range.
* The state reported when no container matches the `--match` / `--ignore` filters (or none are running) is configurable via `--no-match-severity` (default: ok).
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

One CPU and one memory metric is emitted per running container, plus the aggregate metrics below. See the Important Notes for when per-container metrics are and aren't useful.

| Name | Type | Description |
|----|----|----|
| `<container>_cpu_usage` | Percentage | Per-container CPU usage, normalized by host CPU count.                                 |
| `<container>_mem_usage` | Percentage | Per-container memory usage, relative to the container memory limit or host memory.     |
| containers_running      | Number     | Number of running containers.                                                          |
| cpu                     | Number     | Number of host CPUs.                                                                   |
| images                  | Number     | Number of images.                                                                      |
| ram                     | Bytes      | Total host memory.                                                                     |
| read_bytes_per_second   | Bytes      | Bytes read from block devices per second, across all containers.                       |
| rx_bytes_per_second     | Bytes      | Network bytes received per second, across all network namespaces of the containers.    |
| tx_bytes_per_second     | Bytes      | Network bytes transmitted per second, across all network namespaces of the containers. |
| write_bytes_per_second  | Bytes      | Bytes written to block devices per second, across all containers.                      |


## Troubleshooting

### Timeout while running a Podman command

``Timeout after 8s while running `podman stats --no-stream --format {{json .}}`.``

The container engine did not answer within `--timeout`, which covers all Podman commands of a run together. `podman stats` has to query every running container, so a host running many containers, or an engine busy with other work, can take longer than usual. Run the command from the message by hand to see how long it takes, and raise `--timeout` accordingly. Keep it below the timeout of the monitoring system for the check command.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
