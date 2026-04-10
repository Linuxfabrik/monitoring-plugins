# Check wildfly-memory-usage

## Overview

Checks Java heap and non-heap memory usage on a WildFly/JBoss AS server via its HTTP-JSON based management API (JBossAS REST Management API). This approach requires no additional agents or WAR deployments like Jolokia. The plugin supports both standalone mode and domain mode. Reports both "used" and "committed" percentages for heap and non-heap memory.

**Alerting Logic:**

* WARN or CRIT if heap or non-heap memory usage (used or committed) exceeds the configured thresholds (default: 80/90%)
* `--always-ok` suppresses all alerts and always returns OK

**Data Collection:**

* Queries the WildFly management API at `/core-service/platform-mbean/type/memory` using the `read-resource` operation with runtime data
* Authenticates via HTTP Digest Auth (`--username`, `--password`)
* Reports used/committed/max for both heap and non-heap memory

**Compatibility:**

* Tested with WildFly 11 and WildFly 23+
* See [additional notes for all wildfly monitoring plugins](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/PLUGINS-WILDFLY.md)


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/wildfly-memory-usage> |
| Nagios/Icinga Check Name              | `check_wildfly_memory_usage` |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | No (`--username` and `--password` are required) |
| Compiled for Windows                  | No |


## Help

```text
usage: wildfly-memory-usage [-h] [-V] [--always-ok] [--critical CRIT]
                            [--insecure] [--instance INSTANCE]
                            [--mode {standalone,domain}] [--no-proxy]
                            [--node NODE] -p PASSWORD [--timeout TIMEOUT]
                            [--url URL] --username USERNAME [--warning WARN]

Checks Java heap and non-heap memory usage on a WildFly/JBoss AS server via
its HTTP management API. Alerts when memory usage exceeds the configured
thresholds.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --critical CRIT       CRIT threshold in percent. Default: >= 90
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --instance INSTANCE   WildFly instance (server-config) to check when running
                        in domain mode.
  --mode {standalone,domain}
                        WildFly server mode. Default: standalone
  --no-proxy            Do not use a proxy.
  --node NODE           WildFly node (host) when running in domain mode.
  -p, --password PASSWORD
                        WildFly management API password.
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
  --url URL             WildFly management API URL. Default:
                        http://localhost:9990
  --username USERNAME   WildFly management API username. Default: wildfly-
                        monitoring
  --warning WARN        WARN threshold in percent. Default: >= 80
```


## Usage Examples

```bash
./wildfly-memory-usage --username=wildfly-monitoring --password=password --url=http://wildfly:9990 --warning=80 --critical=90
```

Output:

```text
Heap used: 18.04% (82.2MiB of 455.5MiB), Heap committed: 44.35% (202.0MiB of 455.5MiB), Non-Heap used: 14.56% (108.3MiB of 744.0MiB), Non-Heap committed: 16.25% (120.9MiB of 744.0MiB)
```


## States

* OK if all memory usage percentages are below the warning threshold.
* WARN or CRIT if heap or non-heap memory usage (used or committed) is >= `--warning` (default: 80) or >= `--critical` (default: 90).
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| heap-committed | Bytes | Heap memory committed (reserved at OS level). |
| heap-committed-percent | Percentage | Heap committed as percentage of max. |
| heap-max | Bytes | Maximum heap memory. |
| heap-used | Bytes | Heap memory currently in use. |
| heap-used-percent | Percentage | Heap used as percentage of max. |
| non-heap-committed | Bytes | Non-heap memory committed (reserved at OS level). |
| non-heap-committed-percent | Percentage | Non-heap committed as percentage of max. |
| non-heap-max | Bytes | Maximum non-heap memory. |
| non-heap-used | Bytes | Non-heap memory currently in use. |
| non-heap-used-percent | Percentage | Non-heap used as percentage of max. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
