# Check disk-usage


## Overview

Checks used or free disk space for each mounted partition. By default, only physical devices are checked (hard disks, USB drives), ignoring pseudo and memory filesystems. Supports filtering by mountpoint pattern or filesystem type. Thresholds can be set as percentages or absolute values, and can target either used or free space. Note that on ext2/3/4 filesystems, about 5% of disk space is reserved for root by default and is not reflected in the available space shown to regular users. Alerts when usage exceeds the configured thresholds.

**Important Notes:**

* On Unix systems, `total` and `used` refer to the overall total and used space, whereas `free` represents the space available for the user and `percent` represents the user utilization. That is why `percent` may appear 5% higher than expected (starting with psutil v4.3.0)
* Run `disk-usage --list-fstypes` to see which file system types are available on the current machine and which are checked by default

**Data Collection:**

* Uses `psutil` to enumerate mounted partitions and query disk usage per mountpoint
* By default, only physical devices are checked (e.g. hard disks, CD-ROM drives, USB keys), ignoring pseudo, memory, duplicate, and inaccessible file systems
* Read-only and special file systems (iso9660, squashfs, UDF, CDFS) are skipped by default
* The `--fstype` parameter overrides the default behavior, allowing specific file system types to be checked
* Mountpoints can be filtered using `--match` and `--ignore` (case-insensitive Python regular expressions; for case-sensitive matching, wrap the pattern in `(?-i:...)`). A mountpoint hit by `--ignore` is dropped even if it also matches `--match`. On Windows, use drive letters such as `C:` or `C`
* Perfdata output can be limited using `--perfdata-regex`


## Fact Sheet

| Fact | Value |
|----|----| 
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/disk-usage> |
| Nagios/Icinga Check Name              | `check_disk_usage` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | Yes |
| 3rd Party Python modules              | `psutil` |


## Help

```text
usage: disk-usage [-h] [-V] [--always-ok] [--brief] [-c CRIT]
                  [--fstype FSTYPE] [--ignore IGNORE] [--list-fstypes]
                  [--match MATCH] [--mount MOUNT]
                  [--no-match-severity {ok,warn,crit,unknown}]
                  [--perfdata-regex PERFDATA_REGEX] [-w WARN]

Checks used or free disk space for each mounted partition. By default, only
physical devices are checked (hard disks, USB drives), ignoring pseudo and
memory filesystems. Supports filtering by mountpoint pattern or filesystem
type. Thresholds can be set as percentages or absolute values, and can target
either used or free space, globally or per mountpoint via --mount. On systems
with many filesystems (hundreds of mounts), --brief hides rows that are within
the thresholds so the table only shows the filesystems in WARN/CRIT state.
Note that on ext2/3/4 filesystems, about 5% of disk space is reserved for root
by default and is not reflected in the available space shown to regular users.
Alerts when usage exceeds the configured thresholds.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --brief               Hide table rows for filesystems within the thresholds
                        and show only those in WARN/CRIT state. Perfdata and
                        alerting are unaffected: all filesystems still emit
                        perfdata and still drive the overall check state.
                        Default: False
  -c, --critical CRIT   CRIT threshold in the form `<number>[unit][method]`.
                        Unit is one of `%|K|M|G|T|P` (default: `%`). `K` means
                        kibibyte etc. Method is one of `USED|FREE` (default:
                        `USED`). `USED` means "number or more", `FREE` means
                        "number or less". Examples: `95` = 95% used. `9.5M` =
                        9.5 MiB used. `5%FREE`. `1400GUSED`. Default: 95%USED
  --fstype FSTYPE       Override the default behaviour (check physical devices
                        only) and check these file system types instead. Can
                        be specified multiple times. Run `disk-usage --list-
                        fstypes` first to see available types (they are
                        machine dependent).
  --ignore IGNORE       Ignore mountpoints matching this Python regular
                        expression. Case-insensitive by default (on Windows,
                        drive letters and paths are case-insensitive; use
                        drive letters such as `C:` or `C`). For case-sensitive
                        matching, wrap the pattern in `(?-i:...)`, e.g.
                        `(?-i:Data)`. Can be specified multiple times.
  --list-fstypes        Print available file system types and which ones are
                        checked by default, then exit.
  --match MATCH         Only check mountpoints matching this Python regular
                        expression. Case-insensitive by default (on Windows,
                        drive letters and paths are case-insensitive; use
                        drive letters such as `C:` or `C`). For case-sensitive
                        matching, wrap the pattern in `(?-i:...)`, e.g.
                        `(?-i:Data)`. Can be specified multiple times.
  --mount MOUNT         Override the global --warning/--critical thresholds
                        for a single mountpoint, in the form
                        `<mountpoint>,<warning>,<critical>`. Each threshold
                        uses the same `<number>[unit][method]` syntax as
                        --warning/--critical. The mountpoint is matched
                        exactly and case-insensitively, so the override always
                        hits exactly one mountpoint and never several. On
                        Windows, use drive letters such as `C:` or `C`. Can be
                        specified multiple times. Example:
                        `--mount=/var/log,80%USED,90%USED`
  --no-match-severity {ok,warn,crit,unknown}
                        State to report when no item matches the filters and
                        nothing is checked. Default: ok
  --perfdata-regex PERFDATA_REGEX
                        Only emit perfdata keys matching this Python regex.
                        For a list of perfdata keys, see the README or run
                        this plugin. Can be specified multiple times.
  -w, --warning WARN    WARN threshold in the form `<number>[unit][method]`.
                        Unit is one of `%|K|M|G|T|P` (default: `%`). `K` means
                        kibibyte etc. Method is one of `USED|FREE` (default:
                        `USED`). `USED` means "number or more", `FREE` means
                        "number or less". Examples: `95` = 95% used. `9.5M` =
                        9.5 MiB used. `5%FREE`. `1400GUSED`. Default: 90%USED
```


## Usage Examples

Simple usage:

```bash
./disk-usage
```

Output:

```text
Everything is ok. (warn=90%USED crit=95%USED)

Mountpoint     ! Type ! Size      ! Used     ! Avail    ! Use%  
---------------+------+-----------+----------+----------+-------
/              ! xfs  ! 4.0GiB    ! 2.4GiB   ! 1.5GiB   ! 61.4% 
/boot          ! xfs  ! 1014.0MiB ! 287.1MiB ! 726.9MiB ! 28.3% 
/var           ! xfs  ! 4.0GiB    ! 1.4GiB   ! 2.6GiB   ! 34.4% 
/tmp           ! xfs  ! 1014.0MiB ! 39.5MiB  ! 974.5MiB ! 3.9%  
/var/log       ! xfs  ! 1014.0MiB ! 190.9MiB ! 823.1MiB ! 18.8% 
/var/tmp       ! xfs  ! 1014.0MiB ! 39.4MiB  ! 974.6MiB ! 3.9%  
/var/log/audit ! xfs  ! 506.7MiB  ! 63.9MiB  ! 442.7MiB ! 12.6% 
/home          ! xfs  ! 1014.0MiB ! 130.1MiB ! 883.9MiB ! 12.8%
```

For each `/var` partition, except `/var/tmp`, alert when any of these partitions has only 450 MiB of free space left:

```bash
./disk-usage --match=var --ignore=tmp --critical=450MFREE
```

Output:

```text
There are critical errors. (warn=90%USED crit=450MFREE)

Mountpoint     ! Type ! Size      ! Used     ! Avail    ! Use%             
---------------+------+-----------+----------+----------+------------------
/var           ! xfs  ! 4.0GiB    ! 1.4GiB   ! 2.6GiB   ! 34.4%            
/var/log       ! xfs  ! 1014.0MiB ! 190.9MiB ! 823.1MiB ! 18.8%            
/var/log/audit ! xfs  ! 506.7MiB  ! 64.2MiB  ! 442.5MiB ! 12.7% [CRITICAL]|
```

Check exactly one partition:

```bash
./disk-usage --match=audit --warning=60MUSED
```

Output:

```text
/var/log/audit 12.6% [WARNING] - total: 506.7MiB, free: 442.7MiB, used: 63.9MiB (warn=60MUSED crit=95%USED)
```

Override the thresholds for a single mountpoint while every other mountpoint keeps the global thresholds. The override is matched exactly, so `/boot/efi` is not affected by a `/boot` override:

```bash
./disk-usage --warning=90%USED --critical=95%USED --mount='/boot/efi,2GFREE,1GFREE'
```

`--mount` can be repeated, one entry per mountpoint:

```bash
./disk-usage --mount='/var/log,80%USED,90%USED' --mount='/srv,500GFREE,200GFREE'
```

Some other examples:

```bash
./disk-usage --ignore=/var/log --ignore=/tmp --warning=80 --critical=90
./disk-usage --ignore=/var/log --ignore=/tmp --warning=80%USED --critical=90%USED
./disk-usage --ignore=/var/log --ignore=/tmp --warning=80%USED --critical=3GFREE

./disk-usage --fstype=btrfs --fstype=vfat

./disk-usage --perfdata-regex='/-usage'
./disk-usage --perfdata-regex='var.*-usage'

# on Windows:
./disk-usage --ignore=E: --ignore=Y: --warning=80 --critical=90
./disk-usage --mount='C:,90%USED,95%USED'
```


## States

* OK if disk usage is below the warning threshold.
* WARN if disk usage is >= `--warning` (default: 90%USED).
* CRIT if disk usage is >= `--critical` (default: 95%USED).
* A mountpoint listed in `--mount` uses its own thresholds instead of the global `--warning`/`--critical`. `--mount` only changes thresholds; it does not include a mountpoint that is otherwise not checked. If a `--mount` entry matches no checked filesystem (a typo, or a filesystem not checked by default), the plugin reports it in the output and otherwise ignores it, without changing the state.
* UNKNOWN on invalid parameter values, a malformed `--mount` entry, or regex compilation errors.
* `--no-match-severity` sets the state reported when the filters match no filesystem and nothing is checked (default: `ok`); set it to `warn`, `crit`, or `unknown` to alert on an empty selection (for example a filter typo or a missing filesystem) instead of silently returning OK.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

Can be limited by using `--perfdata-regex`.

| Name | Type | Description |
|----|----|----|
| `<mountpoint>`-percent | Percentage | Disk usage in percent. |
| `<mountpoint>`-total | Bytes | Total disk size. |
| `<mountpoint>`-usage | Bytes | Disk usage in bytes. |


## Troubleshooting

### `Python module "psutil" is not installed.`

Install `psutil`: `pip install psutil` or `dnf install python3-psutil`.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
