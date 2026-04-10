# Check dhcp-relayed

## Overview

This plugin tests if a local or remote DHCP server can offer IPv4 addresses (to a specific subnet). It emulates a DHCP client and checks the DHCP offer response from the DHCP server. It only sends a DHCPDISCOVER, not a DHCPREQUEST.

Hints:

* May take three or more seconds to run.
* Requires sudo permissions to open and listen on port 68/udp. Therefore, the machine running this plugin must not be running a dhcp client listening on port 68/udp, like `systemd-networkd` for example.
* Uses standard UDP sockets instead of raw sockets, so this plugin needs to run on a machine that actually has a fixed IP address.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/dhcp-relayed> |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |


## Help

```text
usage: dhcp-relayed [-h] [-V] [--always-ok] [--bind-address BIND_ADDRESS]
                    [-H HOSTNAME] [--mac MAC] [--subnet-mask SUBNET_MASK]
                    [--subnet-selection SUBNET_SELECTION] [--timeout TIMEOUT]

Tests if a DHCP server can offer IPv4 addresses by emulating a DHCP client.
Sends a DHCPDISCOVER packet and verifies that the server responds with a valid
DHCPOFFER. Only performs the discovery step without requesting an actual lease
(no DHCPREQUEST). Works with both local and relayed DHCP servers, and can
target a specific subnet. Alerts if the server does not respond or the
response is invalid. Requires root or sudo.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --bind-address BIND_ADDRESS
                        Local address to bind the socket to. Default: 0.0.0.0
  -H, --hostname HOSTNAME
                        DHCP server address, hostname or IP address. If
                        omitted, the request is sent as broadcast. Default:
                        None
  --mac MAC             Network MAC address to use in the DHCP request. Does
                        not have to be an existing MAC address. Use
                        `--mac=random` for a random MAC address. If omitted,
                        the local hardware address is used.
  --subnet-mask SUBNET_MASK
                        Subnet mask for the DHCP request. Example:
                        `255.255.255.248`. Default: None
  --subnet-selection SUBNET_SELECTION
                        Override the DHCP server subnet selection for address
                        allocation (RFC 3011). Example: `192.168.122.0`.
                        Default: None
  --timeout TIMEOUT     Network timeout in seconds. Default: 7 (seconds)
```


## Usage Examples

```bash
./dhcp-relayed
./dhcp-relayed --mac=random
./dhcp-relayed --mac=80:32:15:12:34:AB
./dhcp-relayed --mac=8032151234AB
./dhcp-relayed --bind-address=192.0.2.74 --hostname=192.168.122.1 --subnet-mask=255.255.0.0 --subnet-selection=192.168.122.0
```

Output:

```text
DHCPOFFER: IP=192.168.122.99/255.255.255.0 Server ID=192.168.122.1 Broadcast Addr=192.168.122.255
DHCPDISCOVER: MAC=52540024b33a Host=192.168.122.1 Network=192.168.122.0/255.255.0.0
```


## States

* WARN if a "Socket timeout" occurs, perhaps because the DHCP pool is exhausted, does not exist, or similar.
* WARN if the returned IP address is 0.0.0.0.


## Perfdata / Metrics

There is no perfdata.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)

* License: The Unlicense, see [LICENSE file](https://unlicense.org/).

* Credits:  
  - inspired by [check_dhcp_relayed](https://exchange.nagios.org/directory/Plugins/Network-Protocols/DHCP-and-BOOTP/check_dhcp_relayed/details)
  - inspired by <https://code.activestate.com/recipes/577649-dhcp-query/>
