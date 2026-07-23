# Check fs-inodes


## Overview

Checks the percentage of used inodes on local filesystems. Fetches a list of local devices that are in use and have a filesystem. Filesystems that do not report inode usage (such as btrfs or some network filesystems) are skipped automatically, and mount points the plugin cannot read (for example a Kubernetes CSI volume that requires root) are reported as unreadable instead of aborting the whole check. Supports filtering mount points by regular expression via `--match` and `--ignore`. Supports extended reporting via `--lengthy`. Alerts when inode usage exceeds the configured thresholds.

**Important Notes:**

* If you get an alert, use `find $MOUNT -xdev -printf '%h\n' | sort | uniq --count | sort --key=1 --numeric-sort --reverse | head -n 10` to find the 10 directories under `$MOUNT` that consume the most inodes
* On Kubernetes hosts, CSI volumes mounted under `/var/lib/kubelet` are only readable by root. Running unprivileged, the plugin reports these mount points as unreadable (`N/A`) without alerting. Use `--ignore '/var/lib/kubelet'` to drop them entirely

**Data Collection:**

* Discovers local disk devices via `lib.disk.get_real_disks()` (parsing `/proc/mounts`)
* Reads total and free inode counts for each local disk mount point via `os.statvfs()`
* Filesystems that do not report inodes (such as btrfs or some network filesystems) are skipped automatically
* A mount point that cannot be read (permission denied or I/O error) is reported as unreadable and does not abort the check
* Mount points can be filtered using `--match` and `--ignore` (case-sensitive Python regular expressions; use `(?i)` for case-insensitive matching). A mount point hit by `--ignore` is dropped even if it also matches `--match`
* Output is sorted by inode usage, fullest first
* Long mount points (such as Kubernetes CSI volumes) are shortened in the human-readable output; performance data keeps the full path


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/fs-inodes> |
| Nagios/Icinga Check Name              | `check_fs_inodes` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Runs on                               | Linux |
| Compiled for Windows                  | No |


## Help

```text
usage: fs-inodes [-h] [-V] [--always-ok] [-c CRIT] [--ignore IGNORE]
                 [--lengthy] [--match MATCH]
                 [--no-match-severity {ok,warn,crit,unknown}] [--no-perfdata]
                 [-w WARN]

Checks the percentage of used inodes on local filesystems. Fetches a list of
local devices that are in use and have a filesystem. Filesystems that do not
report inode usage (such as some network filesystems) are skipped
automatically, and mount points the plugin cannot read (for example a
Kubernetes CSI volume that requires root) are reported as unreadable instead
of aborting the whole check. Supports filtering mount points by regular
expression via --match and --ignore. Supports extended reporting via
--lengthy. Alerts when inode usage exceeds the configured thresholds.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  -c, --critical CRIT   CRIT threshold in percent. Supports Nagios ranges.
                        Default: 95
  --ignore IGNORE       Any item matching this Python regex will be ignored.
                        Can be specified multiple times. Example:
                        `(?i)linuxfabrik` for a case-insensitive match.
  --lengthy             Extended reporting.
  --match MATCH         Filter by this Python regular expression. Case-
                        sensitive by default; use `(?i)` for case-insensitive
                        matching. Can be specified multiple times. Examples:
                        `(?i)example` to match "example" regardless of case.
                        `^(?!.*example).*$` to match any string except
                        "example" (negative lookahead).
  --no-match-severity {ok,warn,crit,unknown}
                        State to report when no item matches the filters and
                        nothing is checked. Default: ok
  --no-perfdata         Suppress the performance data section from the output.
                        The status message and the exit code are unaffected,
                        so alerting keeps working while trending data is
                        dropped.
  -w, --warning WARN    WARN threshold in percent. Supports Nagios ranges.
                        Default: 90
```


## Usage Examples

```bash
./fs-inodes --warning 90 --critical 95
```

Output:

```text
/ 1.7%, /tmp 3.2%, /boot 0.2%
```

Extended reporting with `--lengthy` prints a table with the inode counts per mount point:

```bash
./fs-inodes --lengthy
```

Output:

```text
Everything is ok. (warn=90 crit=95)

Mountpoint ! Device         ! ITotal ! IUsed ! IFree ! Use%
-----------+----------------+--------+-------+-------+-----
/tmp       ! /dev/vda1      ! 6.6M   ! 211.2K ! 6.4M ! 3.2%
/          ! /dev/vda1      ! 6.6M   ! 112.2K ! 6.5M ! 1.7%
/boot      ! /dev/nvme0n1p2 ! 65.5K  ! 109.0  ! 65.4K ! 0.2%
```

Ignore Kubernetes CSI volumes that are only readable by root:

```bash
./fs-inodes --ignore '/var/lib/kubelet'
```


## States

* OK if inode usage on all mount points is below `--warning` (default: 90%).
* WARN if inode usage on any mount point exceeds `--warning` (default: 90%).
* CRIT if inode usage on any mount point exceeds `--critical` (default: 95%).
* Mount points that cannot be read (permission denied or I/O error) are reported as unreadable and do not raise an alert.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

For each mount point (e.g. `/`, `/tmp`, `/boot`):

| Name | Type | Description |
|----|----|----|
| `<mount-point>` | Percentage | Inode usage in percent for this mount point. |

Mount points that cannot be read emit no perfdata.


## Troubleshooting

### `Nothing checked.`

No local disk devices with inode-reporting filesystems matched the filters. This can happen on systems using only btrfs or network-mounted filesystems, or when `--match` / `--ignore` exclude every mount point. Use `--no-match-severity` to control which state is reported in this case.

### `PermissionError` on `/var/lib/kubelet` mount points

Kubernetes CSI volumes are only readable by root. Running unprivileged, the plugin reports them as unreadable (`N/A`) without alerting. Use `--ignore '/var/lib/kubelet'` to drop them from the output.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
