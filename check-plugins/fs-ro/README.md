# Check fs-ro


## Overview

Checks for unexpectedly read-only mounted filesystems, such as a root filesystem that switched to read-only due to disk errors. Ignores ramfs, squashfs (snapd), and other pseudo-filesystems by default. Additional mount points can be excluded via `--extend-ignore`, additional filesystem types via `--extend-ignore-fstype`. Alerts when a read-only filesystem is detected that should be writable.

**Important Notes:**

* A mounted ISO image (`iso9660`) is reported on purpose, so a forgotten installation medium does not stay attached across reboots. Use `--extend-ignore-fstype=iso9660` on hosts where mounted ISO images are expected.
* Some filesystems are read-only by design on certain hosts, for example the `lustre` targets on a Lustre server. Exclude them with `--extend-ignore-fstype=lustre` on those hosts.

**Data Collection:**

* Reads `/proc/mounts` and checks the mount options for each entry
* Skips filesystem types listed in `--ignore-fstype` (default: `ramfs`, `squashfs`). `--ignore-fstype` replaces this list, `--extend-ignore-fstype` appends to it
* Skips mount points whose path starts with any `--ignore` prefix (default: `/dev/loop`, `/proc`, `/run/credentials`, `/snap`, `/sys/fs`, `/var/lib/docker/containers`). `--ignore` replaces this list, `--extend-ignore` appends to it


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
             [--extend-ignore-fstype EXTEND_IGNORE_FSTYPE] [--ignore IGNORE]
             [--ignore-fstype IGNORE_FSTYPE]

Checks for unexpectedly read-only mounted filesystems, such as a root
filesystem that switched to read-only due to disk errors. Ignores ramfs,
squashfs (snapd), and other pseudo-filesystems by default. Additional mount
points can be excluded via --extend-ignore, additional filesystem types via
--extend-ignore-fstype. Alerts when a read-only filesystem is detected that
should be writable.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --extend-ignore EXTEND_IGNORE
                        Mount point prefix to ignore, appended to the default
                        or the `--ignore` list. Can be specified multiple
                        times. Example: `--extend-ignore=/cvmfs`.
  --extend-ignore-fstype EXTEND_IGNORE_FSTYPE
                        Filesystem type to ignore, appended to the default or
                        the `--ignore-fstype` list. Case-sensitive. Can be
                        specified multiple times. Example: `--extend-ignore-
                        fstype=iso9660`.
  --ignore IGNORE       Mount point prefix to ignore. All mount points
                        starting with this value will be skipped. Replaces the
                        default list, use `--extend-ignore` to append to it.
                        Can be specified multiple times. Example:
                        `--ignore=/sys/fs` ignores `/sys/fs/cgroup` and
                        similar. Default: /dev/loop, /proc, /run/credentials,
                        /snap, /sys/fs, /var/lib/docker/containers.
  --ignore-fstype IGNORE_FSTYPE
                        Filesystem type to ignore, as shown in the third
                        column of `/proc/mounts`. Replaces the default list,
                        use `--extend-ignore-fstype` to append to it. Case-
                        sensitive. Can be specified multiple times. Example:
                        `--ignore-fstype=squashfs --ignore-fstype=lustre`.
                        Default: ramfs, squashfs.

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

On a Lustre server, whose targets are mounted read-only by design:

```bash
./fs-ro --extend-ignore-fstype=lustre
```

Output:

```text
Everything is ok. 17 mount points checked.
```


## States

* OK if no unexpected read-only mount points are found.
* WARN if one or more mount points (not on the ignore lists) are mounted read-only.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

There is no perfdata.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
