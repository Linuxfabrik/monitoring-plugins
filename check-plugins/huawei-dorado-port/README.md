# Check huawei-dorado-port


## Overview

Checks the health and link status of the front-end ports of a Huawei OceanStor Dorado storage system via the REST API (`/fc_port`, `/eth_port` and `/sas_port` endpoints). Alerts when a port reports a non-normal health status, and optionally when a link is down. Reports the port type, its location and its link state.

**Important Notes:**

* Tested on Huawei OceanStor Dorado 8000 V6 6.1.0
* A port whose link is down reports exactly what an uncabled port reports, so this does not alert by default. Set `--link-down-severity` on an array where every port is expected to be connected
* These endpoints use their own running-status enumeration: 0 unknown, 10 link up, 11 link down, and 33 to be recovered on Ethernet ports. It has nothing in common with the codes the other objects use
* An endpoint an appliance does not implement, or that carries no port, contributes nothing instead of failing the check. An array without SAS ports is a normal array
* Create a read-only API user that can perform queries only
* The default session timeout period on the storage system is 20 minutes; `--cache-expire` defaults to 15 minutes to stay within that window

**Data Collection:**

* Queries the Huawei OceanStor Dorado REST API at `https://<ip>:<port>/deviceManager/rest/<deviceId>/{fc_port,eth_port,sas_port}`
* Each endpoint is read in a single request, because unlike the other list endpoints these do not implement the `range` parameter
* Authenticates via session tokens (iBaseToken + cookie), cached in a SQLite database to avoid repeated logins
* If the appliance rejects a request, the check logs in again and retries, up to three attempts one second apart


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/huawei-dorado-port> |
| Nagios/Icinga Check Name              | `check_huawei_dorado_port` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | No (`--device-id`, `--password`, `--url` and `--username` are required) |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-huawei-dorado.db` |


## Help

```text
usage: huawei-dorado-port [-h] [-V] [--always-ok]
                          [--cache-expire CACHE_EXPIRE] --device-id DEVICE_ID
                          [--insecure]
                          [--link-down-severity {ok,warn,crit,unknown}]
                          [--match MATCH] [--no-insecure]
                          [--no-match-severity {ok,warn,crit,unknown}]
                          [--no-perfdata] [--no-proxy] --password PASSWORD
                          [--scope SCOPE] [--timeout TIMEOUT] -u URL
                          --username USERNAME

Checks the health and link status of the front-end ports of a Huawei OceanStor
Dorado storage system via the REST API (/fc_port, /eth_port and /sas_port
endpoints). Alerts when a port reports a non-normal health status, and
optionally when a link is down.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --cache-expire CACHE_EXPIRE
                        The amount of time after which the credential/data
                        cache expires, in minutes. Default: 15
  --device-id DEVICE_ID
                        Huawei OceanStor Dorado API device ID.
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --link-down-severity {ok,warn,crit,unknown}
                        State to report for a port whose link is down. A port
                        that is simply not cabled reports the same thing,
                        which is why this defaults to not alerting. Default:
                        ok
  --match MATCH         Filter by ports. Filter by this Python regular
                        expression. Case-sensitive by default; use `(?i)` for
                        case-insensitive matching. Can be specified multiple
                        times. Examples: `(?i)example` to match "example"
                        regardless of case. `^(?!.*example).*$` to match any
                        string except "example" (negative lookahead). The
                        regex is anchored at the start of the string (Python
                        `re.match`) and is matched against the port
                        identifier, its location and its name, so prefix with
                        `.*` to match anywhere. Default:
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
  --password PASSWORD   Huawei OceanStor Dorado API password.
  --scope SCOPE         Huawei OceanStor Dorado API scope.
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
  -u, --url URL         Huawei OceanStor Dorado API URL.
  --username USERNAME   Huawei OceanStor Dorado API username.

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/huawei-dorado-port/
```


## Usage Examples

```bash
./huawei-dorado-port --url=https://oceanstor:8088 --device-id=123456789 --username=monitoring --password=linuxfabrik
```

Output:

```text
Everything is ok.

UUID     ! Type     ! Location       ! Link           ! Health ! Link State
---------+----------+----------------+----------------+--------+-----------
212:0A.0 ! FC       ! CTE0.A.IOM0.P0 ! Link up (10)   ! [OK]   ! [OK]
212:0A.1 ! FC       ! CTE0.A.IOM0.P1 ! Link up (10)   ! [OK]   ! [OK]
213:0A.2 ! Ethernet ! CTE0.A.IOM1.P0 ! Link up (10)   ! [OK]   ! [OK]
213:0A.3 ! Ethernet ! CTE0.A.IOM1.P1 ! Link down (11) ! [OK]   ! [OK]
```

On an array where every front-end port is cabled, alert on a lost link, and look at the FC ports only:

```bash
./huawei-dorado-port --url=https://oceanstor:8088 --device-id=123456789 --username=monitoring --password=linuxfabrik --link-down-severity=crit --match='^212'
```


## States

* OK if all ports report normal health.
* WARN if a port reports a degraded health status, or one this check does not know.
* WARN if a port reports a link state this check does not know.
* CRIT if a port reports health status "Faulty", "Invalid" or "Offline".
* `--link-down-severity` decides what a port whose link is down reports (default: OK).
* UNKNOWN if the appliance lists no front-end ports at all, which points at the query rather than at the array.
* UNKNOWN on invalid API responses or responses with error codes.
* `--match` limits the check to the ports whose identifier, location or name matches the regex; `--no-match-severity` sets what to report when nothing matches (default: OK).
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| \<UUID\>\_health_status | Number | 1: normal, 2: faulty, 5: degraded, 9: inconsistent. |
| \<UUID\>\_running_status | Number | 0: unknown, 10: link up, 11: link down, 33: to be recovered. |

Have a look at the [API documentation](https://support.huawei.com/enterprise/en/doc/EDOC1100144155/387d790e/overview) for details.


## Troubleshooting

### No valuable response from the API

`Got no valuable response from https://...`

Check the `--url`, `--device-id`, `--username` and `--password` parameters. Verify that the API user has query permissions and that the storage system REST API is reachable.

### `This operation fails to be performed because of the unauthorized REST.`

This is a known transient issue with the Huawei REST API. The check makes up to three attempts and forces a fresh login before the second one. If the error persists, verify the API credentials and session timeout settings.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
