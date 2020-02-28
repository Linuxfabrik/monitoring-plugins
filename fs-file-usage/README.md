# Overview

Checks the number of files opened (found in `/proc/sys/fs/file-nr`), in percent.

We recommend to run this check every minute.


# Installation and Usage

```bash
./fs-file-usage --warning 90 --critical 95
./fs-file-usage --help
```


# States and Perfdata

* WARN or CRIT if file usage is above a given threshold.

Perfdata:

* File Usage (%)


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.