# Check multipath


## Overview

Checks the device-mapper multipath maps on this host: how many of the paths to each LUN are usable, which of them the path checker has declared dead, and whether a map has run out of paths altogether and is queueing the I/O that reaches it. The number of usable paths is compared against an expected count as a percentage, so a LUN that lost one of its paths warns long before the last one goes and the storage disappears. Every map is graded against the number of paths it currently holds, which cannot catch a path that disappeared from the map entirely; `--count` states how many paths a LUN on this host is supposed to have and closes that gap, and `--map` pins a single map that has a different number. Alerts when a map is running on fewer usable paths than expected, and when it has none left. Supports extended reporting via `--lengthy`.

**What multipathd reports per path:**

Every path carries two states at once, and the check takes both. The *checker* state is what the path checker last saw when it asked the device, and the *device-mapper* state is what the kernel currently does with the path. A path only counts as usable when both agree.

| Checker state | Usable | Meaning |
|----|----|----|
| `ready`       | yes | The path answered, I/O can go over it. |
| `ghost`       | yes | A passive path of an active/passive array. It answers the checker, but carries no I/O until the array activates it. |
| `i/o pending` | yes | A check is in flight and has not answered yet. |
| `faulty`      | no  | The checker got an error. The path is dead. |
| `shaky`       | no  | The path is not available for normal operation. Only the EMC Clariion checker produces this. |
| `i/o timeout` | no  | The check itself timed out. |
| `delayed`     | no  | The path came back and is deliberately held out of the map until it has stayed up for a configured number of checks. |
| `undef`       | no  | multipathd has no word for what the path is doing. |

**Important Notes:**

* **Needs no root and no `sudo`.** multipathd allows every local user to read its state and refuses only the commands that change something, so the check reads the same answer as `root` while it cannot touch a single path. There is no sudoers file to deploy for it. This is why the check asks the daemon instead of running `multipath -ll`, which does insist on being root.
* **A path that disappears entirely is invisible by default.** multipathd drops a path device that is gone from the system out of the map, and the map then reports one path fewer and looks complete. Only an expectation catches that. In a fabric every LUN normally has the same number of paths, so one `--count=4` covers the whole host; `--map=mpathz=2` pins the odd one out. Without either, the check compares each map against itself and can only see a path that is present and dead.
* **A map without any path is not the end of the story yet.** With `no_path_retry` configured, device-mapper holds the I/O that reaches such a map instead of failing it, and the check reports how much of that grace is left (`is holding its I/O for another 52 sec`). Once it runs out, every read and write fails and the file systems on top go read-only. A map already at that point is reported as failing its I/O.
* **A map whose last path is gone stops being listed at all.** multipathd flushes it rather than keeping it around with zero paths, so a host that suddenly reports no maps has either never had multipathed storage or just lost all of it. That is why the check reports WARN when it finds no map. Lower it with `--no-maps-severity=ok`, and pin the maps you expect with `--map` where the difference matters.
* **The `paths` field in multipathd's own output is not the number of paths.** It counts the usable ones only. The check derives the total from the path groups itself, so `2/4` really means two of four.
* **A ghost path is healthy, not degraded.** On an active/passive array half of the paths are standby by design and answer the checker without carrying I/O. Counting them as failures would put every such array permanently in WARN.
* Related checks: `disk-io` reports the load on the resulting `dm-*` devices, `fs-mounts` whether what is on top of them is mounted, and `systemd-unit` whether `multipathd.service` is up.

**Data Collection:**

* Runs `multipathd show maps json` and reads the answer
* Counts a path as usable when the path checker got an answer over it and device-mapper is sending I/O down it
* Needs no root and no `sudo`


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/multipath> |
| Nagios/Icinga Check Name              | `check_multipath` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Runs on                               | Linux |
| Compiled for Windows                  | No |
| Requirements                          | command-line tool `multipathd`, and the `multipathd` service running |


## Help

```text
usage: multipath [-h] [-V] [--always-ok] [--count COUNT] [-c CRIT]
                 [--ignore IGNORE] [--lengthy] [--map MAP]
                 [--marginal-severity {ok,warn,crit,unknown}]
                 [--no-maps-severity {ok,warn,crit,unknown}]
                 [--no-match-severity {ok,warn,crit,unknown}] [--no-perfdata]
                 [--timeout TIMEOUT] [-w WARN]

Checks the device-mapper multipath maps on this host: how many of the paths to
each LUN are usable, which of them the path checker has declared dead, and
whether a map has run out of paths altogether and is queueing the I/O that
reaches it. The number of usable paths is compared against an expected count
as a percentage, so a LUN that lost one of its paths warns long before the
last one goes and the storage disappears. Every map is graded against the
number of paths it currently holds, which cannot catch a path that disappeared
from the map entirely; --count states how many paths a LUN on this host is
supposed to have and closes that gap, and --map pins a single map that has a
different number. Alerts when a map is running on fewer usable paths than
expected, and when it has none left. Supports extended reporting via
--lengthy.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --count COUNT         Expected number of paths per multipath map. A LUN in a
                        fabric normally has the same number of paths as every
                        other one, so one value covers the whole host and
                        catches a path that disappeared from a map entirely,
                        which comparing a map against itself cannot. `--map`
                        pins a single map that has a different number.
                        Example: `--count=4` on a host with two HBAs and two
                        controllers. Default: None, which grades every map
                        against the paths it currently holds.
  -c, --critical CRIT   CRIT threshold for the percentage of the expected
                        paths that are usable, compared as a Nagios range.
                        Supports Nagios ranges. Example: `--critical=1:`
                        alerts only once a map has no usable path left.
                        Default: 50: (critical when half of the paths or more
                        are gone).
  --ignore IGNORE       Any item matching this Python regex will be ignored.
                        Can be specified multiple times. Example:
                        `(?i)linuxfabrik` for a case-insensitive match.
  --lengthy             Extended reporting.
  --map MAP             Check this multipath map and, optionally, the number
                        of paths it is expected to have, written as
                        `name=count`. The name is the alias where the host
                        uses one, and the WWID otherwise. Without `=count` the
                        map is graded against `--count`, and against its own
                        number of paths where that is not given either. Can be
                        specified multiple times; if given at least once, only
                        the named maps are checked. Example: `--map=mpatha=4`
                        alerts when the `mpatha` map does not have its four
                        paths, even after one of them disappeared from the map
                        entirely. Example: `--map=mpathb` checks `mpathb`
                        against the paths it currently has. Default: None
  --marginal-severity {ok,warn,crit,unknown}
                        State to report for a path multipathd has declared
                        marginal, which means it went up and down often enough
                        that the daemon keeps it out of the normal path
                        groups. Default: warn
  --no-maps-severity {ok,warn,crit,unknown}
                        State to report when multipathd holds no map at all. A
                        map whose last path disappears is flushed rather than
                        kept with zero paths, so this is not necessarily a
                        host without multipathed storage. Default: warn
  --no-match-severity {ok,warn,crit,unknown}
                        State to report when no item matches the filters and
                        nothing is checked. Default: ok
  --no-perfdata         Suppress the performance data section from the output.
                        The status message and the exit code are unaffected,
                        so alerting keeps working while trending data is
                        dropped.
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
  -w, --warning WARN    WARN threshold for the percentage of the expected
                        paths that are usable, compared as a Nagios range.
                        Supports Nagios ranges. Example: `--warning=60:`
                        tolerates losing up to 40% of the paths before
                        warning. Default: 100: (warn as soon as one expected
                        path is not usable).

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/multipath/
```


## Usage Examples

```bash
./multipath
```

Output on a host whose LUNs are reachable over all their paths:

```text
2 multipath maps, 4 of 4 paths usable.

Map    ! Usable/Expected ! State
-------+-----------------+----------
mpatha ! 2/2             ! 2 usable
mpathb ! 2/2             ! 2 usable
```

Output after one path died:

```text
mpatha runs on 1 of 2 paths.
mpatha: sda is faulty, device-mapper has taken it out of the map
Find out what happened to the dead paths before assuming the storage is at fault: `multipath -ll` names the SCSI address behind each of them, and `journalctl --dmesg --grep=sd` shows what the transport said about the device. A path that is back but not in the map is reinstated with `multipathd reinstate path sda`; one that is really gone comes back with a rescan of its SCSI host.

Map    ! Usable/Expected ! State
-------+-----------------+---------------------
mpatha ! 1/2             ! 1 usable [WARNING]
mpathb ! 2/2             ! 2 usable
```

Output after the last path of a LUN died, while device-mapper is still holding the I/O:

```text
mpatha has no usable path left of 2.
mpatha is holding its I/O for another 55 sec before it starts failing it.
mpatha: sda is faulty, the device is offline, device-mapper has taken it out of the map
mpatha: sdc is faulty, the device is offline, device-mapper has taken it out of the map

Map    ! Usable/Expected ! State
-------+-----------------+---------------------------
mpatha ! 0/2             ! no usable path [CRITICAL]
mpathb ! 2/2             ! 2 usable
```

State how many paths a LUN on this host is supposed to have, which is the only way a path that vanished from a map is caught:

```bash
./multipath --count=4
```

Where a single LUN is wired differently from the rest, pin that one and leave `--count` for the others:

```bash
./multipath --count=4 --map=mpathz=2
```

Note that naming a map with `--map` also restricts the run to the named maps, so pin all of them or none.

`--lengthy` adds the WWID, the device-mapper device and the queueing state:

```bash
./multipath --lengthy
```

```text
2 multipath maps, 4 of 4 paths usable.

Map    ! WWID              ! Device ! Usable/Expected ! Map State ! Queueing ! State
-------+-------------------+--------+-----------------+-----------+----------+---------
mpatha ! 333333330000007d0 ! dm-0   ! 2/2             ! active    ! 12 chk   ! 2 usable
mpathb ! 333333330000007d1 ! dm-1   ! 2/2             ! active    ! 12 chk   ! 2 usable
```

On a fabric where losing a single path out of four is routine and only half the paths going is worth waking up for:

```bash
./multipath --warning=60: --critical=50:
```

Leave a single map out, for example one belonging to a LUN that is being decommissioned:

```bash
./multipath --ignore='^mpathz$'
```


## States

* OK if every checked map is running on all the paths it is expected to have.
* WARN if a map has fewer usable paths than expected, as a percentage compared against `--warning` (default `100:`, so one missing path is enough). The expectation is the `--map` pin for that map, otherwise `--count`, otherwise the number of paths the map currently holds.
* CRIT if a map is down to half of its expected paths or fewer, compared against `--critical` (default `50:`). A map without any usable path is therefore always CRIT.
* CRIT if a map is suspended at the device-mapper level, whatever its paths report.
* CRIT if a map named with `--map` is not among the maps multipathd holds.
* WARN if a path is flagged marginal. `--marginal-severity` changes it.
* WARN if multipathd holds no map at all. `--no-maps-severity` changes it.
* WARN if multipathd is not answering on its control socket, and WARN if the `multipathd` command is not installed. Both are things to fix on the host rather than a statement about the storage, but they leave the paths unmonitored, so they do not disappear into UNKNOWN.
* OK if `--ignore` leaves nothing to check. `--no-match-severity` raises that.
* UNKNOWN if multipathd answers something that is not the expected JSON, or nothing at all.
* UNKNOWN if `--ignore` is not a valid Python regular expression, or a `--map` count is not a number.
* UNKNOWN if the check does not run on Linux.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

The values are aggregated over all checked maps. A map's name is its WWID unless the host uses aliases, and the first 19 characters of a WWID are not guaranteed to be unique, which is why there is no per-map metric.

| Name | Type | Description |
|----|----|----|
| maps              | Number | Multipath maps checked. |
| maps_degraded     | Number | Maps that are not in the state they should be in. |
| maps_without_path | Number | Maps with no usable path left. Their I/O is being queued or already failing. |
| paths_expected    | Number | Paths the checked maps are expected to have, summed. |
| paths_usable      | Number | Paths the path checker answered over and device-mapper is using. |
| paths_dead        | Number | Paths present in a map that cannot be used. |
| paths_marginal    | Number | Paths multipathd has declared unreliable. |


## Troubleshooting

### A map lost one of its paths

One leg of the fabric is gone while the LUN itself is still reachable. There is no data at risk yet, and there is also no redundancy left to lose on that path, so this is worth doing today.

1. See which path it is and what the SCSI address behind it is:

    ```bash
    multipath -ll
    multipathd show paths format "%d %t %o %T %m"
    ```

2. Read what the transport said about the device. A path almost never dies quietly:

    ```bash
    journalctl --dmesg --grep=sd
    ```

3. Where the path is a Fibre Channel or iSCSI leg, check the session before the disk:

    ```bash
    systemctl status iscsid
    iscsiadm --mode session
    cat /sys/class/fc_remote_ports/rport-*/port_state
    ```

4. Where the path is back but multipathd has not put it into the map again, reinstate it by hand:

    ```bash
    multipathd reinstate path sda
    ```

5. Where the path device is gone from the system altogether, rescan the SCSI host it hung off, then let multipathd pick it up:

    ```bash
    echo "- - -" > /sys/class/scsi_host/host2/scan
    multipathd reconfigure
    ```

### `mpatha has no usable path left`

Every path to that LUN is dead. What happens next depends on `no_path_retry`: with a value or `queue`, device-mapper holds the I/O and the applications hang; with `fail`, every read and write fails immediately and the file systems on top go read-only.

The check reports which of the two it is, and how much of the grace period is left.

1. Look at the whole fabric rather than at a single path. All paths dying at once is a switch, a controller failover, or a LUN that was unmapped:

    ```bash
    multipath -ll
    journalctl --dmesg --since="15 min ago"
    iscsiadm --mode session
    ```

2. Once the paths are back, they usually return on their own. Where they do not:

    ```bash
    multipathd reconfigure
    multipath -r
    ```

3. Only if the queueing has to be broken to get the applications unstuck, and only knowing that the pending I/O is then lost:

    ```bash
    multipathd disablequeueing map mpatha
    ```

    Turn it back on afterwards with `multipathd restorequeueing map mpatha`.

### `mpatha is suspended and blocks every I/O`

Device-mapper has the map suspended, which blocks every I/O that reaches it regardless of how healthy the paths below it are. A suspended map is normally a step inside another operation (a `multipath -r`, an LVM operation, a snapshot) that did not finish.

```bash
dmsetup info mpatha
dmsetup resume mpatha
```

Where `dmsetup info` shows a device that is open and suspended and nothing is running any more, resuming it is what unblocks the applications waiting on it.

### `multipathd is not answering on its control socket`

The daemon is not running, or it is running but wedged. While it is down nothing watches the paths: a path that dies is not taken out of the map, and a path that comes back is not put in again, so I/O keeps being sent down a dead leg.

```bash
systemctl status multipathd
systemctl enable --now multipathd.service
journalctl --unit=multipathd --since=today
```

On the Red Hat family, multipathd refuses to start without a configuration file. `mpathconf` writes a working one:

```bash
mpathconf --enable --with_multipathd y
```

### `The multipathd command is not installed on this host`

The check was rolled out to a host that has no multipath tools installed. Either the host does have multipathed storage and the package is missing, or it never had any and the check does not belong on it.

```bash
dnf install device-mapper-multipath     # Red Hat family
apt install multipath-tools             # Debian family
systemctl enable --now multipathd.service
```

### `multipathd holds no map`

The daemon is running and has nothing to manage. Both explanations look the same from the outside, so check which one it is:

```bash
multipath -ll
lsscsi
multipath -v3 -d
```

`multipath -v3 -d` is a dry run that says for every block device why it was or was not taken into a map, which is where a blacklist that swallowed the LUNs shows up. Where the LUNs are simply not there any more, the storage side is the place to look.

Where the host genuinely has no multipathed storage, take the check off it, and silence it until then:

```bash
./multipath --no-maps-severity=ok
```

### A path is reported as marginal

multipathd saw that path go up and down often enough to consider it unreliable and keeps it out of the normal path groups, so the map is running on less than it appears to. This is a configured behaviour (`marginal_path_err_rate_threshold` and its relatives), so it only ever shows up on a host where somebody switched it on.

A flapping path is almost always a cable, an SFP or a switch port rather than the array. Look at the error counters on the transport, replace the part, and let multipathd take the path back on its own.

### A path shows as `ghost` and is still counted as usable

Correct and not a defect. On an active/passive array the paths to the passive controller answer the checker but carry no I/O until the array fails over to that controller. They are there precisely so the LUN survives losing the active controller, so counting them as failures would keep every such array in WARN forever.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
