# Check "sensors-temperatures" - Overview

Return certain hardware temperature sensors (it may be a CPU, an hard disk or something else, depending on the OS and its configuration). All temperatures are expressed in celsius. Check is done automatically against hardware thresholds. If sensors are not supported by the OS OK is returned.

We recommend to run this check every minute.


# Installation and Usage

Requirements:
* Python2 psutil

```bash
./sensors-temperatures
./sensors-temperatures --help
```


# States

* WARN or CRIT if temperature for a sensor is above a given hardware threshold (automatically).


# Perfdata

* temperature for each sensor found (°C)


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.
* Credits: https://github.com/giampaolo/psutil/blob/master/scripts/temperatures.py
