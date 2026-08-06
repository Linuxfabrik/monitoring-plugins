# Check huawei-dorado-storagepool


## Overview

Checks the health, running status and capacity usage of all storage pools on a Huawei OceanStor Dorado storage system via the REST API (`/storagepool` endpoint). Alerts when a pool reports a non-normal state, and when its used capacity reaches the warning or critical threshold. Reports used, free and total capacity, the disk domain each pool belongs to, and the data reduction ratio the pool achieves.

**Important Notes:**

* Tested on Huawei OceanStor Dorado 8000 V6 6.1.0
* The usage percentage is the one the appliance itself computes, so the check alerts on the same number DeviceManager shows
* The API counts every capacity in 512-byte sectors; performance data is reported in bytes
* Create a read-only API user that can perform queries only
* The default session timeout period on the storage system is 20 minutes; `--cache-expire` defaults to 15 minutes to stay within that window

**Data Collection:**

* Queries the Huawei OceanStor Dorado REST API at `https://<ip>:<port>/deviceManager/rest/<deviceId>/storagepool`
* Walks the pool list page by page, so an array with more pools than fit in one response is still covered completely
* Authenticates via session tokens (iBaseToken + cookie), cached in a SQLite database to avoid repeated logins
* If the appliance rejects a request, the check logs in again and retries, up to three attempts one second apart


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/huawei-dorado-storagepool> |
| Nagios/Icinga Check Name              | `check_huawei_dorado_storagepool` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | No (`--device-id`, `--password`, `--url` and `--username` are required) |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-huawei-dorado.db` |


## Help

```text
usage: huawei-dorado-storagepool [-h] [-V] [--always-ok]
                                 [--cache-expire CACHE_EXPIRE] [-c CRIT]
                                 --device-id DEVICE_ID [--insecure]
                                 [--match MATCH] [--no-insecure]
                                 [--no-match-severity {ok,warn,crit,unknown}]
                                 [--no-perfdata] [--no-proxy]
                                 --password PASSWORD [--scope SCOPE]
                                 [--timeout TIMEOUT] -u URL
                                 --username USERNAME [-w WARN]

Checks the health, running status and capacity usage of all storage pools on a
Huawei OceanStor Dorado storage system via the REST API (/storagepool
endpoint). Alerts when a pool reports a non-normal state, and when its used
capacity reaches the warning or critical threshold.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --cache-expire CACHE_EXPIRE
                        The amount of time after which the credential/data
                        cache expires, in minutes. Default: 15
  -c, --critical CRIT   CRIT threshold for the used capacity of a pool, as a
                        Nagios range in percent. Default: 90
  --device-id DEVICE_ID
                        Huawei OceanStor Dorado API device ID.
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --match MATCH         Filter by storage pools. Filter by this Python regular
                        expression. Case-sensitive by default; use `(?i)` for
                        case-insensitive matching. Can be specified multiple
                        times. Examples: `(?i)example` to match "example"
                        regardless of case. `^(?!.*example).*$` to match any
                        string except "example" (negative lookahead). The
                        regex is anchored at the start of the string (Python
                        `re.match`) and is matched against the pool
                        identifier, the pool name and the name of its disk
                        domain, so prefix with `.*` to match anywhere.
                        Default:
  --no-insecure         Verify the TLS certificate against the system trust
                        store, overriding the insecure default of this check.
                        Use it once the endpoint presents a publicly trusted
                        certificate, or once its CA has been added to the
                        system trust store.
  --no-match-severity {ok,warn,crit,unknown}
                        State to report when no item matches the filters and
                        nothing is checked. Default: ok
  --no-perfdata         Suppress the performance data section from the output.
                        The status message and the exit code are unaffected,
                        so alerting keeps working while trending data is
                        dropped.
  --no-proxy            Do not use a proxy.
  --password PASSWORD   Huawei OceanStor Dorado API password.
  --scope SCOPE         Huawei OceanStor Dorado API scope.
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
  -u, --url URL         Huawei OceanStor Dorado API URL.
  --username USERNAME   Huawei OceanStor Dorado API username.
  -w, --warning WARN    WARN threshold for the used capacity of a pool, as a
                        Nagios range in percent. Default: 80

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/huawei-dorado-storagepool/
```


## Usage Examples

```bash
./huawei-dorado-storagepool --url=https://oceanstor:8088 --device-id=123456789 --username=monitoring --password=linuxfabrik
```

Output:

```text
Everything is ok.

UUID  ! Name           ! Disk Domain   ! Used     ! Total    ! Usage ! Usage State ! Reduction ! Health ! Running
------+----------------+---------------+----------+----------+-------+-------------+-----------+--------+--------
216:0 ! StoragePool001 ! DiskDomain000 ! 303.3GiB ! 1.5TiB   ! 20%   ! [OK]        ! 3.2:1     ! [OK]   ! [OK]
216:1 ! StoragePool002 ! DiskDomain000 ! 37.9GiB  ! 758.3GiB ! 5%    ! [OK]        ! 3.2:1     ! [OK]   ! [OK]
```

Alert earlier than the defaults, and only on the pools of one disk domain:

```bash
./huawei-dorado-storagepool --url=https://oceanstor:8088 --device-id=123456789 --username=monitoring --password=linuxfabrik --warning=70 --critical=85 --match='.*DiskDomain000'
```


## States

* OK if all storage pools report normal health, are online, and their used capacity is below the thresholds.
* WARN if a pool reports a degraded health status, or one this check does not know.
* WARN if a pool is busy rather than online (pre-copy, rebuilding, balancing, initializing or deleting).
* WARN if a pool's used capacity reaches `--warning` (default: 80%).
* CRIT if a pool reports health status "Faulty", "Invalid" or "Offline".
* CRIT if a pool's running status is "Offline".
* CRIT if a pool's used capacity reaches `--critical` (default: 90%).
* WARN if the appliance reports more storage pools than the check reads in one run, because the list is then incomplete.
* UNKNOWN if the appliance lists no storage pools at all, which points at the query rather than at the array.
* UNKNOWN on invalid API responses or responses with error codes.
* `--match` limits the check to the pools whose identifier, name or disk domain matches the regex; `--no-match-severity` sets what to report when nothing matches (default: OK).
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| \<UUID\>\_data_reduction_ratio | Number | Space reduction the pool achieves, for example 3.2 for 3.2:1. |
| \<UUID\>\_free_capacity | Bytes | Free capacity of the pool. |
| \<UUID\>\_health_status | Number | 1: normal, 2: faulty, 5: degraded. |
| \<UUID\>\_running_status | Number | 14: pre-copy, 16: rebuilding, 27: online, 28: offline, 32: balancing, 53: initializing, 106: deleting. |
| \<UUID\>\_total_capacity | Bytes | Total capacity of the pool. |
| \<UUID\>\_usage_percent | Percentage | Used capacity, as the appliance reports it. |
| \<UUID\>\_used_capacity | Bytes | Used capacity of the pool. |

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
