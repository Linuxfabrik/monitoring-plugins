# Check lvm-thin-pools


## Overview

Monitors the LVM thin pools on this host. A thin pool hands out more space than it has, so the volumes living in it keep working only for as long as the pool has blocks left to give them. When its data runs out, the pool queues every write that reaches any of its volumes and starts failing them a minute later; when its metadata runs out, the pool turns read-only and stays that way until it is repaired. Both take every filesystem in the pool down at once, which is why they are reported apart from how full the pool is. LVM also stops creating new volumes and snapshots in a pool long before its metadata is full, and that boundary is reported for what it is. Alerts when a pool is fuller than the thresholds allow, when LVM will not create another snapshot in it, and when the pool has run out of data or metadata, failed, or is flagged as needing a check.

**The three ways a thin pool fails, and what each of them costs:**

| State | What the kernel does | What it takes to get out |
|----|----|----|
| `out_of_data` | Queues every write to every volume in the pool, then fails them after 60 seconds. The filesystems on top start logging I/O errors. | `lvextend` on the pool. It goes back into write mode the moment the extension lands. |
| `metadata_read_only` | Turns the pool read-only. Nothing in it takes a write any more, and a deactivation does not clear it. | `lvconvert --repair`, then a larger metadata volume. A resize alone does not help. |
| `failed` | The pool answers nothing at all. | Repair, and whatever the pool held has to be restored where the repair does not bring it back. |

**Important Notes:**

* **Requires root or sudo.** `lvs` needs `/run/lock/lvm` and `/dev/mapper/control`, both of which are readable by root alone; membership of the `disk` group does not help. Deploy the sudoers file from `assets/sudoers/` and run the check through `sudo`.
* **A full pool is not one volume's problem, it is the host's.** Every thin volume in the pool stops taking writes at the same moment, the origin of a snapshot as much as the snapshot. That is why the three states above are CRIT and the fill thresholds are not.
* **LVM refuses new snapshots long before the metadata is full.** It keeps the last 4 MiB, or the last quarter of a metadata volume smaller than 16 MiB, out of reach, so a pool with a 4 MiB metadata volume takes no new snapshot from 75% on while the pool itself is perfectly healthy. The check reports that boundary separately, computed per pool from the size of its metadata volume, and `--metadata-limit-severity` decides what it is worth. A flat percentage cannot cover this: 80% is too late for a small metadata volume and far too early for a large one.
* **On the Debian family the repair tools may not be installed.** `thin-provisioning-tools` is a *Recommends* of `lvm2`, not a dependency, so a host installed with `--no-install-recommends` has no `thin_check` and no `thin_repair`. LVM then skips the metadata check on every activation (`Check is skipped, please install recommended missing binary /usr/sbin/thin_check!`), and `lvconvert --repair`, which is the only way out of `metadata_read_only`, fails with `thin_repair: execvp failed: No such file or directory`. Install the package before a pool needs it, not after.
* **A pool that was deactivated and brought back reports no fault until the next write fails.** The health state comes from the running device-mapper target, so a pool that ran out of data space and was reactivated starts in write mode again and says nothing is wrong. Its fill level is still 100%, which is what the thresholds catch, and that is why they are not left to the health state alone.
* **Nothing grows a pool by itself.** `thin_pool_autoextend_threshold` in `lvm.conf` is 100 on both the Red Hat and the Debian family, which means the pool is never extended automatically. Set it below 100 and make sure `lvm2-monitor.service` is running, because the extension is done by `dmeventd`.
* **`lvs` can hang on storage that has stopped answering.** It reads every physical volume on the host, so one that no longer answers blocks the whole command, and no signal ends the wait. The check gives it `--timeout` seconds and reports WARN with the device to look at when it does not come back.
* Related checks: `lvm-snapshots` reports the snapshots that draw on these pools, `lvm-volumes` the health of everything else, and `lvm-volume-groups` whether there is free space left to extend a pool into.

**Data Collection:**

* Runs `lvs` once and reads its JSON report
* Grades the data and the metadata of every thin pool against thresholds of their own
* Computes per pool the fill level at which LVM stops creating thin volumes and snapshots in it
* Requires root or sudo


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/lvm-thin-pools> |
| Nagios/Icinga Check Name              | `check_lvm_thin_pools` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | Yes |
| Runs on                               | Linux |
| Compiled for Windows                  | No |
| Requirements                          | command-line tool `lvs` (package `lvm2`); User with higher permissions |


## Help

```text
usage: lvm-thin-pools [-h] [-V] [--always-ok] [--brief] [-c CRIT]
                      [--critical-metadata CRIT_METADATA] [--ignore IGNORE]
                      [--match MATCH]
                      [--metadata-limit-severity {ok,warn,crit,unknown}]
                      [--no-match-severity {ok,warn,crit,unknown}]
                      [--no-perfdata] [--timeout TIMEOUT] [-w WARN]
                      [--warning-metadata WARN_METADATA]

Monitors the LVM thin pools on this host. A thin pool hands out more space
than it has, so the volumes living in it keep working only for as long as the
pool has blocks left to give them. When its data runs out, the pool queues
every write that reaches any of its volumes and starts failing them a minute
later; when its metadata runs out, the pool turns read-only and stays that way
until it is repaired. Both take every filesystem in the pool down at once,
which is why they are reported apart from how full the pool is. LVM also stops
creating new volumes and snapshots in a pool long before its metadata is full,
and that boundary is reported for what it is. Alerts when a pool is fuller
than the thresholds allow, when LVM will not create another snapshot in it,
and when the pool has run out of data or metadata, failed, or is flagged as
needing a check. Requires root or sudo.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --brief               Hide the rows that are within the thresholds and show
                        only those in a WARN or CRIT state. Perfdata and
                        alerting are unaffected: every item still emits
                        performance data and still drives the overall check
                        state, so this is safe to leave on.
  -c, --critical CRIT   CRIT threshold for how much of the data space of a
                        pool is in use, in percent. Supports Nagios ranges.
                        Default: 90
  --critical-metadata CRIT_METADATA
                        CRIT threshold for how much of the metadata volume of
                        a pool is in use, in percent. Supports Nagios ranges.
                        Default: 90
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
  --metadata-limit-severity {ok,warn,crit,unknown}
                        State to report for a pool whose metadata is full
                        enough that LVM refuses to create another thin volume
                        or snapshot in it. The boundary is not a threshold but
                        a rule inside LVM: it keeps the last 4 MiB, or the
                        last quarter of a metadata volume smaller than 16 MiB,
                        out of reach. The pool itself keeps working, which is
                        why this is reported separately from how full it is.
                        Default: warn
  --no-match-severity {ok,warn,crit,unknown}
                        State to report when no item matches the filters and
                        nothing is checked. Default: ok
  --no-perfdata         Suppress the performance data section from the output.
                        The status message and the exit code are unaffected,
                        so alerting keeps working while trending data is
                        dropped.
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
  -w, --warning WARN    WARN threshold for how much of the data space of a
                        pool is in use, in percent. Supports Nagios ranges.
                        Default: 80
  --warning-metadata WARN_METADATA
                        WARN threshold for how much of the metadata volume of
                        a pool is in use, in percent. Supports Nagios ranges.
                        Default: 80

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/lvm-thin-pools/
```


## Usage Examples

```bash
sudo ./lvm-thin-pools
```

Output on a host whose pools are within their thresholds:

```text
1 LVM thin pool, the fullest at 50%.

Pool         ! Size   ! Data   ! Metadata Size ! Metadata ! Volumes ! When Full ! Health
-------------+--------+--------+---------------+----------+---------+-----------+--------
testvg/tpool ! 2.0GiB ! 50.00% ! 8.0MiB        ! 15.33%   ! 2       ! queue     ! healthy
```

Output after a pool ran out of data space, while the filesystems in it are taking I/O errors:

```text
testvg/dpool: the pool is out of data space, so every write to a volume in it is queued and then failed.
Give the pool room with `lvextend --size +10G vg0/pool0`, which puts it back into write mode as soon as it lands. Where the volume group has nothing left to give, remove what the pool is holding for nothing first, old snapshots above all. `thin_pool_autoextend_threshold` in `lvm.conf` is 100 by default, which means LVM never grows a pool on its own; setting it below 100 is what turns this into a problem that fixes itself.

Pool         ! Size     ! Data    ! Metadata Size ! Metadata ! Volumes ! When Full ! Health
-------------+----------+---------+---------------+----------+---------+-----------+-----------------------
testvg/dpool ! 512.0MiB ! 100.00% ! 8.0MiB        ! 12.79%   ! 1       ! queue     ! out_of_data [CRITICAL]
```

Output for a pool that is still perfectly healthy and will not take another snapshot:

```text
testvg/lpool is too full of metadata for LVM to create another snapshot in it (80% of 75%).
LVM keeps the last 4 MiB, or the last quarter of a small metadata volume, out of reach and refuses to create another thin volume or snapshot once the metadata is that full. The pool itself keeps working. `lvextend --poolmetadatasize +64M vg0/pool0` gives it room again.

Pool         ! Size     ! Data  ! Metadata Size ! Metadata ! Volumes ! When Full ! Health
-------------+----------+-------+---------------+----------+---------+-----------+----------------------------
testvg/lpool ! 256.0MiB ! 0.00% ! 4.0MiB        ! 80.08%   ! 1       ! queue     ! at metadata limit [WARNING]
```

Warn earlier on a host whose pools cannot be extended quickly:

```bash
sudo ./lvm-thin-pools --warning=70 --critical=85
```

Where the pools are extended automatically and the metadata boundary is watched by hand:

```bash
sudo ./lvm-thin-pools --metadata-limit-severity=ok
```

Leave one pool out, for example one that is deliberately overcommitted in a test environment:

```bash
sudo ./lvm-thin-pools --ignore='^testvg/scratch'
```


## States

* OK if every checked pool is within its thresholds, healthy, and below the fill level at which LVM stops creating volumes in it.
* WARN if the data of a pool is at or above `--warning` (default `80`), CRIT at or above `--critical` (default `90`).
* WARN if the metadata of a pool is at or above `--warning-metadata` (default `80`), CRIT at or above `--critical-metadata` (default `90`).
* WARN if the metadata of a pool is full enough that LVM refuses to create another thin volume or snapshot in it. That boundary is `100% - min(25%, 4 MiB / metadata size)` and is computed per pool. `--metadata-limit-severity` changes it. A pool that is already read-only is not reported twice for this.
* CRIT if a pool is out of data space, has read-only metadata, or has failed. In all three the volumes in the pool are not taking writes.
* WARN if a pool is flagged as needing a check.
* OK if the host has no thin pool at all.
* OK if `--match` or `--ignore` leave nothing to check. `--no-match-severity` raises that.
* WARN if `lvs` did not answer within `--timeout`, and WARN if the LVM tools are not installed. Both are things to fix on the host, so they do not disappear into UNKNOWN.
* UNKNOWN if `lvs` refuses to report because the check is not running as root.
* UNKNOWN if the report cannot be read, if `--match` or `--ignore` is not a valid Python regular expression, or if a threshold does not parse.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

Two metrics per pool, plus two counts over the whole host.

| Name | Type | Description |
|----|----|----|
| `<vg>_<lv>_data_usage`     | Percentage | How much of the data space of that pool is handed out. |
| `<vg>_<lv>_metadata_usage` | Percentage | How much of the metadata volume of that pool is in use. |
| thin_pools                 | Number | Thin pools checked. |
| thin_pools_degraded        | Number | Pools that are not in the state they should be in. |

A metric name carries the volume group and the volume, which is what makes it readable in a graph. RRD tells two data sources apart by their first 19 characters, so on a host whose names are long enough to fill those 19 characters before the metric part begins, the graphs of one item merge into one. Shorter volume group and volume names are the only way around it.


## Troubleshooting

### `the pool is out of data space`

The volumes in the pool have asked for more blocks than the pool has. The kernel holds their writes for 60 seconds and then starts failing them, so the filesystems on top go read-only or start losing data. This is the one state here worth acting on at night.

1. See how bad it is and what is holding the space:

    ```bash
    lvs -a -o lv_name,lv_attr,data_percent,metadata_percent,lv_size vg0
    ```

2. Give the pool room. It goes back into write mode as soon as the extension lands:

    ```bash
    lvextend --size +10G vg0/pool0
    ```

3. Where the volume group has nothing left, take something out of the pool first. Old snapshots are usually what is holding the blocks:

    ```bash
    lvs -o lv_name,origin,lv_time -S 'lv_role=~snapshot' vg0
    lvremove vg0/old-snapshot
    ```

4. Then make sure it does not happen again unattended:

    ```bash
    # /etc/lvm/lvm.conf
    #   thin_pool_autoextend_threshold = 70
    #   thin_pool_autoextend_percent = 20
    systemctl enable --now lvm2-monitor.service
    ```

5. Check the filesystems that took the errors. A read-only ext4 needs a remount, and often an `fsck`:

    ```bash
    journalctl --dmesg --grep='I/O error'
    ```

### `the pool metadata is full, so the pool has gone read-only`

This one does not come back with a resize. The pool has to be checked and repaired first, and it survives a deactivation, so a reboot changes nothing.

1. Deactivate everything in the pool. LVM refuses the repair while any sub-volume is still up, and the message it gives then (`Cannot repair active pool`) does not say which one:

    ```bash
    vgchange -an vg0
    lvs -a -o lv_name,lv_attr,lv_active vg0
    ```

2. Repair the metadata. On the Debian family this needs `apt install thin-provisioning-tools` first, because `lvm2` only recommends it. LVM swaps in a new metadata volume and leaves the old one behind as `<pool>_meta0`, which is worth keeping until the pool is proven good again:

    ```bash
    lvconvert --repair vg0/pool0
    ```

3. Give the repaired pool a metadata volume that is large enough, then activate it:

    ```bash
    lvextend --poolmetadatasize +64M vg0/pool0
    lvchange -ay vg0/pool0
    ```

### `too full of metadata for LVM to create another snapshot in it`

Nothing is broken. LVM keeps a reserve of free metadata and refuses to create another thin volume or snapshot once the pool eats into it, which is the smaller of 4 MiB and a quarter of the metadata volume. A backup job that takes a snapshot will start failing with `Cannot create new thin volume, free space in thin pool reached threshold`, while everything already in the pool keeps working.

```bash
lvs -o lv_name,lv_metadata_size,metadata_percent vg0/pool0
lvextend --poolmetadatasize +64M vg0/pool0
```

A pool whose metadata volume is 16 MiB or smaller hits this at 75%, one with 64 MiB at 93.75%. Sizing the metadata volume generously in the first place is what keeps it out of the way.

### `LVM did not answer within 8s`

One of the physical volumes on this host has stopped answering. `lvs` reads all of them to find the volume groups, so a single unresponsive device blocks the command, and the wait cannot be interrupted by a signal.

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
