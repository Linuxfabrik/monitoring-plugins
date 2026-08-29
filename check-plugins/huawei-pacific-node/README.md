# Check huawei-pacific-node


## Overview

Checks the health and running status of all cluster nodes on a Huawei OceanStor Pacific storage system via the REST API (`/cluster/servers` endpoint). Alerts when any node is not online or its OAM agent is not healthy. Supports extended reporting via `--lengthy`.

**Important Notes:**

* Create a read-only API user that can perform queries only
* The credential/session token is cached in a local SQLite database between runs; `--cache-expire` controls how long it is reused before a fresh login

**Data Collection:**

* Queries the Huawei OceanStor Pacific REST API at `https://<ip>:<port>/api/v2/cluster/servers`
* Authenticates via a session token (`X-Auth-Token`), cached in a SQLite database to avoid repeated logins
* If the appliance rejects a request (for example after a session reset or timeout), the check logs in again and retries


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/huawei-pacific-node> |
| Nagios/Icinga Check Name              | `check_huawei_pacific_node` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | No (`--password`, `--url` and `--username` are required) |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No (runs with Python interpreter) |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-huawei-pacific.db` |


## Help

```text
usage: huawei-pacific-node [-h] [-V] [--always-ok]
                           [--cache-expire CACHE_EXPIRE] [--ignore IGNORE]
                           [--insecure] [--lengthy] [--match MATCH]
                           [--no-insecure]
                           [--no-match-severity {ok,warn,crit,unknown}]
                           [--no-perfdata] [--no-proxy] [--password PASSWORD]
                           [--password-file PASSWORD_FILE] [--proxy PROXY]
                           [--scope SCOPE] [--timeout TIMEOUT] -u URL
                           --username USERNAME [-v]
                           [--warranty-severity {ok,warn,crit,unknown}]

Checks the health and running status of all cluster nodes on a Huawei
OceanStor Pacific storage system via the REST API (/cluster/servers endpoint).
Alerts when any node is not online or its OAM agent is not healthy. Supports
extended reporting via --lengthy.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --cache-expire CACHE_EXPIRE
                        The amount of time after which the credential/data
                        cache expires, in minutes. Default: 15
  --ignore IGNORE       Skip cluster nodes. Any item matching this Python
                        regex will be ignored. Can be specified multiple
                        times. Example: `(?i)linuxfabrik` for a case-
                        insensitive match. The regex is anchored at the start
                        of the string (Python `re.match`) and is matched
                        against `name`, `management_ip`, so prefix with `.*`
                        to match anywhere.
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --lengthy             Extended reporting.
  --match MATCH         Limit to cluster nodes. Filter by this Python regular
                        expression. Case-sensitive by default; use `(?i)` for
                        case-insensitive matching. Can be specified multiple
                        times. If both `--match` and `--ignore` are given, an
                        item must match `--match` AND not match `--ignore` to
                        be reported (include first, exclude second). Examples:
                        `(?i)example` to match "example" regardless of case.
                        `^(?!.*example).*$` to match any string except
                        "example" (negative lookahead). The regex is anchored
                        at the start of the string (Python `re.match`) and is
                        matched against `name`, `management_ip`, so prefix
                        with `.*` to match anywhere.
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
  --no-proxy            Do not use a proxy, not even one the environment
                        names. Overrides `--proxy`.
  --password PASSWORD   Huawei OceanStor Pacific API password.
  --password-file PASSWORD_FILE
                        Path to a file holding the password, read from its
                        first line. Keeps the password out of the process
                        list, where a command-line argument is visible to
                        every user on the host. Takes precedence over
                        `--password`. Keep the file readable only by the
                        monitoring user. Example: `--password-
                        file=/etc/icinga2/secrets/storage`.
  --proxy PROXY         Proxy to reach the target through. The scheme defaults
                        to `http` when omitted. Overrides the proxy the
                        environment names (`http_proxy`, `https_proxy`,
                        `all_proxy`) together with the exceptions it lists in
                        `no_proxy`, and is itself overridden by `--no-proxy`.
                        Without either parameter the environment applies.
                        Credentials belong into the environment variable
                        rather than here, because a command-line argument is
                        visible to every user on the host. Example:
                        `--proxy=http://proxy.example.com:3128`.
  --scope SCOPE         Huawei OceanStor Pacific API scope.
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
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
  --warranty-severity {ok,warn,crit,unknown}
                        State to report for a node whose warranty has expired
                        or is about to. This is a commercial fact rather than
                        a fault, so it does not alert by default: a node out
                        of warranty runs exactly as well as one in warranty,
                        right up to the point where a part has to be replaced.
                        Default: ok

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/huawei-pacific-node/
```


## Usage Examples

```bash
./huawei-pacific-node --url=https://oceanstor:8088 --username=monitoring --password=linuxfabrik
```

Output:

```text
Everything is ok.

Name  ! Running ! OAM Agent   ! Warranty                                  ! State
------+---------+-------------+-------------------------------------------+------
FSM01 ! online  ! healthy (0) ! normal, more than six months (1)          ! [OK]
HN00  ! online  ! healthy (0) ! about to expire, less than six months (2) ! [OK]
```

The state in the last column is the worst of everything the check judges about that
node. Which aspect decided it is readable from the columns in front of it. A column
the appliance fills in for no node at all, such as the error code above, is left out
rather than printed as a row of hyphens.

`--lengthy` adds the management IP, the hardware model and the software version of every node:

```bash
./huawei-pacific-node --url=https://oceanstor:8088 --username=monitoring --password=linuxfabrik --lengthy
```

Output:

```text
Everything is ok.

Name  ! Management IP ! Model             ! Base Board         ! Software Version ! Running ! OAM Agent   ! Warranty                                  ! State
------+---------------+-------------------+--------------------+------------------+---------+-------------+-------------------------------------------+------
FSM01 ! 192.0.2.11    ! OceanStor Pacific ! Pacific (STL6SPCM) ! 8.2.0            ! online  ! healthy (0) ! normal, more than six months (1)          ! [OK]
HN00  ! 192.0.2.12    ! OceanStor Pacific ! Pacific (STL6SPCM) ! 8.2.0            ! online  ! healthy (0) ! about to expire, less than six months (2) ! [OK]
```


## States

* OK if all nodes report a running status of "online" and an OAM agent status of "healthy".
* WARN if any node reports a running status this check does not know.
* CRIT if any node's running status is "offline".
* WARN if any node's OAM agent status is not "healthy".
* UNKNOWN if the appliance lists no cluster nodes at all, which points at the query rather than at the hardware.
* UNKNOWN on invalid API responses or responses with error codes.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| \<node\>\_oam_agent_status | Number | OAM agent status of the node. -1: --, 0: healthy, 1: faulty. |


## Troubleshooting

### No valuable response from the API

`Got no valuable response from https://...`

Check the `--url`, `--username` and `--password` parameters. Verify that the API user has query permissions and that the storage system REST API is reachable.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
