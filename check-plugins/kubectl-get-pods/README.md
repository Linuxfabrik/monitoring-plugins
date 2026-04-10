# Check kubectl-get-pods

## Overview

Checks the health and status of Kubernetes pods by running `kubectl get pods` and parsing the JSON output. Lists namespace, pod name, readiness, status, restart count, age, and IP address for each pod. Alerts on pods in Pending or Failed state with configurable severity. Results can be filtered with a custom SQL query.

**Alerting Logic:**

* Pending and Failed pods trigger an alert with configurable severity (WARN or CRIT, default: CRIT)
* Unknown pods result in an UNKNOWN state
* Running and Succeeded pods are considered OK

**Data Collection:**

* Executes `kubectl get pods --output=json` to collect pod data from the Kubernetes cluster
* Optionally queries all namespaces via `--all-namespaces` (by default, only the current namespace is checked)
* Stores results in a temporary local SQLite database (no persistent history) to enable SQL-based filtering via `--query`
* Requires a valid kubeconfig file (default: `/var/spool/icinga2/.kubeconfig`)

**Compatibility:**

* Requires the `kubectl` command-line tool (must be within one minor version difference of your cluster; see [installation](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/))

**Important Notes:**

* OIDC-based login to Kubernetes is not yet supported.
* For the `--query` parameter, the following columns can be used: `namespace` (TEXT), `name` (TEXT), `ready` (TEXT), `status` (TEXT), `restarts` (INT), `age` (INT), `ip` (TEXT).


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/kubectl-get-pods> |
| Nagios/Icinga Check Name              | `check_kubectl_get_pods` |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |
| Uses SQLite DBs                       | `$TEMP/linuxfabrik-monitoring-plugins-kubectl-get-pods.db` |


## Help

```text
usage: kubectl-get-pods [-h] [-V] [--always-ok] [--all-namespaces]
                        [--kubeconfig KUBECONFIG] [--query QUERY]
                        [--severity {warn,crit}] [--test TEST]

Checks the health and status of Kubernetes pods by running "kubectl get pods"
and parsing the results. Lists namespace, pod name, readiness, status, restart
count, age, and IP address. Alerts on pending and failed pods with
configurable severity. Results can be filtered with a custom SQL query.
Supports all namespaces or a single one.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --all-namespaces      List pods across all namespaces. Namespace in current
                        context is ignored even if specified with
                        `--namespace`. Default: False
  --kubeconfig KUBECONFIG
                        Path to the kubeconfig file. Default:
                        /var/spool/icinga2/.kubeconfig
  --query QUERY         SQL WHERE clause to narrow down results. Have a look
                        at the README for a list of available columns.
                        Example: `namespace = 'mynamespace' and name like
                        'prod-%' and status != 'running'`. Default: 1
  --severity {warn,crit}
                        Severity for alerting. Default: crit
  --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                        stderr-file,expected-retc".
```


## Usage Examples

```bash
./kubectl-get-pods \
    --all-namespaces \
    --kubeconfig=/var/spool/icinga2/.kubeconfig \
    --query='namespace = "mynamespace" and name like "mycontainer-%"'
```

Output:

```text
Everything is ok.

NAMESPACE   ! NAME                                ! RDY ! RSTRT ! AGE    ! IP         ! STATUS
------------+-------------------------------------+-----+-------+--------+------------+--------
mynamespace ! mycontainer-mariadb-555df66f6c-5z8h ! 1/1 ! 0     ! 1D 2h  ! 192.0.2.11 ! Running
mynamespace ! mycontainer-postgres-775cb466bb-qkw ! 1/1 ! 0     ! 1M 11h ! 192.0.2.12 ! Running
```


## States

* OK if all pods are in Running or Succeeded state.
* WARN or CRIT (default: CRIT, configurable via `--severity`) if any pod is in Pending or Failed state.
* UNKNOWN if any pod is in Unknown state (usually due to communication errors with the host where the pod should be running).
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| failed | Number | Number of pods in Failed state. |
| pending | Number | Number of pods in Pending state. |
| running | Number | Number of pods in Running state. |
| succeeded | Number | Number of pods in Succeeded state. |
| unknown | Number | Number of pods in Unknown state. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
