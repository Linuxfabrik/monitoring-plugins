# Check "fs-ro" - Overview

The fs-ro plugin checks for read only mount points, for example like `/` mounted read only due to filesystem errors, mounted CD-ROMs or ISO files etc.

We recommend to run this check every 15 minutes.


# Installation and Usage

```bash
./fs-ro
./fs-ro --ignore /proc,/sys/fs
./fs-ro --help
```


# States

* WARN if a read only mount point is found (which is not on the ignore list).


# Perfdata

There is no perfdata.


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.
