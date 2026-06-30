# Check podman-container


## Overview

Checks the lifecycle and health of Podman containers: the container status (running, exited, paused, ...), the result of the container health check (healthy, unhealthy, starting), and the number of automatic restarts. Containers can be selected or excluded by name using regular expressions, and the presence of expected containers can be enforced. For per-container CPU and memory usage, use the podman-stats check. For Docker, use the docker-container check instead. Requires root or sudo.

**Important Notes:**

* Container names are shortened after the replica number by default (e.g. `traefik_traefik.2`). Use `--full-name` to show the full container name
* A container's health is only checked if its image defines a `HEALTHCHECK`. Containers without one are reported with health `-` and never raise an alert on that basis
* The container status is reported but only alerts when you pin an expected status with `--status` (for example `--status=running`)
* The restart count is reported for every container, but only alerts when you set `--warning-restarts` or `--critical-restarts`
* The uptime of running containers is reported, but only alerts when you set `--warning-uptime` or `--critical-uptime` (for example `--warning-uptime=5m:` to catch a container that keeps restarting)
* Podman runs rootless by default, and every user keeps their containers in their own storage. Running the check as root (via `sudo`) sees root's own containers, not the rootless containers of other users. To check a rootless user's containers, pass `--user=<name>`: the check then runs podman as that user. Every line of output names the inspected user, so an empty result against root's storage is obvious

**Data Collection:**

* Executes `podman ps --all --quiet --no-trunc` to list all container IDs
* Executes `podman inspect` on those IDs to read each container's status, health check result and restart count


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/podman-container> |
| Nagios/Icinga Check Name              | `check_podman_container` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| Requirements                          | `podman` CLI |


## Help

```text
usage: podman-container [-h] [-V] [--always-ok]
                        [--critical-restarts CRIT_RESTARTS]
                        [--critical-uptime CRIT_UPTIME] [--full-name]
                        [--ignore IGNORE] [--match MATCH]
                        [--no-match-severity {ok,warn,crit,unknown}]
                        [--status STATUS] [--user USER]
                        [--warning-restarts WARN_RESTARTS]
                        [--warning-uptime WARN_UPTIME]

Checks the lifecycle and health of Podman containers: the container status
(running, exited, paused, ...), the result of the container health check
(healthy, unhealthy, starting), and the number of automatic restarts.
Containers can be selected or excluded by name using regular expressions, and
the presence of expected containers can be enforced. For per-container CPU and
memory usage, use the podman-stats check. For Docker, use the docker-container
check instead. Requires root or sudo.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --critical-restarts CRIT_RESTARTS
                        CRIT threshold for the number of automatic restarts a
                        container has performed, compared as a Nagios range.
                        Example: `--critical-restarts=5` alerts when a
                        container has restarted more than 5 times. By default,
                        the restart count is reported but not alerted on.
                        Default: None
  --critical-uptime CRIT_UPTIME
                        CRIT threshold for the container uptime in a human-
                        readable format (s = seconds, m = minutes, h = hours,
                        D = days, W = weeks, M = months, Y = years). Supports
                        Nagios ranges. Example: `5m:` alerts if a running
                        container has been up for less than 5 minutes (catches
                        a crash-looping or flapping container). By default,
                        the uptime is reported but not alerted on. Default:
                        None
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
                        given, a container must match `--match` AND not match
                        `--ignore` to be checked (include first, exclude
                        second). Example: `--match="^traefik$"` to pin a
                        service to one specific container. Example:
                        `--match="(?i)^web"` (case-insensitive) to check every
                        web container. Default: None
  --no-match-severity {ok,warn,crit,unknown}
                        State to report when no item matches the filters and
                        nothing is checked. Default: ok
  --status STATUS       Desired container status, for example `running`,
                        `exited` or `paused`. A container whose status differs
                        is reported as CRITICAL. If not specified, the status
                        is reported but not alerted on. Default: None
  --user USER           Inspect the rootless containers of this user instead
                        of those visible to the executing user. Podman keeps
                        each user's rootless containers in that user's own
                        storage, so root (the monitoring user runs the check
                        via sudo) does not see them. With --user, the check
                        runs podman as that user. Requires the right to `sudo
                        -u <user>` (root has this by default). Example:
                        `--user=rocketchat`. Default: None
  --warning-restarts WARN_RESTARTS
                        WARN threshold for the number of automatic restarts a
                        container has performed, compared as a Nagios range.
                        Example: `--warning-restarts=3` alerts when a
                        container has restarted more than 3 times. By default,
                        the restart count is reported but not alerted on.
                        Default: None
  --warning-uptime WARN_UPTIME
                        WARN threshold for the container uptime in a human-
                        readable format (s = seconds, m = minutes, h = hours,
                        D = days, W = weeks, M = months, Y = years). Supports
                        Nagios ranges. Example: `5m:` alerts if a running
                        container has been up for less than 5 minutes (catches
                        a crash-looping or flapping container). By default,
                        the uptime is reported but not alerted on. Default:
                        None
```


## Usage Examples

Check every container, alerting on unhealthy ones:

```bash
./podman-container
```

Make sure a specific container is running and healthy, and alert if it is missing:

```bash
./podman-container --match="^traefik$" --status=running --no-match-severity=crit
```

Check every container except the transient Kubernetes infrastructure ones, and alert on flapping:

```bash
./podman-container --ignore="^k8s_" --warning-restarts=3 --critical-restarts=10
```

Check the rootless containers of the `rocketchat` user (run the check as root, for example via the Icinga Director sudo wrapper):

```bash
./podman-container --user=rocketchat
```

Output:

```text
app-unhealthy: health unhealthy [CRITICAL]

Container          ! Status  ! Health    ! Restarts ! State
-------------------+---------+-----------+----------+-----------
app-healthy        ! running ! healthy   ! 0        ! [OK]
app-no-healthcheck ! running ! -         ! 0        ! [OK]
app-unhealthy      ! running ! unhealthy ! 3        ! [CRITICAL]
```


## States

* CRIT if a container's health check reports `unhealthy`.
* WARN if a container's health check reports `starting`.
* CRIT if a container's status differs from `--status` (when given).
* WARN/CRIT if a container's restart count crosses `--warning-restarts` / `--critical-restarts` (when given).
* WARN/CRIT if a running container's uptime crosses `--warning-uptime` / `--critical-uptime` (when given).
* The state reported when no container matches the `--match` / `--ignore` filters (or no containers exist) is configurable via `--no-match-severity` (default: ok).
* CRIT if `podman ps` or `podman inspect` returns a non-zero exit code.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| containers_checked | Number | Number of containers that passed the filters and were checked. |
| containers_running | Number | Number of checked containers in the `running` status. |
| containers_unhealthy | Number | Number of checked containers whose health check reports `unhealthy`. |


## Troubleshooting

### A container stays WARN/CRIT after a restart spike (`--warning-restarts` / `--critical-restarts`)

The restart thresholds compare against the container's `RestartCount`, which the check reads directly from `podman inspect`; the check keeps no state of its own. `RestartCount` counts only the **automatic** restarts performed by the container's restart policy (for example `--restart=on-failure`), and it keeps climbing while the container keeps failing. Once it exceeds your `--warning-restarts` / `--critical-restarts` threshold, the check stays WARN/CRIT until the count drops.

To reset it, simply restart the container:

* `podman restart <container>` (or `podman stop` followed by `podman start`) resets `RestartCount` to 0. This is an ordinary restart, not a teardown: the container, its volumes and its data are kept. On the next check run the container returns to OK. A host reboot resets the count as well.
* You do **not** need to remove and recreate the container. Only the restart policy's automatic restarts increment the count; a manual `podman restart` clears it.
* Acknowledging the problem in the monitoring system does not change the underlying count.

If the restarts are expected for a given workload, raise the threshold, or leave `--warning-restarts` / `--critical-restarts` unset so that restarts are reported but not alerted on.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
