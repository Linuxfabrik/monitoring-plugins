# Check "dmesg" - Overview

Checks emerg, alert, crit and err messages in dmesg, and therefore always returns CRIT if something was found. This check does not need any arguments.

Some very common dmesg messages are ignored, for example `Assuming drive cache: write through` (should be a debug message) or `ioctl error in smb2_get_dfs_refer rc=-5` (a bug as stated in https://access.redhat.com/solutions/3496971).

We recommend to run this check every minute.


# Installation and Usage

```bash
./dmesg --help
```


# States

* CRIT if any of (filtered) emerg, alert, crit and err messages in dmesg are found.


# Perfdata

There is no perfdata.


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.
