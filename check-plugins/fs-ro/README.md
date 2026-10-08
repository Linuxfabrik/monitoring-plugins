# Check fs-ro


## Overview

Checks for unexpectedly read-only mounted filesystems, such as a root filesystem that switched to read-only due to disk errors. Ignores ramfs, squashfs (snapd), iso9660, and other pseudo-filesystems by default. Additional mount points can be excluded via `--extend-ignore` and fs types with `--extend-ignore-type`. Alerts when a read-only filesystem is detected that should be writable.

**Data Collection:**

* Reads `/proc/mounts` and checks the mount options for each entry
* Skips ramfs, squashfs and iso9660 filesystem types entirely
* Skips mount points whose path starts with any `--ignore` prefix (default: `/dev/loop`, `/proc`, `/run/credentials`, `/snap`, `/sys/fs`, `/var/lib/docker/containers`). `--ignore` replaces this list, `--extend-ignore` appends to it
* Skips filesystem types with `--extend-ignore-type`.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/fs-ro> |
| Nagios/Icinga Check Name              | `check_fs_ro` |
| Check Interval Recommendation         | Every 15 minutes |
| Can be called without parameters      | Yes |
| Runs on                               | Linux |
| Compiled for Windows                  | No |


## Help

```text
usage: fs-ro [-h] [-V] [--always-ok] [--extend-ignore EXTEND_IGNORE]
             [--ignore IGNORE] [--extend-ignore-type EXTEND_IGNORE_TYPE]

Checks for unexpectedly read-only mounted filesystems, such as a root
filesystem that switched to read-only due to disk errors. Ignores ramfs,
squashfs (snapd), and other pseudo-filesystems by default. Additional mount
points can be excluded via --extend-ignore and filesystem types with `--extend-ignore-type`.
Alerts when a read-only filesystem is detected that should be writable.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --extend-ignore EXTEND_IGNORE
                        Mount point prefix to ignore, appended to the default
                        or the `--ignore` list. Can be specified multiple
                        times. Example: `--extend-ignore=/cvmfs`.
  --extend-ignore-type EXTEND_IGNORE_TYPE
                        Mount point fs type to ignore, appended to the default
                        list. Can be specified multiple
                        times. Example: `--extend-ignore-type=lustre`.
  --ignore IGNORE       Mount point prefix to ignore. All mount points
                        starting with this value will be skipped. Replaces the
                        default list, use `--extend-ignore` to append to it.
                        Can be specified multiple times. Example:
                        `--ignore=/sys/fs` ignores `/sys/fs/cgroup` and
                        similar. Default: /dev/loop, /proc, /run/credentials,
                        /snap, /sys/fs, /var/lib/docker/containers.

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/fs-ro/
```


## Usage Examples

```bash
./fs-ro --ignore=/proc --ignore=/sys/fs
```

Output:

```text
Everything is ok. 21 mount points checked.
```

Output (with read-only mount):

```text
1 read-only mount point found: /dev/sda1 on / (type ext4)
```

```bash
./fs-ro
1 read-only mount point found: users1-ost0/ost0 on /users1/ost0 (type lustre)

./fs-ro --extend-ignore-type lustre
Everything is ok. 18 mount points checked.
```

## States

* OK if no unexpected read-only mount points are found.
* WARN if one or more mount points (not on the ignore list) are mounted read-only.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

There is no perfdata.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
