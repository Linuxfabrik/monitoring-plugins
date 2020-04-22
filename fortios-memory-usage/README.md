# Check "fortios-memory-usage" - Overview

Returns the current system-wide memory utilization as a percentage from Forti Appliances like FortiGate running FortiOS via FortiOS REST API. The authentication is done via a single API token (Token-based authentication), not via Session-based authentication, which is stated as "legacy".

Hints and Recommendations:
* This plugin tries to check against the global configured `memory-use-threshold-green` and `memory-use-threshold-red` first; only if there is no value, the check's command line values are used.

We recommend to run this check every minute.


# Installation and Usage

```bash
./fortios-memory-usage --hostname fortigate-cluster.linuxfabrik.io --password sSEaTjuNbPYW5yepUD2JtDhyykY59D --warning=50 --critical=70
./fortios-memory-usage --help
```


# States

* OK if overall `memory-usage` is below the thresholds.
* Otherwise CRIT or WARN.


# Perfdata

* `usage_percent`: The overall memory usage.


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.