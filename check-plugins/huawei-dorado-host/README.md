# Check huawei-dorado-host

## Overview

Checks the health and running status of all hosts attached to a Huawei OceanStor Dorado storage system via the REST API (`/host` endpoint). Alerts when any host reports a non-normal health or running state. Reports operating system type and allocated capacity per host.

**Important Notes:**

* Tested on Huawei OceanStor Dorado 8000 V6 6.1.0
* Create a read-only API user that can perform queries only
* The default session timeout period on the storage system is 20 minutes; `--cache-expire` defaults to 15 minutes to stay within that window
* The host list reflects host objects configured on the storage system, not necessarily their actual online/offline status on the network


**Data Collection:**

* Queries the Huawei OceanStor Dorado REST API at `https://<ip>:<port>/deviceManager/rest/<deviceId>/host`
* Authenticates via session tokens (iBaseToken + cookie), cached in a SQLite database to avoid repeated logins
* On transient authorization errors, automatically retries up to 9 times with 1-second intervals

**Compatibility:**

* Cross-platform


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/huawei-dorado-host> |
| Nagios/Icinga Check Name              | `check_huawei_dorado_host` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | No (`--device-id`, `--password`, `--url` and `--username` are required) |
| Compiled for Windows                  | No |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-cache.db` |


## Help

```text
usage: huawei-dorado-host [-h] [-V] [--always-ok]
                          [--cache-expire CACHE_EXPIRE] --device-id DEVICE_ID
                          [--insecure] [--no-proxy] --password PASSWORD
                          [--scope SCOPE] [--test TEST] [--timeout TIMEOUT]
                          -u URL --username USERNAME

Checks the health and running status of all hosts attached to a Huawei
OceanStor Dorado storage system via the REST API (/host endpoint). Alerts when
any host reports a non-normal state.

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
./huawei-dorado-host --url https://oceanstor:8088 --device-id 123456789 --username monitoring --password mypass
```

Output:

```text
There are warnings.

UUID  ! Location ! Name      ! OS         ! Health    ! Running 
------+----------+-----------+------------+-----------+---------
21:1  !          ! host1     ! Solaris    ! [OK]      ! [OK]    
21:2  !          ! host2     ! Linux      ! [WARNING] ! [OK]    
21:0  !          ! site01-01 ! VMware ESX ! [OK]      ! [OK]    
21:1  !          ! site01-02 ! VMware ESX ! [OK]      ! [OK]    
21:2  !          ! site01-03 ! VMware ESX ! [OK]      ! [OK]    
21:3  !          ! site01-04 ! VMware ESX ! [OK]      ! [OK]    
21:4  !          ! site01-05 ! VMware ESX ! [OK]      ! [OK]    
21:5  !          ! site01-06 ! VMware ESX ! [OK]      ! [OK]    
21:6  !          ! site02-01 ! VMware ESX ! [OK]      ! [OK]    
21:7  !          ! site02-02 ! VMware ESX ! [OK]      ! [OK]    
21:8  !          ! site02-03 ! VMware ESX ! [OK]      ! [OK]    
21:9  !          ! site02-04 ! VMware ESX ! [OK]      ! [OK]    
21:10 !          ! site02-05 ! VMware ESX ! [OK]      ! [OK]    
21:11 !          ! site02-06 ! VMware ESX ! [OK]      ! [OK] 

Fetched API 2 times
```


## States

* OK if all hosts report normal health and running status.
* WARN if any host's health status is not "Normal".
* WARN if any host's running status is not "Normal".
* UNKNOWN on invalid API responses or responses with error codes.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| \<UUID\>\_allocatedCapacity | Number | Used (allocated) capacity. |
| \<UUID\>\_HEALTHSTATUS | Number | 1: normal, 17: no redundant link, 18: offline. |
| \<UUID\>\_RUNNINGSTATUS | Number | 1: normal. |

Have a look at the [API documentation](https://support.huawei.com/enterprise/en/doc/EDOC1100144155/387d790e/overview) for details.


## Troubleshooting

`Got no valuable response from https://...`
Check the `--url`, `--device-id`, `--username` and `--password` parameters. Verify that the API user has query permissions and that the storage system REST API is reachable.

`This operation fails to be performed because of the unauthorized REST.`
This is a known transient issue with the Huawei REST API. The check retries automatically up to 9 times. If the error persists, verify the API credentials and session timeout settings.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
