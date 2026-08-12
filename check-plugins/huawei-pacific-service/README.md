# Check huawei-pacific-service

## Overview

Checks the service processes of every node of a Huawei OceanStor Pacific storage system via the REST API (`/cluster_service/service_processes` endpoint). Alerts when a process is not running, and when a node of the cluster does not report its processes at all. Supports extended reporting via `--lengthy` and shorter output via `--brief`.

**Important Notes:**

* Create a read-only API user that can perform queries only
* A node runs a dozen to two dozen processes, so the full table is unreadable on a sizeable cluster. Run the check with `--brief` to see only the processes that are not running; the shipped Director basket sets it. Perfdata and alerting are unaffected by it
* **Nodes of the same cluster do not run the same processes.** Which ones a node runs follows the roles it holds, which `huawei-pacific-node` reports as its `usage`. A node that carries the metadata and coordination roles runs the full set; one that only serves storage runs markedly fewer. A node with fewer processes than its neighbours is therefore normal, and the check makes no assumption about which processes a node ought to have
* The vendor documents no enumeration for the process status. `0` is the only value both REST Interface References show and the only one seen on real hardware, so the check treats `0` as running and reports every other code as the appliance sent it. Look an unfamiliar code up with Huawei support rather than guessing at it
* A process that stops being reported altogether has no status that could be non-zero. The per-node process total is what catches that, so watch each node against its own history in the dashboard rather than expecting an alert
* A node that is part of the cluster and reports no processes is a blind spot, not a known outage: nothing at all is known about its processes while that lasts. It warns by default, tunable with `--silent-node-severity`
* The vendor documents a timeout period of 30 seconds for this endpoint, so the check defaults to `--timeout=30` and the shipped Director basket raises the command timeout to 60 seconds

**Data Collection:**

* Queries the Huawei OceanStor Pacific REST API at `https://<ip>:<port>/api/v2/`
* Enumerates the cluster nodes (`/cluster/servers`), then asks for the processes of all of them in a single request (`/cluster_service/service_processes`), which takes the node addresses as a comma-separated parameter
* Authenticates via a session token (`X-Auth-Token`), cached in a SQLite database to avoid repeated logins
* If the appliance rejects a request (for example after a session reset or timeout), the check logs in again and retries
* Processes can be limited with `--match` and excluded with `--ignore` (Python regular expressions, anchored at the start of the node name and the process name)


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/huawei-pacific-service> |
| Nagios/Icinga Check Name              | `check_huawei_pacific_service` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | No (`--password`, `--url` and `--username` are required) |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-huawei-pacific.db` |


## Help

```text
usage: huawei-pacific-service [-h] [-V] [--always-ok] [--brief]
                              [--cache-expire CACHE_EXPIRE] [--ignore IGNORE]
                              [--insecure] [--lengthy] [--match MATCH]
                              [--no-insecure]
                              [--no-match-severity {ok,warn,crit,unknown}]
                              [--no-perfdata] [--no-proxy]
                              [--password PASSWORD]
                              [--password-file PASSWORD_FILE] [--scope SCOPE]
                              [--silent-node-severity {ok,warn,crit,unknown}]
                              [--timeout TIMEOUT] -u URL --username USERNAME
                              [-v]

Checks the service processes of every node of a Huawei OceanStor Pacific
storage system via the REST API (/cluster_service/service_processes endpoint).
Alerts when a process is not running, and when a node of the cluster does not
report its processes at all. Supports extended reporting via --lengthy and
shorter output via --brief.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --brief               Hide table rows for processes that are running and
                        show only those that are not. Perfdata and alerting
                        are unaffected: every process still emits perfdata and
                        still drives the overall check state. Default: False
  --cache-expire CACHE_EXPIRE
                        The amount of time after which the credential/data
                        cache expires, in minutes. Default: 15
  --ignore IGNORE       Skip processes. Any item matching this Python regex
                        will be ignored. Can be specified multiple times.
                        Example: `(?i)linuxfabrik` for a case-insensitive
                        match. The regex is anchored at the start of the
                        string (Python `re.match`) and is matched against the
                        node name and the process name, so prefix with `.*` to
                        match anywhere. Default: None
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --lengthy             Extended reporting.
  --match MATCH         Limit to processes. Filter by this Python regular
                        expression. Case-sensitive by default; use `(?i)` for
                        case-insensitive matching. Can be specified multiple
                        times. If both `--match` and `--ignore` are given, an
                        item must match `--match` AND not match `--ignore` to
                        be reported (include first, exclude second). Examples:
                        `(?i)example` to match "example" regardless of case.
                        `^(?!.*example).*$` to match any string except
                        "example" (negative lookahead). The regex is anchored
                        at the start of the string (Python `re.match`) and is
                        matched against the node name and the process name, so
                        prefix with `.*` to match anywhere. Default: None
  --no-insecure         Verify the TLS certificate against the system trust
                        store, overriding the insecure default of this check.
                        Use it once the endpoint presents a publicly trusted
                        certificate, or once its CA has been added to the
                        system trust store.
  --no-match-severity {ok,warn,crit,unknown}
                        State to report when no item matches the filters and
                        nothing is checked. Default: ok
  --no-perfdata         Suppress the performance data section from the output.
                        The status message and the exit code are unaffected,
                        so alerting keeps working while trending data is
                        dropped.
  --no-proxy            Do not use a proxy.
  --password PASSWORD   Huawei OceanStor Pacific API password.
  --password-file PASSWORD_FILE
                        Path to a file holding the password, read from its
                        first line. Keeps the password out of the process
                        list, where a command-line argument is visible to
                        every user on the host. Takes precedence over
                        `--password`. Keep the file readable only by the
                        monitoring user. Example: `--password-
                        file=/etc/icinga2/secrets/storage`.
  --scope SCOPE         Huawei OceanStor Pacific API scope.
  --silent-node-severity {ok,warn,crit,unknown}
                        State to report for a cluster node that the process
                        query returns nothing for. Its processes are
                        unmonitored for as long as that lasts, which is not
                        the same as knowing they are down. Default: warn
  --timeout TIMEOUT     Network timeout in seconds. Default: 30 (seconds)
  -u, --url URL         Huawei OceanStor Pacific API URL.
  --username USERNAME   Huawei OceanStor Pacific API username.
  -v, --verbose         Makes this plugin verbose during the operation. Useful
                        for debugging and seeing what is going on under the
                        hood. Appends what every API request returned, so the
                        appliance's own answers can be read while working out
                        how it reports something. Session tokens are redacted.
                        The output is as long as those answers are, so this is
                        a debugging aid rather than something to leave
                        switched on.

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/huawei-pacific-service/
```


## Usage Examples

```bash
./huawei-pacific-service --username=icinga --password=linuxfabrik --url=https://storage.example.com:8088 --brief
```

Output:

```text
Everything is ok. Checked 63 processes on 3 nodes, all running.
```

A process that is down, with the table reduced to what is broken:

```bash
./huawei-pacific-service --username=icinga --password=linuxfabrik --url=https://storage.example.com:8088 --brief
```

Output:

```text
There are critical errors. Checked 63 processes on 3 nodes, 1 not running.

Node   ! Process ! Status          ! State
-------+---------+-----------------+-----------
node02 ! MDC     ! not running (1) ! [CRITICAL]
```

Without `--brief` every process of every node is listed, which is two dozen rows per node. `--lengthy` adds how many instances of a process the node runs: the OSD entry of a storage node carries one process per disk it serves, while a process the appliance tracks without a PID reports none and is running all the same. Narrowed down to three processes so the output fits here:

```bash
./huawei-pacific-service --username=icinga --password=linuxfabrik --url=https://storage.example.com:8088 --lengthy --match='(OSD|MDC|JBODMNG)'
```

Output:

```text
Everything is ok. Checked 9 processes on 3 nodes, all running.

Node   ! Process ! Instances ! Status      ! State
-------+---------+-----------+-------------+------
node01 ! OSD     ! 50        ! running (0) ! [OK]
node01 ! MDC     ! 1         ! running (0) ! [OK]
node01 ! JBODMNG ! 0         ! running (0) ! [OK]
node02 ! OSD     ! 50        ! running (0) ! [OK]
node02 ! MDC     ! 1         ! running (0) ! [OK]
node02 ! JBODMNG ! 0         ! running (0) ! [OK]
node03 ! OSD     ! 50        ! running (0) ! [OK]
node03 ! MDC     ! 1         ! running (0) ! [OK]
node03 ! JBODMNG ! 0         ! running (0) ! [OK]
```


## States

* OK if every checked process reports status `0`.
* CRIT if any checked process reports any other status. A core process of a storage node is not something to look at in the morning.
* WARN if a node that is part of the cluster reports no processes at all, so nothing is known about it. Tunable with `--silent-node-severity`.
* The worst state of all checked processes and nodes becomes the state of the check.
* OK with "No processes matched" if `--match` or `--ignore` excluded every process. Use `--no-match-severity` to report WARN, CRIT or UNKNOWN instead. A node that reports nothing still raises its own state, so a filter cannot hide a blind spot.
* UNKNOWN if the appliance reports no processes for any node at all. A cluster node always runs service processes, so an empty answer is a query that never reached them.
* UNKNOWN if a node of the cluster reports no management IP address, or if the cluster reports more nodes than it lists. Either way part of the cluster could not be asked, and reporting on the rest would look like full coverage.
* UNKNOWN on invalid API responses or responses with error codes, and on an invalid `--match` or `--ignore` pattern.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

Two metrics per cluster node, prefixed with the node name in snake_case. `--brief` and `--lengthy` do not change the perfdata: every node is always reported.

| Name | Type | Description |
|----|----|----|
| &lt;node&gt;_processes_not_running | Number | Processes on the node whose status is not `0`. |
| &lt;node&gt;_processes_total | Number | Processes the node reports. A drop in this number means a process stopped being reported at all, which no status code can show. |


## Troubleshooting

### No valuable response from the API

`Got no valuable response from https://...`

Check the `--url`, `--username` and `--password` parameters. Verify that the API user has query permissions and that the storage system REST API is reachable.

### A node reports no processes at all

`These cluster nodes report no processes at all, so nothing is known about them: ...`

The node is part of the cluster, was asked about, and did not come back with a process list. Check `huawei-pacific-node` first: if the node itself is offline or is being added to the cluster, that check says so and this one is only the echo. If the node is online there, the process query is the problem, and running this check with `--verbose` shows what the appliance actually answered. While this lasts, nothing is known about that node's processes, which is why the check warns rather than reporting OK.

### A process is not running

`node02 ! MDC ! not running (1) ! [CRITICAL]`

Identify what the process does before restarting anything: MDC, ZK and OSD carry the cluster's metadata, coordination and data paths, and a cluster that has lost one of them on a single node is usually still serving from the others. Look at the alarms (`huawei-pacific-alarm`) for the same time window, since the appliance normally raises one of its own, and open a support case with Huawei rather than restarting a process by hand on a storage node.

### The process count of a node dropped

No alert fires for this, by design: a process that is no longer in the list has no status that could be non-zero. Watch the `<node>_processes_total` metric of that node against its own history in the dashboard, where a step down is what a lost process looks like. Do not compare it against the other nodes: they legitimately differ, because a node runs the processes its roles call for.

Which process went missing shows in the full table, without `--brief`, next to a node that holds the same roles. `huawei-pacific-node` reports the roles as the node's `usage`, so pick the comparison node from there rather than by name.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
