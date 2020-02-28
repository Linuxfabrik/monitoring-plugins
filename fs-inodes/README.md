# Overview

Checks the used inode space in percent, default on `/`, `/tmp` and `/boot`.

We recommend to run this check every minute.


# Installation and Usage

```bash
./fs-inodes
./fs-inodes --mount '/, /boot, /tmp' --warning 90 --critical 95
./fs-inodes --help
```


# States and Perfdata

* WARN or CRIT if inode usage is above a given threshold.

Perfdata (for each mount):

* inode usage (%)


# Known Issues and Limitations

* `--mount` parameter is currently csv based and not repeatable.


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.