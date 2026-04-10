# Check huawei-dorado-power

## Overview

Checks the health and running status of all power supply units (PSUs) on a Huawei OceanStor Dorado storage system via the REST API (`/power` endpoint). Alerts when any PSU reports a non-normal health or running state. Reports manufacturer, model, serial number, production date, input/output voltage and temperature per PSU.

**Important Notes:**

* Tested on Huawei OceanStor Dorado 8000 V6 6.1.0
* Create a read-only API user that can perform queries only
* The default session timeout period on the storage system is 20 minutes; `--cache-expire` defaults to 15 minutes to stay within that window


**Data Collection:**

* Queries the Huawei OceanStor Dorado REST API at `https://<ip>:<port>/deviceManager/rest/<deviceId>/power`
* Authenticates via session tokens (iBaseToken + cookie), cached in a SQLite database to avoid repeated logins
* On transient authorization errors, automatically retries up to 9 times with 1-second intervals

**Compatibility:**

* Cross-platform


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/huawei-dorado-power> |
| Nagios/Icinga Check Name              | `check_huawei_dorado_power` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | No (`--device-id`, `--password`, `--url` and `--username` are required) |
| Compiled for Windows                  | No |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-cache.db` |


## Help

```text
usage: huawei-dorado-power [-h] [-V] [--always-ok]
                           [--cache-expire CACHE_EXPIRE] --device-id DEVICE_ID
                           [--insecure] [--no-proxy] --password PASSWORD
                           [--scope SCOPE] [--test TEST] [--timeout TIMEOUT]
                           -u URL --username USERNAME

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

Fetched API 2 times
```


## States

* OK if all PSUs report normal health and running status.
* WARN if any PSU's health status is not "Normal".
* WARN if any PSU's running status is not "Normal", "Running" or "Online".
* UNKNOWN on invalid API responses or responses with error codes.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| \<UUID\>\_HEALTHSTATUS | Number | 0: unknown, 1: normal, 2: faulty, 9: inconsistent, 11: no input. |
| \<UUID\>\_INPUTVOLTAGE | Number | Input voltage (millivolts). |
| \<UUID\>\_OUTPUTVOLTAGE | Number | Output voltage (millivolts). |
| \<UUID\>\_RUNNINGSTATUS | Number | 0: unknown, 1: normal, 2: running, 27: online, 28: offline. |
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
