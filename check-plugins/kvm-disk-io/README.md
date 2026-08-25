# Check kvm-disk-io

## Overview

Reports how much a libvirt host's virtual machines read and write, and how long their storage takes to answer. Warns when a disk sustains a large share of the most throughput it has ever delivered, which is a saturation signal rather than an emergency, and alerts on sustained latency, which is where a hung disk shows up. Supports extended reporting via --lengthy. Runs without root or sudo.

**What the two verdicts mean:**

* **Working hard** compares what a disk moved over the whole period with the most it has ever been seen to move, and warns above `--warning` percent of that. There is no absolute number worth alerting on here: 40 MiB/s is nothing on an NVMe array and everything on a shared spinning disk, so the check calibrates itself against each disk instead of asking for a figure nobody can give. This verdict **never goes critical**, whatever the threshold: a machine working its storage hard is a reason to look, not a reason to be woken up.
* **Slow storage** is the average time a read or write took to complete, what `iostat` calls await. This is where a disk that has stopped answering shows up, so it is the one that may go critical. Both latency thresholds are off by default, because what counts as slow depends on the backing store; the check reports the number so it can be graphed and a threshold picked from what the host actually does.

**Important Notes:**

* **Read the two together.** A disk moving little while taking a long time per request is the worse of the two pictures, and on throughput alone it looks like the quietest disk on the host.
* **Flush latency is reported and never judged.** It is what a guest waits on every fsync, so it is the figure that decides whether a database inside it feels slow, and it is legitimately an order of magnitude slower than a read: 0.2 ms of read latency next to 4.6 ms of flush latency is a healthy disk. Folding it into the value the latency thresholds judge would move the bound for reasons that have nothing to do with the disk being unwell, which is why `iostat` leaves flushes out of await too. Graph it and judge it there.
* Latency is reported rather than judged until `--warning-await` or `--critical-await` are set.
* Throughput can be judged twice over, and whichever bound is tighter is the one that fires. `--warning` compares a disk with the most it has been seen to deliver, which needs nothing configured and adapts to the backing store. `--warning-throughput` and `--critical-throughput` are absolute rates, for a store whose limit is known. Graph it for a few days first, then set the thresholds above what the host does when nothing is wrong.
* A disk that has just appeared, and every disk on the first runs, is named after "Waiting for more data:" until `--count` measurements have accumulated. The disks that have been there all along keep being reported meanwhile.
* **A drive with nothing in it is not reported.** libvirt lists an empty CD-ROM drive among a machine's block devices, counters and all, and virtually every machine has one. Reporting them would put a row that can never move anything next to every machine on the host. The same drive with an image in it is reported like any other disk, and so is a disk on network storage such as Ceph or iSCSI.
* Only running machines are looked at. A machine that is shut off does no I/O and its counters stand still, so a rate computed from them would be a row of zeroes.
* The check connects to libvirt read-only, which needs neither root nor sudo nor membership in the `libvirt` group. Only QEMU/KVM connections report the data it needs; Xen and libvirt-LXC connections are refused with an explanation.
* **`--brief` shortens the table on a busy host.** A host with a hundred machines of three disks each produces three hundred rows, and `--brief` keeps only the disks in a WARN or CRIT state. Performance data and alerting are unaffected: every item still emits its metrics and still drives the overall state, so it is safe to leave on. It combines with `--lengthy`, which decides the columns rather than the rows. When nothing is in a WARN or CRIT state, the check prints its summary line and no table at all.

**Data Collection:**

* Collects the disk counters of every running machine in a single call, whatever the number of machines and disks.
* Keeps the last `--count` measurements per disk in a local SQLite database, so the cumulative counters are reported as rates rather than as ever-growing totals, and reports the average over that whole span. A disk has to stay above a threshold for all of it to alert, so a single busy minute does not.
* The span the values cover is `--count` *measurements*, not a fixed stretch of time. Running the check by hand next to the scheduled one therefore shortens it: five measurements taken a second apart average over five seconds, not over five minutes. The numbers stay correct for the span they cover, but the smoothing is gone.
* The most throughput each disk has been seen to deliver is remembered in the same database and never drops below 10 MiB/s, so a disk that happened to be idle on the first run does not warn about every byte it moves afterwards.
* Disks are named `<machine>/<disk>`, because a disk name is only unique within its machine: virtually every machine has a `vda`. `--match` and `--ignore` see that whole name (case-sensitive Python regular expressions; use `(?i)` for case-insensitive matching), so one pattern picks a single disk and another picks every disk of a machine. A disk hit by `--ignore` is dropped even if it also matches `--match`.


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/kvm-disk-io> |
| Nagios/Icinga Check Name              | `check_kvm_disk_io` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No (runs with Python interpreter) |
| Requirements                          | command-line tool `virsh` (package `libvirt-client` on RHEL and SUSE, `libvirt-clients` on Debian and Ubuntu) |
| Handles Periods                       | Yes (values are averaged over `--count` measurements, default 5) |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-kvm-disk-io-<connection>.db`, one per `--url` |


## Help

```text
usage: kvm-disk-io [-h] [-V] [--always-ok] [--brief] [--count COUNT]
                   [--critical-await AWAIT_CRIT]
                   [--critical-throughput CRIT_THROUGHPUT] [--ignore IGNORE]
                   [--lengthy] [--match MATCH]
                   [--no-match-severity {ok,warn,crit,unknown}]
                   [--no-perfdata] [--timeout TIMEOUT] [--url URL] [-w WARN]
                   [--warning-await AWAIT_WARN]
                   [--warning-throughput WARN_THROUGHPUT]

Reports how much a libvirt host's virtual machines read and write, and how
long their storage takes to answer. Warns when a disk sustains a large share
of the most throughput it has ever delivered, which is a saturation signal
rather than an emergency, and alerts on sustained latency, which is where a
hung disk shows up. Supports extended reporting via --lengthy. Runs without
root or sudo.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --brief               Hide the rows that are within the thresholds and show
                        only those in a WARN or CRIT state. Perfdata and
                        alerting are unaffected: every item still emits
                        performance data and still drives the overall check
                        state, so this is safe to leave on.
  --count COUNT         Number of measurements the reported values are
                        averaged over. A disk has to stay above a threshold
                        for the whole span to alert, so a single busy minute
                        does not. Default: 5
  --critical-await AWAIT_CRIT
                        CRIT threshold for the average time a read or write
                        takes to complete, in milliseconds. Meant for a disk
                        that is effectively hung. Supports Nagios ranges.
                        Default: unset, latency is reported but does not alert
  --critical-throughput CRIT_THROUGHPUT
                        CRIT threshold for the throughput of a disk, as an
                        absolute rate per second, in human-readable format
                        (base is always 1024; valid qualifiers are B, KiB,
                        MiB, GiB etc., see UNITS.md; a value without a
                        qualifier is a number of bytes). Use it where the
                        backing store has a known limit; `--warning` judges
                        the same value against what the disk has been seen to
                        manage instead. Supports Nagios ranges. Default:
                        unset, throughput is judged against the observed
                        maximum only. Example: `500M` alerts above 500 MiB/s.
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
  --no-match-severity {ok,warn,crit,unknown}
                        State to report when no item matches the filters and
                        nothing is checked. Default: ok
  --no-perfdata         Suppress the performance data section from the output.
                        The status message and the exit code are unaffected,
                        so alerting keeps working while trending data is
                        dropped.
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
  --url URL             libvirt connection URI, passed to `virsh --connect`.
                        Use `qemu+ssh://user@host/system` to check a host that
                        runs no local monitoring agent. Only QEMU/KVM
                        connections report the data this check needs. Default:
                        qemu:///system
  -w, --warning WARN    WARN threshold for the throughput of a disk, in
                        percent of the most it has ever been seen to deliver.
                        This part never goes critical: a disk working hard is
                        worth a look, not a call at night. Default: 80
                        (percent)
  --warning-await AWAIT_WARN
                        WARN threshold for the average time a read or write
                        takes to complete, in milliseconds. Supports Nagios
                        ranges. Default: unset, latency is reported but does
                        not alert
  --warning-throughput WARN_THROUGHPUT
                        WARN threshold for the throughput of a disk, as an
                        absolute rate per second, in human-readable format
                        (base is always 1024; valid qualifiers are B, KiB,
                        MiB, GiB etc., see UNITS.md; a value without a
                        qualifier is a number of bytes). Use it where the
                        backing store has a known limit; `--warning` judges
                        the same value against what the disk has been seen to
                        manage instead. Supports Nagios ranges. Default:
                        unset, throughput is judged against the observed
                        maximum only. Example: `400M` alerts above 400 MiB/s.

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/kvm-disk-io/
```


## Usage Examples

```bash
./kvm-disk-io
```

Output on the first run:

```text
Waiting for more data: mailstore01/vda, nextcloud01/vda
```

Output on the following runs:

```text
2 VMs, 2 disks, 416.0KiB/s read, 544.0KiB/s write, averaged over 5 measurements

VM Name     ! Disk ! Read/s (5x) ! Write/s (5x) ! Await ! State
------------+------+-------------+--------------+-------+------
mailstore01 ! vda  ! 96.0KiB/s   ! 64.0KiB/s    ! 0.6ms ! [OK]
nextcloud01 ! vda  ! 320.0KiB/s  ! 480.0KiB/s   ! 0.6ms ! [OK]
```

A machine booting from an installation image, where the CD-ROM drive really is doing the reading:

```text
1 VM, 2 disks, 2.3MiB/s read, 480.0KiB/s write, averaged over 5 measurements

VM Name     ! Disk ! Read/s (5x) ! Write/s (5x) ! Await ! State
------------+------+-------------+--------------+-------+------
nextcloud01 ! sda  ! 2.0MiB/s    ! 0.0B/s       ! 0.5ms ! [OK]
nextcloud01 ! vda  ! 320.0KiB/s  ! 480.0KiB/s   ! 0.6ms ! [OK]
```

A disk working at the top of what it has ever delivered:

```text
1 VM, 1 disk, 40.0MiB/s read, 8.0MiB/s write, averaged over 5 measurements. Working hard: nextcloud01/vda (48.0MiB/s of 48.0MiB/s) [WARNING]

VM Name     ! Disk ! Read/s (5x) ! Write/s (5x) ! Await ! State
------------+------+-------------+--------------+-------+----------
nextcloud01 ! vda  ! 40.0MiB/s   ! 8.0MiB/s     ! 0.4ms ! [WARNING]
```

A disk that has all but stopped answering. Note that the throughput *fell*, which is exactly why the latency is reported next to it:

```bash
./kvm-disk-io --warning-await=100 --critical-await=500
```

```text
1 VM, 1 disk, 40.0KiB/s read, 0.0B/s write, averaged over 5 measurements. Slow storage: nextcloud01/vda (612.0ms) [CRITICAL]

VM Name     ! Disk ! Read/s (5x) ! Write/s (5x) ! Await   ! State
------------+------+-------------+--------------+---------+-----------
nextcloud01 ! vda  ! 40.0KiB/s   ! 0.0B/s       ! 612.0ms ! [CRITICAL]
```

`--lengthy` adds the last interval on its own, the total and the maximum the disk has been seen to deliver:

```bash
./kvm-disk-io --lengthy
```

```text
VM Name     ! Disk ! Read/s    ! Write/s   ! Read/s (5x) ! Write/s (5x) ! Total/s (5x) ! Max/s     ! Await ! State
------------+------+-----------+-----------+-------------+--------------+--------------+-----------+-------+------
mailstore01 ! vda  ! 96.0KiB/s ! 64.0KiB/s ! 96.0KiB/s   ! 64.0KiB/s    ! 160.0KiB/s   ! 10.0MiB/s ! 0.6ms ! [OK]
```

Watching one machine only, and leaving the templates alone:

```bash
./kvm-disk-io --match='^nextcloud01/' --ignore='^tpl_'
```

Checking a hypervisor that runs no local monitoring agent:

```bash
./kvm-disk-io --url=qemu+ssh://monitoring@192.0.2.10/system
```


## States

* OK if every disk stays below the thresholds.
* OK, with the disk named after "Waiting for more data:", for a disk that has no previous measurement yet, which is the case on the first run and after a machine was started.
* OK with "No running virtual machines with disks found." if no machine on the host is running, or none of them has a disk.
* WARN if a disk sustains `--warning` percent or more of the most throughput it has ever delivered (default: 80). This part never goes critical.
* WARN if a disk moves more than `--warning-throughput` per second, CRIT at `--critical-throughput` (both default: unset). These are absolute rates and are judged next to the relative `--warning` above.
* WARN if a read or write takes `--warning-await` milliseconds or more on average (default: unset).
* CRIT if it reaches `--critical-await` (default: unset).
* UNKNOWN if libvirt cannot be reached, if the connection is not a QEMU/KVM one, if `virsh` is missing, or on an invalid `--match` or `--ignore` pattern.
* `--no-match-severity` sets the state reported when `--match` or `--ignore` leave no disk to check (default: `ok`).
* `--brief` hides the rows that are within the thresholds. It changes nothing about the state or the performance data.
* `--always-ok` suppresses all alerts and always returns OK.

Both latency thresholds accept [Nagios ranges](../THRESHOLDS.md). `--warning` does not, on purpose: it is not a bound on the throughput but a share of a figure the check measures for itself, and a range expression such as `@10:20` or `~:50` would mean nothing multiplied by an observed maximum.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| read_bytes_per_second | Bytes | Read across all checked disks, averaged over `--count` measurements. |
| write_bytes_per_second | Bytes | Written across all checked disks, averaged over `--count` measurements. |
| &lt;machine&gt;_&lt;disk&gt;_await | Milliseconds | Average time a read or write took to complete. This is the value the latency thresholds judge. |
| &lt;machine&gt;_&lt;disk&gt;_flush_await | Milliseconds | Average time a flush took to complete. What a guest waits on every fsync. No threshold applies to it. |
| &lt;machine&gt;_&lt;disk&gt;_flush_iops | Number | Flushes completed per second, averaged over `--count` measurements. |
| &lt;machine&gt;_&lt;disk&gt;_read_await | Milliseconds | The same for reads alone. |
| &lt;machine&gt;_&lt;disk&gt;_read_bytes_per_second | Bytes | Read, averaged over `--count` measurements. |
| &lt;machine&gt;_&lt;disk&gt;_read_bytes_per_second1 | Bytes | The same, over the last measurement interval alone. |
| &lt;machine&gt;_&lt;disk&gt;_read_iops | Number | Reads completed per second, averaged over `--count` measurements. |
| &lt;machine&gt;_&lt;disk&gt;_throughput | Bytes | Read plus written, averaged over `--count` measurements. This is the value the throughput threshold judges. |
| &lt;machine&gt;_&lt;disk&gt;_throughput1 | Bytes | The same, over the last measurement interval alone. |
| &lt;machine&gt;_&lt;disk&gt;_write_await | Milliseconds | Average time a write took to complete. |
| &lt;machine&gt;_&lt;disk&gt;_write_bytes_per_second | Bytes | Written, averaged over `--count` measurements. |
| &lt;machine&gt;_&lt;disk&gt;_write_bytes_per_second1 | Bytes | The same, over the last measurement interval alone. |
| &lt;machine&gt;_&lt;disk&gt;_write_iops | Number | Writes completed per second, averaged over `--count` measurements. |


## Troubleshooting

### `Waiting for more data: <disks>`

Expected on the first run and whenever a machine has just been started. The check needs two measurements to turn libvirt's cumulative counters into a rate. Wait for the next check interval.

### A disk warns about working hard although nothing changed

The maximum it is compared against is the most that disk has been seen to deliver, and it grows as the disk is asked for more. A disk that has never had a busy moment is therefore compared against the 10 MiB/s floor, and the first real backup run pushes it over the threshold. That is the check working as intended; the warning goes away as soon as the new maximum is recorded, and it says what the disk is really capable of.

To start over, stop the check and delete its state file, which holds the maximum of every disk. It is not directly in the temporary directory: the databases live in a per-user subdirectory of it that only that user may enter, so the full path is `$TEMP/linuxfabrik-monitoring-plugins-uid<UID>/linuxfabrik-monitoring-plugins-kvm-disk-io-<connection>.db`, with the numeric user id of the account the check runs as.

### A disk sits at a high latency

The host cannot serve the machine's storage as fast as it is asked to. Work through it in this order:

1. Look at the host's own disks (`check_disk_io`). If the backing store is saturated, every machine on it waits.
2. Compare the machines with each other. One machine doing far more I/O than the rest is the usual cause, and `--lengthy` shows which.
3. Check whether the machine's disk is throttled (`virsh blkdeviotune <machine> <disk>`). A limit set once for a migration and forgotten looks exactly like slow storage.
4. Check the disk's cache mode and bus (`virsh dumpxml <machine>`). A disk on an emulated IDE or SATA bus is far slower than the same disk on virtio, and the difference shows up as latency.

### A machine shows fewer disks than its configuration lists

Drives with nothing in them are left out, so a machine with one virtual disk and an empty CD-ROM drive is reported with one disk. Put an image in the drive and it is reported as well.

### The check reports no disks while machines are running

The connection reaches a libvirt daemon that does not hold this host's machines, every machine is filtered out, or the machines really have no disks of their own. Compare with `virsh --readonly --connect=qemu:///system domstats --block --list-running` on the host itself, and check the `--match` and `--ignore` patterns.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
