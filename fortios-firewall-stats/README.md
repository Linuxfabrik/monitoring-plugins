# Check "fortios-firewall-stats" - Overview

Summarizes traffic statistics for all IPv4 and IPv6 firewall policies from Forti Appliances like FortiGate running FortiOS via FortiOS REST API. The authentication is done via a single API token (Token-based authentication), not via Session-based authentication, which is stated as "legacy".

We recommend to run this check every minute.


# Installation and Usage

```bash
./fortios-firewall-stats --hostname fortigate-cluster.linuxfabrik.io --password sSEaTjuNbPYW5yepUD2JtDhyykY59D
./fortios-firewall-stats --help
```


# States

* Always returns OK.


# Perfdata

For example:

* total_active_sessions
* total_asic_bytes
* total_bytes
* total_hit_count
* total_nturbo_bytes
* total_session_count
* total_software_bytes


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.
