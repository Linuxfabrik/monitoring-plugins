# Check huawei-dorado-expboard


## Overview

Checks the health and running status of all fans on a Huawei OceanStor Dorado storage system via the REST API (`/fan` endpoint). Alerts when any fan reports a non-normal health or running state. Reports the run level (low, normal, high) per fan.

**Important Notes:**

* Tested on Huawei OceanStor Dorado 8000 V6 6.1.0
* An array without expansion enclosures has no expansion board and reports OK. Unlike the built-in hardware, this check cannot tell an empty inventory from a query that never reached one
* Create a read-only API user that can perform queries only
* The default session timeout period on the storage system is 20 minutes; `--cache-expire` defaults to 15 minutes to stay within that window

**Data Collection:**

* Queries the Huawei OceanStor Dorado REST API at `https://<ip>:<port>/deviceManager/rest/<deviceId>/expboard`
* Authenticates via session tokens (iBaseToken + cookie), cached in a SQLite database to avoid repeated logins
* If the appliance rejects a request, the check logs in again and retries, up to three attempts one second apart


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/huawei-dorado-expboard> |
| Nagios/Icinga Check Name              | `check_huawei_dorado_expboard` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | No (`--device-id`, `--password`, `--url` and `--username` are required) |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-huawei-dorado.db` |


## Help

```text
usage: huawei-dorado-expboard [-h] [-V] [--always-ok]
                              [--cache-expire CACHE_EXPIRE]
                              --device-id DEVICE_ID [--insecure]
                              [--no-insecure] [--match MATCH]
                              [--no-match-severity {ok,warn,crit,unknown}]
                              [--no-perfdata] [--no-proxy] --password PASSWORD
                              [--scope SCOPE] [--timeout TIMEOUT] -u URL
                              --username USERNAME

Checks the health and running status of all expansion boards on a Huawei
OceanStor Dorado storage system via the REST API (/expboard endpoint). Alerts
when any board reports a non-normal state.

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
  --no-insecure         Verify the TLS certificate against the system trust
                        store, overriding the insecure default of this check.
                        Use it once the endpoint presents a publicly trusted
                        certificate, or once its CA has been added to the
                        system trust store.
  --match MATCH         Filter by expansion boards. Filter by this Python
                        regular expression. Case-sensitive by default; use
                        `(?i)` for case-insensitive matching. Can be specified
                        multiple times. Examples: `(?i)example` to match
                        "example" regardless of case. `^(?!.*example).*$` to
                        match any string except "example" (negative
                        lookahead). The regex is anchored at the start of the
                        string (Python `re.match`) and is matched against
                        `UUID`, `LOCATION`, so prefix with `.*` to match
                        anywhere. Default:
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
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/huawei-dorado-expboard/
```


## Usage Examples

```bash
./huawei-dorado-expboard --url https://oceanstor:8088 --device-id 123456789 --username monitoring --password mypass
```

Output:

```text
Everything is ok.

UUID  ! Location ! Model       ! Health ! Running
------+----------+-------------+--------+--------
208:0 ! DAE000.A ! EXP-12G-SAS ! [OK]   ! [OK]
208:1 ! DAE000.B ! EXP-12G-SAS ! [OK]   ! [OK]
```


## States

* OK if all expansion boards report normal health and running status.
* OK with "No expansion boards found." if the array has no expansion enclosure.
* WARN if any board reports a degraded health status, or one this check does not know.
* WARN if any board's running status is not "Normal", "Running" or "Online", unless it reports an outright failure.
* CRIT if any board reports health status "Faulty", "Invalid" or "Offline".
* CRIT if any board's running status reports a failure ("Offline", "Invalid", "Migration fault", "Error/Faulty", "Power-on failed", "Abnormal" or "Rollback failure").
* `--match` limits the check to the boards whose identifier, location or name matches the regex; `--no-match-severity` sets what to report when nothing matches (default: OK).
* UNKNOWN on invalid API responses or responses with error codes.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| \<UUID\>\_health_status | Number | 0: unknown, 1: normal, 2: faulty. |
| \<UUID\>\_running_status | Number | 0: unknown, 1: normal, 2: running, 12: powering on, 13: powered off, 27: online. |

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
