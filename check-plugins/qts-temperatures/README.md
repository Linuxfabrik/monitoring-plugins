# Check "qts-temperatures" - Overview

Returns system and CPU temperatures. All temperatures are expressed in celsius.

We recommend to run this check every minute.


# Installation and Usage

```bash
./qts-temperatures --url http://192.168.1.100:8080 --username admin --password my-password
./qts-temperatures --help
```


# States

* WARN or CRIT if temperature for a sensor is above the given thresholds.


# Perfdata

* temperature for system and CPU (°C)


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.
