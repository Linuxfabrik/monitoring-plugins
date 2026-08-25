# Check kvm-storage-pool

## Overview

Checks the storage pools a libvirt host keeps its virtual machines on. Reports the storage behind them and the pools themselves in two tables: one per store, with how full it is and which pools sit on it, and one per pool. Alerts if a store is filling up, if a pool lost part of what it serves from, if it cannot be reached at all, and if a pool that is configured to start together with the host is not active. Several pools commonly share one filesystem, which is reported and alerted on once rather than once per pool. Supports extended reporting via --lengthy. Runs without root or sudo.

**Why two tables:**

They answer two different questions, and mixing them is what makes the output of a plain pool listing so hard to read.

* The **store** table answers "is storage running out". It has one row per distinct store, whatever the number of pools on it, with the pools named in it.
* The **pool** table answers "are my pools set up and healthy". It has one row per pool, with where it points, whether it starts with the host, and its state.

A pool that is not running reports no sizes, so it appears in the second table only. Each table carries its own verdict: a pool on a store that is nearly full is not itself broken, and a degraded pool on a half-empty store is.

**What the pool states mean:**

libvirt has five, and the wording matters because three of them describe a pool that *is* running. These are libvirt's own descriptions; how each is judged is this check's decision, taken from them.

| State | libvirt's own description | Reported as |
|----|----|----|
| `running` | Running normally | OK |
| `building` | Initializing pool, not available | OK, a pool is only in it while it is being created |
| `inactive` | Not running | OK on its own, WARN if the pool is set to start with the host |
| `degraded` | Running degraded | WARN, it is serving and one more failure from not serving |
| `inaccessible` | Running, but not accessible | CRIT, the machines on it fail their next I/O |

Anything libvirt adds to that list later is reported by name and treated as worth a look, rather than passed over in silence.

**Important Notes:**

* **The sizes describe the storage a pool sits on, not what the pool holds.** For a directory-backed pool libvirt takes them from the filesystem the pool's path is on and works out what is used as its size minus its free space, so the figure covers everything on that filesystem and not just this pool's share. It is still the right number to alert on, because a pool runs out when the storage under it does; it is the wrong number to answer "how big is my ISO library". `virsh vol-list --pool isos --details` answers that one.
* **A store is reported, and alerted on, once.** Four pools in four different directories of one filesystem all report that filesystem, so they share one store row and raise one alert between them. The check never totals stores either: summing several views of one filesystem would claim storage that exists once as if it existed four times.
* **Pools are recognised as sharing a store by what they report**, because libvirt never says what a pool sits on: same capacity, and free space agreeing within a percent. The tolerance is there because the pools are asked one after another and a filesystem being written to moves in between; without it, a busy host would keep splitting one store into several and renaming its metrics as it went. Two filesystems that really are separate and happen to be exactly the same size *and* equally full to within a percent would be reported as one, which is the price of libvirt not telling anybody what is underneath.
* **The performance data is per store, not per pool**, and named after the store. A dashboard can then not add one filesystem up as if it were four.
* A pool that is not running reports no sizes at all, so it is listed without a percentage rather than with a zero it never sent. So is a pool whose type has no path, an RBD pool for instance.
* The check connects to libvirt read-only, which needs neither root nor sudo nor membership in the `libvirt` group.

**Data Collection:**

* Asks the host for its pools, and then each pool for its state, its sizes and its definition. Asking per pool is the only way to the two states worth reacting to: the pool table libvirt prints by default says `active` for a pool that is running, degraded and inaccessible alike, and asked for details it rounds the sizes to two decimals with a unit. There are a handful of pools on a host, so the extra questions cost little.
* Sizes arrive as exact byte counts.
* Pools can be limited with `--match` and excluded with `--ignore` (case-sensitive Python regular expressions; use `(?i)` for case-insensitive matching). A pool hit by `--ignore` is dropped even if it also matches `--match`.
* Unlike the other checks of this family, this one reads no counters and keeps no history, so it needs no state file and its numbers are whatever the host reports at that moment.


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/kvm-storage-pool> |
| Nagios/Icinga Check Name              | `check_kvm_storage_pool` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No (runs with Python interpreter) |
| Requirements                          | command-line tool `virsh` (package `libvirt-client` on RHEL and SUSE, `libvirt-clients` on Debian and Ubuntu) |
| Handles Periods                       | No |
| Uses State File                       | No |


## Help

```text
usage: kvm-storage-pool [-h] [-V] [--always-ok] [-c CRIT] [--ignore IGNORE]
                        [--lengthy] [--match MATCH]
                        [--no-match-severity {ok,warn,crit,unknown}]
                        [--no-perfdata] [--timeout TIMEOUT] [--url URL]
                        [-w WARN]

Checks the storage pools a libvirt host keeps its virtual machines on. Reports
the storage behind them and the pools themselves in two tables: one per store,
with how full it is and which pools sit on it, and one per pool. Alerts if a
store is filling up, if a pool lost part of what it serves from, if it cannot
be reached at all, and if a pool that is configured to start together with the
host is not active. Several pools commonly share one filesystem, which is
reported and alerted on once rather than once per pool. Supports extended
reporting via --lengthy. Runs without root or sudo.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  -c, --critical CRIT   CRIT threshold for the share of a pool that is taken,
                        in percent. Supports Nagios ranges. Default: 90
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
  -w, --warning WARN    WARN threshold for the share of a pool that is taken,
                        in percent. Supports Nagios ranges. Default: 80

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/kvm-storage-pool/
```


## Usage Examples

```bash
./kvm-storage-pool
```

Output:

```text
Everything is ok (warn=80 crit=90).

Store                   ! Pools   ! Size     ! Used     ! Avail   ! Use%
------------------------+---------+----------+----------+---------+------
/var/lib/libvirt/images ! default ! 1.8TiB   ! 400.0GiB ! 1.4TiB  ! 21.5%
/srv/isos               ! isos    ! 100.0GiB ! 20.0GiB  ! 80.0GiB ! 20.0%

Pool    ! Path                    ! Autostart ! State
--------+-------------------------+-----------+--------
default ! /var/lib/libvirt/images ! yes       ! running
isos    ! /srv/isos               ! yes       ! running
```

A host whose four pools are four directories of one filesystem. One store row for all of them, and the pool table still shows each pool with its own path:

```text
Everything is ok (warn=80 crit=90).

Store ! Pools                           ! Size   ! Used   ! Avail    ! Use%
------+---------------------------------+--------+--------+----------+------
/     ! Downloads, default, isos, nvram ! 1.8TiB ! 1.2TiB ! 586.1GiB ! 68.5%

Pool      ! Path                        ! Autostart ! State
----------+-----------------------------+-----------+--------
Downloads ! /home/user/Downloads        ! yes       ! running
default   ! /var/lib/libvirt/images     ! no        ! running
isos      ! /home/user/isos             ! yes       ! running
nvram     ! /var/lib/libvirt/qemu/nvram ! yes       ! running
```

Storage running out of room. One alert for the store, however many pools are on it, and the pools themselves are fine:

```text
There are critical errors (warn=80 crit=90). Filling up: images, isos (93.0%).

Store   ! Pools        ! Size     ! Used     ! Avail   ! Use%
--------+--------------+----------+----------+---------+-----------------
/srv/vm ! images, isos ! 931.3GiB ! 866.1GiB ! 65.2GiB ! 93.0% [CRITICAL]

Pool   ! Path    ! Autostart ! State
-------+---------+-----------+--------
images ! /srv/vm ! yes       ! running
isos   ! /srv/vm ! yes       ! running
```

The other way round happens too: a pool that lost part of what it serves from, on storage that is nowhere near full:

```text
There are warnings (warn=80 crit=90). Degraded: data.

Store       ! Pools ! Size   ! Used     ! Avail  ! Use%
------------+-------+--------+----------+--------+------
/dev/vgdata ! data  ! 1.8TiB ! 400.0GiB ! 1.4TiB ! 21.5%

Pool ! Path        ! Autostart ! State
-----+-------------+-----------+-------------------
data ! /dev/vgdata ! yes       ! degraded [WARNING]
```

A pool that was supposed to come up with the host. It reports no sizes, so there is no store row for it at all:

```text
There are warnings (warn=80 crit=90). Set to start with the host but not running: backup.

Pool   ! Path        ! Autostart ! State
-------+-------------+-----------+-------------------
backup ! /srv/backup ! yes       ! inactive [WARNING]
```

`--lengthy` adds persistence to the pool table:

```bash
./kvm-storage-pool --lengthy
```

```text
Pool    ! Path                    ! Autostart ! Persistent ! State
--------+-------------------------+-----------+------------+--------
default ! /var/lib/libvirt/images ! yes       ! yes        ! running
isos    ! /srv/isos               ! yes       ! yes        ! running
```

Watching the pools that hold machines and leaving the ISO library alone:

```bash
./kvm-storage-pool --ignore='^isos$' --warning=85 --critical=95
```

Checking a hypervisor that runs no local monitoring agent:

```bash
./kvm-storage-pool --url=qemu+ssh://monitoring@192.0.2.10/system
```


## States

* OK if every pool is running or building, and none of them is above the thresholds.
* OK with "No storage pools found." if the host has no pools at all.
* OK for a pool that is not running and was not asked to start with the host.
* WARN if a pool is `degraded`, or in a state libvirt introduced after this check was written.
* WARN if a pool is set to start with the host and is not running.
* WARN if the storage behind a pool is `--warning` percent full or more (default: 80). Pools sharing that storage are alerted on as one group.
* CRIT if a pool is `inaccessible`, or reaches `--critical` (default: 90).
* UNKNOWN if libvirt cannot be reached, if `virsh` is missing, or on an invalid `--match` or `--ignore` pattern.
* `--no-match-severity` sets the state reported when `--match` or `--ignore` leave no pool to check (default: `ok`).
* `--always-ok` suppresses all alerts and always returns OK.

Both thresholds accept [Nagios ranges](../THRESHOLDS.md), so `--warning=@0:1` alerts on a pool that is suspiciously *empty*, which is what a pool pointing at the wrong place looks like.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| pool_autostart_down | Number | Pools set to start with the host that are not running. |
| pool_building | Number | Pools being created. |
| pool_degraded | Number | Pools running with part of their storage gone. |
| pool_inaccessible | Number | Pools running whose storage cannot be reached. |
| pool_inactive | Number | Pools that are not running. |
| pool_running | Number | Pools running normally. |
| &lt;store&gt;-allocation | Bytes | Storage taken on that store. |
| &lt;store&gt;-available | Bytes | Storage still free on that store. |
| &lt;store&gt;-capacity | Bytes | Size of that store. |
| &lt;store&gt;-usage | Percentage | Share of that store that is taken. This is the value the thresholds judge. |

The last four are emitted **once per store, not once per pool**, and are named after the store rather than after the pools on it, the same way `check_disk_usage` names a filesystem. Pools sharing storage report the same figures to the byte, so a metric per pool would draw one line several times over and let a dashboard add one filesystem up as if it were several.

The store's name is the deepest path that holds every pool on it. Four pools spread over `/home` and `/var` of one root filesystem come out as `/-usage`; a store holding one pool at `/srv/isos` comes out as `/srv/isos-usage`. It is worked out from the paths as text and never from the filesystem, so it stays right for a hypervisor checked over ssh. A pool type that has no path, RBD for one, is named after itself instead (`ceph-usage`).

Every state libvirt knows gets a metric, including the ones no pool is in, so a dashboard keeps a stable set of lines instead of losing one whenever the situation improves.


## Troubleshooting

### Several pools share one store row

Expected. Those pools are directories on one filesystem, and each of them reports that filesystem rather than its own contents, so they are one store with several names on it. One of them filling up means all of them did, which is why there is one row and one alert.

To find out what a single pool really holds, ask for its volumes rather than its size:

```bash
virsh vol-list --pool isos --details
```

### A pool is `degraded`

Part of the storage behind it is gone while the rest keeps serving, so the machines on it are still running and are one failure away from not being. What to look at depends on what the pool is built on: a RAID array or an LVM volume group behind a `logical` or `disk` pool, the paths of a multipath device behind an `mpath` pool, or the mount behind a `dir` or `netfs` pool. `virsh pool-dumpxml <pool>` names the source.

### A pool is `inaccessible`

The pool is up and the storage behind it cannot be reached at all: an NFS or iSCSI target that went away, a mount that is gone, or credentials that stopped working. The machines on it will fail their next I/O if they have not already. Check the source (`virsh pool-dumpxml <pool>`), then whether the host can still reach it, and refresh the pool with `virsh pool-refresh <pool>` once it can.

### A pool is `inactive` although it should be running

The host did not start it, or it failed to. Start it with `virsh pool-start <pool>` and read what it says; a pool whose source is missing refuses with the reason. `virsh pool-autostart <pool>` is what makes the host bring it up on its own.

### A pool has no path

Its type has none. A directory, filesystem, netfs or logical pool points at a path and shows it; an RBD or iSCSI-backed one is addressed by its source instead, which `virsh pool-dumpxml <pool>` shows. Such a pool is never folded together with another, because "no path" is not something two pools have in common.

### The check reports no pools

The connection reaches a libvirt daemon that does not hold this host's pools, or every pool is filtered out. Compare with `virsh --readonly --connect=qemu:///system pool-list --all --name` on the host itself, and check the `--match` and `--ignore` patterns.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
