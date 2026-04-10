# Check wildfly-gc-status

## Overview

Reports garbage collector statistics from a WildFly/JBoss AS server via its HTTP-JSON based management API (JBossAS REST Management API). This approach requires no additional agents or WAR deployments like Jolokia. The plugin supports both standalone mode and domain mode. Reports collection count and total collection time for each garbage collector.

**Important Notes:**

* Tested with WildFly 11 and WildFly 23+



**Data Collection:**

* Queries the WildFly management API at `/core-service/platform-mbean/type/garbage-collector` using the `read-resource` operation with runtime data
* Authenticates via HTTP Digest Auth (`--username`, `--password`)

**Compatibility:**

* Cross-platform


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/wildfly-gc-status> |
| Nagios/Icinga Check Name              | `check_wildfly_gc_status` |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | No (`--username` and `--password` are required) |
| Compiled for Windows                  | No |


## Help

```text
usage: wildfly-gc-status [-h] [-V] [--insecure] [--instance INSTANCE]
                         [--mode {standalone,domain}] [--no-proxy]
                         [--node NODE] -p PASSWORD [--timeout TIMEOUT]
                         [--url URL] --username USERNAME

Reports garbage collector statistics from a WildFly/JBoss AS server via its
HTTP management API, including GC count and total GC time for each collector.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
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
```


## Usage Examples

```bash
./wildfly-gc-status --username=wildfly-monitoring --password=password --url=http://wildfly:9990
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
| garbage-collector-NAME-collection-count | Continuous Counter | Total number of collections that have occurred. |
| garbage-collector-NAME-collection-time | Milliseconds | Approximate accumulated collection elapsed time. |

NAME is the name of the garbage collector (e.g. "MarkSweepCompact", "Copy").


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
