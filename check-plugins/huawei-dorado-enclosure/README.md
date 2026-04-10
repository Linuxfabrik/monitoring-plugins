# Check huawei-dorado-enclosure


## Overview

Checks the health and running status of all enclosures (controller enclosures and disk enclosures) on a Huawei OceanStor Dorado storage system via the REST API (`/enclosure` endpoint). Alerts when any enclosure reports a non-normal health or running state. Reports model, serial number, logic type, MAC address, switch status and temperature per enclosure.

**Important Notes:**

* Tested on Huawei OceanStor Dorado 8000 V6 6.1.0
* Create a read-only API user that can perform queries only
* The default session timeout period on the storage system is 20 minutes; `--cache-expire` defaults to 15 minutes to stay within that window

**Data Collection:**

* Queries the Huawei OceanStor Dorado REST API at `https://<ip>:<port>/deviceManager/rest/<deviceId>/enclosure`
* Authenticates via session tokens (iBaseToken + cookie), cached in a SQLite database to avoid repeated logins
* On transient authorization errors, automatically retries up to 9 times with 1-second intervals

**Compatibility:**

* Cross-platform


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/huawei-dorado-enclosure> |
| Nagios/Icinga Check Name              | `check_huawei_dorado_enclosure` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | No (`--device-id`, `--password`, `--url` and `--username` are required) |
| Compiled for Windows                  | No |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-cache.db` |


## Help

```text
usage: huawei-dorado-enclosure [-h] [-V] [--always-ok]
                               [--cache-expire CACHE_EXPIRE]
                               --device-id DEVICE_ID [--insecure] [--no-proxy]
                               --password PASSWORD [--scope SCOPE]
                               [--test TEST] [--timeout TIMEOUT] -u URL
                               --username USERNAME

Checks the health and running status of all enclosures on a Huawei OceanStor
Dorado storage system via the REST API (/enclosure endpoint). Alerts when any
enclosure reports a non-normal state.

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
./huawei-dorado-enclosure --url https://oceanstor:8088 --device-id 123456789 --username monitoring --password mypass
```

Output:

```text
Everything is ok.

UUID   ! Location ! Name   ! Model                                 ! SerialNumber         ! Logic                                ! MacAddress        ! Switch ! Temp ! Health ! Running 
-------+----------+--------+---------------------------------------+----------------------+--------------------------------------+-------------------+--------+------+--------+---------
206:0  ! 0.1      ! CTE0   ! Unknown                               ! 210235843910E6000009 ! Controller Enclosure                 ! 30:d1:7e:b4:f7:61 ! On     ! 30   ! [OK]   ! [OK]    
206:0  ! --       ! CTE0   ! 4 U 4-controller controller enclosure ! 0815                 ! Controller Enclosure                 ! f4:b7:8d:04:6e:ca ! On     ! 22   ! [OK]   ! [OK]    
206:64 ! --       ! DAE000 ! 2 U 36-slot smart NVMe disk enclosure ! 4711                 ! Expansion Enclosure (Disk Enclosure) ! f4:b4:e1:ab:0f:33 ! On     ! 27   ! [OK]   ! [OK]    
206:65 ! --       ! DAE010 ! 2 U 36-slot smart NVMe disk enclosure ! 4711                 ! Expansion Enclosure (Disk Enclosure) ! f4:b4:e1:7a:13:5d ! On     ! 27   ! [OK]   ! [OK]    
206:66 ! --       ! DAE020 ! 2 U 36-slot smart NVMe disk enclosure ! 4711                 ! Expansion Enclosure (Disk Enclosure) ! f4:b4:e1:ab:14:a5 ! On     ! 28   ! [OK]   ! [OK] 

Fetched API 2 times
```


## States

* OK if all enclosures report normal health and running status.
* WARN if any enclosure's running status is not "Normal", "Running" or "Online".
* CRIT if any enclosure's health status is not "Normal".
* UNKNOWN on invalid API responses or responses with error codes.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| \<UUID\>\_HEALTHSTATUS | Number | 0: unknown, 1: normal, 2: faulty. |
| \<UUID\>\_RUNNINGSTATUS | Number | 0: unknown, 1: normal, 2: running, 5: sleep in high temperature, 27: online, 28: offline, 105: abnormal. |
| \<UUID\>\_SWITCHSTATUS | Number | 1: on, 2: off. |
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
