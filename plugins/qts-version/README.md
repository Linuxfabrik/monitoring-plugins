# Check "qts-version" - Overview

This plugin lets you track if a QTS update is available. To check for updates, this plugin requests the in-built update check of the appliance.

We recommend to run this check once a day.

# Installation and Usage

```bash
./qts-version --url http://192.168.1.100:8080 --username admin --password my-password
./qts-version --help
```


# States

* If wanted, always returns OK,
* else returns WARN if update is available.


# Perfdata

There is no perfdata.


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.
