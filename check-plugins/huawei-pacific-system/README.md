# Check huawei-pacific-system


## Overview

Reports the product model, system version and cluster name of a Huawei OceanStor Pacific storage system via the REST API (`/cluster/product`, `/system_capacity` and `/cluster/servers/count` endpoints). Alerts when the used cluster capacity in percent reaches the warning or critical threshold.

**Important Notes:**

* Create a read-only API user that can perform queries only
* `product_model` is the model Huawei builds (for example `OceanStor 100D`), `oem_product_model` is the name the appliance is branded as (for example `OceanStor Pacific`). The branded name is shown in brackets behind the model whenever the two differ
* The used capacity is the sum of the per-media (SSD, SATA, SAS) used capacities; the total is the cluster's total capacity. Both are reported by the API as a plain number and are interpreted as bytes
* The credential/session token is cached in a local SQLite database between runs; `--cache-expire` controls how long it is reused before a fresh login

**Data Collection:**

* Queries the Huawei OceanStor Pacific REST API at `https://<ip>:<port>/api/v2/cluster/product` and `https://<ip>:<port>/api/v2/system_capacity`
* Authenticates via a session token (`X-Auth-Token`), cached in a SQLite database to avoid repeated logins
* If the appliance rejects a request (for example after a session reset or timeout), the check logs in again and retries


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/huawei-pacific-system> |
| Nagios/Icinga Check Name              | `check_huawei_pacific_system` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | No (`--password`, `--url` and `--username` are required) |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No (runs with Python interpreter) |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-huawei-pacific.db` |


## Help

```text
usage: huawei-pacific-system [-h] [-V] [--always-ok]
                             [--cache-expire CACHE_EXPIRE] [-c CRIT]
                             [--insecure] [--no-insecure] [--no-perfdata]
                             [--no-proxy] [--password PASSWORD]
                             [--password-file PASSWORD_FILE] [--proxy PROXY]
                             [--scope SCOPE] [--timeout TIMEOUT] -u URL
                             --username USERNAME [-v] [-w WARN]

Reports the product model, system version and cluster name of a Huawei
OceanStor Pacific storage system via the REST API (/cluster/product,
/system_capacity and /cluster/servers/count endpoints). Alerts when the used
cluster capacity in percent reaches the warning or critical threshold.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --cache-expire CACHE_EXPIRE
                        The amount of time after which the credential/data
                        cache expires, in minutes. Default: 15
  -c, --critical CRIT   CRIT threshold in percent. Supports Nagios ranges.
                        Default: 95
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
  --no-proxy            Do not use a proxy, not even one the environment
                        names. Overrides `--proxy`.
  --password PASSWORD   Huawei OceanStor Pacific API password.
  --password-file PASSWORD_FILE
                        Path to a file holding the password, read from its
                        first line. Keeps the password out of the process
                        list, where a command-line argument is visible to
                        every user on the host. Takes precedence over
                        `--password`. Keep the file readable only by the
                        monitoring user. Example: `--password-
                        file=/etc/icinga2/secrets/storage`.
  --proxy PROXY         Proxy to reach the target through. The scheme defaults
                        to `http` when omitted. Overrides the proxy the
                        environment names (`http_proxy`, `https_proxy`,
                        `all_proxy`) together with the exceptions it lists in
                        `no_proxy`, and is itself overridden by `--no-proxy`.
                        Without either parameter the environment applies.
                        Credentials belong into the environment variable
                        rather than here, because a command-line argument is
                        visible to every user on the host. Example:
                        `--proxy=http://proxy.example.com:3128`.
  --scope SCOPE         Huawei OceanStor Pacific API scope.
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
  -u, --url URL         Huawei OceanStor Pacific API URL.
  --username USERNAME   Huawei OceanStor Pacific API username.
  -v, --verbose         Makes this plugin verbose during the operation. Useful
                        for debugging and seeing what is going on under the
                        hood. Appends what every API request returned, so the
                        appliance's own answers can be read while working out
                        how it reports something. Session tokens are redacted.
                        The output is as long as those answers are, so this is
                        a debugging aid rather than something to leave
                        switched on.
  -w, --warning WARN    WARN threshold in percent. Supports Nagios ranges.
                        Default: 92

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/huawei-pacific-system/
```


## Usage Examples

```bash
./huawei-pacific-system --url=https://oceanstor:8088 --username=monitoring --password=linuxfabrik --warning=80 --critical=90
```

Output:

```text
OceanStor Pacific V800R001C20 SPC100 (V800R001C20SPH105), Cluster Name: cluster01, 10 nodes
Capacity: 1% used (70.9TiB/5.0PiB usable, 9.2PiB raw)
```

The usable figure is what the cluster can store once erasure coding has taken its
share, and it is what the thresholds judge. The raw figure next to it is the capacity
of the disks themselves, so the difference between the two is visible at a glance.


## States

* OK if the used capacity in percent is below the warning threshold.
* WARN if the used capacity in percent is at or above `--warning` (default: 92).
* CRIT if the used capacity in percent is at or above `--critical` (default: 95).
* OK with "Capacity: no capacity data available yet" if the API reports a total capacity of zero. Model, version and cluster name are still reported.
* UNKNOWN on invalid API responses or responses with error codes.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| usage_percent | Percentage | Used cluster capacity in percent. |
| used_capacity | Bytes | Used cluster capacity, behind the erasure coding. |
| total_capacity | Bytes | Usable cluster capacity, behind the erasure coding. |


## Troubleshooting

### No valuable response from the API

`Got no valuable response from https://...`

Check the `--url`, `--username` and `--password` parameters. Verify that the API user has query permissions and that the storage system REST API is reachable.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
