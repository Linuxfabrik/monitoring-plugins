# Check docker-service


## Overview

Checks the health of Docker Swarm services: how many of the expected tasks (containers) of a service are actually running, and optionally whether those tasks are spread evenly across the swarm nodes. The number of running tasks is compared against an expected count as a percentage, so a service that lost some but not all of its tasks can warn before it goes fully down. Must be run on a swarm manager node, since only managers can list services. Podman does not support swarm mode, so there is no Podman counterpart to this check. Requires root or sudo.

**Important Notes:**

* Run this check on a swarm manager node. A worker cannot list services, so the check reports UNKNOWN there
* The expected task count defaults to the service's own desired replica count. Pin it per service with `--service=name=count` to keep alerting against the count a service is supposed to run, even after someone scaled it down. This is what makes a service scaled from 2 to 1 alert instead of looking healthy at "1/1"
* The state is derived from the percentage of expected tasks that are running: full is OK, and by default the check warns below 100% and crits below 50%. Adjust with `--warning` / `--critical` (Nagios ranges on the percentage)
* Task health is represented by the running count. Swarm reschedules a task that fails its health check, so a task that stays running is the cluster's own health signal, the same one `docker service ls` shows in its `REPLICAS` column
* `--check-distribution` additionally warns when more tasks of a service sit on one node than an even spread (`ceil(expected / number of nodes)`) would place there. All nodes count towards the spread, including a drained one, so both replicas landing on a single node because the other node was drained is still surfaced
* To alert when a specific service disappears entirely, pin it with `--service=name=count` and it will report 0 running tasks (CRIT). For the default all-services mode, a removed service simply drops out of the list; use `--no-match-severity` to alert when the list becomes empty
* For the node and cluster health of the swarm itself (node down, manager quorum), use the docker-swarm check. For plain (non-swarm) container health, use docker-container

**Data Collection:**

* Executes `docker service ls --format '{{json .}}'` to list the swarm services with their mode and running/desired replica counts
* With `--check-distribution`, executes `docker service ps --no-trunc --format '{{json .}}' <service>` per checked service to read task placement, and `docker node ls --format '{{json .}}'` to count the swarm nodes


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/docker-service> |
| Nagios/Icinga Check Name              | `check_docker_service` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| Requirements                          | `docker` CLI, Swarm manager node |


## Help

```text
usage: docker-service [-h] [-V] [--always-ok] [--check-distribution] [-c CRIT]
                      [--ignore IGNORE] [--lengthy]
                      [--no-match-severity {ok,warn,crit,unknown}]
                      [--service SERVICE] [-w WARN]

Checks the health of Docker Swarm services: how many of the expected tasks
(containers) of a service are actually running, and optionally whether those
tasks are spread evenly across the swarm nodes. The number of running tasks is
compared against an expected count as a percentage, so a service that lost
some but not all of its tasks can warn before it goes fully down. The expected
count defaults to the service's own desired replica count, but can be pinned
per service with --service, so scaling a service down by mistake is still
caught against the count the service is supposed to run. With --check-
distribution the check also warns when more tasks of a service sit on a single
node than an even spread would place there, which surfaces a node that
silently stopped taking work. Must be run on a swarm manager node, since only
managers can list services. Podman does not support swarm mode, so there is no
Podman counterpart to this check. Requires root or sudo.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --check-distribution  Also warn when a service has more tasks on a single
                        node than an even spread across all swarm nodes would
                        place there (optimal = ceil(expected / number of
                        nodes)). Catches an imbalance such as both replicas of
                        a two-replica service running on the same node while
                        another node sits idle. Off by default, because it
                        inspects the task placement of every checked service
                        and adds one call per service. Default: False
  -c, --critical CRIT   CRIT threshold for the percentage of expected tasks
                        that are running, compared as a Nagios range. Default:
                        50: (crit when fewer than 50% of the expected tasks
                        run). Example: `--critical=25:` alerts only once more
                        than three quarters of the tasks are gone.
  --ignore IGNORE       Ignore services whose name matches this Python regular
                        expression. Only applies when no --service is given
                        (all services are checked). Case-sensitive by default;
                        use `(?i)` for case-insensitive matching. Can be
                        specified multiple times. Example: `--ignore="^test_"`
                        to skip throwaway test services. Default: None
  --lengthy             Extended reporting.
  --no-match-severity {ok,warn,crit,unknown}
                        State to report when no item matches the filters and
                        nothing is checked. Default: ok
  --service SERVICE     Check this service and, optionally, the number of
                        tasks it is expected to run, written as `name=count`.
                        Without `=count` the service's own desired replica
                        count is used as the expectation. Can be specified
                        multiple times; if given at least once, only the named
                        services are checked. Example: `--service=web=2`
                        alerts when the `web` service does not run its two
                        expected tasks, even after someone scaled it down to
                        one. Example: `--service=traefik` checks `traefik`
                        against its own desired count. Default: None
  -w, --warning WARN    WARN threshold for the percentage of expected tasks
                        that are running, compared as a Nagios range. Default:
                        100: (warn when fewer than 100% of the expected tasks
                        run). Example: `--warning=90:` tolerates losing up to
                        10% of the tasks before warning.
```


## Usage Examples

```bash
./docker-service --service=web=2 --check-distribution --lengthy
```

Output when both replicas run on the same node while the other is drained:

```text
web: 2 tasks on one node (optimal 1) [WARNING]

Service ! Mode       ! Running/Expected ! Node max/optimal ! State
--------+------------+------------------+------------------+----------
web     ! replicated ! 2/2              ! 2/1              ! [WARNING]
```

Output when everything is fine:

```text
Everything is ok, 2 services checked.

Service ! Running/Expected ! State
--------+------------------+------
redis   ! 1/1              ! [OK]
web     ! 2/2              ! [OK]
```


## States

* OK if every checked service runs the expected number of tasks (and, with `--check-distribution`, is evenly spread).
* WARN if a service runs fewer than the expected tasks but stays at or above the critical percentage (default: below 100%).
* WARN if `--check-distribution` finds a service with more tasks on one node than an even spread allows.
* CRIT if a service runs fewer than the critical percentage of its expected tasks (default: below 50%), including a service pinned with `--service` that is scaled to zero or removed.
* UNKNOWN if the node is not a swarm manager (services cannot be listed there).
* `--no-match-severity` sets the state when no service is checked (default: OK).
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| services_checked | Number | Number of services checked. |
| services_degraded | Number | Number of services below their expected tasks or unevenly spread. |
| tasks_expected | Number | Sum of the expected tasks across all checked services. |
| tasks_running | Number | Sum of the running tasks across all checked services. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
