# Check huawei-dorado-power


## Overview

Checks the health and running status of all power supply units (PSUs) on a Huawei OceanStor Dorado storage system via the REST API (`/power` endpoint). Alerts when any PSU reports a non-normal health or running state. Reports manufacturer, model, serial number, production date, input/output voltage and temperature per PSU.

**Important Notes:**

* Tested on Huawei OceanStor Dorado 8000 V6 6.1.0
* A part that reports no temperature or no remaining life answers with 0 or -1, which is left out of the check and out of the performance data
* Create a read-only API user that can perform queries only
* The default session timeout period on the storage system is 20 minutes; `--cache-expire` defaults to 15 minutes to stay within that window

**Data Collection:**

* Queries the Huawei OceanStor Dorado REST API at `https://<ip>:<port>/deviceManager/rest/<deviceId>/power`
* Authenticates via session tokens (iBaseToken + cookie), cached in a SQLite database to avoid repeated logins
* If the appliance rejects a request, the check logs in again and retries, up to three attempts one second apart


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/huawei-dorado-power> |
| Nagios/Icinga Check Name              | `check_huawei_dorado_power` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | No (`--device-id`, `--password`, `--url` and `--username` are required) |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-huawei-dorado.db` |


## Help

```text
usage: huawei-dorado-power [-h] [-V] [--always-ok]
                           [--cache-expire CACHE_EXPIRE]
                           [--critical-temperature CRIT_TEMPERATURE]
                           [--device-id DEVICE_ID] [--ignore IGNORE]
                           [--insecure] [--no-insecure] [--match MATCH]
                           [--no-match-severity {ok,warn,crit,unknown}]
                           [--no-perfdata] [--no-proxy] [--password PASSWORD]
                           [--password-file PASSWORD_FILE] [--scope SCOPE]
                           [--timeout TIMEOUT] -u URL --username USERNAME
                           [--warning-temperature WARN_TEMPERATURE]

Checks the health and running status of all power modules on a Huawei
OceanStor Dorado storage system via the REST API (/power endpoint). Alerts
when any module reports a non-normal state.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --cache-expire CACHE_EXPIRE
                        The amount of time after which the credential/data
                        cache expires, in minutes. Default: 15
  --critical-temperature CRIT_TEMPERATURE
                        CRIT threshold in degrees Celsius. Off by default,
                        because a healthy operating temperature depends on the
                        power module model and on where the array stands.
                        Example: `--critical-temperature=55`
  --device-id DEVICE_ID
                        Huawei OceanStor Dorado API device ID. Optional: the
                        appliance reports its own at login, so this is only
                        needed to override that answer.
  --ignore IGNORE       Skip power modules. Any item matching this Python
                        regex will be ignored. Can be specified multiple
                        times. Example: `(?i)linuxfabrik` for a case-
                        insensitive match. The regex is anchored at the start
                        of the string (Python `re.match`) and is matched
                        against `UUID`, `LOCATION`, so prefix with `.*` to
                        match anywhere.
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --no-insecure         Verify the TLS certificate against the system trust
                        store, overriding the insecure default of this check.
                        Use it once the endpoint presents a publicly trusted
                        certificate, or once its CA has been added to the
                        system trust store.
  --match MATCH         Filter by power modules. Filter by this Python regular
                        expression. Case-sensitive by default; use `(?i)` for
                        case-insensitive matching. Can be specified multiple
                        times. Examples: `(?i)example` to match "example"
                        regardless of case. `^(?!.*example).*$` to match any
                        string except "example" (negative lookahead). The
                        regex is anchored at the start of the string (Python
                        `re.match`) and is matched against `UUID`, `LOCATION`,
                        so prefix with `.*` to match anywhere.
  --no-match-severity {ok,warn,crit,unknown}
                        State to report when no item matches the filters and
                        nothing is checked. Default: ok
  --no-perfdata         Suppress the performance data section from the output.
                        The status message and the exit code are unaffected,
                        so alerting keeps working while trending data is
                        dropped.
  --no-proxy            Do not use a proxy.
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
  -u, --url URL         Huawei OceanStor Dorado API URL.
  --username USERNAME   Huawei OceanStor Dorado API username.
  --warning-temperature WARN_TEMPERATURE
                        WARN threshold in degrees Celsius. Off by default,
                        because a healthy operating temperature depends on the
                        power module model and on where the array stands.
                        Example: `--warning-temperature=45`

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/huawei-dorado-power/
```


## Usage Examples

```bash
./huawei-dorado-power --url https://oceanstor:8088 --device-id 123456789 --username monitoring --password mypass
```

Output:

```text
There are warnings.

UUID       ! Location    ! Manufacturer ! Model         ! SerialNumber         ! Produced   ! In (MV) ! Out (MV) ! Temp ! Health    ! Running   
-----------+-------------+--------------+---------------+----------------------+------------+---------+----------+------+-----------+-----------
23:23.0.0  ! CTE0.PSU0   ! HUAWEI       ! PAC2000S12-BG ! 12345678             ! 2020-08-20 ! 0       ! 0        ! 0    ! [OK]      ! [OK]      
23:23.0.1  ! CTE0.PSU1   ! HUAWEI       ! PAC2000S12-BG ! 12345678             ! 2020-08-20 ! 0       ! 0        ! 0    ! [OK]      ! [OK]      
23:23.64.0 ! DAE000.PSU0 ! Huawei       ! PAC2000S12-BG ! 12345678             ! 2020-12-02 ! 0       ! 0        ! 0    ! [OK]      ! [OK]      
23:0.0B.0  ! CTE0.PSU 0  ! VAPEL        ! HSP960-D1205D ! 21022701328NE5000004 ! 2014-05-03 ! 0       ! 0        ! 0    ! [WARNING] ! [WARNING]   
```


## States

* OK if all PSUs report normal health and running status.
* WARN if any PSU reports a degraded health status, or one this check does not know.
* WARN if any PSU's running status is not "Normal", "Running" or "Online", unless it reports an outright failure.
* CRIT if any PSU reports health status "Faulty", "Invalid" or "Offline".
* CRIT if any PSU's running status reports a failure ("Offline", "Invalid", "Migration fault", "Error/Faulty", "Power-on failed", "Abnormal" or "Rollback failure").
* WARN or CRIT if a PSU's temperature reaches `--warning-temperature` or `--critical-temperature`. Both are off by default.
* UNKNOWN if the appliance lists no power supplies at all, which points at the query rather than at the hardware.
* `--match` limits the check to the power modules whose identifier, location or name matches the regex; `--no-match-severity` sets what to report when nothing matches (default: OK).
* UNKNOWN on invalid API responses or responses with error codes.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| \<UUID\>\_health_status | Number | 0: unknown, 1: normal, 2: faulty, 9: inconsistent, 11: no input. |
| \<UUID\>\_input_voltage | Number | Input voltage (millivolts). |
| \<UUID\>\_output_voltage | Number | Output voltage (millivolts). |
| \<UUID\>\_running_status | Number | 0: unknown, 1: normal, 2: running, 27: online, 28: offline. |
| \<UUID\>\_temperature | Number | Temperature. |

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
