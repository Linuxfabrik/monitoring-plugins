# Overview

The check calls `ipmitool sensor list` locally to fetch detailed sensor
information.

* Tested on OS: CentOS 7 Minimal, Fedora 30, Fedora 31
* Tested with Monitoring Tool: Icinga2

Features:
* Auto Discovery: no
* Default Thresholds: yes (as stated from IPMI)
* Takes time periods into account: no
* Uses temporary files: no

Hints and Recommendations:
* Running this check just makes sense on hardware using an IPMI interface.
* We recommend running this check every 5 minutes.


# Installation and Usage

Requirements: `yum install ipmitools`

```bash
./ipmi-sensor
./ipmi-sensor --help
```


# States

* CRIT, if sensor value is non-recoverable (very worse)
* CRIT, if sensor value is above/below IPMI critical threshold
* WARN, if sensor value is above/below IPMI non-critical threshold
* UNKNOWN on `ipmitool` not found or errors running `ipmitool`.


# Known Issues and Limitations

* The check has to run locally and can't login remotely into an IPMI interface.
* "Discrete" sensors support is not implemented.


# Contents

* README.md: This file.
* LICENSE: The license file.

* ipmi-sensor: The service check in source code format.
* ipmi-sensor.basket.json: The Icinga Director Basket Configuration file for this service.
* ipmi-sensor.grafana.json: The panel file in JSON format for any Grafana dashboard.
* ipmi-sensor.icingaweb2-grafana.ini: The .ini file for the Icingaweb2 Grafana Module.
* ipmi-sensor.png: The 16x16 black icon for the service check.
* ipmi-sensor.sudoers: The sudoers file for the service check.

* examples: Some output files from `ipmitool sensor list`.


# Changelog

* 2019120601: Initial release.


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.

