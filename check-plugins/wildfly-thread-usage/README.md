# Check wildfly-thread-usage

## Overview

Checks thread pool utilization on a WildFly/JBoss AS server via its HTTP-JSON based management API (JBossAS REST Management API). This approach requires no additional agents or WAR deployments like Jolokia. The plugin supports both standalone mode and domain mode. Reports daemon thread count as a percentage of total thread count.

**Data Collection:**

* Queries the WildFly management API at `/core-service/platform-mbean/type/threading` using the `read-resource` operation with runtime data
* Authenticates via HTTP Digest Auth (`--username`, `--password`)

**Compatibility:**

* Tested with WildFly 11 and WildFly 23+
* See [additional notes for all wildfly monitoring plugins](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/PLUGINS-WILDFLY.md)


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/wildfly-thread-usage> |
| Nagios/Icinga Check Name              | `check_wildfly_thread_usage` |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | No (`--username` and `--password` are required) |
| Compiled for Windows                  | No |


## Help

```text
usage: wildfly-thread-usage [-h] [-V] [--always-ok] [--critical CRIT]
                            [--insecure] [--instance INSTANCE]
                            [--mode {standalone,domain}] [--no-proxy]
                            [--node NODE] -p PASSWORD [--timeout TIMEOUT]
                            [--url URL] --username USERNAME [--warning WARN]

Checks thread pool utilization on a WildFly/JBoss AS server via its HTTP
management API. Reports current, peak, and daemon thread counts. Alerts when
thread usage exceeds the configured thresholds.

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
./wildfly-thread-usage --username=wildfly-monitoring --password=password --url=http://wildfly:9990 --warning=80 --critical=90
```

Output:

```text
32.1% used (18/56 threads)
```


## States

* OK if thread usage is below the warning threshold.
* WARN or CRIT if daemon-to-total thread ratio is >= `--warning` (default: 80) or >= `--critical` (default: 90).
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| thread-count | Number | Number of daemon threads (max: total thread count). |
| thread-pct | Percentage | Daemon threads as percentage of total threads. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
