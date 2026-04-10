# Check huawei-dorado-disk

## Overview

Checks the health and running status of all disks on a Huawei OceanStor Dorado storage system via the REST API (`/disk` endpoint). Alerts when any disk reports a non-normal health or running state. Reports abrasion rate, capacity usage, runtime, temperature and remaining service life per disk.

**Alerting Logic:**

* WARN if any disk's health status is not "Normal"
* WARN if any disk's running status is not "Normal" or "Online"

**Data Collection:**

* Queries the Huawei OceanStor Dorado REST API at `https://<ip>:<port>/deviceManager/rest/<deviceId>/disk`
* Authenticates via session tokens (iBaseToken + cookie), cached in a SQLite database to avoid repeated logins
* On transient authorization errors, automatically retries up to 9 times with 1-second intervals

**Compatibility:**

* Tested on Huawei OceanStor Dorado 8000 V6 6.1.0

**Important Notes:**

* Create a read-only API user that can perform queries only
* The default session timeout period on the storage system is 20 minutes; `--cache-expire` defaults to 15 minutes to stay within that window


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/huawei-dorado-disk> |
| Nagios/Icinga Check Name              | `check_huawei_dorado_disk` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | No (`--device-id`, `--password`, `--url` and `--username` are required) |
| Compiled for Windows                  | No |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-cache.db` |


## Help

```text
usage: huawei-dorado-disk [-h] [-V] [--always-ok]
                          [--cache-expire CACHE_EXPIRE] --device-id DEVICE_ID
                          [--insecure] [--no-proxy] --password PASSWORD
                          [--scope SCOPE] [--test TEST] [--timeout TIMEOUT]
                          -u URL --username USERNAME

Checks the health status of all disks on a Huawei OceanStor Dorado storage
system via the REST API (/disk endpoint). Alerts when any disk reports a non-
normal health state.

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
  --no-proxy            Do not use a proxy.
  --password PASSWORD   Huawei OceanStor Dorado API password.
  --scope SCOPE         Huawei OceanStor Dorado API scope.
  --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                        stderr-file,expected-retc".
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
  -u, --url URL         Huawei OceanStor Dorado API URL.
  --username USERNAME   Huawei OceanStor Dorado API username.
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

Fetched API 2 times
```


## States

* OK if all disks report normal health and running status.
* WARN if any disk's health status is not "Normal".
* WARN if any disk's running status is not "Normal" or "Online".
* UNKNOWN on invalid API responses or responses with error codes.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| \<UUID\>\_ABRASIONRATE | Percentage | Wear rate (percentage of used service life to total service life). |
| \<UUID\>\_CAPACITYUSAGE | Percentage | Capacity usage. |
| \<UUID\>\_HEALTHMARK | Number | Health score of the disk. |
| \<UUID\>\_HEALTHSTATUS | Number | 0: unknown, 1: normal, 2: faulty, 3: about to fail, 17: single link. |
| \<UUID\>\_PROGRESS | Percentage | Progress of reconstruction, copyback, pre-copy, or destruction. |
| \<UUID\>\_REMAINLIFE | Seconds | Remaining service life. |
| \<UUID\>\_RUNNINGSTATUS | Number | 0: unknown, 1: normal, 14: pre-copy, 16: reconstruction, 27: online, 28: offline, 114: erasing, 115: verifying. |
| \<UUID\>\_RUNTIME | Seconds | Operating time. |
| \<UUID\>\_TEMPERATURE | Number | Temperature. |

Have a look at the [API documentation](https://support.huawei.com/enterprise/en/doc/EDOC1100144155/387d790e/overview) for details.


## Troubleshooting

`Got no valuable response from https://...`
Check the `--url`, `--device-id`, `--username` and `--password` parameters. Verify that the API user has query permissions and that the storage system REST API is reachable.

`This operation fails to be performed because of the unauthorized REST.`
This is a known transient issue with the Huawei REST API. The check retries automatically up to 9 times. If the error persists, verify the API credentials and session timeout settings.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
