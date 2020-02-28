# Overview

The check calls `ipmitool sensor list` to fetch detailed sensor information. Running this check just makes sense on hardware using an IPMI interface. Needs sudo.

We recommend to run this check every 15 minutes.


# Installation and Usage

Requirements:
* `ipmitool`

```bash
./ipmi-sensor
./ipmi-sensor --help
```


# States and Perfdata

* CRIT, if sensor value is non-recoverable (very worse).
* CRIT, if sensor value is above/below critical threshold given by IPMI.
* WARN, if sensor value is above/below IPMI non-critical threshold.
* UNKNOWN on `ipmitool` not found or errors running `ipmitool`.


# Known Issues and Limitations

* The check has to run locally and can't login remotely into an IPMI interface.
* "Discrete" sensors support is not implemented.


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.