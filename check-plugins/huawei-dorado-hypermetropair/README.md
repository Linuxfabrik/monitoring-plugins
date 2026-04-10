# Check huawei-dorado-hypermetropair


## Overview

Checks the health, running status, and synchronization state of all HyperMetro pairs on a Huawei OceanStor Dorado storage system via the REST API (`/hypermetropair` endpoint). Alerts when any pair reports a non-normal state or synchronization issue. Reports link status, last sync time, sync duration, sync progress, local/remote data consistency and host access state per pair.

**Important Notes:**

* Tested on Huawei OceanStor Dorado 8000 V6 6.1.0
* Create a read-only API user that can perform queries only
* The default session timeout period on the storage system is 20 minutes; `--cache-expire` defaults to 15 minutes to stay within that window

**Data Collection:**

* Queries the Huawei OceanStor Dorado REST API at `https://<ip>:<port>/deviceManager/rest/<deviceId>/hypermetropair`
* Authenticates via session tokens (iBaseToken + cookie), cached in a SQLite database to avoid repeated logins
* On transient authorization errors, automatically retries up to 9 times with 1-second intervals


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/huawei-dorado-hypermetropair> |
| Nagios/Icinga Check Name              | `check_huawei_dorado_hypermetropair` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | No (`--device-id`, `--password`, `--url` and `--username` are required) |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-cache.db` |


## Help

```text
usage: huawei-dorado-hypermetropair [-h] [-V] [--always-ok]
                                    [--cache-expire CACHE_EXPIRE]
                                    --device-id DEVICE_ID [--insecure]
                                    [--no-proxy] --password PASSWORD
                                    [--scope SCOPE] [--test TEST]
                                    [--timeout TIMEOUT] -u URL
                                    --username USERNAME

Checks the health and running status of all HyperMetro pairs on a Huawei
OceanStor Dorado storage system via the REST API (/hypermetropair endpoint).
Alerts when any pair reports a non-normal state or synchronization issue.

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
./huawei-dorado-hypermetropair --url https://oceanstor:8088 --device-id 123456789 --username monitoring --password mypass
```

Output:

```text
Everything is ok.

UUID                                   ! Link ! Last Sync                       ! Duration ! Progr (%) ! LocalJob  ! DataState ! Access ! RemoteJob ! DataState ! Access ! Health ! Running 
---------------------------------------+------+---------------------------------+----------+-----------+-----------+-----------+--------+-----------+-----------+--------+--------+---------
15361:2100f4b78d046ec60000000000000000 ! [OK] ! 2021-08-18 10:39:47 (3M 6D ago) ! 2m 1s    ! 100       ! LUN01-BLH ! [OK]      ! R/W    ! LUN01-COL ! [OK]      ! R/W    ! [OK]   ! [OK]    
15361:2100f4b78d046ec60000000000000001 ! [OK] ! 2021-08-18 10:39:50 (3M 6D ago) ! 2m 3s    ! 100       ! LUN02-BLH ! [OK]      ! R/W    ! LUN02-COL ! [OK]      ! R/W    ! [OK]   ! [OK]    
15361:2100f4b78d046ec60000000000000002 ! [OK] ! 2021-08-18 10:38:29 (3M 6D ago) ! 42s      ! 100       ! LUN03-BLH ! [OK]      ! R/W    ! LUN03-COL ! [OK]      ! R/W    ! [OK]   ! [OK]    

Fetched API 2 times
```


## States

* OK if all HyperMetro pairs report normal health, running status, link status and data consistency.
* WARN if any pair's health status is not "Normal".
* WARN if any pair's running status is not "Normal" or "Synchronizing".
* WARN if any pair's link status is not "connected".
* WARN if any pair's local data state is not "consistent".
* WARN if any pair's remote data state is not "consistent".
* UNKNOWN on invalid API responses or responses with error codes.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| \<UUID\>\_HEALTHSTATUS | Number | 0: unknown, 1: normal, 2: faulty. |
| \<UUID\>\_LINKSTATUS | Number | 1: connected, 2: disconnected. |
| \<UUID\>\_LOCALDATASTATE | Number | 1: consistent, 2: inconsistent. |
| \<UUID\>\_LOCALHOSTACCESSSTATE | Number | 1: access forbidden, 2: read-only, 3: read/write. |
| \<UUID\>\_REMOTEDATASTATE | Number | 1: consistent, 2: inconsistent. |
| \<UUID\>\_REMOTEHOSTACCESSSTATE | Number | 1: access forbidden, 2: read-only, 3: read/write, 5: unknown. |
| \<UUID\>\_RUNNINGSTATUS | Number | 1: normal, 23: synchronizing, 35: invalid, 41: paused, 93: forcibly started, 100: to be synchronized. |
| \<UUID\>\_SYNCPROGRESS | Percentage | Synchronization progress. |

Have a look at the [API documentation](https://support.huawei.com/enterprise/en/doc/EDOC1100144155/387d790e/overview) for details.


## Troubleshooting

`Got no valuable response from https://...`
Check the `--url`, `--device-id`, `--username` and `--password` parameters. Verify that the API user has query permissions and that the storage system REST API is reachable.

`This operation fails to be performed because of the unauthorized REST.`
This is a known transient issue with the Huawei REST API. The check retries automatically up to 9 times. If the error persists, verify the API credentials and session timeout settings.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
