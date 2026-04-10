# Check fs-inodes

## Overview

Checks the percentage of used inodes on local filesystems. Fetches a list of local devices that are in use and have a filesystem. Filesystems that do not report inode usage (such as btrfs or some network filesystems) are skipped automatically. Alerts when inode usage exceeds the configured thresholds.

**Important Notes:**

* If you get an alert, use `find $MOUNT -xdev -printf '%h\n' | sort | uniq --count | sort --key=1 --numeric-sort --reverse | head -n 10` to find the 10 directories under `$MOUNT` that consume the most inodes


**Data Collection:**

* Uses `os.statvfs()` on each local disk mount point to read total and free inode counts
* Discovers local disk devices via `lib.disk.get_real_disks()`

**Compatibility:**

* Cross-platform


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/fs-inodes> |
| Nagios/Icinga Check Name              | `check_fs_inodes` |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |


## Help

```text
usage: fs-inodes [-h] [-V] [--always-ok] [-c CRIT] [-w WARN]

Checks the percentage of used inodes on local filesystems. Fetches a list of
local devices that are in use and have a filesystem. Filesystems that do not
report inode usage (such as some network filesystems) are skipped
automatically. Alerts when inode usage exceeds the configured thresholds.

options:
  -h, --help           show this help message and exit
  -V, --version        show program's version number and exit
  --always-ok          Always returns OK.
  -c, --critical CRIT  CRIT threshold for inode usage in percent. Default: 95
  -w, --warning WARN   WARN threshold for inode usage in percent. Default: 90
```


## Usage Examples

```bash
./fs-inodes --warning 90 --critical 95
```

Output:

```text
/ 1.7%, /tmp 3.2%, /boot 0.2%
```


## States

* OK if inode usage on all mount points is below `--warning` (default: 90%).
* WARN if inode usage on any mount point is >= `--warning` (default: 90%).
* CRIT if inode usage on any mount point is >= `--critical` (default: 95%).
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

For each mount point (e.g. `/`, `/tmp`, `/boot`):

| Name | Type | Description |
|----|----|----|
| `<mount-point>` | Percentage | Inode usage in percent for this mount point. |


## Troubleshooting

`Everything is ok (although nothing checked).`
No local disk devices with inode-reporting filesystems were found. This can happen on systems using only btrfs or network-mounted filesystems.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
