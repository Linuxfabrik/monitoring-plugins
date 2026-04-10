# Check huawei-dorado-controller

## Overview

Checks the health and running status of all controllers on a Huawei OceanStor Dorado storage system via the REST API (`/controller` endpoint). Alerts when any controller reports a non-normal health or running state.

**Important Notes:**

* Tested on Huawei OceanStor Dorado 8000 V6 6.1.0
* Create a read-only API user that can perform queries only
* The default session timeout period on the storage system is 20 minutes; `--cache-expire` defaults to 15 minutes to stay within that window


**Data Collection:**

* Queries the Huawei OceanStor Dorado REST API at `https://<ip>:<port>/deviceManager/rest/<deviceId>/controller`
* Authenticates via session tokens (iBaseToken + cookie), cached in a SQLite database to avoid repeated logins
* On transient authorization errors, automatically retries up to 9 times with 1-second intervals

**Compatibility:**

* Cross-platform


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/huawei-dorado-controller> |
| Nagios/Icinga Check Name              | `check_huawei_dorado_controller` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | No (`--device-id`, `--password`, `--url` and `--username` are required) |
| Compiled for Windows                  | No |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-cache.db` |


## Help

```text
usage: huawei-dorado-controller [-h] [-V] [--always-ok]
                                [--cache-expire CACHE_EXPIRE]
                                --device-id DEVICE_ID [--insecure]
                                [--no-proxy] --password PASSWORD
                                [--scope SCOPE] [--test TEST]
                                [--timeout TIMEOUT] -u URL --username USERNAME

Checks the health and running status of all controllers on a Huawei OceanStor
Dorado storage system via the REST API (/controller endpoint). Alerts when any
controller reports a non-normal health or running state.

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
./huawei-dorado-controller --url https://oceanstor:8088 --device-id 123456789 --username monitoring --password mypass
```

Output:

```text
There are critical errors.

UUID   ! Location ! Model                               ! Role      ! Master ! CPU (%) ! Mem (%) ! Volt ! Health     ! Running 
-------+----------+-------------------------------------+-----------+--------+---------+---------+------+------------+---------
207:0A ! CTE0.A   ! Unknown                             ! Primary   ! -      ! 3       ! 75      ! 120  ! [CRITICAL] ! [OK]    
207:0A ! CTE0.A   ! V6R1C00 4U4C high-end control board ! Secondary ! -      ! 33      ! 87      ! 120  ! [OK]       ! [OK]    
207:0B ! CTE0.B   ! V6R1C00 4U4C high-end control board ! Primary   ! x      ! 17      ! 87      ! 120  ! [OK]       ! [OK]    
207:0C ! CTE0.C   ! V6R1C00 4U4C high-end control board ! Secondary ! -      ! 33      ! 86      ! 120  ! [OK]       ! [OK]    
207:0D ! CTE0.D   ! V6R1C00 4U4C high-end control board ! Secondary ! -      ! 32      ! 92      ! 120  ! [OK]       ! [OK]

Fetched API 2 times
```


## States

* OK if all controllers report normal health and running status.
* WARN if any controller's running status is not "Normal", "Running" or "Online".
* CRIT if any controller's health status is not "Normal".
* UNKNOWN on invalid API responses or responses with error codes.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| \<UUID\>\_CPUUSAGE | Percentage | CPU utilization. |
| \<UUID\>\_DIRTYDATARATE | Percentage | Dirty page usage. |
| \<UUID\>\_HEALTHSTATUS | Number | 0: unknown, 1: normal, 2: faulty. |
| \<UUID\>\_LIGHT_STATUS | Number | 1: off, 2: on. |
| \<UUID\>\_MEMORYUSAGE | Percentage | Memory utilization. |
| \<UUID\>\_RUNNINGSTATUS | Number | 0: unknown, 1: normal, 2: running, 5: sleep in high temperature, 27: online, 28: offline, 105: abnormal. |
| \<UUID\>\_TEMPERATURE | Number | Temperature (only reported if > 0). |
| \<UUID\>\_VOLTAGE | Number | Voltage. |

Have a look at the [API documentation](https://support.huawei.com/enterprise/en/doc/EDOC1100144155/387d790e/overview) for details.


## Troubleshooting

`Got no valuable response from https://...`
Check the `--url`, `--device-id`, `--username` and `--password` parameters. Verify that the API user has query permissions and that the storage system REST API is reachable.

`This operation fails to be performed because of the unauthorized REST.`
This is a known transient issue with the Huawei REST API. The check retries automatically up to 9 times. If the error persists, verify the API credentials and session timeout settings.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
