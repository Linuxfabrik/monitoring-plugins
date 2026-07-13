# Check disk-io


## Overview

Checks disk I/O bandwidth over time and alerts on sustained saturation, not short spikes. The check records per-disk read/write counters and then derives current (R1/W1) and period averages (R{COUNT}/W{COUNT}). It compares the period's total bandwidth against the maximum ever observed for that disk (RWmax). It raises a WARNING when the period average exceeds `--warning` percent of RWmax. This bandwidth part only ever warns, never criticals: sustained I/O is a signal to investigate, not an emergency you have to react to at night.

The check also reports per-disk I/O latency (`await`): the average time a read or write took to complete over the period, in milliseconds. Unlike disk busy percentage, latency is robust against device parallelism, so it is a meaningful "is my storage slow" signal on NVMe, SSD and RAID as well. The optional `--await-warning` and `--await-critical` thresholds alert on sustained latency; both are disabled by default. A critical latency threshold is the place to catch a disk that is effectively hung.

Perfdata is emitted for each disk (read/write throughput per second and I/O latency, plus disk busy percentage on Linux), so you can graph trends. On Linux the check focuses on block devices with a mounted filesystem by default; use `--include-unmounted` to also include raw, unmounted devices such as multipath SAN volumes. On Windows it uses psutil's disk counters. Optionally, `--top` lists the processes that generated the most I/O traffic (read/write totals) to help identify offenders.

This check is cross-platform and works on Linux, Windows, and all psutil-supported systems. The check stores its short trend state locally in an SQLite DB to evaluate sustained load across runs.

**Important Notes:**

* `--count=5` (the default) while checking every minute means that the check will alert if any of your disks have been above a threshold in the last 5 minutes
* Plugin execution may take a moment due to process enumeration when `--top` is enabled

**Data Collection:**

* Uses `psutil` to collect per-disk I/O counters (see Perfdata / Metrics for the full list)
* On Linux, automatically detects "real" block devices that have mountpoints, filtering out virtual devices
* Stores counter snapshots in a local SQLite database and calculates deltas between consecutive runs
* On the first run, returns "Waiting for more data." until at least two measurements are available
* After a system reboot, counter values may be lower than the previous measurement. The check detects this and returns "Waiting for more data." until the next valid measurement pair
* Disk I/O bandwidth tracking starts at 10 MiB/sec as a baseline, but stores the highest measured bandwidth, so the `RWmax/s` value adjusts accordingly over time. The check may throw warnings during the first major disk activities above 10 MiB/sec until the actual maximum bandwidth of the disk has been determined
* On Linux, only block devices with a mounted filesystem are monitored by default; `--include-unmounted` adds raw, unmounted devices (see Troubleshooting). Pseudo devices (loop, ram, zram, floppy, optical) are always excluded
* Disks can be filtered by `--match`, a Python regular expression. It is anchored at the start of the string (Python `re.match`) and matched against the full device path (for example `/dev/sda`), the device-mapper path (for example `/dev/mapper/vg-lv`), and the mountpoint. Prefix the pattern with `.*` to match anywhere in the path, for example `.*sda$` rather than `^sda$`


## Fact Sheet

| Fact | Value |
|----|----| 
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/disk-io> |
| Nagios/Icinga Check Name              | `check_disk_io` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No (runs with Python interpreter) |
| 3rd Party Python modules              | `psutil` |
| Handles Periods                       | Yes |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-disk-io.db` |


## Help

```text
usage: disk-io [-h] [-V] [--always-ok] [--await-critical AWAIT_CRIT]
               [--await-warning AWAIT_WARN] [--count COUNT]
               [--include-unmounted] [--match MATCH]
               [--no-match-severity {ok,warn,crit,unknown}] [--no-perfdata]
               [--top TOP] [--warning WARN]

Checks disk I/O bandwidth over time and alerts on sustained saturation, not
short spikes. The check records per-disk read/write counters and then derives
current (R1/W1) and period averages (R{COUNT}/W{COUNT}). It compares the
period's total bandwidth against the maximum ever observed for that disk
(RWmax). It raises a WARNING when the period average exceeds --warning percent
of RWmax. This bandwidth part only ever warns, never criticals: sustained I/O
is a signal to investigate, not an emergency you have to react to at night.
The check also reports per-disk I/O latency (await): the average time a read
or write took to complete over the period, in milliseconds. Unlike disk busy
percentage, latency is robust against device parallelism, so it is a
meaningful "is my storage slow" signal on NVMe, SSD and RAID as well. Optional
--await-warning and --await-critical thresholds alert on sustained latency;
both are disabled by default. A critical latency threshold is the place to
catch a disk that is effectively hung. Perfdata is emitted for each disk
(read/write throughput per second and I/O latency, plus disk busy percentage
on Linux), so you can graph trends. On Linux the check focuses on block
devices with a mounted filesystem by default; use `--include-unmounted` to
also include raw, unmounted devices such as multipath SAN volumes. On Windows
it uses psutil's disk counters. Optionally, `--top` lists the processes that
generated the most I/O traffic (read/write totals) to help identify offenders.
This check is cross-platform and works on Linux, Windows, and all psutil-
supported systems. The check stores its short trend state locally in an SQLite
DB to evaluate sustained load across runs.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --await-critical AWAIT_CRIT
                        CRIT threshold for per-disk I/O latency (await) in
                        milliseconds, averaged over the last `--count` runs.
                        await is the average time a read or write took to
                        complete. Use this to catch a disk that is effectively
                        hung (sustained latency of seconds), not a merely busy
                        one. Supports Nagios ranges. Disabled by default.
  --await-warning AWAIT_WARN
                        WARN threshold for per-disk I/O latency (await) in
                        milliseconds, averaged over the last `--count` runs.
                        await is the average time a read or write took to
                        complete. A good value depends on the storage (an SSD
                        is well below a millisecond, a busy HDD can sustain
                        tens of milliseconds), so set it to what is abnormal
                        for your disks. Supports Nagios ranges. Disabled by
                        default.
  --count COUNT         Number of consecutive checks the threshold must be
                        exceeded before alerting. Default: 5
  --include-unmounted   Also monitor block devices that have no mounted
                        filesystem (Linux only). By default only block devices
                        with a mounted filesystem are monitored. Enable this
                        to include raw, unmounted devices such as multipath
                        SAN volumes or disks used directly by a database or
                        storage layer. Combine with `--match`, otherwise every
                        unmounted device shows up. Pseudo devices (loop, ram,
                        zram, floppy, optical) are always excluded. Default:
                        False
  --match MATCH         Filter by disk name. Filter by this Python regular
                        expression. Case-sensitive by default; use `(?i)` for
                        case-insensitive matching. Can be specified multiple
                        times. Examples: `(?i)example` to match "example"
                        regardless of case. `^(?!.*example).*$` to match any
                        string except "example" (negative lookahead). The
                        regex is anchored at the start of the string (Python
                        `re.match`) and matched against the full device path
                        (e.g. `/dev/sda`), the device-mapper path (e.g.
                        `/dev/mapper/vg-lv`) and the mountpoint, so prefix
                        with `.*` to match anywhere (`.*sda$` instead of
                        `^sda$`). On Linux only block devices with a mounted
                        filesystem are considered by default; add `--include-
                        unmounted` to also match raw, unmounted devices
                        (multipath SAN volumes, raw LUNs). Default:
  --no-match-severity {ok,warn,crit,unknown}
                        State to report when no item matches the filters and
                        nothing is checked. Default: ok
  --no-perfdata         Suppress the performance data section from the output.
                        The status message and the exit code are unaffected,
                        so alerting keeps working while trending data is
                        dropped.
  --top TOP             Number of top processes to list by I/O traffic. Use
                        `--top=0` to disable. Default: 5
  --warning WARN        WARN threshold for disk bandwidth saturation as a
                        percentage of the observed maximum, measured over the
                        last `--count` runs. Default: >= 80
```


## Usage Examples

Just check disk `dm-0` (if listed as `/dev/dm-0`):

```bash
./disk-io --match='.*dm-0$'
```

Match all disks except `vdc`, `vdh` and `vdz`:

```bash
./disk-io --match='^(?:(?!.*vdc|.*vdh|.*vdz).)*$'
```

Monitor a raw, unmounted multipath SAN volume (for example an Oracle ASM disk):

```bash
./disk-io --include-unmounted --match='.*dm-7$'
```

Output:

```text
/dev/dm-8: 5.6KiB/s read1, 2.2MiB/s write1, 2.2MiB/s total, 10.0MiB/s max

Name ! MntPnts        ! DvMppr           ! RWmax/s ! R1/s   ! W1/s    ! R5/s   ! W5/s    ! RW5/s   
-----+----------------+------------------+---------+--------+---------+--------+---------+---------
dm-0 ! /              ! rl-root          ! 10.0MiB ! 0.0B   ! 426.0B  ! 0.0B   ! 343.0B  ! 343.0B  
vda2 ! /boot          !                  ! 10.0MiB ! 0.0B   ! 0.0B    ! 0.0B   ! 0.0B    ! 0.0B    
vda1 ! /boot/efi      !                  ! 10.0MiB ! 0.0B   ! 0.0B    ! 0.0B   ! 0.0B    ! 0.0B    
dm-5 ! /var           ! rl-var           ! 10.0MiB ! 0.0B   ! 586.0B  ! 0.0B   ! 1.1KiB  ! 1.1KiB  
dm-8 ! /data          ! rl-lv_data       ! 10.0MiB ! 5.6KiB ! 2.2MiB  ! 8.3KiB ! 2.3MiB  ! 2.3MiB  
dm-6 ! /tmp           ! rl-tmp           ! 10.0MiB ! 0.0B   ! 4.8KiB  ! 0.0B   ! 7.1KiB  ! 7.1KiB  
dm-7 ! /home          ! rl-home          ! 10.0MiB ! 0.0B   ! 0.0B    ! 0.0B   ! 0.0B    ! 0.0B    
dm-2 ! /var/tmp       ! rl-var_tmp       ! 10.0MiB ! 0.0B   ! 0.0B    ! 0.0B   ! 0.0B    ! 0.0B    
dm-4 ! /var/log       ! rl-var_log       ! 10.0MiB ! 0.0B   ! 51.8KiB ! 0.0B   ! 51.2KiB ! 51.2KiB 
dm-3 ! /var/log/audit ! rl-var_log_audit ! 10.0MiB ! 0.0B   ! 918.0B  ! 0.0B   ! 876.0B  ! 876.0B  

Top 5 processes that generate the most I/O traffic (r/w):
1. nfsd: 149.2GiB/5.7TiB
2. systemd: 695.7GiB/169.9GiB
3. systemd-journald: 33.9MiB/124.4GiB
4. icinga2: 7.9GiB/4.9GiB
5. rsyslogd: 114.8MiB/4.1GiB
```


## States

* OK if every disk's bandwidth period average is below `--warning` (default: 80%) of the observed maximum, and I/O latency (await) is below the await thresholds (both off by default).
* OK with "Waiting for more data." on the first run or after a reboot.
* WARN if the bandwidth period average (computed over the last `--count` runs, default: 5) reaches `--warning` (default: 80%) of the observed maximum for a disk. Bandwidth alerts never escalate beyond WARN: a busy disk is a signal to investigate, not an emergency.
* WARN if a disk's average I/O latency (await, over the last `--count` runs) reaches `--await-warning` (disabled by default).
* CRIT if a disk's average I/O latency reaches `--await-critical` (disabled by default). This is the place to catch a disk that is effectively hung (sustained multi-second latency); a merely busy disk never criticals.
* `--no-match-severity` sets the state reported when the filters match no disk and nothing is checked (default: `ok`); set it to `warn`, `crit`, or `unknown` to alert on an empty selection (for example a filter typo or a missing disk) instead of silently returning OK.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

Per matched disk, where `<disk>` is the block device name. The `1` suffix is the latest interval (like a "load1"), the `15` suffix is the average over the last `--count` runs (like a "load15"). The byte, throughput and latency metrics are cross-platform; `busy_percent` is Linux only, because the underlying counter (`busy_time`) is not exposed by psutil on Windows:

| Name | Type | Description |
|----|----|----|
| `<disk>`\_await | Seconds | Average time a read or write took to complete over the last `--count` runs, in milliseconds (iostat's await). This is the latency signal that `--await-warning`/`--await-critical` alert on. |
| `<disk>`\_busy_percent | Percentage | **Linux only.** Share of wall-clock time the device had at least one I/O in flight over the last interval. This is exactly iostat's %util, derived from the `io_ticks` counter in `/proc/diskstats`. It is a busy/idle indicator, not a saturation measure: on devices that serve requests in parallel (NVMe, SSD, dm/md, ZFS) it can sit near 100% far below the real throughput limit, which is why the check does not alert on it. |
| `<disk>`\_read_await | Seconds | Average read latency over the last `--count` runs, in milliseconds (iostat's r_await). |
| `<disk>`\_read_bytes_per_second1 | Bytes | Bytes read per second over the latest interval. |
| `<disk>`\_read_bytes_per_second15 | Bytes | Bytes read per second, averaged over the last `--count` runs. |
| `<disk>`\_throughput1 | Bytes | Read plus write bytes per second over the latest interval. |
| `<disk>`\_throughput15 | Bytes | Read plus write bytes per second, averaged over the last `--count` runs. |
| `<disk>`\_write_bytes_per_second1 | Bytes | Bytes written per second over the latest interval. |
| `<disk>`\_write_bytes_per_second15 | Bytes | Bytes written per second, averaged over the last `--count` runs. |


## Troubleshooting

### `Python module "psutil" is not installed.`

Install `psutil`: `pip install psutil` or `dnf install python3-psutil`.

### Outdated psutil

`psutil raised error "not sure how to interpret line '...'"` or `Nothing checked. Running Kernel >= 4.18, this check needs the Python module psutil v5.7.0+`

Update the `psutil` library. On RHEL 8+, use at least `python38` and `python38-psutil` if using `dnf`.

### `Waiting for more data.`

This is expected on the first run. The check needs at least two measurements to calculate a delta. Wait for the next check interval.

### A raw or unmounted device is missing

By default the check only monitors block devices that have a mounted filesystem, so raw, unmounted devices never appear (for example multipath SAN volumes, raw LUNs, Oracle ASM disks). Add `--include-unmounted` to also monitor them, and narrow the result with `--match`, for example `--include-unmounted --match '.*dm-7$'` for a multipath volume. Pseudo devices (loop, ram, zram, floppy, optical) stay excluded. Note that `--match` is anchored at the start of the full device path: use `.*dm-7$`, not `^dm-7$`.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
