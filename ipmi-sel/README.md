# Overview

The check calls `ipmitool sel elist` to fetch the IPMI System Event Log (SEL). If there are entries, it returns a warning, otherwise everything is expected to be OK. Running this check just makes sense on hardware providing an IPMI interface. Needs sudo.

We recommend to run this check every 15 minutes.


# Installation and Usage

Requirements:
* `ipmitool`

```bash
./ipmi-sel
./ipmi-sel --help
```


# States and Perfdata

* WARN, if SEL has entries.
* UNKNOWN on `ipmitool` not found or errors running `ipmitool`.

There is no perfdata.


# Known Issues and Limitations

* The check has to run locally and can't login remotely into an IPMI interface.


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.