# Check dns


## Overview

Performs a DNS lookup and resolves a hostname to one or more IP addresses. Queries the name servers configured on the local machine (e.g. those listed in /etc/resolv.conf). Measures and alerts on the lookup response time. Works with both IPv4 and IPv6.

**Data Collection:**

* Uses Python's `socket.getaddrinfo()` to perform DNS resolution
* Only the name servers configured on the machine running this check are queried - you cannot query other DNS servers
* When no arguments are given, the check tries to resolve `localhost` on port 53, and the full range of results for any available protocol is returned
* The connection type can be narrowed down using `--type` (udp, udp6, tcp, tcp6)

**Compatibility:**

* Cross-platform


## Fact Sheet

| Fact | Value |
|----|----| 
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/dns> |
| Nagios/Icinga Check Name              | `check_dns` |
| Check Interval Recommendation         | Every 15 minutes |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | Yes |


## Help

```text
usage: dns [-h] [-V] [--always-ok] [-c CRIT] [-H HOSTNAME] [-p PORT]
           [--type {udp,udp6,tcp,tcp6}] [-w WARN]

Performs a DNS lookup and resolves a hostname to one or more IP addresses.
Queries the name servers configured on the local machine (e.g. those listed in
/etc/resolv.conf). Measures and alerts on the lookup response time. Works with
both IPv4 and IPv6.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  -c, --critical CRIT   CRIT threshold for DNS lookup time in milliseconds.
                        Default: None
  -H, --hostname HOSTNAME
                        Hostname or IP address to resolve. Default: localhost
  -p, --port PORT       Port number to query. Default: 53
  --type {udp,udp6,tcp,tcp6}
                        Connection type to narrow the list of returned
                        addresses.
  -w, --warning WARN    WARN threshold for DNS lookup time in milliseconds.
                        Default: None
```


## Usage Examples

```bash
./dns --hostname $(hostname)
./dns --hostname www.example.org --type udp --port 53 --warning 1000 --critical 5000
```

Output:

```text
Lookup for webserver.linuxfabrik.ch returns 192.168.26.43 (tcp4:53), 192.168.26.43 (udp4:53), 192.168.26.43 (ip4:53)
```


## States

* OK if the hostname resolves successfully and the lookup time is below the thresholds.
* WARN on socket errors, address-related errors, or network timeouts.
* WARN if the DNS lookup time is >= `--warning`.
* CRIT if the DNS lookup time is >= `--critical`.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| time | Seconds | DNS lookup time in milliseconds. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
