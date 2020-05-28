# Check "fortios-version" - Overview

This plugin lets you track if an FortiOS update for a Forti Appliance like FortiGate is available, using the FortiOS REST API

We recommend to run this check once a day.


# Installation and Usage

```bash
./fortios-version --hostname fortigate-cluster.linuxfabrik.io --password sSEaTjuNbPYW5yepUD2JtDhyykY59D
./fortios-version --help
```


# States

* If wanted, always returns OK,
* else returns WARN if update is available.


# Perfdata

There is no perfdata.


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.
