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

We recommend to run this check every 15 minutes.


# Installation and Usage

Requirements:
* `ipmitools`

```bash
./ipmi-sensor
./ipmi-sensor --help
```


# States and Perfdata

* CRIT, if sensor value is non-recoverable (very worse)
* CRIT, if sensor value is above/below IPMI critical threshold
* WARN, if sensor value is above/below IPMI non-critical threshold
* UNKNOWN on `ipmitool` not found or errors running `ipmitool`.


# Known Issues and Limitations

* The check has to run locally and can't login remotely into an IPMI interface.
* "Discrete" sensors support is not implemented.


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.
