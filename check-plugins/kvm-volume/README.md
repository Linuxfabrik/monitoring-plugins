# Check kvm-volume

## Overview

Reports what the storage pools of a libvirt host actually hold: how much space their volumes have been promised, how much of it they occupy today, and how far the promises exceed the storage underneath. Handing out more than there is is what thin provisioning is for, and it is safe only for as long as the volumes stay unfilled, so this is the number that says how much room is left for that to happen. Alerts if the promises exceed the storage by more than the thresholds allow, which are unset by default because only the administrator knows how far their storage may be oversubscribed. Supports extended reporting via --lengthy. Runs without root or sudo.

**Important Notes:**

* **This check and `kvm-storage-pool` answer two different questions, and both are worth having.** `kvm-storage-pool` reports the storage a pool sits on and alerts when it fills up, which is the failure that stops the machines. This one reports what the pool has promised its volumes, which is how you see that failure coming: a pool may promise several times its storage without anything being wrong today, and only the rate at which the volumes fill decides whether it stays that way.
* **The thresholds are unset by default, so out of the box this check reports and does not alert.** A subscription of 300% is reckless on one host and routine on another, and nothing the check can see tells the two apart. Set `--warning` and `--critical` once you have watched the figure for a while. The store actually running out is alerted on by `kvm-storage-pool`, which needs no thresholds from anybody.
* **Only running pools are reported.** libvirt cannot list the contents of a pool it has not opened. A pool that is not running, including one that was supposed to start with the host, is reported by `kvm-storage-pool`.
* **The sizes are rounded, by about a thousandth.** `virsh vol-list` offers no `--bytes` and prints two decimals with a unit (`64.00 GiB`), which the check converts back. That is precise enough for a ratio between two of them and not precise enough to watch a single volume grow byte by byte. Asking for exact figures would cost one call per volume, and a single directory on an ordinary workstation held 40.
* **A pool can report more taken than promised.** A filesystem allocates in whole blocks, so six volumes of a few kilobytes each occupy more than they asked for. It is normal and needs nothing done about it.
* **`--brief` shortens the table on a busy host.** A host that gives every machine a pool of its own produces one row per machine, and `--brief` keeps only the pools in a WARN or CRIT state. Performance data and alerting are unaffected: every pool still emits its metrics and still drives the overall state, so it is safe to leave on. It combines with `--lengthy`, which decides the columns rather than the rows. When nothing is in a WARN or CRIT state, the check prints its summary line and no table at all.
* The check connects to libvirt read-only, which needs neither root nor sudo nor membership in the `libvirt` group.

**Data Collection:**

* Asks the host for its pools, then each running pool for its sizes and for the volumes it holds.
* `--lengthy` adds a second table with the largest volumes, which is what answers "what is eating this pool". It is capped at the ten largest and the caption counts the ones it left out, because a pool holds as many volumes as the host has disks and forgotten images.
* Pools can be limited with `--match` and excluded with `--ignore` (case-sensitive Python regular expressions; use `(?i)` for case-insensitive matching). A pool hit by `--ignore` is dropped even if it also matches `--match`.
* The check reads no counters and keeps no history, so it needs no state file and its numbers are whatever the host reports at that moment.


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/kvm-volume> |
| Nagios/Icinga Check Name              | `check_kvm_volume` |
| Check Interval Recommendation         | Every hour |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No (runs with Python interpreter) |
| Requirements                          | command-line tool `virsh` (package `libvirt-client` on RHEL and SUSE, `libvirt-clients` on Debian and Ubuntu) |
| Handles Periods                       | No |
| Uses State File                       | No |


## Help

```text
usage: kvm-volume [-h] [-V] [--always-ok] [--brief] [-c CRIT]
                  [--ignore IGNORE] [--lengthy] [--match MATCH]
                  [--no-match-severity {ok,warn,crit,unknown}] [--no-perfdata]
                  [--timeout TIMEOUT] [--url URL] [-w WARN]

Reports what the storage pools of a libvirt host actually hold: how much space
their volumes have been promised, how much of it they occupy today, and how
far the promises exceed the storage underneath. Handing out more than there is
is what thin provisioning is for, and it is safe only for as long as the
volumes stay unfilled, so this is the number that says how much room is left
for that to happen. Alerts if the promises exceed the storage by more than the
thresholds allow, which are unset by default because only the administrator
knows how far their storage may be oversubscribed. Supports extended reporting
via --lengthy. Runs without root or sudo.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --brief               Hide the rows that are within the thresholds and show
                        only those in a WARN or CRIT state. Perfdata and
                        alerting are unaffected: every item still emits
                        performance data and still drives the overall check
                        state, so this is safe to leave on.
  -c, --critical CRIT   CRIT threshold for the space a pool has promised its
                        volumes, in percent of the storage underneath it.
                        Above 100 the pool has promised more than it has.
                        Supports Nagios ranges. Default: unset, the figure is
                        reported but does not alert
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
                        runs no local monitoring agent. Default:
                        qemu:///system
  -w, --warning WARN    WARN threshold for the space a pool has promised its
                        volumes, in percent of the storage underneath it.
                        Above 100 the pool has promised more than it has.
                        Supports Nagios ranges. Default: unset, the figure is
                        reported but does not alert

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/kvm-volume/
```


## Usage Examples

```bash
./kvm-volume
```

Output:

```text
3 pools, 49 volumes, 2.8TiB promised, 148.2GiB taken

Pool        ! Volumes ! Promised ! Taken    ! Store   ! Sub%   ! State
------------+---------+----------+----------+---------+--------+------
default     ! 40      ! 2.8TiB   ! 148.1GiB ! 1.8TiB  ! 153.4% ! [OK]
isos        ! 9       ! 30.3GiB  ! 30.3GiB  ! 1.8TiB  ! 1.6%   ! [OK]
nvram       ! 6       ! 3.1MiB   ! 4.1MiB   ! 1.8TiB  ! 0.0%   ! [OK]
```

The `default` pool has promised its volumes more than the filesystem under it holds. That is thin provisioning working as intended: only 148 GiB of the 2.8 TiB promised has actually been taken. It becomes a problem the day the guests fill their disks.

Alert once a pool promises more than the storage holds:

```bash
./kvm-volume --warning=100 --critical=200
```

Output:

```text
3 pools, 49 volumes, 2.8TiB promised, 148.2GiB taken. Promised more than the storage holds: default (153.4%) [WARNING]

Pool        ! Volumes ! Promised ! Taken    ! Store   ! Sub%   ! State
------------+---------+----------+----------+---------+--------+-----------
default     ! 40      ! 2.8TiB   ! 148.1GiB ! 1.8TiB  ! 153.4% ! [WARNING]
isos        ! 9       ! 30.3GiB  ! 30.3GiB  ! 1.8TiB  ! 1.6%   ! [OK]
nvram       ! 6       ! 3.1MiB   ! 4.1MiB   ! 1.8TiB  ! 0.0%   ! [OK]
```

Find out what is filling a pool:

```bash
./kvm-volume --lengthy --match='^default$'
```

Output:

```text
1 pool, 40 volumes, 2.8TiB promised, 148.1GiB taken

Pool    ! Volumes ! Promised ! Taken    ! Store  ! Sub%   ! State
--------+---------+----------+----------+--------+--------+------
default ! 40      ! 2.8TiB   ! 148.1GiB ! 1.8TiB ! 153.4% ! [OK]


The 10 largest volumes, 30 more not listed:

Pool    ! Volume               ! Type ! Promised ! Taken
--------+----------------------+------+----------+---------
default ! winsrv2025.qcow2     ! file ! 50.0GiB  ! 22.9GiB
default ! tpl_winsrv2025.qcow2 ! file ! 50.0GiB  ! 19.5GiB
default ! fedora43.qcow2       ! file ! 20.0GiB  ! 7.5GiB
```


## States

* OK if every pool stays within the thresholds, which by default is every pool, because the thresholds are unset.
* OK with "No running storage pools found." if the host has no pool running.
* WARN if a pool has promised its volumes more than `--warning` percent of the storage underneath it.
* CRIT if it reaches `--critical`.
* UNKNOWN if libvirt cannot be reached, if `virsh` is missing, or on an invalid `--match` or `--ignore` pattern.
* `--brief` hides the rows that are within the thresholds. It changes nothing about the state or the performance data.
* `--no-match-severity` sets the state reported when `--match` or `--ignore` leave no pool to check (default: `ok`).
* `--always-ok` suppresses all alerts and always returns OK.

Both thresholds accept [Nagios ranges](../THRESHOLDS.md).


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| allocated | Bytes | Space the volumes of all checked pools occupy today. |
| promised | Bytes | Space the volumes of all checked pools have been promised. |
| volumes | Number | Volumes in all checked pools. |
| &lt;pool&gt;_allocated | Bytes | Space this pool's volumes occupy today. |
| &lt;pool&gt;_promised | Bytes | Space this pool's volumes have been promised. |
| &lt;pool&gt;_subscription | Percentage | What the pool has promised, in percent of the storage underneath it. Above 100 it has promised more than it has. This is the value the thresholds judge. Absent for a pool whose storage reports no size. |
| &lt;pool&gt;_volumes | Number | Volumes in this pool. |


## Troubleshooting

### A pool is reported above 100%

The pool has promised its volumes more space than the filesystem under it holds. Nothing is broken yet, and on a host that uses thin provisioning deliberately this is the point of it. What matters is the gap between promised and taken, and whether the storage can still cover it:

1. Compare the two columns. A pool at 300% whose volumes have taken a tenth of their size has years of room; one at 110% whose volumes are nearly full has none.
2. Watch how fast the taken figure grows, in the Grafana dashboard that ships with this check.
3. Look at what is in the pool with `--lengthy`. An image left behind by a machine nobody deleted is the usual reason a pool grew without anybody deciding it should.
4. Either give the store more room, move volumes off it, or shrink the promises with `virsh vol-resize`.

`kvm-storage-pool` is the check that alerts when the store itself runs out, which is the failure this one only predicts.

### A pool reports more taken than promised

Expected for a pool of very small volumes. A filesystem hands out whole blocks, so a 4 KiB volume occupies more than 4 KiB, and six of them add up to more than they were promised. Nothing to do.

### A pool is missing from the output

Only running pools are listed, because libvirt cannot report the contents of a pool it has not opened. `virsh --readonly --connect=qemu:///system pool-list --all` shows which pools are not running, and `kvm-storage-pool` reports the ones that were supposed to start with the host.

### The figures differ slightly from `qemu-img info`

`virsh vol-list` accepts no `--bytes` and prints its sizes rounded to two decimals with a unit, which this check converts back. A 3.31 GiB allocation is therefore accurate to about 5 MiB. For an exact figure on one volume, ask for it directly: `virsh --readonly --connect=qemu:///system vol-info --pool <pool> --bytes <volume>`.

### The check reports no pools

The connection reaches a libvirt daemon that does not hold this host's pools, or every pool is filtered out. Compare with `virsh --readonly --connect=qemu:///system pool-list --all` on the host itself, and check the `--match` and `--ignore` patterns.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
