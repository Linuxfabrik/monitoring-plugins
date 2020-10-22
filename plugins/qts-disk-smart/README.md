# Check "qts-disk-smart" - Overview

Checks the disk SMART values returned by QTS. This check does not run SMART itself. In order to get the latest values, schedule the in-built SMART check in the QTS webinterface.

We recommend to run this check every day.


# Installation and Usage

```bash
./qts-disk-smart --url http://192.168.1.100:8080 --username admin --password my-password
./qts-disk-smart --help
```


# States

* OK if all disks `disk-smart` are ok.
* Otherwise WARN.


# Perfdata

* Temperatures


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.
