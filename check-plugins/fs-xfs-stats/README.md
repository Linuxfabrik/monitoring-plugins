# Check fs-xfs-stats


## Overview

Reports XFS filesystem activity from `/proc/fs/xfs/stat` as per-second rates: read and write system calls, inode cache hit ratio, inode reclaim activity, and directory operations, plus the current number of active inodes. Intended for trending I/O and metadata workload on XFS volumes. This check is informational and does not perform threshold-based alerting. For further information, see <https://xfs.org/index.php/Runtime_Stats>.

**Data Collection:**

* Reads `/proc/fs/xfs/stat` and computes per-second rates for the read/write system calls (`rw`), inode cache operations (`ig`) and directory operations (`dir`), plus the current number of active inodes.
* Rates are calculated in the plugin from the difference between two consecutive check runs, using a local SQLite cache. The first run reports `Waiting for more data.`
* The remaining `/proc/fs/xfs/stat` groups (allocator, B-tree and block-mapping internals) are omitted: they are XFS-internal debugging counters, and several legacy `vnodes` fields are unused slots that always read zero on modern kernels.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/fs-xfs-stats> |
| Nagios/Icinga Check Name              | `check_fs_xfs_stats` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Runs on                               | Linux |
| Compiled for Windows                  | No |
| Uses SQLite DBs                       | `$TEMP/linuxfabrik-monitoring-plugins-fs-xfs-stats.db` |


## Help

```text
usage: fs-xfs-stats [-h] [-V]

Reports XFS filesystem activity from /proc/fs/xfs/stat as per-second rates:
read and write system calls, inode cache hit ratio, inode reclaim activity,
and directory operations, plus the current number of active inodes. Intended
for trending I/O and metadata workload on XFS volumes. This check is
informational and does not raise alerts.

options:
  -h, --help     show this help message and exit
  -V, --version  show program's version number and exit
```


## Usage Examples

```bash
./fs-xfs-stats
```

Output:

```text
824.0 read/s, 25.0 write/s, inode cache hit 50.0%, 1.8K active inodes
```


## States

* Always OK. This check is informational and only collects performance data.
* UNKNOWN if `/proc/fs/xfs/stat` does not exist (no mounted XFS filesystem) or contains unexpected data.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| active_inodes | Number | Current number of active (in-use) XFS inodes. This is a gauge, not a rate. |
| dir_create_per_second | Number | Directory entry creations per second. |
| dir_lookup_per_second | Number | Directory name lookups per second. |
| dir_remove_per_second | Number | Directory entry removals per second. |
| inode_attempts_per_second | Number | Inode cache lookup attempts per second. |
| inode_cache_hit_percent | Percentage | Inode cache hit ratio over the interval (found / attempts). |
| inode_reclaims_per_second | Number | Inode cache reclaims per second (indicates memory pressure). |
| read_calls_per_second | Number | read(2) system calls to XFS files per second. |
| write_calls_per_second | Number | write(2) system calls to XFS files per second. |


## Troubleshooting

### `No mounted XFS filesystem found.`

The system does not have any mounted XFS filesystem. `/proc/fs/xfs/stat` does not exist. Disable this check for this machine.

### `Waiting for more data.`

The plugin needs two consecutive runs to calculate per-second rates. This message is expected on the first run (or after a reboot) and clears on the next check.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
