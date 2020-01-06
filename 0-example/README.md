# Overview

The check is just a development template. What else does the check do?

* OS Packages required: none/on CentOS: `hello_world`
* Tested on OS: CentOS 7 Minimal, Fedora 30, Fedora 31
* Tested with Monitoring Tool: Icinga2
* Python libs required: None

Features:
* Auto Discovery: yes/no
* Runs without arguments: yes/no
* Takes time periods into account: yes/no
* Uses temporary files: yes/no

Hints and Recommendations:
* Running this check just makes sense on hardware, especially with (S)ATA disks.
* Run this check every 8h.


# Installation and Usage

Requirements: `yum install smartmontools python2-psutil`

```bash
./example
./example --ignore sdd,sdbx,mmcblk0
./example --help
```


# States

* CRIT: never
* WARN: if ... >= > < <= ...
* UNKNOWN: when temporary file is empty or can't be read 


# Known Issues and Limitations

...


# Contents

* README.md: This file.
* LICENSE: The license file.

* example: The service check in source code format.
* example.basket.json: The Icinga Director Basket Configuration file for this service.
* example.grafana.json: The panel file in JSON format for any Grafana dashboard.
* example.icingaweb2-grafana.ini: The .ini file for the Icingaweb2 Grafana Module.
* example.png: The 16x16 black icon for the service check.
* example.sudoers: The sudoers file for the service check.


# Changelog

* 2019213101: Initial release.


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.
* Credits:
  * This tool, written in C++ (https://this.tool/): We re-implemented the logic in Python and copied the excellent output.
