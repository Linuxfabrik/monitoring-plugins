# Check huawei-dorado-backup-power

## Overview

Batch querying all backup power modules (Backup Battery Unit (BBU)) of a Huawei OceanStor Dorado storage system via the REST Interface, using the `https://${ip}:${port}/deviceManager/rest/${deviceId}/backup_power` endpoint. Cookies and iBaseTokens are stored and re-used (the session timeout period is usually 20 minutes).

Hints:

* Tested on Huawei OceanStor Dorado 8000 V6 6.1.0.
* Create a read-only API user that can perform query only.
* Sometimes the API returns `This operation fails to be performed because of the unauthorized REST. Before performing this operation, ensure that REST is authorized.`, although everything is fine. In this case, the check simply tries to retrieve the data again, a maximum of 9 times within 9 seconds.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/huawei-dorado-backup-power> |
| Check Interval Recommendation         | Every 15 minutes |
| Can be called without parameters      | No |
| Compiled for Windows                  | No |
| Uses SQLite DBs                       | Yes |


## Help

```text
usage: huawei-dorado-backup-power [-h] [-V] [--always-ok]
                                  [--cache-expire CACHE_EXPIRE]
                                  --device-id DEVICE_ID [--insecure]
                                  [--no-proxy] --password PASSWORD
                                  [--scope SCOPE] [--test TEST]
                                  [--timeout TIMEOUT] -u URL
                                  --username USERNAME

Batch querying all backup power modules of a Huawei OceanStor Dorado storage
system via the REST Interface, using the ``/backup_power`` endpoint.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --cache-expire CACHE_EXPIRE
                        The amount of time after which the credential cache
                        expires, in minutes. Default: 15
  --device-id DEVICE_ID
                        Huawei OceanStor Dorado API Device ID.
  --insecure            This option explicitly allows to perform "insecure"
                        SSL connections. Default: True
  --no-proxy            Do not use a proxy. Default: False
  --password PASSWORD   Huawei OceanStor Dorado API Password.
  --scope SCOPE         Huawei OceanStor Dorado API Scope.
  --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                        stderr-file,expected-retc".
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
  -u, --url URL         Huawei OceanStor Dorado API URL.
  --username USERNAME   Huawei OceanStor Dorado API Username.
```


## Usage Examples

```bash
./huawei-dorado-backup-power --url https://oceanstor:8088 --device-id 123456789 --username monitoring --password mypass
```

Output:

```text
There are warnings.

UUID       ! Location   ! Produced   ! ControllerID ! #Charged ! Remain ! Volt ! Health ! Running   
-----------+------------+------------+--------------+----------+--------+------+--------+-----------
210:0.0A.0 ! CTE0.PSU 0 ! 2014-3-25  ! 0A           ! 7        ! 5Y 4M  ! 16.1 ! [OK]   ! [WARNING] 
210:0.0A.0 ! CTE0.A.BBU ! 2020-10-18 ! 0A           ! 1        ! -1     ! 15.9 ! [OK]   ! [OK]      
210:0.0B.0 ! CTE0.B.BBU ! 2020-10-18 ! 0B           ! 1        ! -1     ! 15.8 ! [OK]   ! [OK]      
210:0.0C.0 ! CTE0.C.BBU ! 2020-10-18 ! 0C           ! 1        ! -1     ! 15.8 ! [OK]   ! [OK]      
210:0.0D.0 ! CTE0.D.BBU ! 2020-10-18 ! 0D           ! 1        ! -1     ! 16.0 ! [OK]   ! [OK] 

Fetched API 2 times
```


## States

* UNKNOWN on invalid responses or responses with error codes.
* WARN if BBU health status is not equal to "Normal".
* WARN if BBU running status is not equal to "Normal", "Running", "Online", "Charging" or "Charging completed".


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| \<UUID\>\_CHARGETIMES | Number | Discharge count. |
| \<UUID\>\_HEALTHSTATUS | Number | 0: unknown, 1: normal, 2: faulty, 3: about to fail, 12: low battery |
| \<UUID\>\_REMAINLIFEDAYS | Seconds | Remaining service life. |
| \<UUID\>\_RUNNINGSTATUS | Number | 0: unknown, 1: normal, 2: running, 27: online, 28: offline, 48: charging, 49: charging completed, 50: discharging |
| \<UUID\>\_VOLTAGE | Number | Current voltage. |

Have a look at the [API documentation](https://support.huawei.com/enterprise/en/doc/EDOC1100144155/387d790e/overview) for details.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
