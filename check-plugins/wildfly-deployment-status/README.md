# Check wildfly-deployment-status

## Overview

Checks the deployment status of applications on a WildFly/JBoss AS server via its HTTP-JSON based management API (JBossAS REST Management API). This approach requires no additional agents or WAR deployments like Jolokia. The plugin supports both standalone mode and domain mode.

**Data Collection:**

* Queries the WildFly management API at `/deployment/*` using the `read-attribute` operation for the `status` attribute
* Authenticates via HTTP Digest Auth (`--username`, `--password`)
* Specific deployments can be checked using `--deployment` (repeatable); if omitted, all deployments are checked

**Compatibility:**

* Tested with WildFly 11 and WildFly 23+
* See [additional notes for all wildfly monitoring plugins](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/PLUGINS-WILDFLY.md)


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/wildfly-deployment-status> |
| Nagios/Icinga Check Name              | `check_wildfly_deployment_status` |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | No (`--username` and `--password` are required) |
| Compiled for Windows                  | No |


## Help

```text
usage: wildfly-deployment-status [-h] [-V] [--always-ok]
                                 [--deployment DEPLOYMENT] [--insecure]
                                 [--instance INSTANCE]
                                 [--mode {standalone,domain}] [--no-proxy]
                                 [--node NODE] -p PASSWORD [--timeout TIMEOUT]
                                 [--url URL] --username USERNAME

Checks the deployment status of applications on a WildFly/JBoss AS server via
its HTTP management API. Alerts when any deployment is not in the expected
enabled state.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --deployment DEPLOYMENT
                        Application deployment name to check. Can be specified
                        multiple times. If not specified, all deployments are
                        checked.
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

Check all deployments:

```bash
./wildfly-deployment-status --username=wildfly-monitoring --password=password --url=http://wildfly:9990
```

Check specific deployments:

```bash
./wildfly-deployment-status --username=wildfly-monitoring --password=password --url=http://wildfly:9990 --deployment=MyFirstApp --deployment=MySecondApp
```

Output:

```text
2 Deployments checked, everything is ok.

* MyFirstApp is OK
* MySecondApp is RUNNING
```


## States

* OK if deployment state is "OK" or "RUNNING".
* WARN if deployment state is "STOPPED".
* CRIT for any other deployment state.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| deployment-state-NAME | Number | 0 (OK), 1 (WARN), 2 (CRIT). |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
