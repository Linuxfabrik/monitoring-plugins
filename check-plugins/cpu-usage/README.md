# Check cpu-usage


## Overview

Reports CPU utilization percentages for all available time categories (user, system, idle, nice, iowait, irq, softirq, steal, guest, guest_nice) plus the overall cpu-usage, which is the total busy share of all CPUs (100 - idle) and therefore includes nice.

Thresholds (WARN/CRIT) are checked against user, system, and the busy share without nice. Work that runs at a lowered priority yields to everything else, so a host busy with nothing but niced batch work stays OK while its cpu-usage graph shows the machine at full load. An alert is raised only if the threshold is exceeded for COUNT consecutive runs, suppressing short spikes and focusing on sustained load. iowait is reported and graphed but never triggers an alert, because Linux iowait is relabelled idle time and unreliable on multi-core systems.

Steal time carries its own threshold, because a virtual machine can sit at a harmless overall utilization while an oversubscribed hypervisor takes a quarter of its CPU time away.

`--per-cpu` adds one utilization metric per core and names the busiest one, which is what a single-threaded bottleneck looks like on a machine that otherwise appears mostly idle.

Perfdata is emitted for every field to enable full graphing. Extended stats (context switches, interrupts, etc.) are included if supported on this platform.

This check is cross-platform and works on Linux, Windows, and all psutil-supported systems. The check stores its short trend state locally in an SQLite DB to evaluate sustained load across runs.

**Important Notes:**

* The reported `cpu-usage` and the value the thresholds are checked against are not the same number. `cpu-usage` is the plain total of everything the CPUs did except idle, niced work included, because that is what a utilization graph should show. The thresholds leave niced work out, because a process that was asked to stand back is not a reason to alert. A host running nothing but `nice`d batch jobs therefore graphs at 100% and stays OK.
* Steal alerts at 10% by default. On a virtual machine whose hypervisor has always been oversubscribed, this reports a WARN that was not reported before. Set `--warning-steal=""` to switch it off, or raise it to the level the platform is expected to deliver.
* The output names the window the percentages were measured over. It is the time since the previous check run, so a check that was delayed or skipped covers a longer one, and the first run after a reboot covers its short blocking sample.
* `--per-cpu` reports no per-core metrics until a second run with `--per-cpu` has a snapshot to measure against. That is the case on the first run, after a reboot, after a core was added to the machine, and after the check ran without `--per-cpu` in between. Only a run given the option records the per-core snapshot, and an older one would cover a different period than the overall percentages printed next to it.

**Data Collection:**

* System-wide aggregate CPU statistics via `psutil.cpu_times()`, and per-core statistics via `psutil.cpu_times(percpu=True)` when `--per-cpu` is given
* Non-blocking measurement using SQLite state persistence between runs: stores a raw CPU time snapshot and computes the delta against the previous run
* On the first run, falls back to a short 0.25s blocking sample to produce sane output
* Guest time is counted once, not twice. The Linux kernel books it into `user` (and niced guest time into `nice`) on top of reporting it separately, so a hypervisor's percentages come out wrong wherever the two are simply added up
* Platform-specific extended metrics where available: context switches, interrupts, soft interrupts (requires psutil >= 4.1.0)
* Detects and skips all-zero CPU samples (can occur on Windows systems with many cores) to avoid false 100% usage reports


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/cpu-usage> |
| Nagios/Icinga Check Name              | `check_cpu_usage` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | Yes |
| 3rd Party Python modules              | `psutil` |
| Handles Periods                       | Yes (alerts only after `--count` consecutive threshold violations) |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-cpu-usage.db` |


## Help

```text
usage: cpu-usage [-h] [-V] [--always-ok] [--count COUNT] [-c CRIT]
                 [--critical-steal CRIT_STEAL] [--no-perfdata] [--per-cpu]
                 [-w WARN] [--warning-steal WARN_STEAL]

Reports CPU utilization percentages for all available time categories (user,
system, idle, nice, iowait, irq, softirq, steal, guest, guest_nice) plus the
overall cpu-usage, which is the total busy share of all CPUs (100 - idle) and
therefore includes nice. Thresholds (WARN/CRIT) are checked against user,
system, and the busy share without nice. Work that runs at a lowered priority
yields to everything else, so a host busy with nothing but niced batch work
stays OK while its cpu-usage graph shows the machine at full load. An alert is
raised only if the threshold is exceeded for COUNT consecutive runs,
suppressing short spikes and focusing on sustained load. iowait is reported
and graphed but never triggers an alert, because Linux iowait is relabelled
idle time and unreliable on multi-core systems. Steal time carries its own
threshold, because a virtual machine can sit at a harmless overall utilization
while an oversubscribed hypervisor takes a quarter of its CPU time away.
--per-cpu adds one utilization metric per core and names the busiest one,
which is what a single-threaded bottleneck looks like on a machine that
otherwise appears mostly idle. Perfdata is emitted for every field to enable
full graphing. Extended stats (context switches, interrupts, etc.) are
included if supported on this platform. This check is cross-platform and works
on Linux, Windows, and all psutil-supported systems. The check stores its
short trend state locally in an SQLite DB to evaluate sustained load across
runs.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --count COUNT         Number of consecutive checks the threshold must be
                        exceeded before alerting. Default: 5
  -c, --critical CRIT   CRIT threshold in percent. Default: >= 90
  --critical-steal CRIT_STEAL
                        CRIT threshold for the share of CPU time an
                        oversubscribed hypervisor takes away from this
                        machine, in percent. Supports Nagios ranges. Alerts
                        only after `--count` consecutive runs above the
                        threshold. Always 0 on a physical machine and on
                        platforms that do not account for it. Default: None
  --no-perfdata         Suppress the performance data section from the output.
                        The status message and the exit code are unaffected,
                        so alerting keeps working while trending data is
                        dropped.
  --per-cpu             Report the utilization of every single core as its own
                        metric, and name the busiest one in the output. Finds
                        the single saturated core that the overall utilization
                        hides on a machine with many cores. Adds one metric
                        per core and does not alert on its own.
  -w, --warning WARN    WARN threshold in percent. Default: >= 80
  --warning-steal WARN_STEAL
                        WARN threshold for the share of CPU time an
                        oversubscribed hypervisor takes away from this
                        machine, in percent. Supports Nagios ranges. Alerts
                        only after `--count` consecutive runs above the
                        threshold. Always 0 on a physical machine and on
                        platforms that do not account for it. Default: 10

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/cpu-usage/
```


## Usage Examples

```bash
./cpu-usage --count=15 --warning=50 --critical=70
```

Output:

```text
2.6% over 60s - user: 1.6%, system: 0.7%, irq: 0.2%, softirq: 0.1%
guest: 0.0%, iowait: 0.0%, guest_nice: 0.0%, steal: 0.0%, nice: 0.0%
ctx_switches: 26.8K/s, interrupts: 9.8K/s, soft_interrupts: 2.6K/s
```

With `--per-cpu`, on a machine where one core carries a single-threaded job:

```bash
./cpu-usage --per-cpu
```

Output:

```text
19.8% over 60s, hottest core cpu2 at 65.5% - user: 15.8%, system: 3.3%, irq: 0.4%
guest: 0.0%, guest_nice: 0.0%, iowait: 0.0%, nice: 0.0%, softirq: 0.0%, steal: 0.0%
ctx_switches: 8.1K/s, interrupts: 6.6K/s, soft_interrupts: 2.6K/s
```

On a virtual machine whose hypervisor is oversubscribed:

```bash
./cpu-usage
```

Output:

```text
74.1% over 60s - steal: 73.7% [WARNING], user: 0.3%, system: 0.1%
guest: 0.0%, guest_nice: 0.0%, iowait: 0.0%, irq: 0.0%, nice: 0.0%, softirq: 0.0%
ctx_switches: 5.3K/s, interrupts: 8.2K/s, soft_interrupts: 3.8K/s
```


## States

* OK if `user`, `system`, and the busy share without `nice` are all below the thresholds within the last `--count` checks (default: 5). `iowait` is reported and graphed but is not part of the thresholds.
* OK with "Waiting for more data (got an all-zero CPU sample, skipping)." if an all-zero sample is detected.
* WARN if any of the checked fields exceeds `--warning` (default: 80) for `--count` consecutive runs.
* CRIT if any of the checked fields exceeds `--critical` (default: 90) for `--count` consecutive runs.
* WARN if `steal` is outside `--warning-steal` (default: 10) for `--count` consecutive runs, CRIT if it is outside `--critical-steal` (default: unset) for that long. Both are evaluated independently of the overall thresholds, so a machine that is barely busy still alerts when its CPU time is taken away. Pass an empty value (`--warning-steal=""`) to switch the alert off.
* `--per-cpu` never changes the state. The per-core metrics are reported and graphed, because a single core at 100% is the normal picture for a single-threaded job and not by itself a fault.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| cpu-usage | Percentage | The overall CPU usage, the total busy share of all CPUs (100 - `idle`). Includes `nice`, unlike the value the thresholds are checked against. |
| `cpu<N>`\_usage | Percentage | The busy share of a single core (100 - its own `idle`), one metric per core, numbered as the operating system numbers its CPUs. Only with `--per-cpu`. |
| ctx_switches_per_second | Number | Context switches (voluntary + involuntary) per second, calculated in the plugin from two consecutive runs. |
| guest | Percentage | Time spent running a virtual CPU (Linux 2.6.24+). |
| guest_nice | Percentage | Time spent running a niced guest (Linux 3.2.0+). |
| interrupts_per_second | Number | Interrupts per second, calculated in the plugin from two consecutive runs. |
| iowait | Percentage | Time spent waiting for I/O to complete. |
| irq | Percentage | Time spent servicing hardware interrupts. |
| nice | Percentage | Time spent by niced (prioritized) processes executing in user mode. |
| soft_interrupts_per_second | Number | Software interrupts per second, calculated in the plugin from two consecutive runs. |
| steal | Percentage | Time a virtual CPU waits for a real CPU while the hypervisor is servicing another virtual processor (Linux 2.6.11+). Carries its own thresholds, `--warning-steal` and `--critical-steal`. |
| system | Percentage | Time spent in kernel space. |
| user | Percentage | Time spent in user space. |


## Troubleshooting

### `Python module "psutil" is not installed.`

Install `psutil`: `pip install psutil` or `dnf install python3-psutil`.

### Sustained steal time

The check reports `steal: NN% [WARNING]` and the machine is a guest on a hypervisor that has more virtual CPUs handed out than it has physical ones. Nothing inside the guest causes this and nothing inside the guest fixes it: the time is spent waiting for a physical CPU that another guest is using.

1. Confirm it is sustained rather than a burst. The alert only fires after `--count` consecutive runs, so the graph should show a plateau, not a spike.
2. Compare it against the other guests on the same host. If several of them alert at once, the host is oversubscribed; if only one does, it is more likely to be pinned to a busy set of cores.
3. Take it to whoever runs the platform, with the graph. On a cloud instance, a smaller steal figure is usually what the next instance size buys.
4. Where the platform is knowingly oversubscribed and the guest is meant to live with it, raise `--warning-steal` to the level the platform is expected to deliver, or pass an empty value to switch the alert off. Do not raise the overall `--warning`; steal is a separate signal for a reason.

### A host graphs at full load but never alerts

Expected where the load is niced. `cpu-usage` is the plain total including `nice`, the thresholds leave `nice` out, and a process that was asked to stand back is not a reason to wake anybody. Check whether the `nice` metric carries the load; if it does, there is nothing to fix.

### `--per-cpu` reports no per-core metrics

The check needs a per-core snapshot from the immediately preceding run to measure against, and it has none: this is the first run with `--per-cpu`, the host rebooted, the machine gained a core, or the check ran without `--per-cpu` in between. Wait for the next check interval. If it keeps happening, `--per-cpu` is not set on every run of this service.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
* Credits: [psutil Documentation](https://psutil.readthedocs.io/en/latest/)
