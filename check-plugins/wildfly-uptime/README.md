# Check wildfly-uptime

## Overview

Reports the uptime of a WildFly/JBoss AS server via its HTTP-JSON based management API (JBossAS REST Management API). This approach requires no additional agents or WAR deployments like Jolokia. The plugin supports both standalone mode and domain mode. Useful for detecting application servers that have not been restarted after deployments or updates.

**Data Collection:**

* Queries the WildFly management API at `/core-service/platform-mbean/type/runtime` using the `read-resource` operation with runtime data
* Authenticates via HTTP Digest Auth (`--username`, `--password`)

**Compatibility:**

* See [additional notes for all wildfly monitoring plugins](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/PLUGINS-WILDFLY.md)

**Important Notes:**

* Tested with WildFly 11 and WildFly 23+



## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/wildfly-uptime> |
| Nagios/Icinga Check Name              | `check_wildfly_uptime` |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | No (`--username` and `--password` are required) |
| Compiled for Windows                  | No |


## Help

```text
usage: wildfly-uptime [-h] [-V] [--always-ok] [--critical CRIT] [--insecure]
                      [--instance INSTANCE] [--mode {standalone,domain}]
                      [--no-proxy] [--node NODE] -p PASSWORD
                      [--timeout TIMEOUT] [--url URL] --username USERNAME
                      [--warning WARN]

Reports the uptime of a WildFly/JBoss AS server via its HTTP management API.
Alerts when the uptime exceeds the configured thresholds (useful for detecting
application servers that have not been restarted after deployments).

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --critical CRIT       CRIT threshold in percent. Default: >= 366
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
  --warning WARN        WARN threshold in percent. Default: >= 180
```


## Usage Examples

```bash
./wildfly-uptime --username=wildfly-monitoring --password=password --url=http://wildfly:9990 --warning=180 --critical=366
```

Output:

```text
Up 1h 11m
```


## States

* OK if uptime is below the warning threshold.
* WARN or CRIT when uptime exceeds `--warning` (default: 180 days) or `--critical` (default: 366 days).
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| uptime | Seconds | WildFly server uptime. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
