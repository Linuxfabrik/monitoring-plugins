# Check conntrack


## Overview

Checks how full the netfilter connection tracking table is, and how often the kernel had to give up on a connection. Every host running a firewall, NAT or a container engine tracks its connections in a fixed-size table; once that table is full the kernel throws established connections out to make room, and after that it drops packets, which shows up as random connection timeouts nobody can explain from the application side. The check reports the table usage together with the kernel's own error counters as per-second rates measured between two runs, so the values reflect the current situation and not a total accumulated since boot. A host that does not track connections at all is reported as OK, because there is no table that could fill up. Supports extended reporting via `--lengthy`. Alerts when the table usage leaves the warning or critical range, and when the kernel evicts entries, refuses to insert them or drops packets.

**Important Notes:**

* The table usage is reported from the first run on. The counter rates need a previous run to compare against, so the first run after a reboot, an update or a wiped cache says "Waiting for more data on the connection tracking counters." and reports the usage only.
* Watching the usage alone is not enough. A short burst can fill the table between two check runs and be gone again by the time the next sample is taken, while `early_drop` keeps the evidence that it happened. That counter is the reason this check reads the kernel statistics at all.
* The counters are per network namespace. Inside a container the check reports that container's connections against the host-wide limit, which is what the kernel enforces there.
* Which counters carry a real value depends on the kernel. Several of them have been retired over the years and are filled with a zero since, so the check reads the column names the kernel prints and reports only the counters that are real on the running kernel. A counter that is missing from the output was never measured, rather than measured as zero. The decision is made from that header line and never from a kernel version, because distributions backport the changes: Rocky 8 ships a 4.18 kernel that already prints the newer column set.
* `insert_failed` alerts only where it means a real failure. A kernel without the upstream 5.10 change also raised it for clashes it went on to resolve, which is an everyday event on a busy multi-CPU host and no reason to wake anybody. There the check still reports the rate, labelled "resolved clashes included", but does not alert on it. RHEL 8 and its rebuilds carry the change in their 4.18 kernel and do alert.
* Related checks: `network-connections` counts the sockets the host itself holds open, `network-errors` reports the error counters of the network interfaces. Neither sees the connection tracking table.

**Data Collection:**

* Reads `/proc/sys/net/netfilter/nf_conntrack_count` and `/proc/sys/net/netfilter/nf_conntrack_max` for the table usage
* Reads `/proc/sys/net/netfilter/nf_conntrack_buckets` for the hash table size reported with `--lengthy`
* Reads `/proc/net/stat/nf_conntrack` for the kernel counters, summing the per-CPU lines
* Stores the previous counter sample in a local SQLite database and reports the difference as a per-second rate, so no cumulative counter ends up in the performance data
* Needs no root and no `sudo`


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/conntrack> |
| Nagios/Icinga Check Name              | `check_conntrack` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Runs on                               | Linux |
| Compiled for Windows                  | No |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-conntrack.db` |


## Help

```text
usage: conntrack [-h] [-V] [--always-ok] [-c CRIT]
                 [--critical-drops CRIT_DROPS] [--lengthy] [--no-perfdata]
                 [-w WARN] [--warning-drops WARN_DROPS]

Checks how full the netfilter connection tracking table is, and how often the
kernel had to give up on a connection. Every host running a firewall, NAT or a
container engine tracks its connections in a fixed-size table; once that table
is full the kernel throws established connections out to make room, and after
that it drops packets, which shows up as random connection timeouts nobody can
explain from the application side. The check reports the table usage together
with the kernel's own error counters as per-second rates measured between two
runs, so the values reflect the current situation and not a total accumulated
since boot. A host that does not track connections at all is reported as OK,
because there is no table that could fill up. Supports extended reporting via
--lengthy. Alerts when the table usage leaves the warning or critical range,
and when the kernel evicts entries, refuses to insert them or drops packets.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  -c, --critical CRIT   CRIT threshold for the connection tracking table usage
                        in percent. Supports Nagios ranges. Default: 90
  --critical-drops CRIT_DROPS
                        CRIT threshold for the per-second rate of each counter
                        that means a connection was given up on: evicted
                        entries, failed inserts and dropped packets. Every
                        counter is compared on its own. Supports Nagios
                        ranges. Default: no critical threshold
  --lengthy             Extended reporting.
  --no-perfdata         Suppress the performance data section from the output.
                        The status message and the exit code are unaffected,
                        so alerting keeps working while trending data is
                        dropped.
  -w, --warning WARN    WARN threshold for the connection tracking table usage
                        in percent. Supports Nagios ranges. Default: 80
  --warning-drops WARN_DROPS
                        WARN threshold for the per-second rate of each counter
                        that means a connection was given up on: evicted
                        entries, failed inserts and dropped packets. Every
                        counter is compared on its own. Supports Nagios
                        ranges. Default: 0 (warns on any such event)

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/conntrack/
```


## Usage Examples

```bash
./conntrack
```

Output:

```text
0.1% conntrack table used (272.0/262.1K)
```

Output on a host whose table is at its limit:

```text
100.0% conntrack table used (262.1K/262.1K) [CRITICAL], early_drop 62456.5/s [WARNING]
The table was at its limit and entries were thrown out to make room. Raise net.netfilter.nf_conntrack_max, and raise net.netfilter.nf_conntrack_buckets along with it, or shorten the timeouts under net.netfilter.nf_conntrack_*_timeout_*.
```

Extended reporting adds the hash table size, the average hash chain length and every counter the running kernel really fills:

```bash
./conntrack --lengthy
```

Output:

```text
0.1% conntrack table used (272.0/262.1K)
Hash table: 262.1K buckets, average chain length 0.00.

Counter        ! Meaning                              ! Per Second
---------------+--------------------------------------+-----------
chainlength    ! inserts refused, hash chain too long ! 0.0
clashres       ! clashes resolved                     ! 0.0
drop           ! packets dropped                      ! 0.0
early_drop     ! entries evicted, table at its limit  ! 0.0
found          ! NAT tuples already in use            ! 0.0
icmp_error     ! ICMP errors without a connection     ! 0.0
insert_failed  ! inserts failed, packet dropped       ! 0.0
invalid        ! packets not tracked                  ! 0.0
search_restart ! lookups restarted, table resized     ! 0.0
```

A firewall or NAT gateway that lives closer to its limit by design wants more headroom before anybody is woken:

```bash
./conntrack --warning=70 --critical=85
```

A host whose table is deliberately kept full, a load balancer holding as many connections as it can, wants the usage threshold switched off and the alert left to the counters that prove real harm. `~:` is the Nagios range for "any value is fine":

```bash
./conntrack --warning=~: --critical=~:
```

Tolerate the occasional evicted entry on a busy gateway and only alert once it becomes a pattern:

```bash
./conntrack --warning-drops=10 --critical-drops=100
```


## States

* OK if the table usage is within `--warning` and `--critical` and none of the drop counters moved.
* OK if connection tracking is not active on this host. Without the module there is no table that could fill up.
* OK on the first run against the kernel counters, because there is no previous sample to compare against yet. The table usage is still evaluated and can alert.
* WARN if the table usage leaves the `--warning` range.
* WARN if the per-second rate of `early_drop`, `drop`, `insert_failed` or `chainlength` leaves the `--warning-drops` range, which by default means any of them moved at all. Each counter is compared on its own, so the output names the one that fired. `insert_failed` is excluded on a kernel that lacks the upstream 5.10 change, where it also counts clashes the kernel resolved.
* CRIT if the table usage leaves the `--critical` range, 90 % by default.
* CRIT if one of the drop counters leaves the `--critical-drops` range. There is no critical threshold by default.
* UNKNOWN if `/proc/sys/net/netfilter/nf_conntrack_max` holds a value of zero or less, which no working kernel reports.
* UNKNOWN if the check does not run on Linux.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

Every rate is a per-second value measured between two check runs, never a total accumulated since boot. A counter that the running kernel fills with a hardcoded zero is not reported at all, so the set of metrics depends on the kernel version.

| Name                      | Type       | Description |
|---------------------------|------------|-------------|
| chainlength_per_second    | Number     | Inserts refused because the hash chain they hash into had grown too long. The packet is dropped. Only on a kernel carrying the upstream 5.15 change. |
| clashres_per_second       | Number     | Clashes between two packets of the same new connection that the kernel resolved. Only on a kernel carrying the upstream 5.10 change. |
| drop_per_second           | Number     | Packets dropped by connection tracking. |
| early_drop_per_second     | Number     | Entries thrown out to make room for a new one, so the table was at its limit at that moment. |
| entries                   | Number     | Connections currently tracked. |
| entries_percent           | Percentage | Connections currently tracked, as a percentage of `nf_conntrack_max`. |
| found_per_second          | Number     | Candidate NAT tuples that were already in use. Stays at zero on a host that does not NAT. |
| icmp_error_per_second     | Number     | ICMP and ICMPv6 error packets that could not be associated with a connection. |
| ignore_per_second         | Number     | Packets that already carried a connection. Only on a kernel without the upstream 5.10 change. |
| insert_failed_per_second  | Number     | Entries that could not be inserted, whereupon the packet was dropped. On a kernel without the upstream 5.10 change this also counts clashes the kernel went on to resolve. |
| invalid_per_second        | Number     | Packets that could not be associated with a connection. Connection tracking still accepts them and the firewall ruleset decides their fate. |
| search_restart_per_second | Number     | Lookups that had to start over because the hash table was resized underneath them. |


## Troubleshooting

### `nf_conntrack: table full, dropping packet`

The kernel writes this to the ring buffer once the table is full and it cannot free an entry to make room. Every new connection is dropped from that moment on, which the applications see as connections that never establish. Read the current situation first:

```bash
sysctl net.netfilter.nf_conntrack_count net.netfilter.nf_conntrack_max
```

Raising the limit is the immediate fix, and the hash table has to grow along with it, otherwise the chains get longer and every lookup gets slower:

```bash
sysctl --write net.netfilter.nf_conntrack_max=524288
sysctl --write net.netfilter.nf_conntrack_buckets=524288
```

Put both into a file under `/etc/sysctl.d/` so they survive a reboot. Each entry costs a few hundred bytes of kernel memory, so a limit of one million entries is worth a few hundred megabytes on a machine that has them to spare.

Raising the limit is not always the answer. A table that fills up with short-lived connections is better served by shorter timeouts, above all `net.netfilter.nf_conntrack_tcp_timeout_time_wait` and `net.netfilter.nf_conntrack_udp_timeout`. And a table that fills up within minutes usually means something is hammering the host; see which connections it holds:

```bash
conntrack --count
conntrack --dump | awk '{for (i = 1; i <= NF; i++) if ($i ~ /^src=/) {print $i; break}}' | sort | uniq --count | sort --numeric-sort --reverse | head
```

The `awk` picks the first `src=` of each line rather than a fixed column, because a TCP entry carries its connection state where a UDP entry already has the addresses.


### `early_drop` moves although the table usage looks harmless

That is the case this check exists for. The usage is a sample taken every check interval, and a burst that fills the table between two samples is gone again before the next one. `early_drop` is the kernel's own record that it had to throw an established connection out to make room, so a rate above zero means the table did reach its limit, whatever the usage says.

Raise the limit as described above rather than the thresholds. Alternatively, if the host is a load balancer or a gateway that is supposed to run its table full and only real drops matter, switch the usage thresholds off with `--warning=~: --critical=~:` and leave the alerting to the drop counters.


### Connections are dropped although the table is not full

`drop` and `insert_failed` also move when two packets of the same new connection arrive on different CPUs at the same moment and the kernel cannot resolve the clash, and when the hash chain a new entry would go into is too long to insert into. Both get worse the longer the chains are, so check them:

```bash
./conntrack --lengthy
```

An average chain length well above two means the hash table is too small for the number of tracked connections, usually because `nf_conntrack_max` was raised at some point and `nf_conntrack_buckets` was not. Set the two to the same value.


### The check reports "Connection tracking is not active on this host."

Nothing on the host has asked the kernel to track connections, so `/proc/sys/net/netfilter/` does not exist and there is no table to watch. That is the normal state of a host with no firewall, no NAT and no container engine, and it is reported as OK on purpose.

If the host is supposed to be filtering, the firewall is the thing to look at, not this check:

```bash
lsmod | grep nf_conntrack
systemctl status firewalld nftables
```


### Fewer counters than expected in the output

The check reports only the counters the running kernel really fills. Several of them have been retired and a hardcoded zero is printed in their place since, and reporting those would put a number into the graph that was never measured. `clashres` needs the upstream 5.10 change, `chainlength` the 5.15 one, and `ignore` is real only without the 5.10 one. Do not go by the kernel version, distributions backport these: a Rocky 8 host on kernel 4.18 prints `clashres` and no `chainlength`. Which columns the kernel prints can be read directly:

```bash
head -1 /proc/net/stat/nf_conntrack
```


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
