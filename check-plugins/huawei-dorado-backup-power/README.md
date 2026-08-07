# Check huawei-dorado-backup-power


## Overview

Checks the health status of all backup power modules (BBU) on a Huawei OceanStor Dorado storage system via the REST API (`/backup_power` endpoint). Alerts when any module reports a non-normal health or running state.

**Important Notes:**

* Tested on Huawei OceanStor Dorado 8000 V6 6.1.0
* A part that reports no temperature or no remaining life answers with 0 or -1, which is left out of the check and out of the performance data
* Create a read-only API user that can perform query only.
* Sometimes the API returns "This operation fails to be performed because of the unauthorized REST. Before performing this operation, ensure that REST is authorized.", although everything is fine. In this case, the check retries the request, a maximum of 9 times within 9 seconds.
* `--insecure` is enabled by default because Huawei OceanStor Dorado typically uses self-signed certificates.

**Data Collection:**

* Queries the Huawei OceanStor Dorado REST API at `https://<ip>:<port>/deviceManager/rest/<deviceId>/backup_power` to retrieve all BBU module data
* Reports health status, running status, discharge count, remaining service life, and voltage for each BBU
* Cookies and iBaseTokens are cached and re-used (the session timeout period is usually 20 minutes, configurable via `--cache-expire`)


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/huawei-dorado-backup-power> |
| Nagios/Icinga Check Name              | `check_huawei_dorado_backup_power` |
| Check Interval Recommendation         | Every 15 minutes |
| Can be called without parameters      | No (`--device-id`, `--password`, `--url`, and `--username` are required) |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-huawei-dorado.db` |


## Help

```text
usage: huawei-dorado-backup-power [-h] [-V] [--always-ok]
                                  [--cache-expire CACHE_EXPIRE] [-c CRIT]
                                  [--critical-voltage CRIT_VOLTAGE]
                                  [--device-id DEVICE_ID] [--ignore IGNORE]
                                  [--insecure] [--no-insecure] [--match MATCH]
                                  [--no-match-severity {ok,warn,crit,unknown}]
                                  [--no-perfdata] [--no-proxy]
                                  [--password PASSWORD]
                                  [--password-file PASSWORD_FILE]
                                  [--scope SCOPE] [--timeout TIMEOUT] -u URL
                                  --username USERNAME [-w WARN]
                                  [--warning-voltage WARN_VOLTAGE]

Checks the health status of all backup power modules (BBU) on a Huawei
OceanStor Dorado storage system via the REST API (/backup_power endpoint).
Alerts when any module reports a non-normal health state, when it runs out of
remaining service life, and optionally when its voltage leaves the range you
expect.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --cache-expire CACHE_EXPIRE
                        The amount of time after which the credential/data
                        cache expires, in minutes. Default: 15
  -c, --critical CRIT   CRIT threshold for the remaining life of a backup
                        power module, as a Nagios range in days. Default: 30:
  --critical-voltage CRIT_VOLTAGE
                        CRIT threshold for the voltage of a backup power
                        module, as a Nagios range in volts. Off by default,
                        because the healthy range depends on the module and on
                        how many cells it has; read the label or watch the
                        graph first. Example: `--critical-voltage=13.5:18.5`
  --device-id DEVICE_ID
                        Huawei OceanStor Dorado API device ID. Optional: the
                        appliance reports its own at login, so this is only
                        needed to override that answer.
  --ignore IGNORE       Skip backup power modules. Any item matching this
                        Python regex will be ignored. Can be specified
                        multiple times. Example: `(?i)linuxfabrik` for a case-
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
  --match MATCH         Filter by backup power modules. Filter by this Python
                        regular expression. Case-sensitive by default; use
                        `(?i)` for case-insensitive matching. Can be specified
                        multiple times. Examples: `(?i)example` to match
                        "example" regardless of case. `^(?!.*example).*$` to
                        match any string except "example" (negative
                        lookahead). The regex is anchored at the start of the
                        string (Python `re.match`) and is matched against
                        `UUID`, `LOCATION`, so prefix with `.*` to match
                        anywhere.
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
  --scope SCOPE         Huawei OceanStor Dorado API scope. Default: 0
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
  -u, --url URL         Huawei OceanStor Dorado API URL.
  --username USERNAME   Huawei OceanStor Dorado API username.
  -w, --warning WARN    WARN threshold for the remaining life of a backup
                        power module, as a Nagios range in days. Default: 180:
  --warning-voltage WARN_VOLTAGE
                        WARN threshold for the voltage of a backup power
                        module, as a Nagios range in volts. Off by default,
                        because the healthy range depends on the module and on
                        how many cells it has; read the label or watch the
                        graph first. Example: `--warning-voltage=15:17`

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/huawei-dorado-backup-power/
```


## Usage Examples

```bash
./huawei-dorado-backup-power --url=https://oceanstor:8088 --device-id=123456789 --username=monitoring --password=linuxfabrik
```

Output:

```text
There are warnings.

UUID       ! Location   ! Produced   ! ControllerID ! #Discharged ! Remain ! Volt ! Health ! Running  
-----------+------------+------------+--------------+-------------+--------+------+--------+----------
210:0.0A.0 ! CTE0.PSU 0 ! 2014-3-25  ! 0A           ! 7           ! 5Y 4M  ! 16.1 ! [OK]   ! [WARNING]
210:0.0A.0 ! CTE0.A.BBU ! 2020-10-18 ! 0A           ! 1           ! 0      ! 15.9 ! [OK]   ! [OK]     
210:0.0B.0 ! CTE0.B.BBU ! 2020-10-18 ! 0B           ! 1           ! 0      ! 15.8 ! [OK]   ! [OK]     
210:0.0C.0 ! CTE0.C.BBU ! 2020-10-18 ! 0C           ! 1           ! 0      ! 15.8 ! [OK]   ! [OK]     
210:0.0D.0 ! CTE0.D.BBU ! 2020-10-18 ! 0D           ! 1           ! 0      ! 16.0 ! [OK]   ! [OK]
```


## States

* OK if all BBU modules report normal health and running status.
* WARN if any backup power module reports a degraded health status, or one this check does not know.
* WARN if any backup power module's running status is not "Normal", "Running", "Online", "Charging" or "Charging completed", unless it reports an outright failure.
* CRIT if any backup power module reports health status "Faulty", "No Input", "Invalid" or "Offline".
* CRIT if any backup power module's running status reports a failure ("Not running", "Sleep in High Temperature", "Offline", "Invalid", "Migration fault", "Error/Faulty", "To be synchronized", "Power-on failed", "Abnormal" or "Rollback failure").
* WARN or CRIT if a backup power module's voltage reaches `--warning-voltage` or `--critical-voltage`. Both are off by default, because the healthy range depends on the module and on how many cells it has. A module that has lost a cell, or one being trickle-charged back up, leaves its normal band long before its health status changes.
* WARN if a backup power module's remaining life falls below `--warning` (default: less than 180 days).
* CRIT if a backup power module's remaining life falls below `--critical` (default: less than 30 days).
* UNKNOWN if the appliance lists no backup power modules at all, which points at the query rather than at the hardware.
* `--match` limits the check to the backup power modules whose identifier, location or name matches the regex; `--no-match-severity` sets what to report when nothing matches (default: OK).
* UNKNOWN on invalid API responses or responses with error codes.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| \<UUID\>_health_status | Number | 0: unknown, 1: normal, 2: faulty, 3: about to fail, 12: low battery. |
| \<UUID\>_remaining_life | Seconds | Remaining service life. Only reported for a module that states one. |
| \<UUID\>_running_status | Number | 0: unknown, 1: normal, 2: running, 27: online, 28: offline, 48: charging, 49: charging completed, 50: discharging. |
| \<UUID\>_voltage | Number | Current voltage, in volts. The appliance counts it in tenths of a volt. |

The discharge count stays out of the performance data. It only ever counts up, and a cumulative counter aggregates wrong in every Grafana panel that touches it ([#320](https://github.com/Linuxfabrik/monitoring-plugins/issues/320)). It is in the table instead, where it reads as the wear of the module.

See the [Huawei OceanStor Dorado API documentation](https://support.huawei.com/enterprise/en/doc/EDOC1100144155/387d790e/overview) for details.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
