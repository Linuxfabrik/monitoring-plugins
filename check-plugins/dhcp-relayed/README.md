# Check dhcp-relayed

## Overview

Tests if a DHCP server can offer IPv4 addresses by emulating a DHCP client. Sends a DHCPDISCOVER packet and verifies that the server responds with a valid DHCPOFFER. Only performs the discovery step without requesting an actual lease (no DHCPREQUEST). Works with both local and relayed DHCP servers, and can target a specific subnet. Alerts if the server does not respond or the response is invalid. Requires root or sudo.

**Data Collection:**

* Constructs and sends a DHCPDISCOVER UDP packet on port 68 (client) to port 67 (server)
* If `--hostname` is specified, sends to that address; otherwise sends as broadcast
* Supports DHCP option 1 (Subnet Mask) and option 118 (Subnet Selection, RFC 3011) for targeting specific subnets
* Waits for a DHCPOFFER response matching the transaction ID
* Extracts the offered IP address, server ID, subnet mask, and broadcast address from the response

**Compatibility:**

* Linux (requires root or sudo to bind to port 68/udp)

**Important Notes:**

* May take three or more seconds to run depending on the DHCP server's response time
* The machine running this plugin must not have a DHCP client listening on port 68/udp (for example `systemd-networkd`)
* Uses standard UDP sockets (not raw sockets), so the machine must have a fixed IP address
* The MAC address can be specified (`--mac`), randomized (`--mac=random`), or auto-detected from the local hardware


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/dhcp-relayed> |
| Nagios/Icinga Check Name              | `check_dhcp_relayed` |
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

* OK if the DHCP server responds with a valid DHCPOFFER containing a non-zero IP address.
* WARN if the offered IP address is `0.0.0.0`.
* WARN if a socket timeout occurs (the DHCP pool may be exhausted, may not exist, or similar).
* UNKNOWN on permission errors (missing root/sudo), OS errors, or invalid `--subnet-mask`/`--subnet-selection` values.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

There is no perfdata.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
* Credits:
  - inspired by [check_dhcp_relayed](https://exchange.nagios.org/directory/Plugins/Network-Protocols/DHCP-and-BOOTP/check_dhcp_relayed/details)
  - inspired by <https://code.activestate.com/recipes/577649-dhcp-query/>
