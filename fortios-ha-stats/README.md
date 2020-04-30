# Check "fortios-ha-stats" - Overview

Returns statistics for members of HA cluster from Forti Appliances like FortiGate running FortiOS via FortiOS REST API. Warns if the number of HA members is more or less than expected (default: 2). The authentication is done via a single API token (Token-based authentication), not via Session-based authentication, which is stated as "legacy".

We recommend to run this check every minute.


# Installation and Usage

```bash
./fortios-ha-stats --hostname fortigate-cluster.linuxfabrik.io --password sSEaTjuNbPYW5yepUD2JtDhyykY59D --count 2
./fortios-ha-stats --help
```


# States

* If wanted, always returns OK,
* else returns WARN if there are more or less cluster members than expected.


# Perfdata

For example:

* node1_sessions
* node1_net_usage
* node1_tbyte
* node1_cpu_usage
* node1_mem_usage
* node2_sessions
* node2_net_usage
* node2_tbyte
* node2_cpu_usage
* node2_mem_usage



# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.
