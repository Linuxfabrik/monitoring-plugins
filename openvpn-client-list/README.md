# Check "openvpn-client-list" - Overview

Prints a list of all clients connected to the OpenVPN Server, and optionally checks their number against thresholds. Fetches the info from `/var/log/openvpn-status.log` (default). Needs sudo.

We recommend to run this check every 5 minutes.


# Installation and Usage

```bash
./openvpn-client-list
./openvpn-client-list --warning 20 --critical 100 --filename /var/log/openvpn-status.log
./openvpn-client-list --help
```


# States

* WARN or CRIT if number of connected users is above a given threshold.


# Perfdata

* Number of clients connected.


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.