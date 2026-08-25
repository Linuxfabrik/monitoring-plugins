# Check wildfly-thread-usage


## Overview

Checks thread pool utilization on a WildFly/JBoss AS server via its HTTP-JSON based management API (JBossAS REST Management API). This approach requires no additional agents or WAR deployments like Jolokia. The plugin supports both standalone mode and domain mode. Reports daemon thread count as a percentage of total thread count.

**Important Notes:**

* Tested with WildFly 11 and WildFly 23+

**Data Collection:**

* Queries the WildFly management API at `/core-service/platform-mbean/type/threading` using the `read-resource` operation with runtime data
* Authenticates via HTTP Digest Auth (`--username`, `--password`)


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/wildfly-thread-usage> |
| Nagios/Icinga Check Name              | `check_wildfly_thread_usage` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | No (`--username` and `--password` are required) |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |


## Help

```text
usage: wildfly-thread-usage [-h] [-V] [--always-ok] [--critical CRIT]
                            [--insecure] [--instance INSTANCE]
                            [--mode {standalone,domain}] [--no-perfdata]
                            [--no-proxy] [--node NODE] -p PASSWORD
                            [--proxy PROXY] [--timeout TIMEOUT] [--url URL]
                            --username USERNAME [--warning WARN]

Checks thread pool utilization on a WildFly/JBoss AS server via its HTTP
management API. Reports current, peak, and daemon thread counts. Alerts when
thread usage exceeds the configured thresholds.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --critical CRIT       CRIT threshold in percent. Default: >= 90
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --instance INSTANCE   WildFly instance (server-config) to check when running
                        in domain mode.
  --mode {standalone,domain}
                        WildFly server mode. Default: standalone
  --no-perfdata         Suppress the performance data section from the output.
                        The status message and the exit code are unaffected,
                        so alerting keeps working while trending data is
                        dropped.
  --no-proxy            Do not use a proxy, not even one the environment
                        names. Overrides `--proxy`.
  --node NODE           WildFly node (host) when running in domain mode.
  -p, --password PASSWORD
                        WildFly management API password.
  --proxy PROXY         Proxy to reach the target through. The scheme defaults
                        to `http` when omitted. Overrides the proxy the
                        environment names (`http_proxy`, `https_proxy`,
                        `all_proxy`) together with the exceptions it lists in
                        `no_proxy`, and is itself overridden by `--no-proxy`.
                        Without either parameter the environment applies.
                        Credentials belong into the environment variable
                        rather than here, because a command-line argument is
                        visible to every user on the host. Example:
                        `--proxy=http://proxy.example.com:3128`.
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
  --url URL             WildFly management API URL. Default:
                        http://localhost:9990
  --username USERNAME   WildFly management API username. Default: wildfly-
                        monitoring
  --warning WARN        WARN threshold in percent. Default: >= 80

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/wildfly-thread-usage/
```


## Usage Examples

```bash
./wildfly-thread-usage --username=wildfly-monitoring --password=password --url=http://wildfly:9990 --warning=80 --critical=90
```

Output:

```text
32.1% used (18/56 threads)
```


## States

* OK if thread usage is below the warning threshold.
* WARN or CRIT if daemon-to-total thread ratio is >= `--warning` (default: 80) or >= `--critical` (default: 90).
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| thread-count | Number | Number of daemon threads (max: total thread count). |
| thread-pct | Percentage | Daemon threads as percentage of total threads. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
