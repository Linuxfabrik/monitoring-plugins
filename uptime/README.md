# Overview

Checks and tells how long the system has been running (in days).

We recommend to run this check every 5 minutes.


# Installation and Usage

Requirements:
* Python2 module `psutil`

```bash
./uptime
./uptime --always-ok
./uptime --warning 180 --critical 366
./uptime --help
```


# States and Perfdata

* WARN or CRIT if system uptime is above a given threshold.


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.