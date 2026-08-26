# Check md-raid


## Overview

Reports the health of the Linux software RAID arrays (md) on this host: how many member devices each array is running on, which of them the kernel has thrown out, whether a resync, recovery or reshape is under way, and how many inconsistent sectors the last consistency check found. Every array the kernel knows is reported, so an array nobody remembers is on the list as well. Alerts when an array has lost the redundancy it was built for, when the kernel declares it failed, and when a consistency check found differences between the members of a parity array. Supports extended reporting via `--lengthy`.

**What the kernel reports:**

An array is in exactly one of these states, and the check takes the word from the kernel rather than deriving one of its own:

| State | Meaning |
|----|----|
| `active` | The array is running. It may still be missing members, which is what the device counters below say. |
| `active (read-only)` | Someone put the array into read-only mode with `mdadm --readonly`. Not a fault. |
| `active (auto-read-only)` | The array was assembled and has not been written to yet, so the kernel is holding back the resync it would otherwise start. The first write switches it to `active`. Not a fault. |
| `inactive` | The array was assembled but never started, because not enough of its members turned up. |
| `broken` | The array has lost so many members that it can no longer serve its data. |

Below that, a redundant array reports how many members it wants and how many are in sync, as `3/4 [_UUU]`: three of four slots are filled, and the first one is not.

**Important Notes:**

* **RAID 0 and linear arrays report almost nothing, and that is not a gap in the check.** They have no redundancy, so the kernel gives them no device counters, no `degraded` attribute and no consistency check. A member that fails while it is still plugged in is invisible: the array keeps reporting `active` and the I/O errors go to whoever was reading. Only a member that is really gone from the system flips the array to `broken`, and even that happens on the first I/O that touches it, not at the moment the disk disappears. Measured on kernel 7.1 by removing the member's PCI device: the array stayed `active` with every member still `in_sync` until something wrote to it. Where the data on a RAID 0 matters, the disks below it need `disk-smart` as well.
* **A consistency check is not run by itself.** The `mismatch_cnt` this check reports is whatever the last `check` or `repair` run left behind, and it stays at that value until the next one runs. Both the Red Hat and the Debian family ship a timer or cron job for it (`mdcheck_start.timer` / `mdcheck_continue.timer`, or `/etc/cron.d/mdadm`); on a host where none of them is enabled, the number reported here is meaningless because nothing ever produced it.
* **A mismatch on a mirror is not the same finding as a mismatch on a parity array.** md(4) is explicit about it: on RAID 5 and RAID 6 "any mismatches should indicate a hardware problem at some level - software issues should never cause such a mismatch", while on RAID 1 and RAID 10 a page written while the check reads it, and above all a swap area, leave the copies different in a place nothing ever reads back, so "the mismatch_cnt value can not be interpreted very reliably". That is why `--mismatch-severity` defaults to `warn` and `--mirror-mismatch-severity` to `ok`. Both numbers are always reported and always in the performance data, so a mirror whose count keeps growing from check to check is still visible on the graph.
* **The commands in the output name this host's array and this host's member.** Where the check reports a problem, the `mdadm` lines it suggests carry the real names it just read, so they can be copied without being checked against the machine first. The one thing it cannot know is the device of the replacement disk, and the text asks for it in words rather than inventing a path.
* **Neither the kernel device nor the array name is a stable identifier, so both are reported.** The kernel hands out `md127` from a pool when the array is assembled, which can differ between boots on a host with several arrays, and the name an array was created under gains a `<homehost>:` prefix as soon as mdadm stops treating the array as local. Measured on a host still called `localhost.localdomain`, where the same array was `/dev/md/raid5` after creation and `/dev/md/localhost.localdomain:raid5` after the next boot. The kernel device is what every `mdadm` command and every path below `/sys` takes, so it is the identifier the check reports and labels its performance data with; `--lengthy` shows the name beside it, and `--match` and `--ignore` accept either.
* **A spare that stepped in does not close the case.** Once the rebuild is done the array reports its full width again and the kernel's `degraded` counter is back to zero, while the member it threw out is still attached and still flagged. Nothing is degraded and a disk has died all the same, which is why the check keeps reporting such an array until the failed device is removed. The array also has no spare left, so the next failure has nothing to fall back on.
* **A rebuild does not raise the state by itself.** An array that is recovering onto a spare is degraded, and the degradation is what alerts; the progress is reported next to it. An array that is merely resyncing after an unclean shutdown, being checked, or being reshaped, is not a problem and stays OK.
* **The count of inconsistent sectors is not the count of bad sectors.** md works in units much larger than a sector, so a single error inside a 64 KiB unit adds 128 to the counter.
* **A host with no array at all reports WARN.** An array is assembled from the superblocks on its members at every boot, so an array that used to be here and is gone is worth a look. Lower it with `--no-arrays-severity=ok` on a host that is meant to run the check without having an array.
* Related checks: `disk-smart` reports the health of the disks the arrays are built on, `disk-io` their load, and `fs-mounts` whether what is on top of an array is actually mounted.

**Data Collection:**

* Reads `/proc/mdstat` for the list of arrays, their members and the progress of a running resync, recovery, reshape or check
* Reads `array_state`, `degraded`, `level`, `mismatch_cnt`, `raid_disks` and `sync_action` below `/sys/block/md*/md`
* Needs no root and no `sudo`, and calls no external command


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/md-raid> |
| Nagios/Icinga Check Name              | `check_md_raid` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Runs on                               | Linux |
| Compiled for Windows                  | No |


## Help

```text
usage: md-raid [-h] [-V] [--always-ok] [--ignore IGNORE] [--lengthy]
               [--match MATCH]
               [--mirror-mismatch-severity {ok,warn,crit,unknown}]
               [--mismatch-severity {ok,warn,crit,unknown}]
               [--no-arrays-severity {ok,warn,crit,unknown}]
               [--no-match-severity {ok,warn,crit,unknown}] [--no-perfdata]
               [--severity {ok,warn,crit,unknown}]

Reports the health of the Linux software RAID arrays (md) on this host: how
many member devices each array is running on, which of them the kernel has
thrown out, whether a resync, recovery or reshape is under way, and how many
inconsistent sectors the last consistency check found. Every array the kernel
knows is reported, so an array nobody remembers is on the list as well. Alerts
when an array has lost the redundancy it was built for, when the kernel
declares it failed, and when a consistency check found differences between the
members of a parity array. Supports extended reporting via --lengthy.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
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
  --mirror-mismatch-severity {ok,warn,crit,unknown}
                        State to report when a consistency check found
                        inconsistent sectors on a mirrored array (RAID 1, RAID
                        10). A page written while the check reads it, and
                        above all a swap area, produce differences between the
                        copies that nothing ever reads back, which is why this
                        defaults to not alerting. Default: ok
  --mismatch-severity {ok,warn,crit,unknown}
                        State to report when a consistency check found
                        inconsistent sectors on a parity array (RAID 4, RAID
                        5, RAID 6). On such an array the difference points at
                        hardware rather than at the way the data was written.
                        Default: warn
  --no-arrays-severity {ok,warn,crit,unknown}
                        State to report when the host runs no software RAID
                        array at all. An array is assembled from the
                        superblocks on its members at every boot, so an array
                        that used to be here and is gone is worth looking at.
                        Default: warn
  --no-match-severity {ok,warn,crit,unknown}
                        State to report when no item matches the filters and
                        nothing is checked. Default: ok
  --no-perfdata         Suppress the performance data section from the output.
                        The status message and the exit code are unaffected,
                        so alerting keeps working while trending data is
                        dropped.
  --severity {ok,warn,crit,unknown}
                        Severity for alerting. Applies to an array that is
                        running on fewer members than it was built for, so it
                        has lost the redundancy it is meant to provide, and to
                        a member the kernel threw out that is still attached
                        to an array a spare has already brought back to its
                        full width. Default: warn

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/md-raid/
```


## Usage Examples

```bash
./md-raid
```

Output on a host whose arrays are all complete:

```text
2 software RAID arrays, all of them intact.

Array ! Level ! Devices    ! State
------+-------+------------+-------
md0   ! raid1 ! 2/2 [UU]   ! active
md1   ! raid5 ! 4/4 [UUUU] ! active
```

Output while an array rebuilds onto a spare after a disk was replaced:

```text
md0: recovery 1.5%, 1m left, 2.0MiB/s, degraded, running on 1 of 2 devices.
md0 is already rebuilding onto a replacement, so let it finish. The member the kernel threw out (vda) can be taken out at any point with `mdadm /dev/md0 --remove /dev/vda`. Until the rebuild is done, the array has no redundancy left to lose.

Array ! Level ! Devices  ! State
------+-------+----------+-------------------
md0   ! raid1 ! 1/2 [_U] ! degraded [WARNING]
```

A running resync, recovery, reshape or check always leads that first line, because whether an array is already healing decides what happens next, and the first line is the only part of the output a service list and a notification show.

Output after a spare finished rebuilding, where the array is complete again and the dead disk is still in it:

```text
md1: complete again but still carrying 1 failed member (vdc).
The array is back to its full width, so a spare has stepped in or the member was replaced, and the device the kernel threw out is still attached. Take it out with `mdadm /dev/md0 --remove /dev/sdb1` and put a new spare in, because the next failure has nothing left to fall back on.

Array ! Level ! Devices   ! State
------+-------+-----------+----------------------------------
md1   ! raid5 ! 3/3 [UUU] ! failed member attached [WARNING]
```

Output on an array the kernel has given up on:

```text
md0: broken.
The kernel has stopped serving this array. Do not write to it and do not recreate it: `mdadm --assemble --force` on the members that are still readable is the way back, and it needs the members left untouched.

Array ! Level ! Devices  ! State
------+-------+----------+------------------
md0   ! raid1 ! 0/2 [__] ! broken [CRITICAL]
```

`--lengthy` adds the metadata version, the members carrying a flag, the inconsistent sectors from the last consistency check and what the array is currently doing:

```bash
./md-raid --lengthy
```

```text
1 software RAID array, intact.
md5: reshape 2.7%, 1m 6s left, 1.8MiB/s

Array ! Level ! Devices    ! Metadata ! Flagged Members ! Mismatches ! Sync                               ! State
------+-------+------------+----------+-----------------+------------+------------------------------------+-------
md5   ! raid5 ! 4/4 [UUUU] ! 1.2      ! -               ! 0          ! reshape 2.7%, 1m 6s left, 1.8MiB/s ! active
```

The flagged members are the ones the kernel prints a marker behind: `faulty` for a member it threw out, `spare` for one waiting to be pulled in, `replacement` for one being built up next to the member it replaces, `write-mostly` for a mirror leg reads avoid, and `journal` for the write journal of a parity array. A member without a marker is doing its ordinary job and is not listed.

On a host where a lost RAID member is a reason to act at night:

```bash
./md-raid --severity=crit
```

On a mirror over a swap area, where the mismatch count is expected to move and only the redundancy matters:

```bash
./md-raid --mirror-mismatch-severity=ok
```

Leave a single array out, for example one that is deliberately kept degraded:

```bash
./md-raid --ignore='^md9$'
```


## States

* OK if every array is running on all the members it was built for and no reported consistency check found anything.
* WARN if an array is running on fewer members than it was built for. `--severity` lowers that to `ok` or raises it to `crit` or `unknown`.
* WARN if a member the kernel threw out is still attached to an array that is back to its full width, which is what a spare taking over leaves behind. `--severity` applies here too.
* WARN if the last consistency check on a parity array (RAID 4, RAID 5, RAID 6) found inconsistent sectors. `--mismatch-severity` changes it.
* OK with the count reported if the last consistency check on a mirror (RAID 1, RAID 10) found inconsistent sectors. `--mirror-mismatch-severity` raises it.
* CRIT if the kernel reports an array as `broken`, which is its own word for an array that can no longer serve its data.
* CRIT if an array is `inactive`, which means it was assembled but never started.
* WARN if the host runs no software RAID array at all, and WARN with a different explanation on a kernel that has no md support loaded, which are two different statements. `--no-arrays-severity` changes both.
* OK if `--match` and `--ignore` leave nothing to check. `--no-match-severity` raises that.
* UNKNOWN if `--match` or `--ignore` is not a valid Python regular expression.
* UNKNOWN if the check does not run on Linux.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

The array counts are taken after `--match` and `--ignore` have been applied, so an array silenced with `--ignore` is out of the graph as well.

| Name | Type | Description |
|----|----|----|
| arrays                     | Number | Software RAID arrays the kernel knows about. |
| arrays_broken              | Number | Arrays the kernel can no longer serve data from. |
| arrays_degraded            | Number | Arrays running on fewer members than they were built for. |
| arrays_inactive            | Number | Arrays that were assembled but never started. |
| arrays_syncing             | Number | Arrays with a resync, recovery, reshape or consistency check running. |
| devices_faulty             | Number | Member devices the kernel has thrown out, across all arrays. |
| devices_spare              | Number | Member devices standing by across all arrays, waiting to be pulled in. |
| *array*_mismatch_cnt       | Number | Inconsistent sectors the last consistency check found on this array, one metric per array. |


## Troubleshooting

### An array is degraded

The kernel threw a member out, or a member never turned up. The array still serves its data and has no redundancy left to lose, so this is worth doing today rather than this week.

1. Find out which member is gone and what the kernel said about it:

    ```bash
    cat /proc/mdstat
    mdadm --detail /dev/md0
    journalctl --dmesg --grep=md
    ```

2. Look at the disk behind it before you decide it is dead. A member is also thrown out by a cable, a backplane or a controller reset:

    ```bash
    smartctl --all /dev/sdb
    ```

3. Take the failed member out of the array, replace the hardware, and partition the new disk the same way as its neighbour:

    ```bash
    mdadm /dev/md0 --remove /dev/sdb1
    sfdisk --dump /dev/sda | sfdisk /dev/sdb
    ```

4. Add it back. The array starts rebuilding by itself, and this check reports the progress until it is done:

    ```bash
    mdadm /dev/md0 --add /dev/sdb1
    ```

    On an array that is read-only, this fails with `add new device failed [...]: Read-only file system`, because the kernel refuses every superblock-changing operation there. Make it writable first:

    ```bash
    mdadm --readwrite /dev/md0
    ```

    An array that is only *auto* read-only needs nothing of the sort, the kernel switches it over by itself at that point. The check names the state in its output and adds the step where it applies.

5. On a boot disk, put the boot loader on the new member as well. A mirror only boots from the disk that carries one:

    ```bash
    grub2-install /dev/sdb          # Red Hat family
    grub-install /dev/sdb           # Debian family
    ```

Where the rebuild is slow enough to matter, the ceiling is a kernel-wide setting and not a property of the array:

```bash
cat /proc/sys/dev/raid/speed_limit_max
echo 200000 > /proc/sys/dev/raid/speed_limit_max
```

### An array is complete again but still carries a failed member

A spare took over and the rebuild finished, so the array has its full width back. The device the kernel threw out is still attached, and the array has used up the spare it had.

1. Take the dead member out:

    ```bash
    mdadm /dev/md0 --remove /dev/sdb1
    ```

2. Replace the hardware and put a new spare in, so the next failure has something to fall back on again:

    ```bash
    sfdisk --dump /dev/sda | sfdisk /dev/sdb
    mdadm /dev/md0 --add /dev/sdb1
    ```

    On an array that is already at its full width, `--add` puts the new device in as a spare rather than starting a rebuild.

### `md0 is broken`

The array has lost more members than its RAID level can survive, and the kernel has stopped serving it. What is on it is not lost yet, but the next few commands decide whether it stays that way.

Do not write to the array, and above all do not run `mdadm --create` on the members: that writes new superblocks and destroys the only record of how the data was laid out.

1. Read what each member still says about itself. The event counters tell you which members dropped out first:

    ```bash
    mdadm --examine /dev/sd[a-d]1
    ```

2. Assemble the array from the members whose event counters are closest together. `--force` tells mdadm to accept the small difference between them:

    ```bash
    mdadm --stop /dev/md0
    mdadm --assemble --force /dev/md0 /dev/sda1 /dev/sdc1
    ```

3. Where that comes up, mount it read-only and copy the data off before doing anything else:

    ```bash
    mount -o ro /dev/md0 /mnt
    ```

A member that is physically fine but was thrown out by a transport error usually comes back this way. A member with unreadable sectors does not, and that is where the backup comes in.

### `md0 is inactive`

The array exists but was never started, because not enough of its members turned up at boot. This is the normal outcome when a disk is missing, when a controller enumerates late, or when `/etc/mdadm.conf` names an array whose members were moved.

```bash
mdadm --detail /dev/md0
mdadm --examine --scan
```

The first command names the members the kernel has, the second the ones the superblocks on the attached disks describe. Where the missing member is simply late, starting the array by hand is enough:

```bash
mdadm --run /dev/md0
```

Where it is really gone, start the array degraded on the members that are there and treat it like the degraded case above:

```bash
mdadm --stop /dev/md0
mdadm --assemble --force --run /dev/md0 /dev/sda1
```

### `No software RAID array on this host`

`/proc/mdstat` is there, so the kernel has the md code, and it lists no array. Either the arrays were dismantled, or their members did not turn up at boot.

```bash
cat /proc/mdstat
mdadm --examine --scan
```

Where the second command prints array definitions and the first does not, the superblocks are still on the disks and only the assembly failed; put what it prints into `/etc/mdadm.conf` (Red Hat family) or `/etc/mdadm/mdadm.conf` (Debian family), rebuild the initial ramdisk and reboot.

Where both come up empty, this host has no software RAID and the check does not belong on it. Until it is taken off, silence it:

```bash
./md-raid --no-arrays-severity=ok
```

### `This kernel has no software RAID support loaded`

There is no `/proc/mdstat` at all. The `md` code reaches the kernel with the first array that is assembled, so a host that never had one does not carry the file, and this message means the check landed on a host that has never run software RAID.

An installed `mdadm` package says nothing either way: on the Red Hat family it sits in `@baseos` and the initial ramdisk pulls it in, so it is present on hosts that will never assemble an array. That is why the check is rolled out by the presence of an array rather than by the package.

Where this host is supposed to run an array, the superblocks on the disks say what it was:

```bash
mdadm --examine --scan
mdadm --assemble --scan
```

Where it is not, take the check off the host, and silence it until then:

```bash
./md-raid --no-arrays-severity=ok
```

### A consistency check found inconsistent sectors

On a parity array (RAID 4, RAID 5, RAID 6) md(4) says this points at a hardware problem at some level, because software alone does not produce it. On a mirror (RAID 1, RAID 10) it can just as well be a page that was written while the check was reading it, which is why the check does not alert on that by default.

1. Look for the disk behind it first. A mismatch that comes back to the same array over and over has a cause in the hardware:

    ```bash
    smartctl --all /dev/sdb
    journalctl --dmesg --grep=md
    ```

2. Rewrite the parity, or bring the copies back in line, and watch the count go back to zero:

    ```bash
    echo repair > /sys/block/md0/md/sync_action
    cat /proc/mdstat
    ```

3. Run another check afterwards. Only that second run says whether the repair held:

    ```bash
    echo check > /sys/block/md0/md/sync_action
    cat /sys/block/md0/md/mismatch_cnt
    ```

On a mirror carrying swap, the count moves on a healthy system and never goes to zero for long. Leave `--mirror-mismatch-severity` at its default there and watch the graph instead.

### The count of inconsistent sectors never changes

Nothing has run a consistency check. `mismatch_cnt` holds whatever the last `check` or `repair` left behind and is reset to zero when the next one starts, so on a host where no check ever runs the number says nothing at all.

Both distribution families ship the job, and both leave it to the administrator to enable it:

```bash
systemctl enable --now mdcheck_start.timer     # Red Hat family, and Debian 12 upwards
systemctl list-timers 'mdcheck*'
```

On the Debian family the same work is done by `/etc/cron.d/mdadm`, which runs `checkarray` on the first Sunday of the month. Check that `AUTOCHECK` is not switched off in `/etc/default/mdadm`.

### A RAID 0 array reports `active` although a disk is broken

Correct and not a defect. RAID 0 and linear arrays have no redundancy, so md keeps no state about the health of their members: there is no `degraded` attribute, no consistency check, and a member is never marked faulty. As long as the disk is still attached, a member that returns nothing but I/O errors leaves the array reporting `active`, and the errors reach whoever is reading.

The array only turns `broken` once the member is really gone from the system, and even then on the first I/O that touches it rather than at the moment it disappeared.

What covers this instead is the health of the disks themselves:

```bash
smartctl --all /dev/sdb
```

Deploy `disk-smart` on hosts whose data sits on a RAID 0.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
