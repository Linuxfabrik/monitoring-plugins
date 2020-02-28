# Check "network-port-tcp" - Overview

Checks whether a network port is reachable.

We recommend to run this check every minute.


# Installation and Usage

```bash
./network-port-tcp
./network-port-tcp --port 22
./network-port-tcp --hostname www.google.ch --port 443 --portname https --timeout 1.3 --state warn
./network-port-tcp --help
```


# States

* WARN (default) or CRIT if port is unreachable.


# Perfdata

There is no perfdata.


# Known Issues and Limitations

* The check works fine for tcp connections, but not for udp. The port response for udp is based on the target application (for example DNS or OpenVPN) and is not standard like tcp.


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.