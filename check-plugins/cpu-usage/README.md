# Check cpu-usage


## Overview

Reports CPU utilization percentages for all available time categories (user, system, idle, nice, iowait, irq, softirq, steal, guest, guest_nice) plus the overall cpu-usage (100 - idle - nice).

Thresholds (WARN/CRIT) are checked against user, system, iowait, and cpu-usage. An alert is raised only if the threshold is exceeded for COUNT consecutive runs, suppressing short spikes and focusing on sustained load.

Perfdata is emitted for every field to enable full graphing. Extended stats (context switches, interrupts, etc.) are included if supported on this platform.

This check is cross-platform and works on Linux, Windows, and all psutil-supported systems. The check stores its short trend state locally in an SQLite DB to evaluate sustained load across runs.

**Data Collection:**

* System-wide aggregate CPU statistics (not per-core) via `psutil.cpu_times()`
* Non-blocking measurement using SQLite state persistence between runs: stores a raw CPU time snapshot and computes the delta against the previous run
* On the first run, falls back to a short 0.25s blocking sample to produce sane output
* Platform-specific extended metrics where available: context switches, interrupts, soft interrupts (requires psutil >= 4.1.0)
* Detects and skips all-zero CPU samples (can occur on Windows systems with many cores) to avoid false 100% usage reports


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/cpu-usage> |
| Nagios/Icinga Check Name              | `check_cpu_usage` |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | Yes |
| 3rd Party Python modules              | `psutil` |
| Handles Periods                       | Yes |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-cpu-usage.db` |


## Help

```text
usage: cpu-usage [-h] [-V] [--always-ok] [--count COUNT] [-c CRIT] [-w WARN]

Reports CPU utilization percentages for all available time categories (user,
system, idle, nice, iowait, irq, softirq, steal, guest, guest_nice) plus the
overall cpu-usage (100 − idle − nice). Thresholds (WARN/CRIT) are checked
against user, system, iowait, and cpu-usage. An alert is raised only if the
threshold is exceeded for COUNT consecutive runs, suppressing short spikes and
focusing on sustained load. Perfdata is emitted for every field to enable full
graphing. Extended stats (context switches, interrupts, etc.) are included if
supported on this platform. This check is cross-platform and works on Linux,
Windows, and all psutil-supported systems. The check stores its short trend
state locally in an SQLite DB to evaluate sustained load across runs.

options:
  -h, --help           show this help message and exit
  -V, --version        show program's version number and exit
  --always-ok          Always returns OK.
  --count COUNT        Number of consecutive checks the threshold must be
                       exceeded before alerting. Default: 5
  -c, --critical CRIT  CRIT threshold in percent. Default: >= 90
  -w, --warning WARN   WARN threshold in percent. Default: >= 80
```


## Usage Examples

```bash
./cpu-usage --count=15 --warning=50 --critical=70
```

Output:

```text
2.6% - user: 1.6%, system: 0.7%, irq: 0.2%, softirq: 0.1%
guest: 0.0%, iowait: 0.0%, guest_nice: 0.0%, steal: 0.0%, nice: 0.0%
interrupts: 582.9M, soft_interrupts: 343.6M, ctx_switches: 1.1G
```


## States

* OK if `user`, `system`, `iowait`, and overall `cpu-usage` are all below the thresholds within the last `--count` checks (default: 5).
* OK with "Waiting for more data (got an all-zero CPU sample, skipping)." if an all-zero sample is detected.
* WARN if any of the checked fields exceeds `--warning` (default: 80) for `--count` consecutive runs.
* CRIT if any of the checked fields exceeds `--critical` (default: 90) for `--count` consecutive runs.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| cpu-usage | Percentage | The overall CPU usage (100 - `idle` - `nice`). |
| ctx_switches | Continous Counter | Number of context switches (voluntary + involuntary) since boot. |
| guest | Percentage | Time spent running a virtual CPU (Linux 2.6.24+). |
| guest_nice | Percentage | Time spent running a niced guest (Linux 3.2.0+). |
| interrupts | Continous Counter | Number of interrupts since boot. |
| iowait | Percentage | Time spent waiting for I/O to complete. |
| irq | Percentage | Time spent servicing hardware interrupts. |
| nice | Percentage | Time spent by niced (prioritized) processes executing in user mode. |
| soft_interrupts | Continous Counter | Number of software interrupts since boot. |
| steal | Percentage | Time a virtual CPU waits for a real CPU while the hypervisor is servicing another virtual processor (Linux 2.6.11+). |
| system | Percentage | Time spent in kernel space. |
| user | Percentage | Time spent in user space. |


## Troubleshooting

`Python module "psutil" is not installed.`  
Install `psutil`: `pip install psutil` or `dnf install python3-psutil`.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
* Credits: [psutil Documentation](https://psutil.readthedocs.io/en/latest/)
