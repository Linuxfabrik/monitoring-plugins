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

Checks the thread utilization of a Wildfly/JBossAS over HTTP.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --critical CRIT       Set the critical threshold.
  --insecure            This option explicitly allows to perform "insecure"
                        SSL connections. Default: False
  --instance INSTANCE   The instance (server-config) to check if running in
                        domain mode.
  --mode {standalone,domain}
                        The mode the server is running.
  --no-proxy            Do not use a proxy. Default: False
  --node NODE           The node (host) if running in domain mode.
  -p, --password PASSWORD
                        WildFly API password.
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
  --url URL             WildFly API URL. Default: http://localhost:9990
  --username USERNAME   WildFly API username. Default: wildfly-monitoring
  --warning WARN        Set the warning threshold.
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
