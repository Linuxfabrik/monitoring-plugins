# Overview

The check warns before an expiration date of one or more events is scheduled to occur. For example, `./countdown --input='Fileserver Hardware, 2025-02-02, 60, 30'` returns WARN/CRIT 60/30 days before 2025-02-02, otherwise OK.

* OS Packages required: none
* Tested on OS: CentOS 7 Minimal, Fedora 30, Fedora 31
* Tested with Monitoring Tool: Icinga2
* Python libs required: None

Features:
* Auto Discovery: no
* Runs without arguments: no
* Takes time periods into account: no
* Uses temporary files: no

Hints and Recommendations:
* Run this check every 24h.


# Installation and Usage

Use `./countdown --input='<Event Name>, <yyyy-mm-dd>, <WARN days before>, <CRIT days before>'`.

```bash
./countdown --input='Fileserver Hardware, 2025-02-02, 60, 30'
./countdown --input='Contract A, 2023-12-31, 60, None; Contract B, 2024-12-31, 30, 14;'
./countdown --help
```


# States

For each tuple:
* CRIT: if event is <= days away; 'None' means that CRIT is never returned
* WARN: if event is <= days away; 'None' is not possible


# Known Issues and Limitations

-


# Changelog

* 2019123101: Initial release.


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.
