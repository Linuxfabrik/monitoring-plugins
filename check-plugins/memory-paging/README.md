# Check memory-paging


## Overview

Reports how much a host pages, as per-second rates measured between two runs: the traffic it moves to and from swap, and how often a process had to wait for the disk before it could go on. How full swap is says little on its own, because a host can sit at 40 percent swap usage for weeks without anyone noticing, and another one can thrash itself to a standstill while its usage barely moves. What hurts is the traffic, and that is what this check alerts on. Swap read back in is the number that matters: pages come back because something asked for them again, which means the working set no longer fits into memory. Pages written out alone can be the kernel parking what nobody has touched in hours, which is what swap is there for. Tables name the processes behind the numbers: those that waited for the disk most and those whose memory has just been pushed out to swap. Supports extended reporting via `--lengthy`. Alerts when the rate read back in leaves the warning or critical range for `--count` runs in a row. The rate written out and the major fault rate alert only where a threshold is set for them.

**Important Notes:**

* The rates need a previous run to compare against, so the first run after a reboot, an update or a wiped cache says "Waiting for more data on the paging counters." and reports nothing else. The kernel counters restart at zero on every boot, which the check notices and treats the same way.
* The major fault rate carries no threshold by default. It counts every page fault that had to wait for I/O, from swap as well as from mapped files, so it moves on a perfectly healthy host that reads a lot off its disks. It is reported because it is the closest the kernel comes to "processes are waiting for the disk", and it is worth a threshold once the normal level of a given host is known.
* The rate read back in also covers pages the kernel reads ahead of the one that faulted, in the expectation that they are asked for next. It is therefore an upper bound on what the workload really demanded, which does not change what it says: pages are coming back from swap.
* The rate written out carries no threshold by default either. Pages go out to swap whenever the kernel decides to park memory nobody has asked for in a while, which is what swap is for, and the pages that come back are what hurts. `--warning-swap-out` and `--critical-swap-out` exist for a host where the write rate itself is a problem, for example swap on a slow disk or on flash that is supposed to last.
* The tables name processes, but the kernel keeps no swap counters per process. What they show is what each process leaves behind: the major faults it caused, which a swap read-in is one of and so is every page of a mapped file read off the disk, and the swap it gained since the previous run, which is memory pushed out. Processes of the same name are one row. A process that ended since the previous run is not in them, a process that started in between counts with everything it did. `swap-usage` lists who holds the most swap, which is a state and not a movement: a process can sit on a gigabyte of swap without touching it.
* Without `--count` every run is judged on its own, which is what an Icinga service with `max_check_attempts` above 1 and a retry interval expects. `--count` makes the check itself hold back until the rate has been above its threshold for that many runs in a row, for a monitoring server that does not retry, and it applies to all three thresholds. The output says when a rate is above its threshold but not yet for long enough.
* On a host without swap the two swap rates can only ever be zero, and the check says so instead of leaving three zeros to be read as a measurement. Where swap lives on zram, paging costs CPU and memory rather than disk I/O, and the check says that too.
* Related checks: `swap-usage` reports how full swap is and which processes sit in it, `memory-usage` reports how much memory is in use, `disk-io` reports the I/O of the block devices underneath. None of them sees the paging traffic.

**Data Collection:**

* Reads the `pswpin`, `pswpout` and `pgmajfault` counters from `/proc/vmstat`
* Reads `/proc/swaps` for the swap devices, their type and their priority
* Multiplies the two swap counters by the page size of the running system, because the kernel counts them in pages
* Stores the previous sample in a local SQLite database and reports the difference as a per-second rate, so no cumulative counter ends up in the performance data
* Needs no root and no `sudo`


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/memory-paging> |
| Nagios/Icinga Check Name              | `check_memory_paging` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Runs on                               | Linux |
| Compiled for Windows                  | No |
| Handles Periods                       | Yes (alerts only after `--count` consecutive threshold violations) |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-memory-paging.db` |


## Help

```text
usage: memory-paging [-h] [-V] [--always-ok] [--count COUNT] [-c CRIT]
                     [--critical-major-faults CRIT_MAJOR_FAULTS]
                     [--critical-swap-out CRIT_SWAP_OUT] [--lengthy]
                     [--no-perfdata] [--top TOP] [-w WARN]
                     [--warning-major-faults WARN_MAJOR_FAULTS]
                     [--warning-swap-out WARN_SWAP_OUT]

Reports how much a host pages, as per-second rates measured between two runs:
the traffic it moves to and from swap, and how often a process had to wait for
the disk before it could go on. How full swap is says little on its own,
because a host can sit at 40 percent swap usage for weeks without anyone
noticing, and another one can thrash itself to a standstill while its usage
barely moves. What hurts is the traffic, and that is what this check alerts
on. Swap read back in is the number that matters: pages come back because
something asked for them again, which means the working set no longer fits
into memory. Pages written out alone can be the kernel parking what nobody has
touched in hours, which is what swap is there for. Tables name the processes
behind the numbers: those that waited for the disk most and those whose memory
has just been pushed out to swap. Supports extended reporting via --lengthy.
Alerts when the rate read back in leaves the warning or critical range for
`--count` runs in a row. The rate written out and the major fault rate alert
only where a threshold is set for them.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --count COUNT         Number of consecutive checks the threshold must be
                        exceeded before alerting. Applies to all thresholds.
                        Default: 1
  -c, --critical CRIT   CRIT threshold for the swap traffic read back in, as a
                        rate per second in human-readable format (base is
                        always 1024; valid qualifiers are B, KiB, MiB, GiB
                        etc., see UNITS.md; a value without a qualifier is a
                        number of bytes). Supports Nagios ranges. Example:
                        `10M` alerts above 10 MiB/s. Default: 10M
  --critical-major-faults CRIT_MAJOR_FAULTS
                        CRIT threshold for the number of page faults per
                        second that had to wait for I/O. Supports Nagios
                        ranges. Default: unset, the rate is reported but does
                        not alert
  --critical-swap-out CRIT_SWAP_OUT
                        CRIT threshold for the swap traffic written out, as a
                        rate per second in human-readable format (see
                        `--critical`). Supports Nagios ranges. Default: unset,
                        the rate is reported but does not alert
  --lengthy             Extended reporting.
  --no-perfdata         Suppress the performance data section from the output.
                        The status message and the exit code are unaffected,
                        so alerting keeps working while trending data is
                        dropped.
  --top TOP             Number of processes listed in each of the tables that
                        name who waited for the disk and whose memory was
                        pushed out to swap. 0 switches the tables off.
                        Default: 5
  -w, --warning WARN    WARN threshold for the swap traffic read back in, as a
                        rate per second in human-readable format (base is
                        always 1024; valid qualifiers are B, KiB, MiB, GiB
                        etc., see UNITS.md; a value without a qualifier is a
                        number of bytes). Supports Nagios ranges. Example:
                        `10M` alerts above 10 MiB/s. Default: 1M
  --warning-major-faults WARN_MAJOR_FAULTS
                        WARN threshold for the number of page faults per
                        second that had to wait for I/O. Supports Nagios
                        ranges. Default: unset, the rate is reported but does
                        not alert
  --warning-swap-out WARN_SWAP_OUT
                        WARN threshold for the swap traffic written out, as a
                        rate per second in human-readable format (see
                        `--warning`). Supports Nagios ranges. Default: unset,
                        the rate is reported but does not alert

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/memory-paging/
```


## Usage Examples

```bash
./memory-paging
```

Output on an idle host whose swap lives on zram:

```text
swap in 0.0B/s, swap out 0.0B/s, 0 major faults/s
Swap lives on zram, which is compressed memory, so paging costs CPU and memory on this host rather than disk I/O.
```

Output on a host that is thrashing:

```text
swap in 849.5MiB/s [CRITICAL], swap out 848.4MiB/s, 28.7K major faults/s
The host is reading pages back from swap, so its working set no longer fits into memory. Add memory, move a workload off the host, or find the process that grew: the tables below name the processes that waited for the disk and the ones whose swap grew, and `swap-usage` lists who holds the most swap.

Waited for the disk most, major faults per second. A swap read-in is one of them, a page of a mapped file is another:
Process   ! Count ! Faults/s
----------+-------+---------
mongod    ! 1     ! 9K
mongodump ! 1     ! 5K
node      ! 1     ! 200

Gained the most swap since the last run, which is memory pushed out:
Process ! Count ! Swap Gained/s
--------+-------+--------------
mongod  ! 1     ! 293.0MiB/s
```

`--top=3` limits each table to three rows, `--top=0` switches the tables off.

Extended reporting adds the swap devices with their type and priority, and a table of every counter:

```bash
./memory-paging --lengthy
```

Output:

```text
swap in 4.5MiB/s, swap out 0.0B/s, 785 major faults/s [WARNING]
A process waited for the disk on every one of these faults, while the swap rates stayed within their thresholds. The pages come from mapped files rather than from swap, so it is the page cache that is too small for what the host reads.
Swap: /dev/zram0 (partition, priority 100), /var/tmp/lf-swaptest (file, priority 50)

Counter    ! Meaning                         ! Per Second
-----------+---------------------------------+----------------
pgmajfault ! faults that had to wait for I/O ! 785.0 [WARNING]
pswpin     ! pages read back from swap       ! 1141.0
pswpout    ! pages written out to swap       ! 0.0
```

A host with fast swap that is expected to page, a build machine or a batch node, wants more headroom before anybody is woken:

```bash
./memory-paging --warning=50M --critical=200M
```

A host that is supposed to page and where only the graph matters wants the thresholds switched off. `~:` is the Nagios range for "any value is fine":

```bash
./memory-paging --warning=~: --critical=~:
```

Once the normal level of major faults on a host is known, it is worth a threshold of its own:

```bash
./memory-paging --warning-major-faults=1000 --critical-major-faults=5000
```


## States

* OK if the rate read back in stays within `--warning` and `--critical`, and the rate written out and the major fault rate stay within their own thresholds where those are set.
* OK with "Waiting for more data on the paging counters." on the first run, after a reboot and after the cache was wiped, because there is no previous sample to compare against yet.
* WARN if the rate read back in leaves the `--warning` range, 1 MiB/s by default.
* WARN if the rate written out leaves the `--warning-swap-out` range. There is no such threshold by default.
* WARN if the major fault rate leaves the `--warning-major-faults` range. There is no such threshold by default.
* CRIT if the rate read back in leaves the `--critical` range, 10 MiB/s by default, if the rate written out leaves the `--critical-swap-out` range, or if the major fault rate leaves the `--critical-major-faults` range. There is no critical threshold for the last two by default.
* Every one of these needs the rate to be outside its range for `--count` runs in a row (default: 1, which judges every run on its own).
* UNKNOWN if `/proc/vmstat` is missing or cannot be read, which on a Linux host means `/proc` is not mounted.
* UNKNOWN if the kernel does not report the paging counters at all, which is the case for a kernel built without `CONFIG_VM_EVENT_COUNTERS`.
* UNKNOWN if the check does not run on Linux.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

Every value is a per-second rate measured between two check runs, never a total accumulated since boot.

| Name | Type | Description |
|----|----|----|
| major_faults_per_second   | Number | Page faults the kernel could not satisfy from memory, so the faulting process had to wait for I/O. Raised by the swap path as well as by mapped files, tmpfs and DAX. |
| swap_in_bytes_per_second  | Bytes  | Pages read back from swap, converted to bytes with the page size of the running system. Includes the pages the kernel read ahead. |
| swap_out_bytes_per_second | Bytes  | Pages written out to swap, converted to bytes with the page size of the running system. |


## Troubleshooting

### The host is reading pages back from swap

The working set no longer fits into memory, so the kernel is fetching pages back that something asked for again. This is the expensive direction: every one of those pages is a process waiting for the disk. The tables in the output name the processes that waited for the disk most and the ones whose swap grew since the previous run. `swap-usage` lists who holds the most swap. By hand, see how much swap is in use and which processes sit in it:

```bash
swapon --show
for p in /proc/[0-9]*; do s=$(awk '/^VmSwap:/{print $2}' "$p/status" 2>/dev/null); [ -n "$s" ] && [ "$s" -gt 0 ] && echo "$s $(cat "$p/comm")"; done | sort --numeric-sort --reverse | head
```

The output is in kibibytes, biggest first. From there the answer is one of three: add memory, move a workload off the host, or cap the process that grew, for example with `MemoryHigh` on its systemd unit. Lowering `vm.swappiness` only changes how eagerly the kernel reaches for swap in the first place and does nothing about a machine that is genuinely short of memory.

Where swap sits on a slow disk, the same rate hurts far more than it does on an NVMe or on zram. `--lengthy` names the devices in use.


### Pages are written out and none come back

The kernel is parking memory nobody has asked for in a while, which is what swap is there for, and by itself it is no reason to act. Worth watching: once the rate read back in follows, the host has moved on to the case above. The rate written out does not alert by default, so this case shows up only on a host where `--warning-swap-out` or `--critical-swap-out` is set. Raising them is a legitimate answer on a host that parks memory as a matter of course, and so is leaving them unset and letting the alerting follow the rate that comes back in.


### Major faults are high while the swap rates are quiet

The pages come from mapped files rather than from swap: an executable, a shared library, a memory-mapped database. Every one of those faults waited for the disk, so the page cache is too small for what the host reads. Look at how much of it is left and what the disks are doing:

```bash
free --human
vmstat 1 5
```

Either the host needs more memory, or something is reading far more than it should, which the `disk-io` check shows over time. A threshold that fits the host belongs on `--warning-major-faults` afterwards, so the next time it stands out on its own.


### `Waiting for more data on the paging counters.`

Expected on the first run. The check needs two samples to turn the cumulative kernel counters into a rate. It also appears after a reboot, because the counters restart at zero there and the previous sample is worthless, and after the cache file was removed. The next check interval reports normally again.


### `The kernel does not report pgmajfault, pswpin, pswpout in /proc/vmstat`

The kernel was built without `CONFIG_VM_EVENT_COUNTERS`, which drops every event counter from `/proc/vmstat` and leaves only the zone and node statistics. No distribution kernel does this, so it points at a hand-built or heavily stripped kernel, where nothing on the host can measure paging. Which counters exist can be read directly:

```bash
grep --extended-regexp '^(pswpin|pswpout|pgmajfault) ' /proc/vmstat
```


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
