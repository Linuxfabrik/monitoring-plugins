# Overview

Checks the used inode space in percent, default on "/", "/tmp" and "/boot".

We recommend to run this check every minute.


# Installation and Usage

```bash
./fs-inodes
./fs-inodes --mount '/, /boot, /tmp'
./fs-inodes --help
```


# States and Perfdata

tbd


# Known Issues and Limitations

* `--mount` parameter is csv based, not repeatable.


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.