# Check "qts-memory-usage" - Overview

Returns the current system-wide memory utilization as a percentage from a QNAP Appliance running QTS, using the HTTP API.

We recommend to run this check every minute.


# Installation and Usage

```bash
./qts-memory-usage --url http://192.168.1.100:8080 --username admin --password my-password
./qts-memory-usage --help
```


# States

* OK if overall `memory-usage` is below the thresholds.
* Otherwise CRIT or WARN.


# Perfdata

* `memory-usage`: The overall memory usage.
* `free`: The free memory.
* `total`: The total memory.
* `used`: The used memory.


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.
