# Overview

The check calls `ipmitool sel elist` locally to fetch the IPMI System Event Log
(SEL). If there are entries, it throws a warning, otherwise everything is
expected to be OK.

* Tested on OS: CentOS 7 Minimal, Fedora 30, Fedora 31
* Tested with Monitoring Tool: Icinga2

Features:
* Auto Discovery: no
* Default Thresholds: no (does not use any thresholds at all)
* Takes time periods into account: no
* Uses temporary files: no

Hints and Recommendations:
* Running this check just makes sense on hardware using an IPMI interface.
* We recommend running this check every 15 minutes.


# Installation and Usage

Requirements: `yum install ipmitools`

```bash
./ipmi-sel
./ipmi-sel --help
```


# States

* WARN, if SEL has entries.
* UNKNOWN on `ipmitool` not found or errors running `ipmitool`.


# Known Issues and Limitations

* The check has to run locally and can't login remotely into an IPMI interface.


# Contents

* README.md: This file.
* LICENSE: The license file.

* ipmi-sel: The service check in source code format.
* ipmi-sel.basket.json: The Icinga Director Basket Configuration file for this service.
* ipmi-sel.grafana.json: The panel file in JSON format for any Grafana dashboard.
* ipmi-sel.icingaweb2-grafana.ini: The .ini file for the Icingaweb2 Grafana Module.
* ipmi-sel.png: The 16x16 black icon for the service check.
* ipmi-sel.sudoers: The sudoers file for the service check.

* examples: Some output files from `ipmitool sel list`.


# Changelog

* 2019120601: Initial release.


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.
