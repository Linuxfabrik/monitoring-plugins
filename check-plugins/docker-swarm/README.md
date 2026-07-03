# Check docker-swarm


## Overview

Checks whether the local node participates in a Docker Swarm and whether the cluster is healthy. On every node the local swarm state is verified (active, pending, inactive, locked, error). On a manager node the check additionally lists all cluster nodes, alerts on nodes that are down and verifies that the managers still form a quorum, so a lost or unreachable manager is caught before the control plane fails. Node availability (active, pause, drain) is reported for context but does not raise an alert, since draining a node is a deliberate operator action. Podman does not support swarm mode, so there is no Podman counterpart to this check. Requires root or sudo.

**Important Notes:**

* Run this check on every swarm node. A worker node can only verify its own local swarm state; the node inventory and the manager quorum are only visible on a manager node
* The local swarm state is the primary signal on every node: `active` is healthy, `pending` warns (the node is joining or leaving), and `inactive`, `locked` or `error` are critical (the node is not usefully part of the swarm)
* A node reported as down warns rather than crits: it costs the cluster redundancy but is not a full outage on its own
* The manager quorum turns critical once half or more of the managers are unreachable, because the raft consensus needs a majority to keep the control plane writable
* Node availability (`active`, `pause`, `drain`) is shown with `--lengthy` but never raises an alert, since draining or pausing a node is a deliberate operator action
* For the health of individual swarm services and their replica counts, use the docker-service check

**Data Collection:**

* Executes `docker info --format '{{json .}}'` to read the local swarm state (from the `Swarm` object) and whether the node is a manager
* Executes `docker node ls --format '{{json .}}'` on a manager node to list every cluster node with its status, availability and manager role


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/docker-swarm> |
| Nagios/Icinga Check Name              | `check_docker_swarm` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| Requirements                          | `docker` CLI, Swarm mode |


## Help

```text
usage: docker-swarm [-h] [-V] [--always-ok] [--lengthy]

Checks whether the local node participates in a Docker Swarm and whether the
cluster is healthy. On every node the local swarm state is verified (active,
pending, inactive, locked, error). On a manager node the check additionally
lists all cluster nodes, alerts on nodes that are down and verifies that the
managers still form a quorum, so a lost or unreachable manager is caught
before the control plane fails. Node availability (active, pause, drain) is
reported for context but does not raise an alert, since draining a node is a
deliberate operator action. Podman does not support swarm mode, so there is no
Podman counterpart to this check. Requires root or sudo.

options:
  -h, --help     show this help message and exit
  -V, --version  show program's version number and exit
  --always-ok    Always returns OK.
  --lengthy      Extended reporting.
```


## Usage Examples

```bash
./docker-swarm --lengthy
```

Output on a manager node:

```text
Swarm is active. 2/2 nodes ready, 1/1 manager reachable

Hostname ! Status ! Availability ! Manager ! State
---------+--------+--------------+---------+------
docker-1 ! Ready  ! Active       ! Leader  ! [OK]
docker-2 ! Ready  ! Active       ! -       ! [OK]
```

Output on a worker node:

```text
Swarm is active (worker node)
```


## States

* OK if the local node state is `active` and, on a manager, all nodes are ready and the managers keep their quorum.
* WARN if the local node state is `pending`, or a cluster node is down.
* CRIT if the local node state is `inactive`, `locked` or `error`.
* CRIT if the managers have lost their quorum (half or more unreachable).
* CRIT if `docker info` returns a non-zero exit code (daemon unreachable).
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

Perfdata is only emitted on a manager node, where the cluster inventory is available.

| Name | Type | Description |
|----|----|----|
| managers_reachable | Number | Number of managers currently reachable (Leader or Reachable). |
| managers_total | Number | Total number of manager nodes. |
| nodes_down | Number | Number of nodes not in the ready state. |
| nodes_ready | Number | Number of nodes in the ready state. |
| nodes_total | Number | Total number of nodes in the swarm. |


## Troubleshooting

### `Unable to parse the swarm state. This check requires Docker; Podman does not support swarm mode.`

The output of `docker info` does not contain a swarm object. Podman does not implement swarm mode, so this check only works with Docker. For multi-host orchestration under Podman, use Kubernetes manifests (`podman kube play`) instead.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
