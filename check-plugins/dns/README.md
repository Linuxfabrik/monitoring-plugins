# Check "dns" - Overview

Performs a DNS lookup and converts a hostname to one or more IP addresses. Only the name servers configured on the machine running this check plugin (for example those visible in `/etc/resolv.conf`) will be queried - you can't query other DNS servers. When no arguments or options are given, the check tries to resolve "localhost", and the full range of results for any available protocol is returned.

This command works with both IPv4 and IPv6.

We recommend to run this check every 15 minutes.


# Installation and Usage

```bash
./dns
./dns --hostname $(hostname)
./dns --hostname www.example.org --type udp --port 53
./dns --hostname www.example.org --type tcp6 --port 80 --warning 1000 --critical 5000
./dns --help
```


# States

* WARN on socket errors, address related errors, network timeouts.
* WARN or CRIT if you provide thresholds for the DNS lookup time duration.
* Otherwise OK.


# Perfdata

* time: DNS lookup time


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.