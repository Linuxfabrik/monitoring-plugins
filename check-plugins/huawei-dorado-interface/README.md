# Check huawei-dorado-interface

## Overview

Checks the health and running status of all interface modules (I/O modules) on a Huawei OceanStor Dorado storage system via the REST API (`/intf_module` endpoint). Alerts when any module reports a non-normal health or running state. Reports model, run mode (FC, Ethernet, RoCE, etc.) and LED status per module.

**Data Collection:**

* Queries the Huawei OceanStor Dorado REST API at `https://<ip>:<port>/deviceManager/rest/<deviceId>/intf_module`
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
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/huawei-dorado-interface> |
| Nagios/Icinga Check Name              | `check_huawei_dorado_interface` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | No (`--device-id`, `--password`, `--url` and `--username` are required) |
| Compiled for Windows                  | No |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-cache.db` |


## Help

```text
usage: huawei-dorado-interface [-h] [-V] [--always-ok]
                               [--cache-expire CACHE_EXPIRE]
                               --device-id DEVICE_ID [--insecure] [--no-proxy]
                               --password PASSWORD [--scope SCOPE]
                               [--test TEST] [--timeout TIMEOUT] -u URL
                               --username USERNAME

Checks the health and running status of all interface modules on a Huawei
OceanStor Dorado storage system via the REST API (/intf_module endpoint).
Alerts when any module reports a non-normal state.

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
./huawei-dorado-interface --url https://oceanstor:8088 --device-id 123456789 --username monitoring --password mypass
```

Output:

```text
Everything is ok.

UUID       ! Location     ! Model                                 ! RunMode  ! LED ! Health ! Running 
-----------+--------------+---------------------------------------+----------+-----+--------+---------
209:0A.1   ! CTE0.A.IOM1  ! Unknown                               ! FC       ! Off ! [OK]   ! [OK]    
209:0.128  ! CTE0.IOM.H0  ! 2 ports FE 100 Gbit/s ETH I/O module  ! Ethernet ! Off ! [OK]   ! [OK]    
209:0.129  ! CTE0.IOM.H1  ! 2 ports FE 100 Gbit/s ETH I/O module  ! Ethernet ! Off ! [OK]   ! [OK]    
209:0.134  ! CTE0.IOM.H6  ! 2 ports BE 100 Gbit/s RDMA I/O module ! RoCE     ! Off ! [OK]   ! [OK]    
209:0.135  ! CTE0.IOM.H7  ! 2 ports BE 100 Gbit/s RDMA I/O module ! RoCE     ! Off ! [OK]   ! [OK]    
209:0.64   ! CTE0.SMM0    ! System Management Module              ! Unknown  ! Off ! [OK]   ! [OK]    
209:0.65   ! CTE0.SMM1    ! System Management Module              ! Unknown  ! Off ! [OK]   ! [OK]    
209:0A.130 ! CTE0.IOM.H2  ! AI Accelerator Card                   ! Unknown  ! Off ! [OK]   ! [OK]    

Fetched API 2 times
```


## States

* OK if all interface modules report normal health and running status.
* WARN if any interface module's health status is not "Normal".
* WARN if any interface module's running status is not "Normal", "Running", "Powering on" or "Online".
* UNKNOWN on invalid API responses or responses with error codes.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| \<UUID\>\_HEALTHSTATUS | Number | 0: unknown, 1: normal, 2: faulty. |
| \<UUID\>\_RUNNINGSTATUS | Number | 0: unknown, 1: normal, 2: running, 12: powering on, 13: powered off, 27: online, 28: offline, 103: power-on failed. |

Have a look at the [API documentation](https://support.huawei.com/enterprise/en/doc/EDOC1100144155/387d790e/overview) for details.


## Troubleshooting

`Got no valuable response from https://...`
Check the `--url`, `--device-id`, `--username` and `--password` parameters. Verify that the API user has query permissions and that the storage system REST API is reachable.

`This operation fails to be performed because of the unauthorized REST.`
This is a known transient issue with the Huawei REST API. The check retries automatically up to 9 times. If the error persists, verify the API credentials and session timeout settings.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
