# Check huawei-dorado-controller


## Overview

Checks the health and running status of all controllers on a Huawei OceanStor Dorado storage system via the REST API (`/controller` endpoint). Alerts when any controller reports a non-normal health or running state.

**Important Notes:**

* Tested on Huawei OceanStor Dorado 8000 V6 6.1.0
* A controller that does not report a temperature answers with 0, which is left out of the temperature check and out of the performance data
* Create a read-only API user that can perform queries only
* The default session timeout period on the storage system is 20 minutes; `--cache-expire` defaults to 15 minutes to stay within that window

**Data Collection:**

* Queries the Huawei OceanStor Dorado REST API at `https://<ip>:<port>/deviceManager/rest/<deviceId>/controller`
* Authenticates via session tokens (iBaseToken + cookie), cached in a SQLite database to avoid repeated logins
* If the appliance rejects a request, the check logs in again and retries, up to three attempts one second apart


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/huawei-dorado-controller> |
| Nagios/Icinga Check Name              | `check_huawei_dorado_controller` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | No (`--device-id`, `--password`, `--url` and `--username` are required) |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-huawei-dorado.db` |


## Help

```text
usage: huawei-dorado-controller [-h] [-V] [--always-ok]
                                [--cache-expire CACHE_EXPIRE] [-c CRIT]
                                [--critical-temperature CRIT_TEMPERATURE]
                                [--device-id DEVICE_ID] [--ignore IGNORE]
                                [--insecure] [--lengthy] [--no-insecure]
                                [--match MATCH]
                                [--no-match-severity {ok,warn,crit,unknown}]
                                [--no-perfdata] [--no-proxy] [--performance]
                                [--password PASSWORD]
                                [--password-file PASSWORD_FILE]
                                [--scope SCOPE] [--timeout TIMEOUT] -u URL
                                --username USERNAME [-w WARN]
                                [--warning-temperature WARN_TEMPERATURE] [-v]

Checks the health and running status of all controllers on a Huawei OceanStor
Dorado storage system via the REST API (/controller endpoint). Alerts when any
controller reports a non-normal health or running state, and optionally when
its CPU, memory or temperature exceeds the configured thresholds. Supports
extended reporting via --lengthy, and reporting the I/O and cache counters via
--performance.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --cache-expire CACHE_EXPIRE
                        The amount of time after which the credential/data
                        cache expires, in minutes. Default: 15
  -c, --critical CRIT   CRIT threshold for CPU and memory usage, as a Nagios
                        range in percent. Off by default, because a controller
                        under load is doing its job; set it once you know what
                        your array normally sits at. Example: `--critical=90`
  --critical-temperature CRIT_TEMPERATURE
                        CRIT threshold in degrees Celsius. Off by default,
                        because a healthy operating temperature depends on the
                        controller model and on where the array stands.
                        Example: `--critical-temperature=55`
  --device-id DEVICE_ID
                        Huawei OceanStor Dorado API device ID. Optional: the
                        appliance reports its own at login, so this is only
                        needed to override that answer.
  --ignore IGNORE       Skip controllers. Any item matching this Python regex
                        will be ignored. Can be specified multiple times.
                        Example: `(?i)linuxfabrik` for a case-insensitive
                        match. The regex is anchored at the start of the
                        string (Python `re.match`) and is matched against
                        `UUID`, `LOCATION`, so prefix with `.*` to match
                        anywhere.
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --lengthy             Extended reporting.
  --no-insecure         Verify the TLS certificate against the system trust
                        store, overriding the insecure default of this check.
                        Use it once the endpoint presents a publicly trusted
                        certificate, or once its CA has been added to the
                        system trust store.
  --match MATCH         Limit to controllers. Filter by this Python regular
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
  --performance         Additionally report the I/O counters of every
                        controller. Costs one API request per object, so a
                        large appliance may need a higher --timeout.
  --password PASSWORD   Huawei OceanStor Dorado API password. Password.
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
  -u, --url URL         Huawei OceanStor Dorado API URL. URL to the endpoint.
  --username USERNAME   Huawei OceanStor Dorado API username. Username.
  -w, --warning WARN    WARN threshold for CPU and memory usage, as a Nagios
                        range in percent. Off by default, because a controller
                        under load is doing its job; set it once you know what
                        your array normally sits at. Example: `--warning=80`
  --warning-temperature WARN_TEMPERATURE
                        WARN threshold in degrees Celsius. Off by default,
                        because a healthy operating temperature depends on the
                        controller model and on where the array stands.
                        Example: `--warning-temperature=45`
  -v, --verbose         Makes this plugin verbose during the operation. Useful
                        for debugging and seeing what is going on under the
                        hood. Appends what every API request returned, so the
                        appliance's own answers can be read while working out
                        how it reports something. Session tokens are redacted.
                        The output is as long as those answers are, so this is
                        a debugging aid rather than something to leave
                        switched on.

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/huawei-dorado-controller/
```


## Usage Examples

```bash
./huawei-dorado-controller --url=https://oceanstor:8088 --device-id=123456789 --username=monitoring --password=linuxfabrik
```

Output:

```text
There are critical errors.

UUID   ! Location ! Master ! CPU (%) ! Mem (%) ! Health     ! Running     ! State
-------+----------+--------+---------+---------+------------+-------------+-----------
207:0A ! CTE0.A   ! -      ! 3       ! 75      ! Faulty (2) ! Online (27) ! [CRITICAL]
207:0E ! CTE0.E   ! -      ! 33      ! 87      ! Normal (1) ! Online (27) ! [OK]
207:0B ! CTE0.B   ! x      ! 17      ! 87      ! Normal (1) ! Online (27) ! [OK]
207:0C ! CTE0.C   ! -      ! 33      ! 86      ! Normal (1) ! Online (27) ! [OK]
```

`--lengthy` adds the board model, its role in the pair and the board voltage:

```bash
./huawei-dorado-controller --url=https://oceanstor:8088 --device-id=123456789 --username=monitoring --password=linuxfabrik --lengthy
```

Output:

```text
There are critical errors.

UUID   ! Location ! Model              ! Role      ! Master ! CPU (%) ! Mem (%) ! Volt ! Health     ! Running     ! State
-------+----------+--------------------+-----------+--------+---------+---------+------+------------+-------------+-----------
207:0A ! CTE0.A   ! Unknown            ! Primary   ! -      ! 3       ! 75      ! 12.0 ! Faulty (2) ! Online (27) ! [CRITICAL]
207:0E ! CTE0.E   ! 4U4C control board ! Secondary ! -      ! 33      ! 87      ! 12.0 ! Normal (1) ! Online (27) ! [OK]
207:0B ! CTE0.B   ! 4U4C control board ! Primary   ! x      ! 17      ! 87      ! 12.0 ! Normal (1) ! Online (27) ! [OK]
207:0C ! CTE0.C   ! 4U4C control board ! Secondary ! -      ! 33      ! 86      ! 12.0 ! Normal (1) ! Online (27) ! [OK]
```


## States

* OK if all controllers report normal health and running status.
* WARN if any controller reports a degraded health status, or one this check does not know.
* WARN if any controller's running status is not "Normal", "Running" or "Online", unless it reports an outright failure.
* CRIT if any controller reports health status "Faulty", "No Input", "Invalid" or "Offline".
* CRIT if any controller's running status reports a failure ("Not running", "Sleep in High Temperature", "Offline", "Invalid", "Migration fault", "Error/Faulty", "To be synchronized", "Power-on failed", "Abnormal" or "Rollback failure").
* WARN or CRIT if a controller's CPU or memory usage reaches `--warning` or `--critical`. Both are off by default.
* WARN or CRIT if a controller's temperature reaches `--warning-temperature` or `--critical-temperature`. Both are off by default.
* UNKNOWN if the appliance lists no controllers at all, which points at the query rather than at the hardware.
* `--match` limits the check to the controllers whose identifier, location or name matches the regex; `--no-match-severity` sets what to report when nothing matches (default: OK).
* UNKNOWN on invalid API responses or responses with error codes.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| \<UUID\>\_cpu_usage | Percentage | CPU utilization. |
| \<UUID\>\_dirty_data_rate | Percentage | Dirty page usage. |
| \<UUID\>\_health_status | Number | 0: unknown, 1: normal, 2: faulty. |
| \<UUID\>\_light_status | Number | Location indicator, as the bare code the appliance sends. The vendor documents it both ways round for the same field, so it cannot be translated into on/off reliably. |
| \<UUID\>\_memory_usage | Percentage | Memory utilization. |
| \<UUID\>\_running_status | Number | 0: unknown, 1: normal, 2: running, 5: sleep in high temperature, 27: online, 28: offline, 105: abnormal. |
| \<UUID\>\_temperature | Number | Temperature in degrees Celsius. A board without a sensor reports -1 and is left out. |
| \<UUID\>\_voltage | Number | Board voltage in volts. The appliance counts it in tenths of a volt. |

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
