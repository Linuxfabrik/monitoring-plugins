# Check network-port-tcp


## Overview

Checks whether a TCP network port is reachable by attempting to establish a connection. Useful for monitoring service availability from the network perspective.

**Important Notes:**

* This check works with TCP connections only. UDP port responses depend on the target application (e.g. DNS or OpenVPN) and are not standardized like TCP.

**Data Collection:**

* Attempts a TCP socket connection to the specified host and port
* Supports both IPv4 (`tcp`) and IPv6 (`tcp6`) via the `--type` parameter


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/network-port-tcp> |
| Nagios/Icinga Check Name              | `check_network_port_tcp` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | Yes |


## Help

```text
usage: network-port-tcp [-h] [-V] [-H HOSTNAME] [-p PORT]
                        [--portname PORTNAME] [--severity {warn,crit}]
                        [-t TIMEOUT] [--type {tcp,tcp6}]

Checks whether a TCP network port is reachable by attempting to establish a
connection. Measures and reports the connection time. Useful for monitoring
service availability from the network perspective. Alerts if the port is
unreachable or the connection time exceeds the configured thresholds.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  -H, --hostname HOSTNAME
                        Host or IP address to check. Default: localhost
  -p, --port PORT       TCP port number to check. Default: 22
  --portname PORTNAME   Human-readable display name for the port in the output
                        message. Example: `--portname https`.
  --severity {warn,crit}
                        Severity for alerting. Default: warn
  -t, --timeout TIMEOUT
                        Network timeout in seconds. Default: 2
  --type {tcp,tcp6}     Connection type, "tcp" for IPv4 or "tcp6" for IPv6.
                        Default: tcp
```


## Usage Examples

```bash
./network-port-tcp --hostname www.linuxfabrik.ch --port 443 --portname https --timeout 1.3 --severity warn
```

Output:

```text
www.linuxfabrik.ch:https/tcp is reachable.
```


## States

* OK if the port is reachable.
* WARN (default) or CRIT (via `--severity`) if the port is unreachable.
* UNKNOWN if the connection cannot be initiated (e.g. DNS resolution failure).


## Perfdata / Metrics

There is no perfdata.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
