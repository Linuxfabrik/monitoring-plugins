# Check wildfly-server-status


## Overview

Checks the overall server status of a WildFly/JBoss AS instance via its HTTP-JSON based management API (JBossAS REST Management API). This approach requires no additional agents or WAR deployments like Jolokia. The plugin supports both standalone mode and domain mode. Reports server state, launch type, running mode, and product version.

**Important Notes:**

* Tested with WildFly 11 and WildFly 23+

**Data Collection:**

* Queries the WildFly management API for `server-state`, `launch-type`, `running-mode`, and `product-version` (falls back to `release-version` if `product-version` is not available)
* Authenticates via HTTP Digest Auth (`--username`, `--password`)


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/wildfly-server-status> |
| Nagios/Icinga Check Name              | `check_wildfly_server_status` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | No (`--username` and `--password` are required) |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |


## Help

```text
usage: wildfly-server-status [-h] [-V] [--always-ok] [--insecure]
                             [--instance INSTANCE]
                             [--mode {standalone,domain}] [--no-proxy]
                             [--node NODE] -p PASSWORD [--timeout TIMEOUT]
                             [--url URL] --username USERNAME

Checks the overall server status of a WildFly/JBoss AS instance via its HTTP
management API. Alerts when the server is not in "running" state.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
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
./wildfly-server-status --username=wildfly-monitoring --password=password --url=http://wildfly:9990
```

Output:

```text
Server status "running", Launch Type STANDALONE, Running Mode NORMAL, v23.0.0.Final
```


## States

* OK if `server-state` is "running".
* WARN if `server-state` is "reload-required" or "restart-required".
* CRIT for any other server state.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| server-state | Number | 0 (OK/running), 1 (WARN/reload-required or restart-required), 2 (CRIT/other). |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
