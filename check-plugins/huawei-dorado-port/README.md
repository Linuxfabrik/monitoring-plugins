# Check huawei-dorado-port


## Overview

Checks the health and link status of the front-end ports of a Huawei OceanStor Dorado storage system via the REST API (`/fc_port`, `/eth_port`, `/sas_port` and `/bond_port` endpoints). Alerts when a port reports a non-normal health status, when it negotiated a speed below the one it is configured or built for, and optionally when a link is down. Reports the port type, its location, its link state, its operating speed and the link error counters the appliance keeps, as per-second rates.

**Important Notes:**

* Tested on Huawei OceanStor Dorado 8000 V6 6.1.0
* A port whose link is down reports exactly what an uncabled port reports, so this does not alert by default. Set `--link-down-severity` on an array where every port is expected to be connected
* A port that negotiated below its configured or maximum speed still carries traffic, so nothing else in this check notices it. It is what a dirty connector, the wrong transceiver or a mismatched switch port look like, which is why `--slow-port-severity` defaults to WARN
* The appliance counts its link errors as totals since it started counting. The check stores the previous reading in a local database and reports the difference as a per-second rate, so the **first run after an update or a reboot reports no error rates at all**. The second run has a baseline to compare against
* The error thresholds are off by default. A healthy link sits at 0 errors per second; watch the graph before setting `--warning-errors`
* Bond ports are aggregates of other ports and report neither a speed nor error counters, so those columns stay empty for them
* These endpoints use their own running-status enumeration: 0 unknown, 10 link up, 11 link down, and 33 to be recovered on Ethernet ports. It has nothing in common with the codes the other objects use
* An endpoint an appliance does not implement, or that carries no port, contributes nothing instead of failing the check. An array without SAS ports is a normal array
* FCoE and InfiniBand ports are not queried. Neither REST Interface Reference documents an endpoint for them
* Create a read-only API user that can perform queries only
* The default session timeout period on the storage system is 20 minutes; `--cache-expire` defaults to 15 minutes to stay within that window

**Data Collection:**

* Queries the Huawei OceanStor Dorado REST API at `https://<ip>:<port>/deviceManager/rest/<deviceId>/{fc_port,eth_port,sas_port,bond_port}`
* Each endpoint is read in a single request, because unlike the other list endpoints these do not implement the `range` parameter
* Authenticates via session tokens (iBaseToken + cookie), cached in a SQLite database to avoid repeated logins
* If the appliance rejects a request, the check logs in again and retries, up to three attempts one second apart
* Stores the previous link error counter reading in a local SQLite database, so the ever-growing totals can be reported as per-second rates ([#320](https://github.com/Linuxfabrik/monitoring-plugins/issues/320))


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/huawei-dorado-port> |
| Nagios/Icinga Check Name              | `check_huawei_dorado_port` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | No (`--device-id`, `--password`, `--url` and `--username` are required) |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-huawei-dorado.db` (API session), `$TEMP/linuxfabrik-monitoring-plugins-huawei-dorado-port.db` (link error counters) |


## Help

```text
usage: huawei-dorado-port [-h] [-V] [--always-ok] [--brief]
                          [--cache-expire CACHE_EXPIRE]
                          [--critical-errors CRIT_ERRORS]
                          [--device-id DEVICE_ID] [--ignore IGNORE]
                          [--insecure]
                          [--link-down-severity {ok,warn,crit,unknown}]
                          [--match MATCH] [--no-insecure]
                          [--no-match-severity {ok,warn,crit,unknown}]
                          [--no-perfdata] [--no-proxy] [--performance]
                          [--password PASSWORD]
                          [--password-file PASSWORD_FILE] [--proxy PROXY]
                          [--scope SCOPE]
                          [--slow-port-severity {ok,warn,crit,unknown}]
                          [--timeout TIMEOUT] -u URL --username USERNAME
                          [--warning-errors WARN_ERRORS] [-v]

Checks the health and link status of the front-end ports of a Huawei OceanStor
Dorado storage system via the REST API (/fc_port, /eth_port, /sas_port and
/bond_port endpoints). Alerts when a port reports a non-normal health status,
when it negotiated a speed below the one it is configured or built for, and
optionally when a link is down. Reports the link error counters the appliance
keeps as per-second rates. Supports reporting the I/O counters via
--performance.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --brief               Hide the rows that are within the thresholds and show
                        only those in a WARN or CRIT state. Perfdata and
                        alerting are unaffected: every item still emits
                        performance data and still drives the overall check
                        state, so this is safe to leave on. Worth setting on
                        an array with many ports. Default: False
  --cache-expire CACHE_EXPIRE
                        The amount of time after which the credential/data
                        cache expires, in minutes. Default: 15
  --critical-errors CRIT_ERRORS
                        CRIT threshold for the link errors of a port, as a
                        Nagios range in errors per second, summed over every
                        error counter that port keeps. Off by default, because
                        a link that drops the occasional frame is not worth
                        waking anyone; watch the graph first and set it once
                        you know what your fabric normally sits at. A healthy
                        link sits at 0. Example: `--critical-errors=10`
  --device-id DEVICE_ID
                        Huawei OceanStor Dorado API device ID. Optional: the
                        appliance reports its own at login, so this is only
                        needed to override that answer.
  --ignore IGNORE       Skip ports. Any item matching this Python regex will
                        be ignored. Can be specified multiple times. Example:
                        `(?i)linuxfabrik` for a case-insensitive match. The
                        regex is anchored at the start of the string (Python
                        `re.match`) and is matched against the port
                        identifier, its location and its name, so prefix with
                        `.*` to match anywhere. Default: None
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --link-down-severity {ok,warn,crit,unknown}
                        State to report for a port whose link is down. A port
                        that is simply not cabled reports the same thing,
                        which is why this defaults to not alerting. Default:
                        ok
  --match MATCH         Limit to ports. Filter by this Python regular
                        expression. Case-sensitive by default; use `(?i)` for
                        case-insensitive matching. Can be specified multiple
                        times. If both `--match` and `--ignore` are given, an
                        item must match `--match` AND not match `--ignore` to
                        be reported (include first, exclude second). Examples:
                        `(?i)example` to match "example" regardless of case.
                        `^(?!.*example).*$` to match any string except
                        "example" (negative lookahead). The regex is anchored
                        at the start of the string (Python `re.match`) and is
                        matched against the port identifier, its location and
                        its name, so prefix with `.*` to match anywhere.
                        Default: None
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
  --performance         Additionally report the I/O counters of every front-
                        end port. Costs one API request per object, so a large
                        appliance may need a higher --timeout.
  --password PASSWORD   Huawei OceanStor Dorado API password.
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
  --scope SCOPE         Huawei OceanStor Dorado API scope.
  --slow-port-severity {ok,warn,crit,unknown}
                        State to report for a port that negotiated a speed
                        below the one it is configured for, or below the one
                        it is built for where it is set to auto-negotiate. A
                        dirty connector, the wrong transceiver or a mismatched
                        switch port show up this way long before the link
                        drops. Default: warn
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
  -u, --url URL         Huawei OceanStor Dorado API URL.
  --username USERNAME   Huawei OceanStor Dorado API username.
  --warning-errors WARN_ERRORS
                        WARN threshold for the link errors of a port, as a
                        Nagios range in errors per second, summed over every
                        error counter that port keeps. Off by default, because
                        a link that drops the occasional frame is not worth
                        alerting on; watch the graph first and set it once you
                        know what your fabric normally sits at. A healthy link
                        sits at 0. Example: `--warning-errors=1`
  -v, --verbose         Makes this plugin verbose during the operation. Useful
                        for debugging and seeing what is going on under the
                        hood. Appends what every API request returned, so the
                        appliance's own answers can be read while working out
                        how it reports something. Session tokens are redacted.
                        The output is as long as those answers are, so this is
                        a debugging aid rather than something to leave
                        switched on.

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

UUID     ! Type     ! Location       ! Mbit/s ! Link           ! Health     ! State
---------+----------+----------------+--------+----------------+------------+------
212:0A.0 ! FC       ! CTE0.A.IOM0.P0 ! 32000  ! Link up (10)   ! Normal (1) ! [OK]
212:0A.1 ! FC       ! CTE0.A.IOM0.P1 ! 32000  ! Link up (10)   ! Normal (1) ! [OK]
213:0A.2 ! Ethernet ! CTE0.A.IOM1.P0 ! 25000  ! Link up (10)   ! Normal (1) ! [OK]
213:0A.3 ! Ethernet ! CTE0.A.IOM1.P1 ! --     ! Link down (11) ! Normal (1) ! [OK]
```

On an array where every front-end port is cabled, alert on a lost link, and look at the FC ports only:

```bash
./huawei-dorado-port --url=https://oceanstor:8088 --device-id=123456789 --username=monitoring --password=linuxfabrik --link-down-severity=crit --match='^212'
```


## States

* OK if all ports report normal health.
* WARN if a port reports a degraded health status, or one this check does not know.
* WARN if a port reports a link state this check does not know.
* CRIT if a port reports health status "Faulty", "No Input", "Invalid" or "Offline".
* `--link-down-severity` decides what a port whose link is down reports (default: OK).
* `--slow-port-severity` decides what a port that negotiated below its configured speed reports, or below its maximum speed where it is set to auto-negotiate (default: WARN).
* WARN or CRIT if a port's link errors per second, summed over every counter that port keeps, reach `--warning-errors` or `--critical-errors`. Both are off by default.
* UNKNOWN if the appliance lists no front-end ports at all, which points at the query rather than at the array.
* UNKNOWN on invalid API responses or responses with error codes.
* `--match` limits the check to the ports whose identifier, location or name matches the regex; `--no-match-severity` sets what to report when nothing matches (default: OK).
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| \<UUID\>\_health_status | Number | 1: normal, 2: faulty, 5: degraded, 9: inconsistent. |
| \<UUID\>\_running_status | Number | 0: unknown, 10: link up, 11: link down, 33: to be recovered. |
| \<UUID\>\_speed | Number | Operating speed in Mbit/s. A port with no link reports none and is left out. |
| \<UUID\>\_bad_characters_per_second | Number | FC ports: invalid characters received, per second. |
| \<UUID\>\_crc_errors_per_second | Number | FC and Ethernet ports: CRC errors, per second. |
| \<UUID\>\_disparity_errors_per_second | Number | SAS ports: disparity errors, per second. |
| \<UUID\>\_end_of_frame_errors_per_second | Number | FC ports: frame end sign errors, per second. |
| \<UUID\>\_error_packets_per_second | Number | Ethernet ports: error packets, per second. |
| \<UUID\>\_frame_errors_per_second | Number | Ethernet ports: frame errors, per second. |
| \<UUID\>\_frame_length_errors_per_second | Number | Ethernet ports: frame length errors, per second. |
| \<UUID\>\_invalid_dwords_per_second | Number | SAS ports: invalid dwords, per second. |
| \<UUID\>\_link_failures_per_second | Number | FC ports: link failures, per second. |
| \<UUID\>\_lost_dwords_per_second | Number | SAS ports: lost dwords, per second. |
| \<UUID\>\_lost_packets_per_second | Number | Ethernet ports: lost packets, per second. |
| \<UUID\>\_lost_signals_per_second | Number | FC ports: lost signals, per second. |
| \<UUID\>\_lost_sync_per_second | Number | FC ports: lost synchronizations, per second. |
| \<UUID\>\_overflowed_packets_per_second | Number | Ethernet ports: overflowed packets, per second. |
| \<UUID\>\_phy_reset_errors_per_second | Number | SAS ports: failed PHY resets, per second. |

Every port reports only the counters its own kind keeps, and the rates appear from the second check run onwards.

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
