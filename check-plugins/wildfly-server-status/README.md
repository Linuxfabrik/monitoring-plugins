# Check wildfly-server-status

## Overview

This check plugin monitors a WildFly server, using its HTTP-JSON based API (JBossAS REST Management API). This allows us to monitor the application server without any additional configuration and installation - no need to deploy WAR-Agents like Jolokia. The plugin supports both standalone mode and domain mode.

Tested with WildFly 11 and WildFly 23+.

Hints:

* See [additional notes for all wildfly monitoring plugins](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/PLUGINS-WILDFLY.md)


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/wildfly-server-status> |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | No |
| Compiled for Windows                  | No |


## Help

```text
usage: wildfly-server-status [-h] [-V] [--always-ok] [--insecure]
                             [--instance INSTANCE]
                             [--mode {standalone,domain}] [--no-proxy]
                             [--node NODE] -p PASSWORD [--timeout TIMEOUT]
                             [--url URL] --username USERNAME

Checks the health of a Wildfly/JBossAS over HTTP.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
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
./wildfly-server-status --username wildfly-monitoring --password password --url http://wildfly:9990
```

Output:

```text
Server status "running", Launch Type STANDALONE, Running Mode NORMAL, v23.0.0.Final
```


## States

Triggers an alarm on its own.

* OK: server-state == 'running'
* WARN: server-state in \['reload-required', 'restart-required'\]
* CRIT: everything else


## Perfdata / Metrics

* server-state: 0 (STATE_OK), 1 (STATE_WARN), 2 (STATE_CRIT)


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
