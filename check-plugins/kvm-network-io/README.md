# Check kvm-network-io

## Overview

Reports what a libvirt host's virtual machines send and receive over each of their network interfaces, together with the frames those interfaces lost. Warns when an interface sustains a large share of the most traffic it has ever carried, which is a saturation signal rather than an emergency. Optional thresholds alert on lost frames; which of the two loss counters carries anything depends on how the interface is attached to the host, and both are reported. Supports extended reporting via --lengthy. Runs without root or sudo.

**What the verdicts mean:**

* **Working hard** compares what an interface carried over the whole period with the most it has ever been seen to carry, and warns above `--warning` percent of that. There is no absolute number worth alerting on here: 40 MiB/s is nothing on a 25 GbE fabric and everything on a shared 1 GbE uplink, so the check calibrates itself against each interface instead of asking for a figure nobody can give. This verdict **never goes critical**, whatever the threshold: a machine using its network hard is a reason to look, not a reason to be woken up.
* **Losing frames** covers the two loss counters, `Dropped` and `Bad`. Both are off by default and are reported for trending until thresholds are set, because what counts as too much depends on the machine and on how it reaches the network.

**Which loss counter to watch:**

This is the part worth reading before setting a threshold. The two counters are filled by whatever the host attaches the machine to, and on the most common setup only one of them can ever move.

| How the machine is attached | `Dropped` | `Bad` |
|----|----|----|
| A virtual network or a bridge (the default) | The counter that moves. It counts a queue the guest is not draining, and a frame the host could not take from it. | Stays at zero. The host side is a tap device, and nothing fills this counter for one. |
| macvtap (a "direct" attachment) | Moves | Moves |
| Straight onto a host interface, for example a passed-through card | Moves | Moves, with the usual meaning it has on a physical interface |

So on a normal machine on a bridge, `--warning-drops` is the threshold with something behind it, and a `Bad` count that never leaves zero is the expected picture rather than a sign of health. Graph both for a few days before picking numbers.

**Important Notes:**

* **Inbound and outbound are from the machine's point of view.** Inbound is what the guest received. The host's own view of the same interface is the exact opposite, because what the machine sends is what the host receives, so a figure read from `ip -s link show vnet4` on the host will not match and comparing the two directly leads nowhere.
* **An interface is identified by its position in the machine, not by its host-side device.** `nic0` is the machine's first interface and stays that whatever happens; the `vnetN` device next to it is handed out by libvirt from a counter when the machine starts and is not kept, which is also why libvirt itself leaves it out of the machine's stored configuration. The same interface of the same machine, unchanged and with the same MAC address, was measured as `vnet1` before a restart and as `vnet4` after it. The device is shown (`--lengthy`) rather than used as the name.
* **A loss counter the host does not keep is reported as `-`, not as zero.** On every ordinary configuration libvirt reports all of them. A vhost-user interface is the exception: there the figures come from Open vSwitch, which names only the counters it keeps, and the rest never arrive. Zero is what a healthy interface reports, so filling them in would claim the interface loses nothing and let `--warning-drops` and `--warning-errors` confirm that on every run. Those thresholds skip such an interface, and the first line names it.
* Traffic can be judged twice over, and whichever bound is tighter is the one that fires. `--warning` compares an interface with the most it has been seen to carry, which needs nothing configured and adapts to the host's network. `--warning-throughput` and `--critical-throughput` are absolute rates, for a link whose speed is known.
* An interface that has just appeared, and every interface on the first runs, is named after "Waiting for more data:" until `--count` measurements have accumulated. The interfaces that have been there all along keep being reported meanwhile.
* Only running machines are looked at. A machine that is shut off has no interface on the host at all.
* The check connects to libvirt read-only, which needs neither root nor sudo nor membership in the `libvirt` group. Only QEMU/KVM connections report the data it needs; Xen and libvirt-LXC connections are refused with an explanation.
* **`--brief` shortens the table on a busy host.** A host with a hundred machines of two interfaces each produces two hundred rows, and `--brief` keeps only the interfaces in a WARN or CRIT state. Performance data and alerting are unaffected: every item still emits its metrics and still drives the overall state, so it is safe to leave on. It combines with `--lengthy`, which decides the columns rather than the rows. When nothing is in a WARN or CRIT state, the check prints its summary line and no table at all.

**Data Collection:**

* Collects the interface counters of every running machine in a single call, whatever the number of machines and interfaces.
* Keeps the last `--count` measurements per interface in a local SQLite database, so the cumulative counters are reported as rates rather than as ever-growing totals, and reports the average over that whole span. An interface has to stay above a threshold for all of it to alert, so a single busy minute does not.
* The span the values cover is `--count` *measurements*, not a fixed stretch of time. Running the check by hand next to the scheduled one therefore shortens it: five measurements taken a second apart average over five seconds, not over five minutes. The numbers stay correct for the span they cover, but the smoothing is gone.
* The most traffic each interface has been seen to carry is remembered in the same database and never drops below 10 MiB/s, so an interface that happened to be quiet on the first run does not warn about every packet it carries afterwards.
* Interfaces are named `<machine>/nic<position>`. `--match` and `--ignore` see that whole name (case-sensitive Python regular expressions; use `(?i)` for case-insensitive matching), so one pattern picks a single interface and another picks every interface of a machine. An interface hit by `--ignore` is dropped even if it also matches `--match`.
* An interface libvirt could not read is left out rather than reported as a row of zeroes, which would claim it carried no traffic instead of saying nothing is known about it.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/kvm-network-io> |
| Nagios/Icinga Check Name              | `check_kvm_network_io` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No (runs with Python interpreter) |
| Requirements                          | command-line tool `virsh` (package `libvirt-client` on RHEL and SUSE, `libvirt-clients` on Debian and Ubuntu) |
| Handles Periods                       | Yes (values are averaged over `--count` measurements, default 5) |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-kvm-network-io-<connection>.db`, one per `--url` |


## Help

```text
usage: kvm-network-io [-h] [-V] [--always-ok] [--brief] [--count COUNT]
                      [--critical-drops CRIT_DROPS]
                      [--critical-errors CRIT_ERRORS]
                      [--critical-throughput CRIT_THROUGHPUT]
                      [--ignore IGNORE] [--lengthy] [--match MATCH]
                      [--no-match-severity {ok,warn,crit,unknown}]
                      [--no-perfdata] [--timeout TIMEOUT] [--url URL]
                      [-w WARN] [--warning-drops WARN_DROPS]
                      [--warning-errors WARN_ERRORS]
                      [--warning-throughput WARN_THROUGHPUT]

Reports what a libvirt host's virtual machines send and receive over each of
their network interfaces, together with the frames those interfaces lost.
Warns when an interface sustains a large share of the most traffic it has ever
carried, which is a saturation signal rather than an emergency. Optional
thresholds alert on lost frames; which of the two loss counters carries
anything depends on how the interface is attached to the host, and both are
reported. Supports extended reporting via --lengthy. Runs without root or
sudo.

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
                        averaged over. An interface has to stay above a
                        threshold for the whole span to alert, so a single
                        busy minute does not. Default: 5
  --critical-drops CRIT_DROPS
                        CRIT threshold for the number of frames per second an
                        interface drops, incoming and outgoing together. This
                        is the counter that moves on a machine attached
                        through a bridge or a virtual network. Supports Nagios
                        ranges. Default: unset, dropped frames are reported
                        but do not alert
  --critical-errors CRIT_ERRORS
                        CRIT threshold for the number of frames per second an
                        interface reports as bad, incoming and outgoing
                        together. This counter stays at zero for a machine
                        attached through a bridge or a virtual network, where
                        the host does not fill it. Supports Nagios ranges.
                        Default: unset, bad frames are reported but do not
                        alert
  --critical-throughput CRIT_THROUGHPUT
                        CRIT threshold for the traffic on an interface, as an
                        absolute rate per second, in human-readable format
                        (base is always 1024; valid qualifiers are B, KiB,
                        MiB, GiB etc., see UNITS.md; a value without a
                        qualifier is a number of bytes). Use it where the link
                        speed is known; `--warning` judges the same value
                        against what the interface has been seen to carry
                        instead. Supports Nagios ranges. Default: unset,
                        traffic is judged against the observed maximum only.
                        Example: `900M` alerts above 900 MiB/s.
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
  -w, --warning WARN    WARN threshold for the traffic on an interface, in
                        percent of the most it has ever been seen to carry.
                        This part never goes critical: an interface working
                        hard is worth a look, not a call at night. Default: 80
                        (percent)
  --warning-drops WARN_DROPS
                        WARN threshold for the number of frames per second an
                        interface drops, incoming and outgoing together. This
                        is the counter that moves on a machine attached
                        through a bridge or a virtual network. Supports Nagios
                        ranges. Default: unset, dropped frames are reported
                        but do not alert
  --warning-errors WARN_ERRORS
                        WARN threshold for the number of frames per second an
                        interface reports as bad, incoming and outgoing
                        together. This counter stays at zero for a machine
                        attached through a bridge or a virtual network, where
                        the host does not fill it. Supports Nagios ranges.
                        Default: unset, bad frames are reported but do not
                        alert
  --warning-throughput WARN_THROUGHPUT
                        WARN threshold for the traffic on an interface, as an
                        absolute rate per second, in human-readable format
                        (base is always 1024; valid qualifiers are B, KiB,
                        MiB, GiB etc., see UNITS.md; a value without a
                        qualifier is a number of bytes). Use it where the link
                        speed is known; `--warning` judges the same value
                        against what the interface has been seen to carry
                        instead. Supports Nagios ranges. Default: unset,
                        traffic is judged against the observed maximum only.
                        Example: `800M` alerts above 800 MiB/s.

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/kvm-network-io/
```


## Usage Examples

```bash
./kvm-network-io
```

Output on the first run:

```text
Waiting for more data: mailstore01/nic0, nextcloud01/nic0, nextcloud01/nic1
```

Output on the following runs:

```text
2 VMs, 3 NICs, 612.0KiB/s in, 1.0MiB/s out, averaged over 5 measurements

VM Name     ! NIC  ! In/s (5x)  ! Out/s (5x) ! Dropped ! Bad   ! State
------------+------+------------+------------+---------+-------+------
mailstore01 ! nic0 ! 96.0KiB/s  ! 32.0KiB/s  ! 0.0/s   ! 0.0/s ! [OK]
nextcloud01 ! nic0 ! 512.0KiB/s ! 1.0MiB/s   ! 0.0/s   ! 0.0/s ! [OK]
nextcloud01 ! nic1 ! 4.0KiB/s   ! 2.0KiB/s   ! 0.0/s   ! 0.0/s ! [OK]
```

An interface carrying as much as it ever has:

```text
1 VM, 1 NIC, 8.0MiB/s in, 2.0MiB/s out, averaged over 5 measurements. Working hard: nextcloud01/nic0 (10.0MiB/s of 10.0MiB/s) [WARNING]

VM Name     ! NIC  ! In/s (5x) ! Out/s (5x) ! Dropped ! Bad   ! State
------------+------+-----------+------------+---------+-------+----------
nextcloud01 ! nic0 ! 8.0MiB/s  ! 2.0MiB/s   ! 0.0/s   ! 0.0/s ! [WARNING]
```

A machine on a bridge losing frames. Note that the traffic is unremarkable and the `Bad` counter is at zero, which is exactly what this case looks like:

```bash
./kvm-network-io --warning-drops=100 --critical-drops=1000
```

```text
1 VM, 1 NIC, 40.0KiB/s in, 8.0KiB/s out, averaged over 5 measurements. Losing frames: nextcloud01/nic0 (160.0/s dropped) [WARNING]

VM Name     ! NIC  ! In/s (5x) ! Out/s (5x) ! Dropped ! Bad   ! State
------------+------+-----------+------------+---------+-------+----------
nextcloud01 ! nic0 ! 40.0KiB/s ! 8.0KiB/s   ! 160.0/s ! 0.0/s ! [WARNING]
```

`--lengthy` adds the host-side device, the last interval on its own, the total and the maximum the interface has been seen to carry:

```bash
./kvm-network-io --lengthy
```

```text
VM Name ! NIC  ! Device ! In/s   ! Out/s  ! In/s (5x) ! Out/s (5x) ! Total/s (5x) ! Max/s     ! Dropped ! Bad   ! State
--------+------+--------+--------+--------+-----------+------------+--------------+-----------+---------+-------+------
rocky9  ! nic0 ! vnet4  ! 0.0B/s ! 0.0B/s ! 24.6B/s   ! 0.0B/s     ! 24.6B/s      ! 10.0MiB/s ! 0.0/s   ! 0.0/s ! [OK]
```

Watching one machine only, and leaving the templates alone:

```bash
./kvm-network-io --match='^nextcloud01/' --ignore='^tpl_'
```

Checking a hypervisor that runs no local monitoring agent:

```bash
./kvm-network-io --url=qemu+ssh://monitoring@192.0.2.10/system
```


## States

* OK if every interface stays below the thresholds.
* OK, with the interface named after "Waiting for more data:", for an interface that has no previous measurement yet, which is the case on the first run and after a machine was started.
* OK with "No running virtual machines with network interfaces found." if no machine on the host is running, or none of them has an interface.
* WARN if an interface sustains `--warning` percent or more of the most traffic it has ever carried (default: 80). This part never goes critical.
* WARN if an interface carries more than `--warning-throughput` per second, CRIT at `--critical-throughput` (both default: unset). These are absolute rates and are judged next to the relative `--warning` above.
* WARN if an interface drops more frames per second than `--warning-drops` allows, or reports more bad ones than `--warning-errors` allows (both default: unset).
* CRIT if it reaches `--critical-drops` or `--critical-errors` (both default: unset).
* OK for the loss thresholds on an interface whose loss counters the host does not keep. There is nothing to judge, so nothing is judged; the traffic thresholds still apply to it.
* UNKNOWN if libvirt cannot be reached, if the connection is not a QEMU/KVM one, if `virsh` is missing, or on an invalid `--match` or `--ignore` pattern.
* `--no-match-severity` sets the state reported when `--match` or `--ignore` leave no interface to check (default: `ok`).
* `--brief` hides the rows that are within the thresholds. It changes nothing about the state or the performance data.
* `--always-ok` suppresses all alerts and always returns OK.

All four loss thresholds accept [Nagios ranges](../THRESHOLDS.md). `--warning` does not, on purpose: it is not a bound on the traffic but a share of a figure the check measures for itself, and a range expression such as `@10:20` or `~:50` would mean nothing multiplied by an observed maximum.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| rx_bytes_per_second | Bytes | Received across all checked interfaces, averaged over `--count` measurements. |
| tx_bytes_per_second | Bytes | Sent across all checked interfaces, averaged over `--count` measurements. |
| &lt;machine&gt;_nic&lt;n&gt;_drops_per_second | Number | Frames the interface dropped, incoming and outgoing together. On a machine attached through a bridge or a virtual network this is the loss counter that carries anything. Absent for an interface whose loss counters the host does not keep. |
| &lt;machine&gt;_nic&lt;n&gt;_errors_per_second | Number | Frames the interface reported as bad, incoming and outgoing together. Stays at zero for a machine attached through a bridge or a virtual network. Absent for an interface whose loss counters the host does not keep. |
| &lt;machine&gt;_nic&lt;n&gt;_rx_bytes_per_second | Bytes | Received by the machine, averaged over `--count` measurements. |
| &lt;machine&gt;_nic&lt;n&gt;_rx_bytes_per_second1 | Bytes | The same, over the last measurement interval alone. |
| &lt;machine&gt;_nic&lt;n&gt;_rx_packets_per_second | Number | Packets received by the machine, averaged over `--count` measurements. |
| &lt;machine&gt;_nic&lt;n&gt;_throughput | Bytes | Received plus sent, averaged over `--count` measurements. This is the value the traffic threshold judges. |
| &lt;machine&gt;_nic&lt;n&gt;_throughput1 | Bytes | The same, over the last measurement interval alone. |
| &lt;machine&gt;_nic&lt;n&gt;_tx_bytes_per_second | Bytes | Sent by the machine, averaged over `--count` measurements. |
| &lt;machine&gt;_nic&lt;n&gt;_tx_bytes_per_second1 | Bytes | The same, over the last measurement interval alone. |
| &lt;machine&gt;_nic&lt;n&gt;_tx_packets_per_second | Number | Packets sent by the machine, averaged over `--count` measurements. |


## Troubleshooting

### `Waiting for more data: <interfaces>`

Expected on the first run and whenever a machine has just been started. The check needs two measurements to turn libvirt's cumulative counters into a rate. Wait for the next check interval.

### The numbers do not match what the host says about `vnetN`

They are not supposed to. The check reports from the machine's point of view, so what it calls inbound is what the guest received, and that is exactly what the host *sent* on the tap device. Reading `ip -s link show vnet4` or `/proc/net/dev` on the host gives the two the other way round.

### The `Bad` column never leaves zero

Expected on a machine attached to a virtual network or a bridge, and not a statement about that machine's health. Nothing on the host fills that counter for such an interface. Watch `Dropped` instead, and see the table above for which attachment fills which counter.

### An interface warns about working hard although nothing changed

The maximum it is compared against is the most that interface has been seen to carry, and it grows as it is asked for more. An interface that has never had a busy moment is therefore compared against the 10 MiB/s floor, and the first large file transfer pushes it over the threshold. That is the check working as intended; the warning goes away as soon as the new maximum is recorded, and it says what the interface is really capable of.

To start over, stop the check and delete its state file, which holds the maximum of every interface. It is not directly in the temporary directory: the databases live in a per-user subdirectory of it that only that user may enter, so the full path is `$TEMP/linuxfabrik-monitoring-plugins-uid<UID>/linuxfabrik-monitoring-plugins-kvm-network-io-<connection>.db`, with the numeric user id of the account the check runs as.

### An interface is losing frames

A virtual interface has no cable to blame, so the cause is inside the machine or on the host. Work through it in this order:

1. Look at the machine itself. Frames dropped on the way in usually mean the guest is not taking them off its queue fast enough, so check its CPU (`check_kvm_cpu_usage`) and whether it has the virtio drivers.
2. Check the interface model (`virsh domiflist <machine>`). An emulated `e1000` or `rtl8139` interface is far slower than `virtio` and starts losing frames much earlier.
3. Check whether the machine's interface is rate-limited (`virsh domiftune <machine> <device>`). A limit set once and forgotten shows up as traffic that stops climbing and as frames going missing.
4. Look at the host's own interfaces (`check_network_errors`) and at the bridge the machine hangs on (`virsh domiflist <machine>` names it, `ip -s link` shows its counters).

### A machine shows fewer interfaces than its configuration lists

libvirt counts an interface it could not read among the machine's interfaces but reports no counters for it, and such an interface is left out rather than reported as a row of zeroes. `virsh domstats --interface --list-running` on the host shows which one is missing its counters.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
