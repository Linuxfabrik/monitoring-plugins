# Check fs-mounts


## Overview

Checks that every filesystem listed in `/etc/fstab` is really mounted. A filesystem that never came up is invisible to disk usage, inode and read-only checks, because those only look at what is mounted, and it does not show up as a failed systemd unit either, because a mount that is not there is inactive and not failed. Applications keep writing into the empty mount point on the underlying filesystem instead, usually filling up the root filesystem, until someone notices that the data is in the wrong place. Swap areas and entries marked `noauto` are skipped, the latter unless they also carry `x-systemd.automount`, because those are expected to be present as an automount. Mount points that are not managed through `/etc/fstab`, for example one that a systemd mount unit or an automounter map provides, can be named with `--mount`. Supports extended reporting via `--lengthy`. Alerts when an expected filesystem is not mounted.

**Important Notes:**

* An entry marked `nofail` is reported like any other. `nofail` only tells the boot process not to wait for the filesystem, it does not say that the filesystem is optional.
* A host without an `/etc/fstab`, and one whose `/etc/fstab` holds no mountable entry, reports OK. Nothing in the file means nothing to compare against.
* Whether the right filesystem is mounted, and with which options, is not part of this check. A device that is mounted read-only is reported by `fs-ro`, its space by `disk-usage` and its inodes by `fs-inodes`.

**Data Collection:**

* Reads `/etc/fstab` for the filesystems that are expected to be mounted, plus every mount point `--mount` names
* Reads `/proc/self/mountinfo` for the filesystems that really are mounted
* Skips swap areas, entries whose second field is not an absolute path, and entries marked `noauto` without `x-systemd.automount`
* Skips mount points matching `--ignore`, and looks only at those matching `--match` if that parameter is given
* Resolves a mount point through its symlinks when it has no direct match, because `mount` resolves the target before mounting and the kernel then reports the resolved path


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/fs-mounts> |
| Nagios/Icinga Check Name              | `check_fs_mounts` |
| Check Interval Recommendation         | Every 15 minutes |
| Can be called without parameters      | Yes |
| Runs on                               | Linux |
| Compiled for Windows                  | No |


## Help

```text
usage: fs-mounts [-h] [-V] [--always-ok] [--brief] [--ignore IGNORE]
                 [--lengthy] [--match MATCH] [--mount MOUNT]
                 [--no-match-severity {ok,warn,crit,unknown}] [--no-perfdata]

Checks that every filesystem listed in /etc/fstab is really mounted. A
filesystem that never came up is invisible to disk usage, inode and read-only
checks, because those only look at what is mounted, and it does not show up as
a failed systemd unit either, because a mount that is not there is inactive
and not failed. Applications keep writing into the empty mount point on the
underlying filesystem instead, usually filling up the root filesystem, until
someone notices that the data is in the wrong place. Swap areas and entries
marked "noauto" are skipped, the latter unless they also carry
"x-systemd.automount", because those are expected to be present as an
automount. Mount points that are not managed through /etc/fstab, for example
one that a systemd mount unit or an automounter map provides, can be named
with --mount. Supports extended reporting via --lengthy. Alerts when an
expected filesystem is not mounted.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --brief               Hide the rows that are within the thresholds and show
                        only those in a WARN or CRIT state. Perfdata and
                        alerting are unaffected: every item still emits
                        performance data and still drives the overall check
                        state, so this is safe to leave on.
  --ignore IGNORE       Any item matching this Python regex will be ignored.
                        Can be specified multiple times. Example:
                        `(?i)linuxfabrik` for a case-insensitive match.
  --lengthy             Extended reporting.
  --match MATCH         Filter by this Python regular expression. Case-
                        sensitive by default; use `(?i)` for case-insensitive
                        matching. Can be specified multiple times. If both
                        `--match` and `--ignore` are given, an item must match
                        `--match` AND not match `--ignore` to be reported
                        (include first, exclude second). Examples:
                        `(?i)example` to match "example" regardless of case.
                        `^(?!.*example).*$` to match any string except
                        "example" (negative lookahead).
  --mount MOUNT         Mount point that has to be mounted although /etc/fstab
                        does not list it, for example one that a systemd mount
                        unit or an automounter map provides. Absolute path.
                        Can be specified multiple times. Example:
                        `--mount=/srv/data`
  --no-match-severity {ok,warn,crit,unknown}
                        State to report when no item matches the filters and
                        nothing is checked. Default: ok
  --no-perfdata         Suppress the performance data section from the output.
                        The status message and the exit code are unaffected,
                        so alerting keeps working while trending data is
                        dropped.

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/fs-mounts/
```


## Usage Examples

```bash
./fs-mounts
```

Output:

```text
Everything is ok. 4 filesystems from /etc/fstab are mounted.
```

Output (with a filesystem that is not mounted):

```text
2 filesystems from /etc/fstab are not mounted:
* /dev/disk/by-uuid/deadbeef-0000-0000-0000-000000000000 on /mnt/missing
* /dev/disk/by-uuid/deadbeef-0000-0000-0000-000000000001 on /mnt/nofail
```

Extended reporting, listing every filesystem that is expected to be mounted:

```bash
./fs-mounts --lengthy
```

Output:

```text
Everything is ok. 4 filesystems from /etc/fstab are mounted.

Mountpoint ! Device                                    ! Type  ! State
-----------+-------------------------------------------+-------+--------
/          ! UUID=4cbb5eda-5cff-4df5-b215-5aba13b02f6e ! btrfs ! mounted
/boot      ! UUID=4056ef4c-690b-4e72-8bfc-babb6924eb62 ! ext4  ! mounted
/boot/efi  ! UUID=3AAA-F1B8                            ! vfat  ! mounted
/home      ! UUID=4cbb5eda-5cff-4df5-b215-5aba13b02f6e ! btrfs ! mounted
```

On a host with many mount points, `--brief` keeps the table down to the filesystems that are not mounted:

```bash
./fs-mounts --lengthy --brief
```

Output:

```text
1 filesystem from /etc/fstab is not mounted: /dev/nvme0n1p3 on /home

Mountpoint ! Device         ! Type ! State
-----------+----------------+------+----------------------
/home      ! /dev/nvme0n1p3 ! ext4 ! not mounted [WARNING]
```

Also check a mount point that no `/etc/fstab` entry provides. A filesystem that a systemd mount unit or an automounter map mounts is not written down in `/etc/fstab`, so the check learns about it only when `--mount` names it:

```bash
./fs-mounts --mount=/srv/data
```

Output:

```text
Everything is ok. 5 filesystems from /etc/fstab and --mount are mounted.
```

Output (when that mount point is not there):

```text
1 filesystem from /etc/fstab and --mount is not mounted: /srv/data
```

Ignore the mount points of a backup target that is attached only now and then:

```bash
./fs-mounts --ignore='^/mnt/backup'
```


## States

* OK if every expected filesystem is mounted.
* OK if there is nothing to compare against, either because there is no `/etc/fstab` or because it holds no entry that has to be mounted.
* OK if `--match` and `--ignore` dropped every mount point. The output says how many the host carries and which parameter dropped them. `--no-match-severity` raises that case to WARN, CRIT or UNKNOWN.
* WARN if at least one expected filesystem is not mounted.
* UNKNOWN if the host does not provide `/proc/self/mountinfo`.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name                  | Type   | Description |
|-----------------------|--------|-------------|
| fs_mounts_expected    | Number | Number of filesystems that are expected to be mounted, after filtering. |
| fs_mounts_not_mounted | Number | Number of those filesystems that are not mounted. |


## Troubleshooting

### A filesystem is reported although it is mounted

Compare the mount point in the alert with the fifth field of the matching `/proc/self/mountinfo` line. The check compares the two paths, so they have to name the same directory:

```bash
grep ' /your/mount/point ' /proc/self/mountinfo
```

A path that leads through a symlink is resolved before it is compared, so that case is covered. A path that differs in any other way, a typo in `/etc/fstab` or a bind mount that landed somewhere else, is a real finding: the filesystem is mounted, but not where `/etc/fstab` says it should be.


### A backup disk or a removable device is reported every time it is detached

Either mark its `/etc/fstab` entry `noauto`, which is what an entry that is not supposed to be mounted at boot should carry anyway, or exclude its mount point with `--ignore`.


### A filesystem is not mounted and nothing in the logs says why

The mount unit systemd derives from the `/etc/fstab` entry holds the reason, and it is not among the failed units, so it has to be asked for by name:

1. Ask systemd for the unit of that mount point:

    ```bash
    systemctl status "$(systemd-escape --path --suffix=mount /your/mount/point)"
    ```

2. A unit that is `inactive (dead)` never ran. The usual reason is that the device behind it is absent: check `blkid` for the UUID or label the `/etc/fstab` entry names.
3. Try the mount by hand and read the error:

    ```bash
    mount /your/mount/point
    ```

4. After correcting `/etc/fstab`, run `systemctl daemon-reload` before `mount --all`, otherwise systemd keeps working from the units it generated from the old file.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
