# Check huawei-dorado-fan


## Overview

Checks the health and running status of all fans on a Huawei OceanStor Dorado storage system via the REST API (`/fan` endpoint). Alerts when any fan reports a non-normal health or running state. Reports the run level (low, normal, high) per fan.

**Important Notes:**

* Tested on Huawei OceanStor Dorado 8000 V6 6.1.0
* Create a read-only API user that can perform queries only
* The default session timeout period on the storage system is 20 minutes; `--cache-expire` defaults to 15 minutes to stay within that window

**Data Collection:**

* Queries the Huawei OceanStor Dorado REST API at `https://<ip>:<port>/deviceManager/rest/<deviceId>/fan`
* Authenticates via session tokens (iBaseToken + cookie), cached in a SQLite database to avoid repeated logins
* If the appliance rejects a request, the check logs in again and retries, up to three attempts one second apart


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/huawei-dorado-fan> |
| Nagios/Icinga Check Name              | `check_huawei_dorado_fan` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | No (`--device-id`, `--password`, `--url` and `--username` are required) |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-huawei-dorado.db` |


## Help

```text
usage: huawei-dorado-fan [-h] [-V] [--always-ok] [--cache-expire CACHE_EXPIRE]
                         [--device-id DEVICE_ID] [--ignore IGNORE]
                         [--insecure] [--no-insecure] [--match MATCH]
                         [--no-match-severity {ok,warn,crit,unknown}]
                         [--no-perfdata] [--no-proxy] [--password PASSWORD]
                         [--password-file PASSWORD_FILE] [--scope SCOPE]
                         [--timeout TIMEOUT] -u URL --username USERNAME [-v]

Checks the health and running status of all fans on a Huawei OceanStor Dorado
storage system via the REST API (/fan endpoint). Alerts when any fan reports a
non-normal state.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --cache-expire CACHE_EXPIRE
                        The amount of time after which the credential/data
                        cache expires, in minutes. Default: 15
  --device-id DEVICE_ID
                        Huawei OceanStor Dorado API device ID. Optional: the
                        appliance reports its own at login, so this is only
                        needed to override that answer.
  --ignore IGNORE       Skip fans. Any item matching this Python regex will be
                        ignored. Can be specified multiple times. Example:
                        `(?i)linuxfabrik` for a case-insensitive match. The
                        regex is anchored at the start of the string (Python
                        `re.match`) and is matched against `UUID`, `LOCATION`,
                        so prefix with `.*` to match anywhere.
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --no-insecure         Verify the TLS certificate against the system trust
                        store, overriding the insecure default of this check.
                        Use it once the endpoint presents a publicly trusted
                        certificate, or once its CA has been added to the
                        system trust store.
  --match MATCH         Limit to fans. Filter by this Python regular
                        expression. Case-sensitive by default; use `(?i)` for
                        case-insensitive matching. Can be specified multiple
                        times. If both `--match` and `--ignore` are given, an
                        item must match `--match` AND not match `--ignore` to
                        be reported (include first, exclude second). Examples:
                        `(?i)example` to match "example" regardless of case.
                        `^(?!.*example).*$` to match any string except
                        "example" (negative lookahead). The regex is anchored
                        at the start of the string (Python `re.match`) and is
                        matched against `UUID`, `LOCATION`, so prefix with
                        `.*` to match anywhere.
  --no-match-severity {ok,warn,crit,unknown}
                        State to report when no item matches the filters and
                        nothing is checked. Default: ok
  --no-perfdata         Suppress the performance data section from the output.
                        The status message and the exit code are unaffected,
                        so alerting keeps working while trending data is
                        dropped.
  --no-proxy            Do not use a proxy.
  --password PASSWORD   Huawei OceanStor Dorado API password.
  --password-file PASSWORD_FILE
                        Path to a file holding the password, read from its
                        first line. Keeps the password out of the process
                        list, where a command-line argument is visible to
                        every user on the host. Takes precedence over
                        `--password`. Keep the file readable only by the
                        monitoring user. Example: `--password-
                        file=/etc/icinga2/secrets/storage`.
  --scope SCOPE         Huawei OceanStor Dorado API scope.
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
  -u, --url URL         Huawei OceanStor Dorado API URL.
  --username USERNAME   Huawei OceanStor Dorado API username.
  -v, --verbose         Makes this plugin verbose during the operation. Useful
                        for debugging and seeing what is going on under the
                        hood. Appends what every API request returned, so the
                        appliance's own answers can be read while working out
                        how it reports something. Session tokens are redacted.
                        The output is as long as those answers are, so this is
                        a debugging aid rather than something to leave
                        switched on.

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/huawei-dorado-fan/
```


## Usage Examples

```bash
./huawei-dorado-fan --url=https://oceanstor:8088 --device-id=123456789 --username=monitoring --password=linuxfabrik
```

Output:

```text
Everything is ok.

UUID            ! Location      ! Runlevel   ! Health     ! Running     ! State
----------------+---------------+------------+------------+-------------+------
211:211.0.0.00  ! CTE0.A.FAN0   ! normal (1) ! Normal (1) ! Running (2) ! [OK]
211:211.0.0.01  ! CTE0.A.FAN1   ! normal (1) ! Normal (1) ! Running (2) ! [OK]
211:211.0.0.02  ! CTE0.A.FAN2   ! normal (1) ! Normal (1) ! Running (2) ! [OK]
211:211.0.0.03  ! CTE0.A.FAN3   ! normal (1) ! Normal (1) ! Running (2) ! [OK]
```


## States

* OK if all fans report normal health and running status.
* WARN if any fan reports a degraded health status, or one this check does not know.
* WARN if any fan's running status is not "Normal", "Running" or "Online", unless it reports an outright failure.
* CRIT if any fan reports health status "Faulty", "No Input", "Invalid" or "Offline".
* CRIT if any fan's running status reports a failure ("Not running", "Sleep in High Temperature", "Offline", "Invalid", "Migration fault", "Error/Faulty", "To be synchronized", "Power-on failed", "Abnormal" or "Rollback failure").
* UNKNOWN if the appliance lists no fans at all, which points at the query rather than at the hardware.
* `--match` limits the check to the fans whose identifier, location or name matches the regex; `--no-match-severity` sets what to report when nothing matches (default: OK).
* UNKNOWN on invalid API responses or responses with error codes.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| \<UUID\>\_health_status | Number | 0: unknown, 1: normal, 2: faulty. |
| \<UUID\>\_run_level | Number | 0: low, 1: normal, 2: high. |
| \<UUID\>\_running_status | Number | 0: unknown, 1: normal, 2: running, 3: not running, 8: spin down, 27: online, 28: offline. |

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
