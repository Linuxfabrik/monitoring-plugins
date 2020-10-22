# Check "qts-uptime" - Overview

Checks and tells how long the system has been running (in days).

We recommend to run this check every 5 minutes.


# Installation and Usage

```bash
./qts-uptime --url http://192.168.1.100:8080 --username admin --password my-password
./qts-uptime --help
```


# States

* WARN or CRIT if system uptime is above a given threshold.


# Perfdata

* Uptime (seconds)


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.
