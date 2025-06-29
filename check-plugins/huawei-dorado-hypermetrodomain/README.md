# Check huawei-dorado-hypermetrodomain

## Overview

Batch querying HyperMetro domain information of a Huawei OceanStor Dorado storage system via the REST Interface, using the `https://${ip}:${port}/deviceManager/rest/${deviceId}/hypermetrodomain` endpoint. Cookies and iBaseTokens are stored and re-used (the session timeout period is usually 20 minutes).

Hints:

* Tested on Huawei OceanStor Dorado 8000 V6 6.1.0.
* Create a read-only API user that can perform query only.
* Sometimes the API returns `This operation fails to be performed because of the unauthorized REST. Before performing this operation, ensure that REST is authorized.`, although everything is fine. In this case, the check simply tries to retrieve the data again, a maximum of 9 times within 9 seconds.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/huawei-dorado-hypermetrodomain> |
| Check Interval Recommendation         | Every 15 minutes |
| Can be called without parameters      | No |
| Compiled for Windows                  | No |
| Uses SQLite DBs                       | Yes |


## Help

```text
usage: huawei-dorado-hypermetrodomain [-h] [-V] [--always-ok]
                                      [--cache-expire CACHE_EXPIRE]
                                      --device-id DEVICE_ID [--insecure]
                                      [--no-proxy] --password PASSWORD
                                      [--scope SCOPE] [--test TEST]
                                      [--timeout TIMEOUT] -u URL
                                      --username USERNAME

Batch querying HyperMetro domain information of a Huawei OceanStor Dorado
storage system via the REST Interface, using the ``/hypermetrodomain``
endpoint.

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
./huawei-dorado-hypermetrodomain --url https://oceanstor:8088 --device-id 123456789 --username monitoring --password mypass
```

Output:

```text
Everything is ok.

UUID                   ! Name               ! QuorumSrv ! QuorumType    ! Running 
-----------------------+--------------------+-----------+---------------+---------
15362:f4b78d046ec60100 ! HyperMetroDomain01 ! xyz       ! Quorum Server ! [OK]    
15362:8038bc14bd750100 ! test               !           ! None          ! [OK] 

Fetched API 2 times
```


## States

* UNKNOWN on invalid responses or responses with error codes.
* WARN if HyperMetroDomain running status is not equal to "Normal".


## Perfdata / Metrics

| Name                    | Type   | Description                                 |
|-------------------------|--------|---------------------------------------------|
| \<UUID\>\_RUNNINGSTATUS | Number | 1: Normal, 33: To be recovered, 35: Invalid |

Have a look at the [API documentation](https://support.huawei.com/enterprise/en/doc/EDOC1100144155/387d790e/overview) for details.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
