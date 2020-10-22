# Check "sensors-battery" - Overview

Return battery status information. If no battery is installed or metrics can’t be determined OK is returned.

We recommend to run this check every minute.


# Installation and Usage

Requirements:
* Python2 psutil

```bash
./sensors-battery --warning 20 --critical 5
./sensors-battery --help
```


# States

* WARN or CRIT if battery power left as % is below a given threshold.


# Perfdata

* battery power as a percentage (%)


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.
* Credits: https://github.com/giampaolo/psutil/blob/master/scripts/battery.py
