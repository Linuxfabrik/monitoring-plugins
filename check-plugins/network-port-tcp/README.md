# Check network-port-tcp

## Overview

Checks whether a TCP network port is reachable by attempting to establish a connection. Useful for monitoring service availability from the network perspective.

**Data Collection:**

* Attempts a TCP socket connection to the specified host and port
* Supports both IPv4 (`tcp`) and IPv6 (`tcp6`) via the `--type` parameter

**Compatibility:**

* Cross-platform: Linux, Windows

**Important Notes:**

* This check works with TCP connections only. UDP port responses depend on the target application (e.g. DNS or OpenVPN) and are not standardized like TCP.


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/network-port-tcp> |
| Nagios/Icinga Check Name              | `check_network_port_tcp` |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | Yes |


## Help

```text
Traceback (most recent call last):
  File "/home/markusfrei/git/linuxfabrik/github/monitoring-plugins/check-plugins/network-port-tcp/network-port-tcp", line 141, in 'module'
    main()
    ~~~~^^
  File "/home/markusfrei/git/linuxfabrik/github/monitoring-plugins/check-plugins/network-port-tcp/network-port-tcp", line 105, in main
    args = parse_args()
  File "/home/markusfrei/git/linuxfabrik/github/monitoring-plugins/check-plugins/network-port-tcp/network-port-tcp", line 72, in parse_args
    help=lib.args.help('--severity') + ' Default: %(default)s',
         ^^^^^^^^
AttributeError: module 'lib' has no attribute 'args'
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
