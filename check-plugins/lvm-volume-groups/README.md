# Check lvm-volume-groups


## Overview

Reports the LVM volume groups on this host, how many physical volumes each of them is built from, and how many of those it can no longer find. A volume group that is missing a physical volume carries volumes that are incomplete, and it refuses to activate them at the next boot unless that is asked for explicitly, so a reboot in this state comes back without them. The free space of a group is reported as well, and graded only where thresholds are given: a group with every extent handed out is a perfectly normal and often deliberate state, and alerting on it by default would put a permanent warning on most hosts. Set the thresholds where free space has to be kept for a thin pool or a snapshot to grow into. Alerts when a volume group is missing a physical volume, and when its free space is outside the thresholds, if any are given. Requires root or sudo.

**Important Notes:**

* **Requires root or sudo.** `vgs` needs `/run/lock/lvm` and `/dev/mapper/control`, both of which are readable by root alone; membership of the `disk` group does not help. Deploy the sudoers file from `assets/sudoers/` and run the check through `sudo`.
* **The usage thresholds are off by default, on purpose.** A default install hands every extent of its volume group to root and swap and leaves nothing free, so a check that warns at 90% used would be in WARN on almost every host from the first run. Set `--warning` and `--critical` where free space actually has to be kept: on a host whose thin pools are supposed to be extended automatically, or where a backup takes a snapshot that needs room.
* **Free space in the volume group is what fixes a full thin pool and a full snapshot.** `lvextend` on a pool and `snapshot_autoextend_threshold` both need extents to hand out, so this is the check that tells you in advance whether the fix for those alerts will be available.
* **A group without a single logical volume is reported too.** It has a size and free space like any other, and it is often a group that was prepared and then forgotten.
* **`vgs` can hang on storage that has stopped answering.** It reads every physical volume on the host, so one that no longer answers blocks the whole command, and no signal ends the wait. The check gives it `--timeout` seconds and reports WARN with the device to look at when it does not come back.
* Related checks: `lvm-volumes` reports the health of the volumes in these groups, `lvm-thin-pools` and `lvm-snapshots` the things that need this free space.

**Data Collection:**

* Runs `vgs` once and reads its JSON report
* Reports every group, including one that holds no logical volume
* Requires root or sudo


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/lvm-volume-groups> |
| Nagios/Icinga Check Name              | `check_lvm_volume_groups` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | Yes |
| Runs on                               | Linux |
| Compiled for Windows                  | No |
| Requirements                          | command-line tool `vgs` (package `lvm2`); User with higher permissions |


## Help

```text
usage: lvm-volume-groups [-h] [-V] [--always-ok] [--brief] [-c CRIT]
                         [--ignore IGNORE] [--match MATCH]
                         [--no-match-severity {ok,warn,crit,unknown}]
                         [--no-perfdata] [--timeout TIMEOUT] [-w WARN]

Reports the LVM volume groups on this host, how many physical volumes each of
them is built from, and how many of those it can no longer find. A volume
group that is missing a physical volume carries volumes that are incomplete,
and it refuses to activate them at the next boot unless that is asked for
explicitly, so a reboot in this state comes back without them. The free space
of a group is reported as well, and graded only where thresholds are given: a
group with every extent handed out is a perfectly normal and often deliberate
state, and alerting on it by default would put a permanent warning on most
hosts. Set the thresholds where free space has to be kept for a thin pool or a
snapshot to grow into. Alerts when a volume group is missing a physical
volume, and when its free space is outside the thresholds, if any are given.
Requires root or sudo.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --brief               Hide the rows that are within the thresholds and show
                        only those in a WARN or CRIT state. Perfdata and
                        alerting are unaffected: every item still emits
                        performance data and still drives the overall check
                        state, so this is safe to leave on.
  -c, --critical CRIT   CRIT threshold for how much of a volume group is
                        handed out to logical volumes, in percent. Not set by
                        default, because a volume group with every extent in
                        use is a normal state and not a fault; set it where
                        free space has to be kept for a thin pool or a
                        snapshot to grow into. Supports Nagios ranges.
                        Example: `--critical=95` keeps a twentieth of the
                        group free for a pool or a snapshot to grow into.
                        Default: None
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
  -w, --warning WARN    WARN threshold for how much of a volume group is
                        handed out to logical volumes, in percent. Not set by
                        default, because a volume group with every extent in
                        use is a normal state and not a fault; set it where
                        free space has to be kept for a thin pool or a
                        snapshot to grow into. Supports Nagios ranges.
                        Example: `--warning=90` keeps a tenth of the group
                        free for a pool or a snapshot to grow into. Default:
                        None

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/lvm-volume-groups/
```


## Usage Examples

```bash
sudo ./lvm-volume-groups
```

Output on a default install, where every extent is handed out and that is exactly as intended:

```text
1 LVM volume group, 0.0B free in total.

Group ! Size    ! Free ! PVs ! LVs ! Snapshots ! Usage
------+---------+------+-----+-----+-----------+----------------
rl    ! 18.4GiB ! 0.0B ! 1   ! 2   ! 0         ! 100.00% in use
```

Output after a physical volume disappeared from a group:

```text
parttest is missing 1 of its 2 physical volumes.
Find the missing physical volume before anything else: `pvs` lists it as `[unknown]`, and `lsblk` plus the logs of the storage transport say whether the device is gone or merely unplugged. Once it is back, `vgchange --refresh` picks it up again; where it is gone for good, `vgreduce --removemissing` takes it out of the volume group, and whatever sat on it has to be restored from a backup.

Group    ! Size   ! Free      ! PVs           ! LVs ! Snapshots ! Usage
---------+--------+-----------+---------------+-----+-----------+-------------------------
parttest ! 4.0GiB ! 1016.0MiB ! 2 (1 missing) ! 1   ! 0         ! 75.15% in use [CRITICAL]
```

On a host whose thin pools are extended automatically, so the group needs to keep room for that:

```bash
sudo ./lvm-volume-groups --warning=80 --critical=90
```

Grade only the group the snapshots are taken in and leave the fully allocated system group alone:

```bash
sudo ./lvm-volume-groups --match='^datavg$' --warning=80 --critical=90
```


## States

* OK if no checked group is missing a physical volume, and if the thresholds, where they are given, are not exceeded.
* CRIT if a group cannot find one of its physical volumes. The volumes on it are incomplete and will not activate at the next boot.
* WARN or CRIT if the share of a group that is handed out to logical volumes reaches `--warning` or `--critical`. Both are unset by default, and nothing is graded until they are given.
* OK if the host has no volume group at all.
* OK if `--match` or `--ignore` leave nothing to check. `--no-match-severity` raises that.
* WARN if `vgs` did not answer within `--timeout`, and WARN if the LVM tools are not installed. Both are things to fix on the host, so they do not disappear into UNKNOWN.
* UNKNOWN if `vgs` refuses to report because the check is not running as root.
* UNKNOWN if the report cannot be read, if `--match` or `--ignore` is not a valid Python regular expression, or if a threshold does not parse.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

Two metrics per group, plus two counts over the whole host.

| Name | Type | Description |
|----|----|----|
| `<vg>_usage`             | Percentage | How much of the group is handed out to logical volumes. |
| `<vg>_free`              | Bytes | Extents the group has left to hand out. |
| volume_groups            | Number | Volume groups checked. |
| physical_volumes_missing | Number | Physical volumes the groups can no longer find. |

A metric name carries the volume group and the volume, which is what makes it readable in a graph. RRD tells two data sources apart by their first 19 characters, so on a host whose names are long enough to fill those 19 characters before the metric part begins, the graphs of one item merge into one. Shorter volume group and volume names are the only way around it.


## Troubleshooting

### `is missing 1 of its 2 physical volumes`

A device the volume group is built from is gone. Everything that had extents on it is incomplete, and at the next boot LVM will not activate those volumes at all unless partial activation is asked for explicitly.

1. Find out which device it is. LVM lists it as `[unknown]`:

    ```bash
    pvs
    vgs -o vg_name,vg_attr,vg_missing_pv_count,pv_count
    ```

2. Read what the transport said about it:

    ```bash
    lsblk
    journalctl --dmesg
    ```

3. Where the device is back, tell LVM to pick it up again:

    ```bash
    vgchange --refresh vg0
    ```

4. Where it is gone for good, take it out of the group. Everything that sat on it has to be restored from a backup:

    ```bash
    vgreduce --removemissing --force vg0
    ```

### A group is permanently at 100% and it is not a problem

That is the state of almost every default install: the installer hands the whole group to root and swap. It is only a problem where something is supposed to grow into that space, which is why the thresholds are unset by default. Set them on the groups where a thin pool is extended automatically or a backup takes a snapshot, and leave the system group ungraded:

```bash
lvm-volume-groups --match='^datavg$' --warning=80 --critical=90
```

### There is no room left to fix a full thin pool

`lvextend` on a pool needs free extents in its volume group, and there are none. Either the group grows, or something in it goes.

```bash
vgs -o vg_name,vg_size,vg_free
lvs -o lv_name,origin,lv_size,lv_time -S 'lv_role=~snapshot' vg0
```

Adding a device is the clean way out:

```bash
pvcreate /dev/sdc
vgextend vg0 /dev/sdc
```

### `LVM did not answer within 8s`

One of the physical volumes on this host has stopped answering. `vgs` reads all of them to find the volume groups, so a single unresponsive device blocks the command, and the wait cannot be interrupted by a signal.

```bash
lsblk
journalctl --dmesg
pvs
```

### `LVM refused to report as this user`

The check ran without the rights it needs. `/run/lock/lvm` and `/dev/mapper/control` belong to root, and no supplementary group changes that. Deploy the sudoers file from [assets/sudoers](https://github.com/Linuxfabrik/monitoring-plugins/tree/main/assets/sudoers) and let the monitoring agent call the check through `sudo`.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich, Switzerland](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
