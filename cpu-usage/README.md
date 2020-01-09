# Overview

Returns floats representing the current system-wide CPU utilization as a percentage. Warns only if `user`, `system`, `iowait` or overall `cpu-usage` is above a certain threshold within the last n checks.

The checked attributes:

* `cpu-usage`: The overall cpu usage. This is (100 - `idle`).
* `ctx_switches`: Number of context switches (voluntary + involuntary) since boot. A context switch is a procedure that a computer’s CPU (central processing unit) follows to change from one task (or process) to another while ensuring that the tasks do not conflict.
* `idle`: Percent of CPU used by any program. Every program or task that runs on a computer system occupies a certain amount of processing time on the CPU. If the CPU has completed all tasks it is idle.
* `interrupts`: Number of interrupts since boot.
* `iowait`: Time spent waiting for I/O to complete. This is not accounted in idle time counter.
* `irq`: Time spent for servicing hardware interrupts.
* `nice`: Time spent by niced (prioritized) processes executing in user mode; this also includes guest_nice time.
* `soft_interrupts`: Number of software interrupts since boot.
* `steal`: Percentage of time a virtual CPU waits for a real CPU while the hypervisor is servicing another virtual processor.
* `system`: Percent time spent in kernel space. System CPU time is the time spent running code in the Operating System kernel.
* `user`: Percent time spent in user space. User CPU time is the time spent on the processor running your program’s code (or code in libraries).

About this check:

* Tested on OS: CentOS 7 Minimal, Fedora 30, Fedora 31
* Tested with Monitoring Tool: Icinga2

Features:
* Auto Discovery: yes
* Default Thresholds: yes
* Takes time periods into account: yes
* Uses temporary files: yes

Hints and Recommendations:
* We check global CPU stats, not per-CPU.
* We recommend running this check every minute.
* `--count=15` (the default) while checking every minute means that the check reports a warning if `user`, `system`, `iowait` or overall `cpu-usage` was above a threshold in the last 15 minutes.
* Check needs at least 250ms to run.


# Installation and Usage

```bash
./cpu-usage
./cpu-usage --count=15 --warning=50 --critical=70
./cpu-usage --help
```


# States

OK, if `user`, `system`, `iowait` and overall `cpu-usage` are all below the thresholds within the last `--count` checks.

Otherwise CRIT or WARN.


# Known Issues and Limitations

-


# Contents

* README.md: This file.
* LICENSE: The license file.

* cpu-usage: The service check in source code format.
* cpu-usage.basket.json: The Icinga Director Basket Configuration file for this service.
* cpu-usage.grafana.json: The panel file in JSON format for any Grafana dashboard.
* cpu-usage.icingaweb2-grafana.ini: The .ini file for the Icingaweb2 Grafana Module.
* cpu-usage.png: The 16x16 black icon for the service check.
* cpu-usage.sudoers: The sudoers file for the service check.


# Changelog

* 2019121901: Initial release.


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.
* Inspired by:
  * Glances (https://glances.readthedocs.io/en/stable/glances.html)
