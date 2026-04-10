# Check network-bonding

## Overview

Reports the state of network bonding (channel bonding) interfaces. Checks that all slave interfaces are active and that the bonding mode and link status are healthy. Channel bonding allows two or more network interfaces to act as one, increasing bandwidth and providing redundancy. Requires root or sudo.

**Data Collection:**

* Reads bonding interface status from `/proc/net/bonding/`
* Parses MII status, link failure count, bonding mode, and partner MAC address for each bond and its slave interfaces

**Compatibility:**

* Linux


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/network-bonding> |
| Nagios/Icinga Check Name              | `check_network_bonding` |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |


## Help

```text
usage: network-bonding [-h] [-V] [--always-ok] [--test TEST]

Reports the state of network bonding (channel bonding) interfaces. Checks that
all slave interfaces are active and that the bonding mode and link status are
healthy. Channel bonding allows two or more network interfaces to act as one,
increasing bandwidth and providing redundancy. Alerts when any slave interface
is down or the bond is degraded. Requires root or sudo.

options:
  -h, --help     show this help message and exit
  -V, --version  show program's version number and exit
  --always-ok    Always returns OK.
  --test TEST    For unit tests. Needs "path-to-bonding-file". Example:
                 `--test /tmp/bond0`.
```


## Usage Examples

```bash
./network-bonding
```

Output:

```text
One or more errors.

* [WARNING] bond0 (IEEE 802.3ad Dynamic link aggregation)
    * Could not detect the MAC Address of the switch. This could indicate that LACP is not configured properly.
```


## States

* OK if all bonding interfaces and their slaves are healthy.
* WARN if any slave interface in a bond is not up.
* WARN if LACP partner MAC address cannot be detected.
* UNKNOWN if no bonding interfaces are found.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| \<bond\>\_\<slave\>\_link_failure_count | Number | Link failure count per slave interface. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
