# Check "dmesg" - Overview

Checks emerg, alert, crit and err messages in dmesg, and unless the `--severity` parameter is ommitted, always returns CRIT if something was found.

Some very common dmesg messages are ignored, for example `Assuming drive cache: write through` (should be a debug message) or `ioctl error in smb2_get_dfs_refer rc=-5` (a bug as stated in https://access.redhat.com/solutions/3496971).

Be aware that the reported timestamps could be inaccurate. The time source used for dmesg is not updated after system SUSPEND/RESUME. Timestamps are adjusted according to current delta between boottime and monotonic clocks, this works only for messages printed after last resume.

We recommend to run this check every minute.


# Installation and Usage

Requirements:
* `dmesg`

```bash
./dmesg --help
```


# States

* CRIT or state given by `--severity` if any of (filtered) emerg, alert, crit and err messages in dmesg are found.


# Perfdata

There is no perfdata.


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.
