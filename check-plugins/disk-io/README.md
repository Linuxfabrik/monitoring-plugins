# Check disk-io


## Overview

Checks disk I/O bandwidth over time and alerts on sustained saturation, not short spikes. The check records per-disk read/write counters and then derives current (R1/W1) and period averages (R{COUNT}/W{COUNT}). It compares the period's total bandwidth against the maximum ever observed for that disk (RWmax). WARN/CRIT trigger if the period average exceeds the configured percentage of RWmax for COUNT consecutive runs.

On Linux, the check also monitors how much I/O wait the system accumulates (CPU time spent waiting for I/O). The machine-wide iowait reported by the kernel is normalized to a per-core basis and shown as *saturated cores*: `1.0 cores` means the equivalent of one CPU core spent the whole interval waiting for I/O, `2.0 cores` means two, and so on. This is the same mental model as the load average. Reporting per-core instead of as a percentage of the whole machine is deliberate: it lets you deploy one identical threshold to an entire fleet. `--iowait-warning` and `--iowait-critical` are expressed in percent of a single core (default 80/90), so `90` means "alert when 1 core is stuck 90% in I/O wait", and that means the same thing on a 4-core VM and a 64-core VM, even when the core count changes over time. Like bandwidth alerts, iowait alerts require COUNT consecutive threshold violations.

Perfdata is emitted for each disk (read/write throughput per second and disk busy percentage) and for iowait, so you can graph trends. On Linux the check focuses on block devices with a mounted filesystem by default; use `--include-unmounted` to also include raw, unmounted devices such as multipath SAN volumes. On Windows it uses psutil's disk counters. Optionally, `--top` lists the processes that generated the most I/O traffic (read/write totals) to help identify offenders.

This check is cross-platform and works on Linux, Windows, and all psutil-supported systems. The check stores its short trend state locally in an SQLite DB to evaluate sustained load across runs.

**Important Notes:**

* `--count=5` (the default) while checking every minute means that the check will alert if any of your disks have been above a threshold in the last 5 minutes
* iowait is only available on Linux. It is reported as saturated cores (`1.0` = one core fully waiting for I/O); a value above `1.0` cores is normal and means more than one core's worth of I/O wait
* Plugin execution may take a moment due to process enumeration when `--top` is enabled

**Data Collection:**

* Uses `psutil` to collect per-disk I/O counters (see Perfdata / Metrics for the full list)
* On Linux, automatically detects "real" block devices that have mountpoints, filtering out virtual devices
* On Linux, derives the machine-wide iowait non-blockingly from `/proc/stat` via `psutil.cpu_times()`, then normalizes it to a per-core basis (saturated cores) so one fleet-wide threshold fits hosts of any core count
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
| Runs on                               | Linux |
| Compiled for Windows                  | Yes |
| 3rd Party Python modules              | `psutil` |
| Handles Periods                       | Yes |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-disk-io.db` |


## Help

```text
usage: disk-io [-h] [-V] [--always-ok] [--count COUNT] [--critical CRIT]
               [--iowait-critical IOWAIT_CRIT] [--iowait-warning IOWAIT_WARN]
               [--include-unmounted] [--match MATCH]
               [--no-match-severity {ok,warn,crit,unknown}] [--top TOP]
               [--warning WARN]

Checks disk I/O bandwidth over time and alerts on sustained saturation, not
short spikes. The check records per-disk read/write counters and then derives
current (R1/W1) and period averages (R{COUNT}/W{COUNT}). It compares the
period's total bandwidth against the maximum ever observed for that disk
(RWmax). WARN/CRIT trigger if the period average exceeds the configured
percentage of RWmax for COUNT consecutive runs. On Linux, the check also
monitors how much I/O wait the system accumulates (CPU time spent waiting for
I/O). The machine-wide iowait is normalized to a per-core basis and reported
as saturated cores, where 1.0 cores means the equivalent of one CPU core spent
the whole interval waiting for I/O. Because the value is per-core, a single
fleet-wide threshold works on every host regardless of its core count:
--iowait-warning and --iowait-critical are given in percent of one core
(default 80/90, i.e. alert near one saturated core). Like bandwidth alerts,
iowait alerts require COUNT consecutive threshold violations. Perfdata is
emitted for each disk (read/write throughput per second and disk busy
percentage) and for iowait, so you can graph trends. On Linux the check
focuses on block devices with a mounted filesystem by default; use `--include-
unmounted` to also include raw, unmounted devices such as multipath SAN
volumes. On Windows it uses psutil's disk counters. Optionally, `--top` lists
the processes that generated the most I/O traffic (read/write totals) to help
identify offenders. This check is cross-platform and works on Linux, Windows,
and all psutil-supported systems. The check stores its short trend state
locally in an SQLite DB to evaluate sustained load across runs.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --count COUNT         Number of consecutive checks the threshold must be
                        exceeded before alerting. Default: 5
  --critical CRIT       CRIT threshold for disk bandwidth saturation as a
                        percentage of the observed maximum, measured over the
                        last `--count` runs. Default: >= 90
  --iowait-critical IOWAIT_CRIT
                        CRIT threshold for iowait, in percent of a single CPU
                        core (Linux only). 100 means the equivalent of one
                        core spent the whole interval waiting for I/O,
                        independent of the host total core count, so the same
                        threshold works fleet-wide regardless of how many
                        cores a host has. The measured value is reported as
                        saturated cores (e.g. 1.02 cores). Default: >= 90
  --iowait-warning IOWAIT_WARN
                        WARN threshold for iowait, in percent of a single CPU
                        core (Linux only). 100 means the equivalent of one
                        core spent the whole interval waiting for I/O,
                        independent of the host total core count, so the same
                        threshold works fleet-wide regardless of how many
                        cores a host has. The measured value is reported as
                        saturated cores (e.g. 1.02 cores). Default: >= 80
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
iowait: 0.00 cores saturated. /dev/dm-8: 5.6KiB/s read1, 2.2MiB/s write1, 2.2MiB/s total, 10.0MiB/s max

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

* OK if disk bandwidth period average is below `--warning` (default: 80%) of the observed maximum for each disk.
* OK with "Waiting for more data." on the first run or after a reboot.
* WARN if the bandwidth period average is >= `--warning` (default: 80%) of the observed maximum for `--count` (default: 5) consecutive runs.
* CRIT if the bandwidth period average is >= `--critical` (default: 90%) of the observed maximum for `--count` (default: 5) consecutive runs.
* WARN if iowait reaches `--iowait-warning` (default: 80% of one core, i.e. 0.8 saturated cores) for `--count` (default: 5) consecutive runs (Linux only).
* CRIT if iowait reaches `--iowait-critical` (default: 90% of one core, i.e. 0.9 saturated cores) for `--count` (default: 5) consecutive runs (Linux only).
* `--no-match-severity` sets the state reported when the filters match no disk and nothing is checked (default: `ok`); set it to `warn`, `crit`, or `unknown` to alert on an empty selection (for example a filter typo or a missing disk) instead of silently returning OK.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

Global:

| Name | Type | Description |
|----|----|----|
| iowait | Number | Machine-wide I/O wait normalized to saturated CPU cores (`1.0` = one core fully waiting for I/O). Linux only. |

Per matched disk, where `<disk>` is the block device name. The `1` suffix is the latest interval (like a "load1"), the `15` suffix is the average over the last `--count` runs (like a "load15"):

| Name | Type | Description |
|----|----|----|
| `<disk>`\_busy_percent | Percentage | Share of wall-clock time the device was busy with I/O over the last interval (iostat's %util). |
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

### iowait shows more than 1.0 cores

This is expected, not an error. iowait is reported as saturated CPU cores, so on a multi-core host the value legitimately rises above `1.0` once more than one core's worth of I/O wait piles up (see the Overview for the per-core threshold rationale). When the alert fires, the host really does have roughly one or more cores stuck waiting for I/O, sustained over the last `--count` runs; investigate the busy disks and the `--top` process list, not the core count.

### A raw or unmounted device is missing

By default the check only monitors block devices that have a mounted filesystem, so raw, unmounted devices never appear (for example multipath SAN volumes, raw LUNs, Oracle ASM disks). Add `--include-unmounted` to also monitor them, and narrow the result with `--match`, for example `--include-unmounted --match '.*dm-7$'` for a multipath volume. Pseudo devices (loop, ram, zram, floppy, optical) stay excluded. Note that `--match` is anchored at the start of the full device path: use `.*dm-7$`, not `^dm-7$`.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
