# Check huawei-dorado-disk


## Overview

Checks the health and running status of all disks on a Huawei OceanStor Dorado storage system via the REST API (`/disk` endpoint). Alerts when any disk reports a non-normal health or running state. Reports abrasion rate, capacity usage, runtime, temperature and remaining service life per disk.

**Important Notes:**

* Tested on Huawei OceanStor Dorado 8000 V6 6.1.0
* A spinning disk has no wear-out life to report and answers with 0. Such a disk is left out of the remaining-life check and out of the performance data, instead of being read as a drive at its end
* Create a read-only API user that can perform queries only
* The default session timeout period on the storage system is 20 minutes; `--cache-expire` defaults to 15 minutes to stay within that window

**Data Collection:**

* Queries the Huawei OceanStor Dorado REST API at `https://<ip>:<port>/deviceManager/rest/<deviceId>/disk`
* Authenticates via session tokens (iBaseToken + cookie), cached in a SQLite database to avoid repeated logins
* If the appliance rejects a request, the check logs in again and retries, up to three attempts one second apart


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/huawei-dorado-disk> |
| Nagios/Icinga Check Name              | `check_huawei_dorado_disk` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | No (`--device-id`, `--password`, `--url` and `--username` are required) |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-huawei-dorado.db` |


## Help

```text
usage: huawei-dorado-disk [-h] [-V] [--always-ok]
                          [--cache-expire CACHE_EXPIRE] [-c CRIT]
                          [--critical-temperature CRIT_TEMPERATURE]
                          --device-id DEVICE_ID [--insecure] [--no-insecure]
                          [--match MATCH]
                          [--no-match-severity {ok,warn,crit,unknown}]
                          [--no-perfdata] [--no-proxy] --password PASSWORD
                          [--scope SCOPE] [--timeout TIMEOUT] -u URL
                          --username USERNAME [-w WARN]
                          [--warning-temperature WARN_TEMPERATURE]

Checks the health status of all disks on a Huawei OceanStor Dorado storage
system via the REST API (/disk endpoint). Alerts when any disk reports a
non-normal health state.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --cache-expire CACHE_EXPIRE
                        The amount of time after which the credential/data
                        cache expires, in minutes. Default: 15
  -c, --critical CRIT   CRIT threshold for the remaining life of a disk, as a
                        Nagios range in days. Default: 30:
  --critical-temperature CRIT_TEMPERATURE
                        CRIT threshold in degrees Celsius. Off by default,
                        because a healthy operating temperature depends on the
                        drive model and on where the array stands. Example:
                        `--critical-temperature=50`
  --device-id DEVICE_ID
                        Huawei OceanStor Dorado API device ID.
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --no-insecure         Verify the TLS certificate against the system trust
                        store, overriding the insecure default of this check.
                        Use it once the endpoint presents a publicly trusted
                        certificate, or once its CA has been added to the
                        system trust store.
  --match MATCH         Filter by disks. Filter by this Python regular
                        expression. Case-sensitive by default; use `(?i)` for
                        case-insensitive matching. Can be specified multiple
                        times. Examples: `(?i)example` to match "example"
                        regardless of case. `^(?!.*example).*$` to match any
                        string except "example" (negative lookahead). The
                        regex is anchored at the start of the string (Python
                        `re.match`) and is matched against `UUID`, `LOCATION`,
                        so prefix with `.*` to match anywhere. Default:
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
  -w, --warning WARN    WARN threshold for the remaining life of a disk, as a
                        Nagios range in days. Default: 180:
  --warning-temperature WARN_TEMPERATURE
                        WARN threshold in degrees Celsius. Off by default,
                        because a healthy operating temperature depends on the
                        drive model and on where the array stands. Example:
                        `--warning-temperature=45`

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/huawei-dorado-disk/
```


## Usage Examples

```bash
./huawei-dorado-disk --url https://oceanstor:8088 --device-id 123456789 --username monitoring --password mypass
```

Output:

```text
Everything is ok.

UUID         ! Location ! Manufacturer ! Model            ! SerialNumber         ! Abrasion% ! Progress% ! Runtime ! Temp ! Health ! Running 
-------------+----------+--------------+------------------+----------------------+-----------+-----------+---------+------+--------+---------
10:134234112 ! DAE000.0 ! HUAWEI       ! HSSD-D7294DL7T6E ! 12345678             ! 67        ! 0         ! 4M 2W   ! 36   ! [OK]   ! [OK]    
10:134234113 ! DAE000.1 ! HUAWEI       ! HSSD-D7294DL7T6E ! 12345679             ! 70        ! 0         ! 4M 2W   ! 37   ! [OK]   ! [OK]    
10:0         ! CTE0.0   ! Seagate      ! ST2000NM0023     ! Z1X2F480000094381WYN ! 0         ! 0         ! 1Y 4M   ! 37   ! [OK]   ! [OK]    
```


## States

* OK if all disks report normal health and running status.
* WARN if any disk reports a degraded health status, or one this check does not know.
* WARN if any disk's running status is not "Normal" or "Online", unless it reports an outright failure.
* CRIT if any disk reports health status "Faulty", "Invalid" or "Offline".
* CRIT if any disk's running status reports a failure ("Offline", "Invalid", "Migration fault", "Error/Faulty", "Power-on failed", "Abnormal" or "Rollback failure").
* WARN if a disk's remaining life falls below `--warning` (default: less than 180 days).
* CRIT if a disk's remaining life falls below `--critical` (default: less than 30 days).
* WARN or CRIT if a disk's temperature reaches `--warning-temperature` or `--critical-temperature`. Both are off by default.
* UNKNOWN if the appliance lists no disks at all, which points at the query rather than at the hardware.
* `--match` limits the check to the disks whose identifier, location or name matches the regex; `--no-match-severity` sets what to report when nothing matches (default: OK).
* UNKNOWN on invalid API responses or responses with error codes.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| \<UUID\>\_abrasion_rate | Percentage | Wear rate (percentage of used service life to total service life). |
| \<UUID\>\_capacity_usage | Percentage | Capacity usage. |
| \<UUID\>\_health_mark | Number | Health score of the disk. |
| \<UUID\>\_health_status | Number | 0: unknown, 1: normal, 2: faulty, 3: about to fail, 17: single link. |
| \<UUID\>\_progress | Percentage | Progress of reconstruction, copyback, pre-copy, or destruction. |
| \<UUID\>\_remaining_life | Seconds | Remaining service life. |
| \<UUID\>\_running_status | Number | 0: unknown, 1: normal, 14: pre-copy, 16: reconstruction, 27: online, 28: offline, 114: erasing, 115: verifying. |
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
