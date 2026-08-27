# Check lvm-volumes


## Overview

Reports the health of the LVM logical volumes on this host: a volume whose physical volume has gone missing, a mirrored or RAID volume running on fewer legs than it was built with, a cache that has failed, and a volume that is not active. LVM answers all of this with a state and never with a number, so there is nothing to set a threshold on. A volume that has lost a physical volume is the one that deserves the most attention: it is not only incomplete, it also refuses to come up at the next boot unless it is activated in partial mode by hand. Snapshots and thin pools are checked by `lvm-snapshots` and `lvm-thin-pools`, so nothing is reported twice. Alerts when a volume is missing a physical volume, when a RAID volume needs a refresh or a repair, when a scrub found copies that disagree, when a cache has failed, and when a volume is flagged as needing a check.

**What LVM reports about a volume, and what it means:**

| Health | Reported as | Meaning |
|----|----|----|
| `partial`                  | CRIT | One of the physical volumes the volume sits on is missing. The volume is incomplete and will not activate at the next boot. |
| `failed`                   | CRIT | A cache has failed and answers nothing. |
| `refresh needed`           | WARN | A leg the kernel marked dead. Up to lvm2 2.03.38 this covers both the device that is back and the one that is gone for good. |
| `repair needed`            | WARN | A leg whose device is gone for good and has to be replaced. Only reported by lvm2 2.03.39 and newer. |
| `refresh or repair needed` | WARN | The array is reshaping and LVM cannot tell the two apart. Only reported by lvm2 2.03.39 and newer. |
| `mismatches exist`         | WARN | A scrub found blocks whose copies disagree. |
| `metadata_read_only`       | WARN | The metadata of a cache is full and it has gone read-only. |
| `error`                    | WARN | A writecache is erroring. |
| `writemostly`              | WARN | A leg is marked write-mostly and is read from only as a last resort. |
| `unknown`                  | WARN | The state of an array could not be read. |

**Important Notes:**

* **Requires root or sudo.** `lvs` needs `/run/lock/lvm` and `/dev/mapper/control`, both of which are readable by root alone; membership of the `disk` group does not help. Deploy the sudoers file from `assets/sudoers/` and run the check through `sudo`.
* **A degraded RAID volume still reports 100% synchronised.** `copy_percent` and `raid_sync_action` say `100.00` and `idle` while the array runs on one leg, because the legs it still has are in sync with each other. Only the health state gives it away, which is why this check reports no synchronisation percentage.
* **`partial` hides the RAID state.** LVM tests for a missing physical volume before every other case, so a raid1 whose leg is gone reports `partial` and never `refresh needed`. The RAID states show up once the device is back.
* **`refresh needed` covers more than its name says.** Up to lvm2 2.03.38 a leg the kernel has marked dead reports `refresh needed` whether its device is back or gone for good; `lvchange --refresh` fixes the first case and `lvconvert --repair` the second, so look at the device before picking one. From 2.03.39 on LVM tells the two apart and reports `repair needed` for the latter.
* **An inactive volume does not alert by default.** A volume belonging to a machine that is switched off, and one created with activation skipped, are both inactive and both fine. On a host where every volume is supposed to be up, `--inactive-severity=warn` turns an activation that silently did not happen at boot into an alert.
* **Snapshots and thin pools are deliberately left out.** They have checks of their own, so one missing physical volume raises one alert and not three.
* **`lvs` can hang on storage that has stopped answering.** It reads every physical volume on the host, so one that no longer answers blocks the whole command, and no signal ends the wait. The check gives it `--timeout` seconds and reports WARN with the device to look at when it does not come back.
* Related checks: `lvm-snapshots`, `lvm-thin-pools` and `lvm-volume-groups` cover the rest of LVM, `md-raid` covers software RAID built with `mdadm` rather than with LVM, and `disk-usage` covers how full the filesystems on these volumes are.

**Data Collection:**

* Runs `lvs` once and reads its JSON report
* Reports the health state of every volume that is neither a snapshot nor a thin pool
* Requires root or sudo


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/lvm-volumes> |
| Nagios/Icinga Check Name              | `check_lvm_volumes` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | Yes |
| Runs on                               | Linux |
| Compiled for Windows                  | No |
| Requirements                          | command-line tool `lvs` (package `lvm2`); User with higher permissions |


## Help

```text
usage: lvm-volumes [-h] [-V] [--always-ok] [--brief] [--ignore IGNORE]
                   [--inactive-severity {ok,warn,crit,unknown}]
                   [--match MATCH]
                   [--no-match-severity {ok,warn,crit,unknown}]
                   [--no-perfdata] [--timeout TIMEOUT]

Reports the health of the LVM logical volumes on this host: a volume whose
physical volume has gone missing, a mirrored or RAID volume running on fewer
legs than it was built with, a cache that has failed, and a volume that is not
active. LVM answers all of this with a state and never with a number, so there
is nothing to set a threshold on. A volume that has lost a physical volume is
the one that deserves the most attention: it is not only incomplete, it also
refuses to come up at the next boot unless it is activated in partial mode by
hand. Snapshots and thin pools are checked by lvm-snapshots and
lvm-thin-pools, so nothing is reported twice. Alerts when a volume is missing
a physical volume, when a RAID volume needs a refresh or a repair, when a
scrub found copies that disagree, when a cache has failed, and when a volume
is flagged as needing a check. Requires root or sudo.

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
  --inactive-severity {ok,warn,crit,unknown}
                        State to report for a volume that is not active. A
                        volume is deliberately left inactive often enough that
                        this does not alert by default: one that belongs to a
                        machine that is switched off, and one created with
                        activation skipped, are both inactive and both
                        perfectly fine. Raise it on a host where every volume
                        is supposed to be up, and an activation that silently
                        did not happen at boot becomes visible. Default: ok
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

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/lvm-volumes/
```


## Usage Examples

```bash
sudo ./lvm-volumes
```

Output on a plain host:

```text
2 LVM logical volumes, 2 healthy.

Volume  ! Layout ! Size    ! Pool ! Usage ! Active ! Health
--------+--------+---------+------+-------+--------+--------
rl/root ! linear ! 16.4GiB ! -    ! -     ! yes    ! healthy
rl/swap ! linear ! 2.0GiB  ! -    ! -     ! yes    ! healthy
```

Output after a physical volume disappeared underneath a volume:

```text
parttest/spanned: one of the physical volumes it sits on is missing.
Find the missing physical volume before anything else: `pvs` lists it as `[unknown]`, and `lsblk` plus the logs of the storage transport say whether the device is gone or merely unplugged. A volume group that is missing a physical volume does not activate its incomplete volumes at the next boot, so a host in this state comes back up without them. Once the device is back, `vgchange --refresh` picks it up again; where it is gone for good, `vgreduce --removemissing` takes it out of the volume group and whatever sat on it has to be restored.

Volume           ! Layout ! Size   ! Pool ! Usage ! Active ! Health
-----------------+--------+--------+------+-------+--------+-------------------
parttest/spanned ! linear ! 3.0GiB ! -    ! -     ! yes    ! partial [CRITICAL]
```

Output after a leg of a RAID volume came back and the array has not been told to use it again:

```text
raidvg/r1: a device came back and the array has not been refreshed onto it.
A RAID volume that needs a refresh has all its devices back and has not been told to use them yet, which `lvchange --refresh` does. One that needs a repair is missing a device that has to be replaced first, with `lvconvert --repair`. In both states the volume reports 100% synchronised, because the legs it still has are in sync with each other.

Volume    ! Layout     ! Size     ! Pool ! Usage ! Active ! Health
----------+------------+----------+------+-------+--------+--------------------------
raidvg/r1 ! raid,raid1 ! 400.0MiB ! -    ! -     ! yes    ! refresh needed [WARNING]
```

A thin volume reports how much of its virtual size carries data; a thick one has all of its size allocated and reports nothing, which is not a zero:

```text
2 LVM logical volumes, 2 healthy.

Volume      ! Layout      ! Size    ! Pool  ! Usage  ! Active ! Health
------------+-------------+---------+-------+--------+--------+--------
rl/root     ! linear      ! 16.4GiB ! -     ! -      ! yes    ! healthy
testvg/tvol ! thin,sparse ! 4.0GiB  ! tpool ! 25.00% ! yes    ! healthy
```

On a host where every volume is supposed to be up, so an activation that did not happen at boot becomes visible:

```bash
sudo ./lvm-volumes --inactive-severity=warn
```

Leave one volume group out, for example one belonging to virtual machines that are switched off most of the time:

```bash
sudo ./lvm-volumes --ignore='^vmvg/'
```

On a host with hundreds of volumes, `--brief` prints only the ones that are not healthy, while every volume still drives the state:

```bash
sudo ./lvm-volumes --brief
```


## States

* OK if every checked volume is healthy.
* CRIT if a volume is missing one of its physical volumes, or if a cache has failed.
* WARN for every other health state LVM reports: a RAID volume that needs a refresh or a repair, a scrub that found copies which disagree, a writecache that is erroring, a cache whose metadata is read-only, a leg marked write-mostly, an array whose state could not be read, and a volume flagged as needing a check.
* OK if a volume is not active. `--inactive-severity` raises that.
* OK if the host has no logical volume at all.
* OK if `--match` or `--ignore` leave nothing to check. `--no-match-severity` raises that.
* WARN if `lvs` did not answer within `--timeout`, and WARN if the LVM tools are not installed. Both are things to fix on the host, so they do not disappear into UNKNOWN.
* UNKNOWN if `lvs` refuses to report because the check is not running as root.
* UNKNOWN if the report cannot be read, or if `--match` or `--ignore` is not a valid Python regular expression.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

Counts over all checked volumes. There is no per-volume metric, because what LVM reports here is a state and not a number.

| Name | Type | Description |
|----|----|----|
| volumes           | Number | Logical volumes checked, snapshots and thin pools excluded. |
| volumes_degraded  | Number | Volumes LVM reports a health problem for. |
| volumes_inactive  | Number | Volumes that are not active. |


## Troubleshooting

### `one of the physical volumes it sits on is missing`

A device the volume group is built from is gone. The volume is incomplete now, and at the next boot LVM will not activate it at all unless partial activation is asked for explicitly, so a host in this state comes back up without the filesystem on that volume.

1. Find out which device it is. LVM lists it as `[unknown]`:

    ```bash
    pvs
    vgs -o vg_name,vg_missing_pv_count,pv_count
    ```

2. Read what the transport said about it. A device rarely disappears quietly:

    ```bash
    lsblk
    journalctl --dmesg
    ```

3. Where the device is back, tell LVM to pick it up again:

    ```bash
    vgchange --refresh vg0
    ```

4. Where it is gone for good, take it out of the volume group. Everything that sat on it has to be restored from a backup:

    ```bash
    vgreduce --removemissing --force vg0
    ```

5. Until then, an incomplete volume can be activated for a rescue attempt, which is also what a boot in this state would need:

    ```bash
    vgchange -ay --activationmode partial vg0
    ```

### `a device came back and the array has not been refreshed onto it`

A leg of a mirrored or RAID volume was missing and is available again. LVM does not start using it by itself, so the array keeps running with less redundancy than it looks like.

```bash
lvchange --refresh vg0/raidvol
lvs -o lv_name,lv_attr,lv_health_status,sync_percent vg0
```

Where the leg is gone for good, the array needs a replacement device instead:

```bash
lvconvert --repair vg0/raidvol
```

### `a scrub found blocks whose copies disagree`

A `lvchange --syncaction check` run found blocks whose copies are not identical. LVM cannot tell which copy is right, so it only counts them.

```bash
lvs -o lv_name,raid_mismatch_count,raid_sync_action vg0
lvchange --syncaction repair vg0/raidvol
```

A repair overwrites the mismatching blocks from the first leg, which is a guess, so verify the data afterwards. A rising count on a RAID 1 is a reason to look at the disks with `disk-smart`. Note that the array reports 100% synchronised and an idle sync action throughout, so the count and the health state are the only signals there are.

### A volume is reported as not active and nothing seems wrong

That is the default answer for a volume LVM did not bring up, and it is often correct: a volume group belonging to a machine that is switched off, or a volume created with activation skipped, both read as inactive. Look at it when the volume is one of those that should be up at every boot:

```bash
lvs -o lv_name,lv_attr,lv_active vg0
journalctl --unit=lvm2-monitor.service
vgchange -ay vg0
```

### `LVM did not answer within 8s`

One of the physical volumes on this host has stopped answering. `lvs` reads all of them to find the volume groups, so a single unresponsive device blocks the command, and the wait cannot be interrupted by a signal.

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
