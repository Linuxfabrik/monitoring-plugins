# Check lvm-snapshots


## Overview

Monitors the LVM snapshots on this host. A classic snapshot holds the blocks its origin has overwritten since it was taken, in a store of a fixed size, and the kernel throws the whole snapshot away the moment that store is full: the origin keeps running, while the snapshot silently stops being readable and whatever was backing up from it has lost its source. This check reports how full each store is before that happens, and says so when it already has. Thin snapshots draw on their pool instead of on a store of their own and are reported without a fill level, because what can run out for them is the pool. Alerts when the store of a classic snapshot is fuller than the thresholds allow, when the kernel has thrown a snapshot away, and when merging a snapshot back into its origin has failed. Optionally alerts on the age of a snapshot, which is what usually precedes a full one.

**What the two kinds of snapshot do when they run out of room:**

| | Classic snapshot | Thin snapshot |
|----|----|----|
| Where the data goes | Into a copy-on-write store of its own, sized when the snapshot is created. | Into the thin pool it shares with its origin and every other volume in that pool. |
| What runs out | The store. Reported here as a percentage. | The pool. Reported by `lvm-thin-pools`. |
| What happens then | The kernel invalidates the snapshot. Reads give I/O errors, a mounted filesystem on it is thrown out, and the origin is untouched. | Every volume in the pool stops taking writes, the origin among them. |
| Can it be undone | No. The snapshot is gone and has to be taken again. | Yes, by giving the pool more room. |

**Important Notes:**

* **Requires root or sudo.** `lvs` needs `/run/lock/lvm` and `/dev/mapper/control`, both of which are readable by root alone; membership of the `disk` group does not help. Deploy the sudoers file from `assets/sudoers/` and run the check through `sudo`.
* **A full classic snapshot is silent without a check.** LVM's own `lv_health_status` field stays empty for it, so a check that reads only that field reports a destroyed snapshot as healthy. What says so is `lv_snapshot_invalid`, and that is what this check reads.
* **A snapshot that is already gone is not graded on its fill level.** It reports 100% for as long as it is left lying around, and raising that to CRIT on every run afterwards would put a permanent alarm on a snapshot that cannot be saved either way. The state stays WARN with the message that says what happened.
* **Nothing grows a snapshot by itself.** `snapshot_autoextend_threshold` in `lvm.conf` is 100 on both the Red Hat and the Debian family, which means the store is never extended automatically. Set it below 100 to have LVM grow the store before it fills, which needs free space in the volume group.
* **The age check is off by default.** A snapshot that outlives its purpose is what usually fills a store, but how long a snapshot is supposed to live differs per site, so `--warning-age` and `--critical-age` start at `0D`, which is off.
* **`lvs` can hang on storage that has stopped answering.** It reads every physical volume on the host, so one that no longer answers blocks the whole command, and no signal ends the wait. The check gives it `--timeout` seconds and reports WARN with the device to look at when it does not come back.
* Related checks: `lvm-thin-pools` reports the pools that thin snapshots draw on, `lvm-volumes` the health of everything else, and `lvm-volume-groups` whether there is free space left to grow a store into.

**Data Collection:**

* Runs `lvs` once and reads its JSON report
* Grades the fill level of classic snapshots only; a thin snapshot has no store of its own that can run out
* Reads `lv_snapshot_invalid` and `lv_merge_failed` next to `lv_health_status`, because the first two are what a snapshot fails with
* Requires root or sudo


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/lvm-snapshots> |
| Nagios/Icinga Check Name              | `check_lvm_snapshots` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | Yes |
| Runs on                               | Linux |
| Compiled for Windows                  | No |
| Requirements                          | command-line tool `lvs` (package `lvm2`); User with higher permissions |


## Help

```text
usage: lvm-snapshots [-h] [-V] [--always-ok] [--brief] [-c CRIT]
                     [--critical-age CRIT_AGE] [--ignore IGNORE]
                     [--match MATCH]
                     [--no-match-severity {ok,warn,crit,unknown}]
                     [--no-perfdata] [--timeout TIMEOUT] [-w WARN]
                     [--warning-age WARN_AGE]

Monitors the LVM snapshots on this host. A classic snapshot holds the blocks
its origin has overwritten since it was taken, in a store of a fixed size, and
the kernel throws the whole snapshot away the moment that store is full: the
origin keeps running, while the snapshot silently stops being readable and
whatever was backing up from it has lost its source. This check reports how
full each store is before that happens, and says so when it already has. Thin
snapshots draw on their pool instead of on a store of their own and are
reported without a fill level, because what can run out for them is the pool.
Alerts when the store of a classic snapshot is fuller than the thresholds
allow, when the kernel has thrown a snapshot away, and when merging a snapshot
back into its origin has failed. Optionally alerts on the age of a snapshot,
which is what usually precedes a full one. Requires root or sudo.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --brief               Hide the rows that are within the thresholds and show
                        only those in a WARN or CRIT state. Perfdata and
                        alerting are unaffected: every item still emits
                        performance data and still drives the overall check
                        state, so this is safe to leave on.
  -c, --critical CRIT   CRIT threshold for how full the store of a classic
                        snapshot is, in percent. Does not apply to thin
                        snapshots, which have no store of their own. Supports
                        Nagios ranges. Default: 90
  --critical-age CRIT_AGE
                        CRIT threshold for the age of a snapshot. A snapshot
                        is meant to live for as long as something reads from
                        it, and one that outlives its purpose keeps collecting
                        the writes of its origin until its store is full. A
                        duration such as `12h`, `8D` or `2W`; `0D` disables
                        the age check. Example: `--critical-age=7D` alerts on
                        a snapshot that has been around for a week. Default:
                        0D
  --ignore IGNORE       Any item matching this Python regex will be ignored.
                        Can be specified multiple times. Example:
                        `(?i)linuxfabrik` for a case-insensitive match.
  --match MATCH         Filter by this Python regular expression. Case-
                        sensitive by default; use `(?i)` for case-insensitive
                        matching. Can be specified multiple times. If both
                        `--match` and `--ignore` are given, an item must match
                        `--match` AND not match `--ignore` to be reported
                        (include first, exclude second). Examples:
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
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
  -w, --warning WARN    WARN threshold for how full the store of a classic
                        snapshot is, in percent. Does not apply to thin
                        snapshots, which have no store of their own. Supports
                        Nagios ranges. Default: 80
  --warning-age WARN_AGE
                        WARN threshold for the age of a snapshot. A snapshot
                        is meant to live for as long as something reads from
                        it, and one that outlives its purpose keeps collecting
                        the writes of its origin until its store is full. A
                        duration such as `12h`, `8D` or `2W`; `0D` disables
                        the age check. Example: `--warning-age=2D` alerts on a
                        snapshot that outlived the nightly job that took it.
                        Default: 0D

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/lvm-snapshots/
```


## Usage Examples

```bash
sudo ./lvm-snapshots
```

Output on a host whose snapshots are within their thresholds. A thin snapshot has no store of its own, so it carries no fill level:

```text
2 LVM snapshots, the fullest at 84%, the oldest 1h 4m old.

Snapshot        ! Origin ! Pool  ! Size     ! Usage  ! Age     ! Type
----------------+--------+-------+----------+--------+---------+--------
testvg/goodsnap ! orig   ! -     ! 300.0MiB ! 83.74% ! 55m 29s ! classic
testvg/tsnap    ! tvol   ! tpool ! 4.0GiB   ! -      ! 1h 4m   ! thin
```

Output after a store ran full and the kernel threw the snapshot away:

```text
testvg/snap: its copy-on-write store ran full and the kernel threw it away.
A snapshot the kernel has thrown away cannot be brought back; whatever read from it has to run again from a new one. Remove it with `lvremove`, and give the next one a store that covers the writes its origin takes while it lives (`lvcreate --size`). `snapshot_autoextend_threshold` in `lvm.conf` is off by default and lets LVM grow the store before it fills, as long as the volume group has room to grow it into.

Snapshot        ! Origin ! Pool  ! Size     ! Usage   ! Age     ! Type
----------------+--------+-------+----------+---------+---------+------------------
testvg/goodsnap ! orig   ! -     ! 300.0MiB ! 83.74%  ! 55m 29s ! classic
testvg/snap     ! orig   ! -     ! 200.0MiB ! 100.00% ! 1h 5m   ! classic [WARNING]
testvg/tsnap    ! tvol   ! tpool ! 4.0GiB   ! -       ! 1h 4m   ! thin
```

Alert on a snapshot that has been around for more than two days, which on most hosts means the job that made it never cleaned up:

```bash
sudo ./lvm-snapshots --warning-age=2D --critical-age=7D
```

Warn earlier than the default, on a host whose origins take a lot of writes:

```bash
sudo ./lvm-snapshots --warning=60 --critical=80
```

Leave the snapshots of one volume group out, for example a backup host that keeps them around on purpose:

```bash
sudo ./lvm-snapshots --ignore='^backupvg/'
```

On a host with hundreds of snapshots, `--brief` prints only the ones that are not within their thresholds, while every snapshot still emits performance data and still drives the state:

```bash
sudo ./lvm-snapshots --brief
```


## States

* OK if every checked classic snapshot is within `--warning` and `--critical`, and nothing is wrong with any of them.
* WARN if the store of a classic snapshot is at or above `--warning` (default `80`).
* CRIT if it is at or above `--critical` (default `90`).
* WARN if the kernel has thrown a snapshot away because its store ran full. The fill thresholds do not apply to such a snapshot any more, so this stays WARN even with `--critical` set below 100.
* WARN if merging a snapshot back into its origin has failed.
* WARN or CRIT if a snapshot is older than `--warning-age` or `--critical-age`. Both default to `0D`, which is off.
* OK if the host has no snapshot at all. That is the normal state of most hosts, not a fault.
* OK if `--match` or `--ignore` leave nothing to check. `--no-match-severity` raises that.
* WARN if `lvs` did not answer within `--timeout`, and WARN if the LVM tools are not installed. Both are things to fix on the host, so they do not disappear into UNKNOWN.
* UNKNOWN if `lvs` refuses to report because the check is not running as root.
* UNKNOWN if the report cannot be read, if `--match` or `--ignore` is not a valid Python regular expression, or if a threshold does not parse.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

One metric per classic snapshot, plus two counts over the whole host. A thin snapshot emits no fill metric, because it has no store of its own.

| Name | Type | Description |
|----|----|----|
| `<vg>_<lv>_usage` | Percentage | How full the copy-on-write store of that classic snapshot is. |
| snapshots         | Number | Snapshots checked, of both kinds. |
| snapshots_invalid | Number | Snapshots the kernel has thrown away. |

A metric name carries the volume group and the volume, which is what makes it readable in a graph. RRD tells two data sources apart by their first 19 characters, so on a host whose names are long enough to fill those 19 characters before the metric part begins, the graphs of one item merge into one. Shorter volume group and volume names are the only way around it.


## Troubleshooting

### `its copy-on-write store ran full and the kernel threw it away`

The origin took more writes while the snapshot existed than the snapshot had room to keep, so device-mapper invalidated it (`Invalidating snapshot: Unable to allocate exception.` in the kernel log). The snapshot cannot be recovered, and anything that was reading from it, a backup above all, has to run again against a new one.

1. Confirm what happened and when:

    ```bash
    journalctl --dmesg --grep='Invalidating snapshot'
    ```

2. Remove the dead snapshot. It is holding its extents for nothing:

    ```bash
    lvremove vg0/snap0
    ```

3. Size the next one for the writes its origin takes while it lives. A store that holds an hour of writes is not enough for a backup that runs for three:

    ```bash
    lvcreate --snapshot --size 20G --name snap0 vg0/data
    ```

4. Where the volume group has room, let LVM grow the store instead of guessing. Set `snapshot_autoextend_threshold` to for example `70` and `snapshot_autoextend_percent` to `20` in `/etc/lvm/lvm.conf`, and make sure `lvm2-monitor.service` is running, because the extension is done by `dmeventd`:

    ```bash
    systemctl status lvm2-monitor.service
    ```

### A snapshot keeps filling up although nothing writes to it

A classic snapshot fills from writes to its **origin**, not from writes to the snapshot. Every block the origin overwrites is copied into the store first, so a busy origin fills a snapshot that nobody touches. Either give the store more room or shorten the life of the snapshot.

### `LVM did not answer within 8s`

One of the physical volumes on this host has stopped answering. `lvs` reads all of them to find the volume groups, so a single unresponsive device blocks the command, and the wait cannot be interrupted by a signal. Naming a single volume group does not help, because LVM scans every device to find it.

```bash
lsblk
journalctl --dmesg
pvs
```

Once the device is back or has been taken out of the volume group with `vgreduce --removemissing`, the check answers again.

### `LVM refused to report as this user`

The check ran without the rights it needs. `/run/lock/lvm` and `/dev/mapper/control` belong to root, and no supplementary group changes that. Deploy the sudoers file from [assets/sudoers](https://github.com/Linuxfabrik/monitoring-plugins/tree/main/assets/sudoers) and let the monitoring agent call the check through `sudo`.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich, Switzerland](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
