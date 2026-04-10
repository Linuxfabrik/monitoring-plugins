# Check wildfly-non-xa-datasource-stats

## Overview

Monitors non-XA datasource connection pool metrics on a WildFly/JBoss AS server via its HTTP-JSON based management API (JBossAS REST Management API). This approach requires no additional agents or WAR deployments like Jolokia. The plugin supports both standalone mode and domain mode. Reports active, available, and idle connections per datasource.

**Important Notes:**

* Tested with WildFly 11 and WildFly 23+
* To enable database statistics:

    * Open the WildFly Admin Console
    * Go to Configuration > Subsystems > Datasources & Drivers > Datasources
    * Select your datasource
    * Click on View > Tab Attributes > Edit "Statistics Enabled"

**Data Collection:**

* Queries the WildFly management API at `/subsystem/datasources/data-source/*/statistics/pool/` using the `read-resource` operation with runtime data
* Authenticates via HTTP Digest Auth (`--username`, `--password`)
* Specific datasources can be checked using `--datasource` (repeatable); if omitted, all non-XA datasources are checked
* The check detects if statistics are not enabled for a datasource and reports this accordingly

**Compatibility:**

* Cross-platform



## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/wildfly-non-xa-datasource-stats> |
| Nagios/Icinga Check Name              | `check_wildfly_non_xa_datasource_stats` |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | No (`--username` and `--password` are required) |
| Compiled for Windows                  | No |


## Help

```text
usage: wildfly-non-xa-datasource-stats [-h] [-V] [--always-ok]
                                       [--critical CRIT]
                                       [--datasource DATASOURCE] [--insecure]
                                       [--instance INSTANCE]
                                       [--mode {standalone,domain}]
                                       [--no-proxy] [--node NODE] -p PASSWORD
                                       [--timeout TIMEOUT] [--url URL]
                                       --username USERNAME [--warning WARN]

Monitors non-XA datasource connection pool metrics on a WildFly/JBoss AS
server via its HTTP management API. Reports active, available, and idle
connections. Alerts when pool usage exceeds the configured thresholds.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --critical CRIT       CRIT threshold in percent. Default: >= 90
  --datasource DATASOURCE
                        Non-XA datasource name to check. Can be specified
                        multiple times. If not specified, all non-XA
                        datasources are checked.
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

Check all datasources:

```bash
./wildfly-non-xa-datasource-stats --username=wildfly-monitoring --password=password --url=http://wildfly:9990 --warning=80 --critical=90
```

Check specific datasources:

```bash
./wildfly-non-xa-datasource-stats --username=wildfly-monitoring --password=password --url=http://wildfly:9990 --warning=80 --critical=90 --datasource=MyFirstDS --datasource=MySecondDS
```

Output:

```text
MyFirstDS: 0.0% active used (0/20), 0.0% max used (0/20); Statistics are not enabled for data source MySecondDS
```


## States

* OK if all connection pool usage percentages are below the warning threshold.
* WARN or CRIT if active or max-used connection pool percentage is >= `--warning` (default: 80) or >= `--critical` (default: 90).
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| non-xa-ds-NAME-active | Number | Number of active connections (in use or available in the pool). |
| non-xa-ds-NAME-active-pct | Percentage | Active connections as percentage of available. |
| non-xa-ds-NAME-available | Number | Number of available connections in the pool. |
| non-xa-ds-NAME-blockingfailurecount | Number | Number of blocking failures. |
| non-xa-ds-NAME-createdcount | Number | Number of connections created. |
| non-xa-ds-NAME-destroyedcount | Number | Number of connections destroyed. |
| non-xa-ds-NAME-idlecount | Number | Number of idle connections. |
| non-xa-ds-NAME-inusecount | Number | Number of connections currently in use. |
| non-xa-ds-NAME-maxused | Number | Maximum number of connections used. |
| non-xa-ds-NAME-maxused-pct | Percentage | Max used connections as percentage of available. |
| non-xa-ds-NAME-maxwaitcount | Number | Maximum number of requests waiting for a connection simultaneously. |
| non-xa-ds-NAME-waitcount | Number | Number of requests that had to wait for a connection. |

Also have a look at <https://access.redhat.com/documentation/en-us/jboss_enterprise_application_platform/6.2/html/administration_and_configuration_guide/datasource_statistics>.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
