# Check jitsi-videobridge-status


## Overview

Checks the Jitsi Videobridge health state via the `/about/health` REST endpoint. Returns OK if the bridge is healthy, WARN or CRIT otherwise.

**Important Notes:**

* Jitsi Videobridge v2.1+

**Data Collection:**

* Queries the `/about/health` endpoint on the Jitsi Videobridge private REST interface
* The Videobridge performs periodic internal health tests and returns the latest result
* A HTTP 200 response indicates a healthy state; any other status indicates a problem
* For details see the [Jitsi Videobridge health check documentation](https://github.com/jitsi/jitsi-videobridge/blob/master/doc/health-checks.md)


## Fact Sheet

| Fact | Value |
|----|------|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/jitsi-videobridge-status> |
| Nagios/Icinga Check Name              | `check_jitsi_videobridge_status` |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |


## Help

```text
usage: jitsi-videobridge-status [-h] [-V] [--always-ok] [--insecure]
                                [--no-proxy] [-p PASSWORD]
                                [--severity {warn,crit}] [--test TEST]
                                [--timeout TIMEOUT] [--url URL]
                                [--username USERNAME]

Checks the Jitsi Videobridge health state via the /about/health REST endpoint.
Returns OK if the bridge is healthy, WARN or CRIT otherwise.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --no-proxy            Do not use a proxy.
  -p, --password PASSWORD
                        Jitsi API password.
  --severity {warn,crit}
                        Severity for alerting. Default: warn
  --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                        stderr-file,expected-retc".
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
  --url URL             Jitsi API URL. Default: http://localhost:8080
  --username USERNAME   Jitsi API username. Default: None
```


## Usage Examples

```bash
./jitsi-videobridge-status --severity warn
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
