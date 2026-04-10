# Check disk-usage

## Overview

Measures the usage of all mounted disk *partitions*. It does not check the usage on the raw disks, because in LVM for example, more than one disk can be a member of a logical volume, and some of the disks might be full - which is fine as long as LVM has some space available.

By default, this plugin only checks physical devices (e.g. hard disks, CD-ROM drives, USB keys) and ignores all others (e.g. pseudo, memory, duplicate, inaccessible file systems). You can override this behaviour by using the `--fstype` parameter and specifying which file system types should be checked explicitly.

To get a list of file system types you can specify, run `disk-usage --list-fstype` first (as file system types are machine dependent).

> [!NOTE]
> UNIX usually reserves 5% of the total disk space for the root user. `total` and `used` fields on UNIX refer to the overall total and used space, whereas `free` represents the space available for the user and `percent` represents the user utilization. That is why `percent` value may look 5% bigger than what you would expect it to be (starting with psutil v4.3.0; quote from the [psutil documentation](https://psutil.readthedocs.io/en/latest/)).

Hints:

* On Windows, mount point folder paths are also supported.
* Important when using parameter values on Windows: As long as there is no space in the value, it works without quotes. If you need quotes, they must be enclosed in double quotes (single quotes will not work). Working example: `disk-usage.exe --include-pattern="Sales Documents"`


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/disk-usage> |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | Yes |
| 3rd Party Python modules              | `psutil` |


## Help

```text
usage: disk-usage [-h] [-V] [--always-ok] [-c CRIT]
                  [--exclude-pattern EXCLUDE_PATTERN]
                  [--exclude-regex EXCLUDE_REGEX] [--fstype FSTYPE]
                  [--include-pattern INCLUDE_PATTERN]
                  [--include-regex INCLUDE_REGEX] [--list-fstypes]
                  [--perfdata-regex PERFDATA_REGEX] [-w WARN]

Checks used or free disk space for each mounted partition. By default, only
physical devices are checked (hard disks, USB drives), ignoring pseudo and
memory filesystems. Supports filtering by mountpoint pattern or filesystem
type. Thresholds can be set as percentages or absolute values, and can target
either used or free space. Note that on Unix systems, 5% of disk space is
typically reserved for root and not reflected in the available space shown to
regular users. Alerts when usage exceeds the configured thresholds.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  -c, --critical CRIT   CRIT threshold in the form `<number>[unit][method]`.
                        Unit is one of `%|K|M|G|T|P` (default: `%`). `K` means
                        kibibyte etc. Method is one of `USED|FREE` (default:
                        `USED`). `USED` means "number or more", `FREE` means
                        "number or less". Examples: `95` = 95% used. `9.5M` =
                        9.5 MiB used. `5%FREE`. `1400GUSED`. Default: 95%USED.
  --exclude-pattern EXCLUDE_PATTERN
                        Exclude any mountpoint containing this substring
                        (case-insensitive). Example: `boot` excludes `/boot`
                        and `/boot/efi`. Can be specified multiple times. On
                        Windows, use drive letters without backslash (`Y:` or
                        `Y`). Includes are matched before excludes.
  --exclude-regex EXCLUDE_REGEX
                        Exclude any mountpoint matching this Python regex
                        (case-insensitive). Can be specified multiple times.
                        On Windows, use drive letters without backslash (`Y:`
                        or `Y`). Includes are matched before excludes.
  --fstype FSTYPE       Override the default behaviour (check physical devices
                        only) and check these file system types instead. Can
                        be specified multiple times. Run `disk-usage --list-
                        fstypes` first to see available types (they are
                        machine dependent).
  --include-pattern INCLUDE_PATTERN
                        Only include mountpoints containing this substring
                        (case-insensitive). Example: `boot` includes `/boot`
                        and `/boot/efi`. Can be specified multiple times. On
                        Windows, use drive letters without backslash (`Y:` or
                        `Y`). Includes are matched before excludes.
  --include-regex INCLUDE_REGEX
                        Only include mountpoints matching this Python regex
                        (case-insensitive). Can be specified multiple times.
                        On Windows, use drive letters without backslash (`Y:`
                        or `Y`). Includes are matched before excludes.
  --list-fstypes        Print available file system types and which ones are
                        checked by default, then exit.
  --perfdata-regex PERFDATA_REGEX
                        Only emit perfdata keys matching this Python regex.
                        For a list of perfdata keys, see the README or run
                        this plugin. Can be specified multiple times.
  -w, --warning WARN    WARN threshold in the form `<number>[unit][method]`.
                        Unit is one of `%|K|M|G|T|P` (default: `%`). `K` means
                        kibibyte etc. Method is one of `USED|FREE` (default:
                        `USED`). `USED` means "number or more", `FREE` means
                        "number or less". Examples: `95` = 95% used. `9.5M` =
                        9.5 MiB used. `5%FREE`. `1400GUSED`. Default: 90%USED.
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
./disk-usage --include-pattern=var --exclude-pattern=tmp --critical 450MFREE
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
./disk-usage --include-pattern=audit --warning 60MUSED
```

Output:

```text
/var/log/audit 12.6% [WARNING] - total: 506.7MiB, free: 442.7MiB, used: 63.9MiB (warn=60MUSED crit=95%USED)
```

Some other examples:

```bash
./disk-usage --exclude-pattern=/var/log --exclude-pattern=/tmp --warning=80 --critical=90
./disk-usage --exclude-pattern=/var/log --exclude-pattern=/tmp --warning=80%USED --critical=90%USED
./disk-usage --exclude-pattern=/var/log --exclude-pattern=/tmp --warning=80%USED --critical=3GFREE

./disk-usage --fstype=btrfs --fstype=vfat

./disk-usage --perfdata-pattern='/-usage'
./disk-usage --perfdata-pattern='var.*-usage'

# on Windows:
./disk-usage --exclude-pattern=E: --exclude-pattern=Y: --warning=80 --critical=90
```


## States

* WARN or CRIT if disk usage in percent is above a given threshold.


## Perfdata / Metrics

Can be limited by using `--perfdata-regex`.

| Name                   | Type       | Description      |
|------------------------|------------|------------------|
| \<mountpoint\>-percent | Percentage | Usage in percent |
| \<mountpoint\>-total   | Bytes      | Total Disksize   |
| \<mountpoint\>-usage   | Bytes      | Usage in Bytes   |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
