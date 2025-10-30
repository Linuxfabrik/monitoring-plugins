# Check cpu-usage

## Overview

Monitors system-wide CPU utilization with sustained load detection to avoid false alerts from short-lived spikes. Reports percentages across all standard CPU time categories (user, system, idle, nice, iowait, irq, softirq, steal, guest, guest_nice) plus calculated overall CPU usage (100 - idle - nice).

**Alerting Logic:**

* Thresholds apply to: `user`, `system`, `iowait`, and overall `cpu-usage`
* Alert triggers only when threshold exceeded for `--count` consecutive check runs (default: 5)
* Example: With default settings and 1-minute check interval, WARN/CRIT states require sustained high CPU for 5 consecutive minutes
* Single brief spikes are ignored, focusing on persistent performance issues

**Data Collection:**

* System-wide aggregate CPU statistics (not per-core)
* Non-blocking measurement using SQLite state persistence between runs
* Platform-specific extended metrics where available (context switches, interrupts, soft interrupts)
* Optional top-N CPU-consuming processes (`--top`, default: 5)

**Compatibility:**

* Cross-platform: Linux, Windows, and all psutil-supported systems
* Uses SQLite database (`$TEMP/linuxfabrik-monitoring-plugins-cpu-usage.db`) for trend tracking
* Full perfdata output for graphing all metrics in Nagios/Icinga


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/cpu-usage> |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | Yes |
| 3rd Party Python modules              | `psutil` |
| Handles Periods                       | Yes |
| Uses SQLite DBs                       | `$TEMP/linuxfabrik-monitoring-plugins-cpu-usage.db` |


## Help

```text
usage: cpu-usage [-h] [-V] [--always-ok] [--count COUNT] [-c CRIT] [--top TOP]
                 [-w WARN]

Reports CPU utilization percentages for all available time categories (user,
system, idle, nice, iowait, irq, softirq, steal, guest, guest_nice) plus the
overall cpu-usage (100 − idle − nice). Thresholds (WARN/CRIT) are checked
against user, system, iowait, and cpu-usage. An alert is raised only if the
threshold is exceeded for COUNT consecutive runs, suppressing short spikes and
focusing on sustained load. Perfdata is emitted for every field to enable full
graphing. Extended stats (context switches, interrupts, etc.) are included if
supported on this platform. With `--top`, the most CPU-intensive processes are
also listed for quick diagnosis. This check is cross-platform and works on
Linux, Windows, and all psutil-supported systems. The check stores its short
trend state locally in an SQLite DB to evaluate sustained load across runs.

options:
  -h, --help           show this help message and exit
  -V, --version        show program's version number and exit
  --always-ok          Always returns OK.
  --count COUNT        Number of times the value must exceed specified
                       thresholds before alerting. Default: 5
  -c, --critical CRIT  Set the critical threshold CPU Usage Percentage.
                       Default: 90
  --top TOP            List x "Top processes using the most cpu time". Use
                       `--top=0` to disable this feature. Default: 5
  -w, --warning WARN   Set the warning threshold CPU Usage Percentage.
                       Default: 80
```


## Usage Examples

```bash
./cpu-usage --count=15 --warning=50 --critical=70 --top=3
```

Output:

```text
2.6% - user: 1.6%, system: 0.7%, irq: 0.2%, softirq: 0.1%
guest: 0.0%, iowait: 0.0%, guest_nice: 0.0%, steal: 0.0%, nice: 0.0%
interrupts: 582.9M, soft_interrupts: 343.6M, ctx_switches: 1.1G

Top 3 processes using the most cpu time:
1. Xorg: 2h 13m
2. gnome-shell: 2h 1m
3. firefox: 1h 24m
```


## States

* OK if `user`, `system`, `iowait` and overall `cpu-usage` (minus `nice`) are all below the thresholds within the last `--count` checks.
* Otherwise CRIT or WARN.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| cpu-usage | Percentage | The overall cpu usage. This is (100 - `idle`). |
| ctx_switches | Continous Counter | Number of context switches (voluntary + involuntary) since boot. A context switch is a procedure that a computer's CPU (central processing unit) follows to change from one task (or process) to another while ensuring that the tasks do not conflict. |
| guest | Percentage | Linux 2.6.24+: Time spent running a virtual CPU. |
| guest_nice | Percentage | Linux 3.2.0+ |
| idle | Percentage | If the CPU has completed all tasks it is idle. |
| interrupts | Continous Counter | Number of interrupts since boot. |
| iowait | Percentage | Time spent waiting for I/O to complete. This is not accounted in idle time counter. |
| irq | Percentage | Time spent for servicing hardware interrupts. |
| nice | Percentage | Time spent by niced (prioritized) processes executing in user mode; this also includes guest_nice time. |
| soft_interrupts | Continous Counter | Number of software interrupts since boot. |
| steal | Percentage | Linux 2.6.11+; Percentage of time a virtual CPU waits for a real CPU while the hypervisor is servicing another virtual processor. |
| system | Percentage | Percent time spent in kernel space. System CPU time is the time spent running code in the Operating System kernel. |
| user | Percentage | Percent time spent in user space. User CPU time is the time spent on the processor running your program's code (or code in libraries). |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
* Credits: [psutil Documentation](https://psutil.readthedocs.io/en/latest/)
