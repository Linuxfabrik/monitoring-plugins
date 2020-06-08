# Check "network-bonding" - Overview

Reports the state of all channel bonding interfaces. Channel bonding enables two or more network interfaces to act as one, simultaneously increasing the bandwidth and providing redundancy.

We recommend to run this check every minute.


# Installation and Usage

```bash
./network-bonding
./network-bonding --help
```


# States

* WARN if any interface in a bonding interface is not up, or if there are warnings considering the configuration.


# Perfdata

* `link_failure_count` (for each interface)


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.
