# Check wildfly-thread-usage

## Overview

This check plugin monitors the thread statistics of a WildFly server, using its HTTP-JSON based API (JBossAS REST Management API). This allows us to monitor the application server without any additional configuration and installation - no need to deploy WAR-Agents like Jolokia. The plugin supports both standalone mode and domain mode.

Tested with WildFly 11 and WildFly 23+.

Hints:

* See [additional notes for all wildfly monitoring plugins](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/PLUGINS-WILDFLY.md)


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/wildfly-thread-usage> |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | No |
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
  --critical CRIT       CRIT threshold in percent. Supports Nagios ranges.
                        Default: >= 90
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
                        Default: >= 80
```


## Usage Examples

```bash
./wildfly-thread-usage --username wildfly-monitoring --password password --url http://wildfly:9990 --warning 80 --critical 90
```

Output:

```text
32.1% used (18/56 threads)
```


## States

Triggers an alarm on usage in percent.

* WARN or CRIT if thread counts are above certain thresholds (default 80/90%).


## Perfdata / Metrics

* thread-pct
* thread-count


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
