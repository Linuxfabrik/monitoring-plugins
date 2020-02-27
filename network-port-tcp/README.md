# Overview

We recommend to run this check every minute.

Limitations:
* Works only for TCP connections: The check Works fine for tcp connections, but not for udp. The port response for udp is based on the target application (for example, DNS or OpenVPN) and is not standard like tcp.

./network-port-tcp
./network-port-tcp --port=22
./network-port-tcp --hostname=www.google.ch --port=443 --portname=https --timeout=1.3 --state=warn


# Installation and Usage

```bash
./0-example --help
```


# States and Perfdata

There is no perfdata.


# Known Issues and Limitations


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.