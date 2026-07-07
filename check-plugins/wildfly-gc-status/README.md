# Check wildfly-gc-status


## Overview

Reports garbage collector activity from a WildFly/JBoss AS server via its HTTP-JSON based management API (JBossAS REST Management API). This approach requires no additional agents or WAR deployments like Jolokia. The plugin supports both standalone mode and domain mode. Reports the collection rate and the share of wall-clock time spent in garbage collection (GC overhead) for each garbage collector.

**Important Notes:**

* Tested with WildFly 11 and WildFly 23+

**Data Collection:**

* Queries the WildFly management API at `/core-service/platform-mbean/type/garbage-collector` using the `read-resource` operation with runtime data
* Authenticates via HTTP Digest Auth (`--username`, `--password`)


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/wildfly-gc-status> |
| Nagios/Icinga Check Name              | `check_wildfly_gc_status` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | No (`--username` and `--password` are required) |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |


## Help

```text
usage: wildfly-gc-status [-h] [-V] [--insecure] [--instance INSTANCE]
                         [--mode {standalone,domain}] [--no-proxy]
                         [--node NODE] -p PASSWORD [--timeout TIMEOUT]
                         [--url URL] --username USERNAME

Reports garbage collector activity from a WildFly/JBoss AS server via its HTTP
management API, reporting the collection rate and the share of wall-clock time
spent in garbage collection (GC overhead) for each collector.

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
MarkSweepCompact: 0.02/s collections, 0.4% GC time; Copy: 0.53/s collections, 1.8% GC time
```


## States

* Always returns OK.
* On the first run (or after a JVM restart) it returns OK with "Waiting for more data.", because the per-second rates need two consecutive runs.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| garbage-collector-NAME-collection-count-per-second | Number | Garbage collections per second. |
| garbage-collector-NAME-collection-time-percent | Percentage | Share of wall-clock time spent in garbage collection (GC overhead). |

NAME is the name of the garbage collector (e.g. "MarkSweepCompact", "Copy").


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
