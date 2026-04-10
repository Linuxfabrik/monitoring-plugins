# Check wildfly-uptime

## Overview

This check plugin monitors the uptime of a WildFly server, using its HTTP-JSON based API (JBossAS REST Management API). This allows us to monitor the application server without any additional configuration and installation - no need to deploy WAR-Agents like Jolokia. The plugin supports both standalone mode and domain mode.

Tested with WildFly 11 and WildFly 23+.

Hints:

* See [additional notes for all wildfly monitoring plugins](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/PLUGINS-WILDFLY.md)


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/wildfly-uptime> |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | No |
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
  --critical CRIT       CRIT threshold in percent. Supports Nagios ranges.
                        Default: >= 366
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
  --warning WARN        WARN threshold in percent. Supports Nagios ranges.
                        Default: >= 180
```


## Usage Examples

```bash
./wildfly-uptime --username wildfly-monitoring --password password --url http://wildfly:9990 --warning 180 --critical 366
```

Output:

```text
Up 1h 11m
```


## States

Triggers an alarm on uptime in days.

* WARN or CRIT when uptime (the number of days) exceeds the thresholds (default 180/366 days)


## Perfdata / Metrics

* uptime: seconds


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
