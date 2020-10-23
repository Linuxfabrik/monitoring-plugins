# Check "sensors-fans" - Overview

Return hardware fans speed. Fan speed is expressed in RPM (rounds per minute). OK if no fans are found.

We recommend to run this check every minute.


# Installation and Usage

Requirements:
* Python2 psutil

```bash
./sensors-fans --warning 10000 --critical 20000
./sensors-fans --help
```


# States

* WARN or CRIT if fan speed (RPM) is above a given threshold.


# Perfdata

* for each fan: its speed (RPM)


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.
* Credits: https://github.com/giampaolo/psutil/blob/master/scripts/fans.py
