# Check huawei-dorado-system


## Overview

Checks overall system health, capacity and running status of a Huawei OceanStor Dorado storage system via the REST API (`/system/` endpoint). Alerts when the system reports a non-normal health or running state, or when storage capacity exceeds configurable thresholds. Reports product model, firmware version, health/running status, total capacity usage and storage pool capacity usage.

**Important Notes:**

* Tested on Huawei OceanStor Dorado 8000 V6 6.1.0
* Create a read-only API user that can perform queries only
* The default session timeout period on the storage system is 20 minutes; `--cache-expire` defaults to 15 minutes to stay within that window
* The API counts every capacity in 512-byte sectors; performance data is reported in bytes

**Data Collection:**

* Queries the Huawei OceanStor Dorado REST API at `https://<ip>:<port>/deviceManager/rest/<deviceId>/system/`
* Authenticates via session tokens (iBaseToken + cookie), cached in a SQLite database to avoid repeated logins
* If the appliance rejects a request, the check logs in again and retries, up to three attempts one second apart


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/huawei-dorado-system> |
| Nagios/Icinga Check Name              | `check_huawei_dorado_system` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | No (`--device-id`, `--password`, `--url` and `--username` are required) |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-huawei-dorado.db` |


## Help

```text
usage: huawei-dorado-system [-h] [-V] [--always-ok]
                            [--cache-expire CACHE_EXPIRE] [-c CRIT]
                            [--device-id DEVICE_ID] [--insecure]
                            [--no-insecure] [--no-perfdata] [--no-proxy]
                            [--password PASSWORD]
                            [--password-file PASSWORD_FILE] [--scope SCOPE]
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
  -c, --critical CRIT   CRIT threshold in percent. Supports Nagios ranges.
                        Default: 95
  --device-id DEVICE_ID
                        Huawei OceanStor Dorado API device ID. Optional: the
                        appliance reports its own at login, so this is only
                        needed to override that answer.
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --no-insecure         Verify the TLS certificate against the system trust
                        store, overriding the insecure default of this check.
                        Use it once the endpoint presents a publicly trusted
                        certificate, or once its CA has been added to the
                        system trust store.
  --no-perfdata         Suppress the performance data section from the output.
                        The status message and the exit code are unaffected,
                        so alerting keeps working while trending data is
                        dropped.
  --no-proxy            Do not use a proxy.
  --password PASSWORD   Huawei OceanStor Dorado API password. Password.
  --password-file PASSWORD_FILE
                        Path to a file holding the password, read from its
                        first line. Keeps the password out of the process
                        list, where a command-line argument is visible to
                        every user on the host. Takes precedence over
                        `--password`. Keep the file readable only by the
                        monitoring user. Example: `--password-
                        file=/etc/icinga2/secrets/storage`.
  --scope SCOPE         Huawei OceanStor Dorado API scope.
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
  -u, --url URL         Huawei OceanStor Dorado API URL.
  --username USERNAME   Huawei OceanStor Dorado API username.
  -w, --warning WARN    WARN threshold in percent. Supports Nagios ranges.
                        Default: 90

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/huawei-dorado-system/
```


## Usage Examples

```bash
./huawei-dorado-system --url https://oceanstor:8088 --device-id 123456789 --username monitoring --password mypass
```

Output:

```text
OceanStor Dorado 8000 V6 6.1.0.SPH12, UUID: 201:4711, Name: myname, Location: Zurich, Health Status: Faulty (2) [CRITICAL], Running Status: Powering off (47) [WARNING]
Capacity: Total 1% used (8.8TiB/726.4TiB), Storage Pool 1% used (8.8TiB/612.2TiB)
```

```bash
./huawei-dorado-system --url https://oceanstor:8088 --device-id 123456789 --username monitoring --password mypass --warning 80 --critical 90
```


## States

* OK if system health and running status are normal and capacity usage is below thresholds.
* WARN if the system reports a degraded health status, or one this check does not know.
* WARN if the system's running status is not "Normal", unless it reports an outright failure.
* WARN if total capacity usage is >= `--warning` (default: 90%).
* WARN if storage pool capacity usage is >= `--warning` (default: 90%).
* CRIT if the system reports health status "Faulty", "Invalid" or "Offline".
* CRIT if the system's running status reports a failure ("Offline", "Invalid", "Migration fault", "Error/Faulty", "Power-on failed", "Abnormal" or "Rollback failure").
* CRIT if total capacity usage is >= `--critical` (default: 95%).
* CRIT if storage pool capacity usage is >= `--critical` (default: 95%).
* UNKNOWN on invalid API responses or responses with error codes.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| free_disks_capacity | Bytes | Total raw capacity of all free disks (0 if none exist). |
| health_status | Number | 1: normal, 2: faulty. |
| hot_spare_disks_capacity | Bytes | Total raw capacity of all hot spare disks (0 if none exist; always 0 on XVE architecture). |
| mapped_luns_capacity | Bytes | Total capacity of mapped LUNs. |
| running_status | Number | 1: normal, 3: not running, 12: powering on, 47: powering off, 51: upgrading. |
| storage_pool_free_capacity | Bytes | Total free capacity of all storage pools (after RAID). |
| storage_pool_hot_spare_capacity | Bytes | Total hot spare capacity of all storage pools (after RAID). |
| storage_pool_raw_capacity | Bytes | Total raw capacity of disks in all storage pools. |
| storage_pool_total_capacity | Bytes | Total capacity of all storage pools (after RAID). |
| storage_pool_usage_percent | Percentage | Storage pool capacity usage. |
| storage_pool_used_capacity | Bytes | Total used capacity of all storage pools (after RAID). |
| thick_luns_allocated_capacity | Bytes | Total capacity allocated to all thick LUNs. |
| thick_luns_used_capacity | Bytes | Total used capacity of all thick LUNs. |
| thin_luns_allocated_capacity | Bytes | Total capacity allocated to all thin LUNs. |
| thin_luns_used_capacity | Bytes | Total used capacity of all thin LUNs. |
| total_capacity | Bytes | Total system capacity. |
| unavailable_disks_capacity | Bytes | Total raw capacity of all unavailable disks (0 if none exist). |
| unmapped_luns_capacity | Bytes | Total capacity of unmapped LUNs. |
| usage_percent | Percentage | Total capacity usage. |
| used_capacity | Bytes | Used system capacity. |
| user_free_capacity | Bytes | Available system capacity. Counts thin-provisioned space, so it can exceed the physical total. |

A capacity the appliance does not track is reported as `-1` and left out of the performance data.

Have a look at the [API documentation](https://support.huawei.com/enterprise/en/doc/EDOC1100144155/387d790e/overview) for details.


## Troubleshooting

### No valuable response from the API

`Got no valuable response from https://...`

Check the `--url`, `--device-id`, `--username` and `--password` parameters. Verify that the API user has query permissions and that the storage system REST API is reachable.

### `This operation fails to be performed because of the unauthorized REST.`

This is a known transient issue with the Huawei REST API. The check makes up to three attempts and forces a fresh login before the second one. If the error persists, verify the API credentials and session timeout settings.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
