# Check "fortios-cpu-usage" - Overview

Returns the current system-wide CPU utilization as a percentage from Forti Appliances like FortiGate running FortiOS via FortiOS REST API. Warns only if the overall CPU usage is above a certain threshold within the last n checks (default: 5). The authentication is done via a single API token (Token-based authentication), not via Session-based authentication, which is stated as "legacy".

Hints and Recommendations:
* This plugin tries to check against the global configured `cpu-use-threshold` first; only if there is no value, the check's command line values are used.
* `--count=5` (the default) while checking every minute means that the check reports a warning if the overall CPU usage is above a threshold in the last 5 minutes.
* Check uses a SQLite database in `/tmp` to store its historic data.

We recommend to run this check every minute.


# Installation and Usage

```bash
./fortios-cpu-usage --hostname fortigate-cluster.linuxfabrik.io --password sSEaTjuNbPYW5yepUD2JtDhyykY59D --count=15 --warning=50 --critical=70
./fortios-cpu-usage --help
```


# States

* OK if overall `cpu-usage` is below the thresholds within the last `--count` checks.
* Otherwise CRIT or WARN.


# Perfdata

* `cpu-usage`: The overall cpu usage.


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.