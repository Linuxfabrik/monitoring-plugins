# Check huawei-pacific-system-capacity


## Overview

Checks the overall cluster capacity usage of a Huawei OceanStor Pacific storage system via the REST API (`/system_capacity` endpoint). Alerts when the used capacity in percent reaches the warning or critical threshold.

**Important Notes:**

* Create a read-only API user that can perform queries only
* The used capacity is the sum of the per-media (SSD, SATA, SAS) used capacities; the total is the cluster's total capacity. Both are reported by the API as a plain number and are interpreted as bytes
* The credential/session token is cached in a local SQLite database between runs; `--cache-expire` controls how long it is reused before a fresh login

**Data Collection:**

* Queries the Huawei OceanStor Pacific REST API at `https://<ip>:<port>/api/v2/system_capacity`
* Authenticates via a session token (`X-Auth-Token`), cached in a SQLite database to avoid repeated logins
* If the appliance rejects a request (for example after a session reset or timeout), the check logs in again and retries


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/huawei-pacific-system-capacity> |
| Nagios/Icinga Check Name              | `check_huawei_pacific_system_capacity` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | No (`--password`, `--url` and `--username` are required) |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-cache.db` |


## Help

```text
usage: huawei-pacific-system-capacity [-h] [-V] [--always-ok]
                                      [--cache-expire CACHE_EXPIRE] [-c CRIT]
                                      [--insecure] [--no-proxy]
                                      --password PASSWORD [--scope SCOPE]
                                      [--timeout TIMEOUT] -u URL
                                      --username USERNAME [-w WARN]

Checks the overall cluster capacity usage of a Huawei OceanStor Pacific
storage system via the REST API (/system_capacity endpoint). Alerts when the
used capacity in percent reaches the warning or critical threshold.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --cache-expire CACHE_EXPIRE
                        The amount of time after which the credential/data
                        cache expires, in minutes. Default: 15
  -c, --critical CRIT   CRIT threshold in percent. Supports Nagios ranges.
                        Default: 90
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --no-proxy            Do not use a proxy.
  --password PASSWORD   Huawei OceanStor Pacific API password.
  --scope SCOPE         Huawei OceanStor Pacific API scope.
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
  -u, --url URL         Huawei OceanStor Pacific API URL.
  --username USERNAME   Huawei OceanStor Pacific API username.
  -w, --warning WARN    WARN threshold in percent. Supports Nagios ranges.
                        Default: 80
```


## Usage Examples

```bash
./huawei-pacific-system-capacity --url=https://oceanstor:8088 --username=monitoring --password=mypass --warning=80 --critical=90
```

Output:

```text
42% used (391.2GiB/931.3GiB)|'usage_percent'=42%;80;90;0;100 [...]
```


## States

* OK if the used capacity in percent is below the warning threshold.
* WARN if the used capacity in percent is at or above `--warning` (default: 80).
* CRIT if the used capacity in percent is at or above `--critical` (default: 90).
* OK with "No capacity data available yet." if the API reports a total capacity of zero.
* UNKNOWN on invalid API responses or responses with error codes.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| usage_percent | Percentage | Used cluster capacity in percent. |
| used_capacity | Bytes | Used cluster capacity (sum of the per-media used capacities). |
| total_capacity | Bytes | Total cluster capacity. |


## Troubleshooting

### No valuable response from the API

`Got no valuable response from https://...`

Check the `--url`, `--username` and `--password` parameters. Verify that the API user has query permissions and that the storage system REST API is reachable.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
