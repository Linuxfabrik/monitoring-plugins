# Check disk-io


## Overview

Checks disk I/O bandwidth over time and alerts on sustained saturation, not short spikes. The check records per-disk read/write counters and then derives current (R1/W1) and period averages (R{COUNT}/W{COUNT}). It compares the period's total bandwidth against the maximum ever observed for that disk (RWmax). WARN/CRIT trigger if the period average exceeds the configured percentage of RWmax for COUNT consecutive runs.

On Linux, the check also monitors the system-wide iowait percentage (CPU time spent waiting for I/O). The raw iowait value is normalized by multiplying it with the number of logical CPUs, so that 100% always means one CPU core is fully I/O-saturated, regardless of the total number of CPUs. This makes the default thresholds (80/90%) work consistently across different hardware. Like bandwidth alerts, iowait alerts require COUNT consecutive threshold violations.

Perfdata is emitted for each disk (busy_time, read_bytes, read_time, write_bytes, write_time) and for iowait, so you can graph trends. On Linux the check automatically focuses on "real" block devices with mountpoints; on Windows it uses psutil's disk counters. Optionally, `--top` lists the processes that generated the most I/O traffic (read/write totals) to help identify offenders.

This check is cross-platform and works on Linux, Windows, and all psutil-supported systems. The check stores its short trend state locally in an SQLite DB to evaluate sustained load across runs.

**Important Notes:**

* `--count=5` (the default) while checking every minute means that the check will alert if any of your disks have been above a threshold in the last 5 minutes
* iowait is only available on Linux. Values above 100% indicate that more than one CPU core is waiting for I/O
* Plugin execution may take a moment due to process enumeration when `--top` is enabled

**Data Collection:**

* Uses `psutil` to collect per-disk I/O counters (read_bytes, write_bytes, busy_time, read_time, write_time)
* On Linux, automatically detects "real" block devices that have mountpoints, filtering out virtual devices
* On Linux, derives the system-wide iowait percentage non-blockingly from `/proc/stat` via `psutil.cpu_times()`
* Stores counter snapshots in a local SQLite database and calculates deltas between consecutive runs
* On the first run, returns "Waiting for more data." until at least two measurements are available
* After a system reboot, counter values may be lower than the previous measurement. The check detects this and returns "Waiting for more data." until the next valid measurement pair
* Disk I/O bandwidth tracking starts at 10 MiB/sec as a baseline, but stores the highest measured bandwidth, so the `RWmax/s` value adjusts accordingly over time. The check may throw warnings during the first major disk activities above 10 MiB/sec until the actual maximum bandwidth of the disk has been determined
* Disks can be filtered by `--match` (Python regular expression matching block device, device mapper device, or mountpoint)


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
               [--match MATCH] [--top TOP] [--warning WARN]

Checks disk I/O bandwidth over time and alerts on sustained saturation, not
short spikes. The check records per-disk read/write counters and then derives
current (R1/W1) and period averages (R{COUNT}/W{COUNT}). It compares the
period's total bandwidth against the maximum ever observed for that disk
(RWmax). WARN/CRIT trigger if the period average exceeds the configured
percentage of RWmax for COUNT consecutive runs. On Linux, the check also
monitors the system-wide iowait percentage (CPU time spent waiting for I/O).
The raw iowait value is normalized by multiplying it with the number of
logical CPUs, so that 100% always means one CPU core is fully I/O-saturated,
regardless of the total number of CPUs. This makes the default thresholds
(80/90%) work consistently across different hardware. Like bandwidth alerts,
iowait alerts require COUNT consecutive threshold violations. Perfdata is
emitted for each disk (busy_time, read_bytes, read_time, write_bytes,
write_time) and for iowait, so you can graph trends. On Linux the check
automatically focuses on "real" block devices with mountpoints; on Windows it
uses psutil's disk counters. Optionally, `--top` lists the processes that
generated the most I/O traffic (read/write totals) to help identify offenders.
This check is cross-platform and works on Linux, Windows, and all psutil-
supported systems. The check stores its short trend state locally in an SQLite
DB to evaluate sustained load across runs.

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
                        CRIT threshold for normalized iowait in percent (Linux
                        only). The iowait value is normalized so that 100%
                        means one CPU core is fully I/O-saturated. Values
                        above 100% indicate that more than one core is waiting
                        for I/O. Default: >= 90
  --iowait-warning IOWAIT_WARN
                        WARN threshold for normalized iowait in percent (Linux
                        only). The iowait value is normalized so that 100%
                        means one CPU core is fully I/O-saturated. Values
                        above 100% indicate that more than one core is waiting
                        for I/O. Default: >= 80
  --match MATCH         Filter by disk name. Filter by this Python regular
                        expression. Case-sensitive by default; use `(?i)` for
                        case-insensitive matching. Can be specified multiple
                        times. Examples: `(?i)example` to match "example"
                        regardless of case. `^(?!.*example).*$` to match any
                        string except "example" (negative lookahead). Default:
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

Output:

```text
iowait: 0.1%. /dev/dm-8: 5.6KiB/s read1, 2.2MiB/s write1, 2.2MiB/s total, 10.0MiB/s max

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
* WARN if iowait is >= `--iowait-warning` (default: 80%) for `--count` (default: 5) consecutive runs (Linux only).
* CRIT if iowait is >= `--iowait-critical` (default: 90%) for `--count` (default: 5) consecutive runs (Linux only).
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

Global:

| Name | Type | Description |
|----|----|----|
| iowait | Percentage | System-wide normalized iowait (Linux only). |

Per matched disk, where `<disk>` is the block device name:

| Name | Type | Description |
|----|----|----|
| `<disk>`\_busy_time | Continuous Counter | Time spent doing actual I/Os (in milliseconds). |
| `<disk>`\_read_bytes | Continuous Counter | Number of bytes read. |
| `<disk>`\_read_time | Continuous Counter | Time spent reading from disk (in milliseconds). |
| `<disk>`\_write_bytes | Continuous Counter | Number of bytes written. |
| `<disk>`\_write_time | Continuous Counter | Time spent writing to disk (in milliseconds). |


## Troubleshooting

`psutil raised error "not sure how to interpret line '...'"` or `Nothing checked. Running Kernel >= 4.18, this check needs the Python module psutil v5.7.0+`  
Update the `psutil` library. On RHEL 8+, use at least `python38` and `python38-psutil` if using `dnf`.

`Python module "psutil" is not installed.`  
Install `psutil`: `pip install psutil` or `dnf install python3-psutil`.

`Waiting for more data.`  
This is expected on the first run. The check needs at least two measurements to calculate a delta. Wait for the next check interval.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
