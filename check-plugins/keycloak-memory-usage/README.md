# Check keycloak-memory-usage


## Overview

Monitors Java heap and non-heap memory usage of a Keycloak server via its HTTP API. Alerts when memory usage exceeds the configured thresholds, and if the server does not report memory information to the account the check authenticates with, which Keycloak grants only to an account holding the "manage-realm" role in its administration realm. Tested with Keycloak 17 and later.

**Important Notes:**

* Verified against Keycloak 17 to 26
* The account the check authenticates with needs the client role `manage-realm` of the `master-realm` client. Keycloak 26.7 and later report the `memoryInfo` section of `/admin/serverinfo` only to an account holding that role, so an account set up with a narrower role reports UNKNOWN after the server is upgraded
* All API paths are relative to `--url`. An instance that serves below a context path (Keycloak 16 and older by default, or a Quarkus instance started with `--http-relative-path=/auth`) needs that path in `--url`, for example `--url=http://127.0.0.1:8080/auth`
* See [Creating an API user account to monitor Keycloak](https://linuxfabrik.github.io/monitoring-plugins/plugins-keycloak/) for setting up the required API credentials.

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
                             [--critical CRIT] [--insecure] [--no-perfdata]
                             [--no-proxy] [-p PASSWORD] [--proxy PROXY]
                             [--realm REALM] [--timeout TIMEOUT] [--url URL]
                             [--username USERNAME] [--warning WARN]

Monitors Java heap and non-heap memory usage of a Keycloak server via its HTTP
API. Alerts when memory usage exceeds the configured thresholds, and if the
server does not report memory information to the account the check
authenticates with, which Keycloak grants only to an account holding the
"manage-realm" role in its administration realm. Tested with Keycloak 17 and
later.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --client-id CLIENT_ID
                        Keycloak API Client-ID. Default: admin-cli
  --critical CRIT       CRIT threshold in percent. Default: >= 90
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --no-perfdata         Suppress the performance data section from the output.
                        The status message and the exit code are unaffected,
                        so alerting keeps working while trending data is
                        dropped.
  --no-proxy            Do not use a proxy, not even one the environment
                        names. Overrides `--proxy`.
  -p, --password PASSWORD
                        Keycloak API password. Default: admin
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
  --realm REALM         Keycloak API realm. Default: master
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
  --url URL             Keycloak API URL. Default: http://127.0.0.1:8080
  --username USERNAME   Keycloak API username. Default: admin
  --warning WARN        WARN threshold in percent. Default: >= 80

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/keycloak-memory-usage/
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
* UNKNOWN if the account the check authenticates with may not read the memory information, on API connection errors, or if Keycloak answers without usable heap figures.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| free | Bytes | Free memory (not in use). |
| total | Bytes | Total available memory. |
| usage_percent | Percentage | Percentage of memory currently in use. |
| used | Bytes | Memory currently in use. |


## Troubleshooting

### `Keycloak reports no "memoryInfo" for this account.`

Keycloak answered without the section that carries the memory figures. It hands that section out only to an account holding the client role `manage-realm` of the `master-realm` client, and only in the administration realm (`master`). Assign that role to the account named in `--username`, or point `--username` at an account that already has it. See [Creating an API user account to monitor Keycloak](https://linuxfabrik.github.io/monitoring-plugins/plugins-keycloak/) for the full account setup.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
