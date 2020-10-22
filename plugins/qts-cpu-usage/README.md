# Check "qts-cpu-usage" - Overview

Returns the current system-wide CPU utilization as a percentage from a QNAP Appliance running QTS, using the HTTP API. Warns only if the overall CPU usage is above a certain threshold within the last n checks (default: 5).

Hints and Recommendations:
* `--count=5` (the default) while checking every minute means that the check reports a warning if the overall CPU usage is above a threshold in the last 5 minutes.
* Check uses a SQLite database in `/tmp` to store its historical data.

We recommend to run this check every minute.


# Installation and Usage

```bash
./qts-cpu-usage --url http://192.168.1.100:8080 --username admin --password my-password
./qts-cpu-usage --help
```


# States

* OK if overall `cpu-usage` is below the thresholds within the last `--count` checks.
* Otherwise CRIT or WARN.


# Perfdata

* `cpu-usage`: The overall cpu usage.


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.
