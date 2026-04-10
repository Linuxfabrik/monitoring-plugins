# Check huawei-dorado-system

## Overview

Checks overall system health, capacity and running status of a Huawei OceanStor Dorado storage system via the REST API (`/system/` endpoint). Alerts when the system reports a non-normal health or running state, or when storage capacity exceeds configurable thresholds. Reports product model, firmware version, health/running status, total sector capacity usage and storage pool capacity usage.

**Important Notes:**

* Tested on Huawei OceanStor Dorado 8000 V6 6.1.0
* Create a read-only API user that can perform queries only
* The default session timeout period on the storage system is 20 minutes; `--cache-expire` defaults to 15 minutes to stay within that window
* Capacity values in perfdata are reported in sectors (as returned by the API)


**Data Collection:**

* Queries the Huawei OceanStor Dorado REST API at `https://<ip>:<port>/deviceManager/rest/<deviceId>/system/`
* Authenticates via session tokens (iBaseToken + cookie), cached in a SQLite database to avoid repeated logins
* On transient authorization errors, automatically retries up to 9 times with 1-second intervals

**Compatibility:**

* Cross-platform


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/huawei-dorado-system> |
| Nagios/Icinga Check Name              | `check_huawei_dorado_system` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | No (`--device-id`, `--password`, `--url` and `--username` are required) |
| Compiled for Windows                  | No |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-cache.db` |


## Help

```text
usage: huawei-dorado-system [-h] [-V] [--always-ok]
                            [--cache-expire CACHE_EXPIRE] [-c CRIT]
                            --device-id DEVICE_ID [--insecure] [--no-proxy]
                            --password PASSWORD [--scope SCOPE] [--test TEST]
                            [--timeout TIMEOUT] -u URL --username USERNAME
                            [-w WARN]

Checks overall system health, capacity, and performance of a Huawei OceanStor
Dorado storage system via the REST API (/system endpoint). Reports health
status, running status, storage capacity, and I/O performance metrics. Alerts
when the system reports a non-normal health or running state.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --cache-expire CACHE_EXPIRE
                        The amount of time after which the credential/data
                        cache expires, in minutes. Default: 15
  -c, --critical CRIT   CRIT threshold in percent. Default: >= 95
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
  -w, --warning WARN    WARN threshold in percent. Default: >= 90
```


## Usage Examples

```bash
./huawei-dorado-system --url https://oceanstor:8088 --device-id 123456789 --username monitoring --password mypass
```

Output:

```text
OceanStor Dorado 8000 V6 6.1.0.SPH12, UUID: 201:4711, Name: myname, Location: Zurich, Health Status: Faulty (2) [CRITICAL], Running Status: Powering off (47) [WARNING]
Sectors: Total 1.0% used (19.0G/1.6T), Storage Pool 1.0% used (19.0G/1.3T)

Fetched API 2 times
```

```bash
./huawei-dorado-system --url https://oceanstor:8088 --device-id 123456789 --username monitoring --password mypass --warning 80 --critical 90
```


## States

* OK if system health and running status are normal and capacity usage is below thresholds.
* WARN if system running status is not "Normal".
* WARN if total sector capacity usage is >= `--warning` (default: 90%).
* WARN if storage pool capacity usage is >= `--warning` (default: 90%).
* CRIT if system health status is not "Normal".
* CRIT if total sector capacity usage is >= `--critical` (default: 95%).
* CRIT if storage pool capacity usage is >= `--critical` (default: 95%).
* UNKNOWN on invalid API responses or responses with error codes.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| FREEDISKSCAPACITY | Sectors | Total raw capacity of all free disks (0 if none exist). |
| HEALTHSTATUS | Number | 1: normal, 2: faulty. |
| HOTSPAREDISKSCAPACITY | Sectors | Total raw capacity of all hot spare disks (0 if none exist; always 0 on XVE architecture). |
| mappedLunsCountCapacity | Sectors | Total capacity of mapped LUNs. |
| RUNNINGSTATUS | Number | 1: normal, 3: not running, 12: powering on, 47: powering off, 51: upgrading. |
| sectors-capacity-percent | Percentage | Total sector capacity usage. |
| sectors-storagepool-percent | Percentage | Storage pool capacity usage. |
| STORAGEPOOLFREECAPACITY | Sectors | Total free capacity of all storage pools (after RAID). |
| STORAGEPOOLHOSTSPARECAPACITY | Sectors | Total hot spare capacity of all storage pools (after RAID). |
| STORAGEPOOLRAWCAPACITY | Sectors | Total raw capacity of disks in all storage pools. |
| STORAGEPOOLUSEDCAPACITY | Sectors | Total used capacity of all storage pools (after RAID). |
| THICKLUNSALLOCATECAPACITY | Sectors | Total capacity allocated to all thick LUNs. |
| THICKLUNSUSEDCAPACITY | Sectors | Total used capacity of all thick LUNs. |
| THINLUNSALLOCATECAPACITY | Sectors | Total capacity allocated to all thin LUNs. |
| THINLUNSUSEDCAPACITY | Sectors | Total used capacity of all thin LUNs. |
| UNAVAILABLEDISKSCAPACITY | Sectors | Total raw capacity of all unavailable disks (0 if none exist). |
| unMappedLunsCountCapacity | Sectors | Total capacity of unmapped LUNs. |
| USEDCAPACITY | Sectors | Used system capacity. |
| userFreeCapacity | Sectors | Available system capacity. |

Have a look at the [API documentation](https://support.huawei.com/enterprise/en/doc/EDOC1100144155/387d790e/overview) for details.


## Troubleshooting

`Got no valuable response from https://...`
Check the `--url`, `--device-id`, `--username` and `--password` parameters. Verify that the API user has query permissions and that the storage system REST API is reachable.

`This operation fails to be performed because of the unauthorized REST.`
This is a known transient issue with the Huawei REST API. The check retries automatically up to 9 times. If the error persists, verify the API credentials and session timeout settings.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
