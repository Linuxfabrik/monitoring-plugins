# Check "fortios-network-io" - Overview

This plugin checks network I/O and link states on all interfaces found on a Forti Appliance like FortiGate running FortiOS, using the FortiOS REST API. Warns on link up/down, speed or duplex change as well as bandwidth saturation. The authentication is done via a single API token (Token-based authentication), not via Session-based authentication, which is stated as "legacy".

Hints and Recommendations:
* `--count=5` (the default) while checking every minute means that the check reports a warning if any interface was above a threshold in the last 5 minutes.
* Check needs `count` runs to warm up its caches.
* Check uses a SQLite database in `/tmp` to store its historical data.
* The check inventorizes your appliance. If you change any of Forti's interfaces, and you want to reset the check's warnings about this, simply delete its `fortios-network-io.db` file.

We recommend to run this check every minute.


# Installation and Usage

```bash
./fortios-network-io --hostname fortigate-cluster.linuxfabrik.io --password sSEaTjuNbPYW5yepUD2JtDhyykY59D
./fortios-network-io --hostname fortigate-cluster.linuxfabrik.io --password sSEaTjuNbPYW5yepUD2JtDhyykY59D --count 5 --warning 800000000 --critical 900000000
./fortios-network-io --help
```


# States

* WARN or CRIT, if network I/O (bps) is greater or equal a given threshold
* WARN, if link state, speed rate or duplex mode for an interface changes


# Perfdata

Depends on your hardware. Example:

* modem_rx1: Received bytes on this interface since the last check
* modem_tx1: Sent bytes since the last check
* modem_rxn: Received bytes since the last n checks (default: 5)
* modem_txn: Sent bytes since the last n checks
* ...


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.