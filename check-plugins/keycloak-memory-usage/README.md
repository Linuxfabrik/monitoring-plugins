# Check keycloak-memory-usage


## Overview

Monitors Java heap and non-heap memory usage of a Keycloak server via its HTTP API and alerts when memory usage exceeds configurable thresholds.

**Important Notes:**

* Tested with Keycloak 18 and later
* See [Creating an API user account to monitor Keycloak](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/PLUGINS-KEYCLOAK.md) for setting up the required API credentials.

**Data Collection:**

* Authenticates against the Keycloak OIDC token endpoint using client credentials (`--client-id`, `--username`, `--password`)
* Queries the Keycloak Admin REST API at `/admin/serverinfo` to retrieve `memoryInfo` (used, total, free, freePercentage)


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/keycloak-memory-usage> |
| Nagios/Icinga Check Name              | `check_keycloak_memory_usage` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |


## Help

```text
usage: keycloak-memory-usage [-h] [-V] [--always-ok] [--client-id CLIENT_ID]
                             [--critical CRIT] [--insecure] [--no-proxy]
                             [-p PASSWORD] [--realm REALM] [--timeout TIMEOUT]
                             [--url URL] [--username USERNAME]
                             [--warning WARN]

Monitors Java heap and non-heap memory usage of a Keycloak server via its HTTP
API. Alerts when memory usage exceeds the configured thresholds. Tested with
Keycloak 18 and later.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --client-id CLIENT_ID
                        Keycloak API Client-ID. Default: admin-cli
  --critical CRIT       CRIT threshold in percent. Default: >= 90
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --no-proxy            Do not use a proxy.
  -p, --password PASSWORD
                        Keycloak API password. Default: admin
  --realm REALM         Keycloak API realm. Default: master
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
  --url URL             Keycloak API URL. Default: http://127.0.0.1:8080
  --username USERNAME   Keycloak API username. Default: admin
  --warning WARN        WARN threshold in percent. Default: >= 80
```


## Usage Examples

```bash
./keycloak-memory-usage --username=keycloak-monitoring --password=linuxfabrik --url=http://keycloak:8080 --warning=80 --critical=90
```

Output:

```text
89% [WARNING] - total: 494.9MiB, used: 441.6MiB, free: 53.4MiB
```


## States

* OK if memory usage is below `--warning` (default: 80%).
* WARN if memory usage is >= `--warning` (default: 80%).
* CRIT if memory usage is >= `--critical` (default: 90%).
* UNKNOWN on API connection errors or missing data in the Keycloak response.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| free | Bytes | Free memory (not in use). |
| total | Bytes | Total available memory. |
| usage_percent | Percentage | Percentage of memory currently in use. |
| used | Bytes | Memory currently in use. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
