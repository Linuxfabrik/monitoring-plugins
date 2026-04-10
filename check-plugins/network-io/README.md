# Check network-io


## Overview

Monitors network I/O throughput per interface over time. Calculates bytes per second from cumulative counters using SQLite state persistence between runs. Alerts only if bandwidth thresholds have been exceeded for a configurable number of consecutive check runs (default: 5), suppressing short spikes. Also reports packet rates, errors, and drops per interface.

**Important Notes:**

* `--count=5` (the default) while checking every minute means that the check reports a warning if any of your interfaces were above a threshold in the last 5 minutes
* Interfaces starting with `lo` are ignored by default; use `--ignore` to exclude additional interfaces

**Data Collection:**

* Uses `psutil.net_io_counters()` to collect bytes sent/received, packets, errors, and drops per interface
* Uses SQLite state persistence between runs to calculate deltas (bytes per second)
* On the first run, returns "Waiting for more data." until at least two measurements are available
* After a system reboot, counter values may be lower than the previous measurement. The check detects this (negative delta) and returns "Waiting for more data." until the next valid measurement pair.
* The all-time maximum throughput per interface is stored in the cache and never decreases automatically


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/network-io> |
| Nagios/Icinga Check Name              | `check_network_io` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | Yes |
| 3rd Party Python modules              | `psutil` |
| Uses SQLite DBs                       | `$TEMP/linuxfabrik-monitoring-plugins-network-io.db` |


## Help

```text
usage: network-io [-h] [-V] [--always-ok] [--count COUNT] [--critical CRIT]
                  [--ignore IGNORE] [--warning WARN]

Monitors network I/O throughput per interface over time. Calculates bytes per
second from cumulative counters using SQLite state persistence between runs.
Alerts only if bandwidth thresholds have been exceeded for a configurable
number of consecutive check runs (default: 5), suppressing short spikes. Also
reports packet rates, errors, and drops per interface.

options:
  -h, --help       show this help message and exit
  -V, --version    show program's version number and exit
  --always-ok      Always returns OK.
  --count COUNT    Number of consecutive checks the threshold must be exceeded
                   before alerting. Default: 5
  --critical CRIT  CRIT threshold for network I/O rx/tx rate over the entire
                   period as a percentage of the maximum network I/O rate.
                   Default: >= 90
  --ignore IGNORE  Ignore network interfaces starting with this string. Can be
                   specified multiple times. Example: `--ignore tun`. Default:
                   ['lo']
  --warning WARN   WARN threshold for network I/O rx/tx rate over the entire
                   period as a percentage of the maximum network I/O rate.
                   Default: >= 80
```


## Usage Examples

```bash
./network-io --ignore lo --warning 80 --critical 90 --count 5
```

Output:

```text
wlp0s20f3: 28.1MiB/s rx, 5.6KiB/s tx (current)

Interface ! rxtx-max/s ! rx1/s   ! tx1/s  ! rx5/s    ! tx5/s  ! rxtx5/s  
----------+------------+---------+--------+----------+--------+----------
tun0      ! 10.0MiB    ! 0.0B    ! 0.0B   ! 2.8B     ! 7.8B   ! 10.6B    
tun2      ! 10.0MiB    ! 183.0B  ! 106.0B ! 2.9B     ! 7.9B   ! 10.8B    
wlp0s20f3 ! 30.0MiB    ! 28.1MiB ! 5.6KiB ! 25.1 MiB ! 2.9KiB ! 25.1MiB [WARNING]
```

The first line always shows the interface with the currently highest throughput. The table columns mean:

* `rxtx-max/s`: The maximum throughput ever measured for this interface.
* `rx1/s`, `tx1/s`: The current throughput (receive and transmit).
* `rx5/s`, `tx5/s`: The averaged throughput over the last 5 measured values.
* `rxtx5/s`: The combined rx+tx throughput over the period. This is what gets compared against the threshold.


## States

* OK if throughput over the measured period is below the warning threshold for all interfaces.
* OK with "Waiting for more data." on the first run or after a reboot.
* WARN or CRIT if the throughput over the last n measured values exceeds the specified percentage of the all-time maximum throughput.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

Per interface:

| Name | Type | Description |
|----|----|----|
| \<interface\>\_bytes_recv | Continuous Counter | Number of bytes received. |
| \<interface\>\_bytes_recv_per_second1 | Bytes | Current bytes received per second. |
| \<interface\>\_bytes_recv_per_second15 | Bytes | Averaged bytes received per second over the configured count. |
| \<interface\>\_bytes_sent | Continuous Counter | Number of bytes sent. |
| \<interface\>\_bytes_sent_per_second1 | Bytes | Current bytes sent per second. |
| \<interface\>\_bytes_sent_per_second15 | Bytes | Averaged bytes sent per second over the configured count. |
| \<interface\>\_dropin | Continuous Counter | Total number of incoming packets which were dropped. |
| \<interface\>\_dropout | Continuous Counter | Total number of outgoing packets which were dropped (always 0 on macOS and BSD). |
| \<interface\>\_errin | Continuous Counter | Total number of errors while receiving. |
| \<interface\>\_errout | Continuous Counter | Total number of errors while sending. |
| \<interface\>\_packets_recv | Continuous Counter | Number of packets received. |
| \<interface\>\_packets_sent | Continuous Counter | Number of packets sent. |
| \<interface\>\_throughput1 | None | Current bytes per second (bytes_recv_per_second1 + bytes_sent_per_second1). |
| \<interface\>\_throughput15 | None | Averaged bytes per second over the configured count. |


## Troubleshooting

`Waiting for more data.`
This is expected on the first run or after a reboot. The check needs at least two measurements to calculate a delta. Wait for the next check interval.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
