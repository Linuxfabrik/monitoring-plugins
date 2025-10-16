# Check wildfly-gc-status

## Overview

This check plugin prints the garbage collector of a WildFly server, using its HTTP-JSON based API (JBossAS REST Management API). This allows us to monitor the application server without any additional configuration and installation - no need to deploy WAR-Agents like Jolokia. The plugin supports both standalone mode and domain mode.

Tested with WildFly 11 and WildFly 23+.

Hints:

* See [additional notes for all wildfly monitoring plugins](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/PLUGINS-WILDFLY.md)


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/wildfly-gc-status> |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | No |
| Compiled for Windows                  | No |


## Help

```text
usage: wildfly-gc-status [-h] [-V] [--insecure] [--instance INSTANCE]
                         [--mode {standalone,domain}] [--no-proxy]
                         [--node NODE] -p PASSWORD [--timeout TIMEOUT]
                         [--url URL] --username USERNAME

Prints the status of the Wildfly/JBossAS garbage collector.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
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
```


## Usage Examples

```bash
./wildfly-gc-status --username wildfly-monitoring --password password --url http://wildfly:9990
```

Output:

```text
MarkSweepCompact: CollectionCount 2.0, CollectionTime 1s; Copy: CollectionCount 32.0, CollectionTime 4s
```


## States

* Always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| garbage-collector-NAME-collection-count | Continous Counter | The total number of collections that have occurred. |
| garbage-collector-NAME-collection-time | Milliseconds | The approximate accumulated collection elapsed time in milliseconds. |

NAME is the name of the garbage collector.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
