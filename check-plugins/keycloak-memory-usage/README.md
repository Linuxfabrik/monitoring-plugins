# Check keycloak-memory-usage

## Overview

This check plugin monitors the memory usage of a Keycloak server using its HTTP-based API. Tested with Keycloak 18+.

Hints:

* See [Creating an API user account to monitor Keycloak](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/PLUGINS-KEYCLOAK.rst).


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/keycloak-memory-usage> |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |


## Help

```text
usage: keycloak-memory-usage [-h] [-V] [--always-ok] [--client-id CLIENT_ID]
                             [--critical CRIT] [--insecure] [--no-proxy]
                             [-p PASSWORD] [--realm REALM] [--timeout TIMEOUT]
                             [--url URL] [--username USERNAME]
                             [--warning WARN]

This check plugin monitors the memory usage of a Keycloak server using its
HTTP-based API. Tested with Keycloak 18+.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --client-id CLIENT_ID
                        Keycloak API Client-ID. Default: admin-cli
  --critical CRIT       Set the critical threshold.
  --insecure            This option explicitly allows to perform "insecure"
                        SSL connections. Default: False
  --no-proxy            Do not use a proxy. Default: False
  -p, --password PASSWORD
                        Keycloak API password. Default: admin
  --realm REALM         Keycloak API Realm. Default: master
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
  --url URL             Keycloak API URL. Default: http://127.0.0.1:8080
  --username USERNAME   Keycloak API username. Default: admin
  --warning WARN        Set the warning threshold.
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

Triggers an alarm on usage in percent.

* WARN or CRIT if memory usage is above certain thresholds (default 80/90%)


## Perfdata / Metrics

| Name          | Type       | Description                  |
|---------------|------------|------------------------------|
| free          | Bytes      | Memory not being used at all |
| total         | Bytes      | Total memory                 |
| usage_percent | Percentage |                              |
| used          | Bytes      | Memory used                  |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
