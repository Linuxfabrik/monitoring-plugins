# Check jitsi-videobridge-status


## Overview

Checks the Jitsi Videobridge health state via the `/about/health` REST endpoint. Alerts when the Videobridge reports an unhealthy state, at the level `--severity` sets.

**Important Notes:**

* Jitsi Videobridge v2.1+

**Data Collection:**

* Queries the `/about/health` endpoint on the Jitsi Videobridge private REST interface
* The Videobridge performs periodic internal health tests and returns the latest result
* A HTTP 200 response indicates a healthy state; any other status indicates a problem
* For details see the [Jitsi Videobridge health check documentation](https://github.com/jitsi/jitsi-videobridge/blob/master/doc/health-checks.md)


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/jitsi-videobridge-status> |
| Nagios/Icinga Check Name              | `check_jitsi_videobridge_status` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No (runs with Python interpreter) |


## Help

```text
usage: jitsi-videobridge-status [-h] [-V] [--always-ok] [--insecure]
                                [--no-perfdata] [--no-proxy] [-p PASSWORD]
                                [--proxy PROXY] [--severity {warn,crit}]
                                [--timeout TIMEOUT] [--url URL]
                                [--username USERNAME]

Checks the Jitsi Videobridge health state via the /about/health REST endpoint.
Alerts when the Videobridge reports an unhealthy state, at the level
`--severity` sets.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --no-perfdata         Suppress the performance data section from the output.
                        The status message and the exit code are unaffected,
                        so alerting keeps working while trending data is
                        dropped.
  --no-proxy            Do not use a proxy, not even one the environment
                        names. Overrides `--proxy`.
  -p, --password PASSWORD
                        Jitsi API password.
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
  --severity {warn,crit}
                        Severity for alerting. Default: warn
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
  --url URL             Jitsi API URL. Default: http://localhost:8080
  --username USERNAME   Jitsi API username. Default: None

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/jitsi-videobridge-status/
```


## Usage Examples

```bash
./jitsi-videobridge-status --severity=warn
```

Output (healthy):

```text
Everything is ok.
```

Output (unhealthy):

```text
Problems with jitsi-videobridge.
```


## States

* OK if the Videobridge reports a healthy state (HTTP 200).
* WARN if `--severity=warn` (default) and the Videobridge reports an unhealthy state.
* CRIT if `--severity=crit` and the Videobridge reports an unhealthy state.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| jitsi-videobridge-state | Number | The current state (0 = OK, 1 = WARN, 2 = CRIT). |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
