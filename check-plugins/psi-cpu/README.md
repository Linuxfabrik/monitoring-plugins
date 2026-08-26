# Check psi-cpu


## Overview

Reports how much of its time a host loses waiting for a CPU, taken from the pressure stall information of the Linux kernel. A pressure of 10 percent means that for a tenth of the time work could not go on because the CPUs were contended. The check alerts on the share of time in which at least one task was ready to run and had to wait for a CPU, averaged over the last minute. It answers what CPU utilization cannot: a host can be busy to the last percent and serve everything on time, and it can be busy to the same percent while everything queues up behind it. The ten second average is reported but not judged, until `--warning-avg10` or `--critical-avg10` give it a threshold; those catch a burst that the one minute average smooths away. A host whose kernel keeps no pressure statistics is reported as OK, because there is nothing to measure; raise `--severity-no-psi` to flag it where the statistics are expected. Alerts when the pressure leaves the warning or critical range.

**What the numbers mean:**

The kernel writes a share of wall clock time, not a share of the CPUs. `some` is the time in which at least one task was runnable but got no CPU. On an idle host it is zero, on a host with more runnable work than cores it approaches the share of time somebody is queuing.

The kernel also prints a `full` line for the CPU, and it is a hardcoded zero. `psi_show()` in `kernel/sched/psi.c` skips the accounting for it at the system level, and the kernel documentation calls it "undefined at the system level, but reported since 5.13 for backward compatibility". This check therefore does not report it. A tool that graphs `cpu full` graphs a line that can never move.

The value comes as an average over the last 10, 60 and 300 seconds. The check alerts on the 60 second average because that is the window a check running every minute can actually see: 10 seconds is gone again before the next run, 300 seconds smears a burst until it no longer stands out. All three go into the performance data, so the graph keeps the short spike as well as the long trend.

**Important Notes:**

* **This is not CPU utilization.** A single process pinning one core to 100 % produces no pressure at all, because nothing is waiting. Pressure appears when there is more runnable work than there are CPUs. Measured on this reference host, an eight core machine: sixteen busy loops produced around 50 %, thirty-two busy loops around 60 % over ten seconds. `cpu-usage` reports how busy the CPUs are, this check what the queueing costs.
* **It is also not the load average.** Load counts tasks that are runnable or in uninterruptible sleep, whatever the machine size, so a load of 8 is harmless on one host and desperate on another. Pressure is already normalised: it is time lost, on any machine.
* **The averages need time to rise.** Measured here: fourteen seconds into a heavy load the 10 second average had reached 40 % while the 60 second average was still at 10 %. The check therefore reports sustained pressure, not the burst that lasted a moment. The `some_avg10` performance data shows the bursts.
* **The values are system-wide.** Where the pressure is high and the cause is unclear, the same statistics exist per cgroup and name the guilty service, see [Troubleshooting](#the-pressure-is-high-and-nothing-obvious-is-running).
* **Red Hat ships the interface switched off.** Rocky, RHEL and their rebuilds compile pressure accounting in (`CONFIG_PSI=y`) but disable it by default (`CONFIG_PSI_DEFAULT_DISABLED=y`), verified against the shipped kernel configuration of Rocky 8, 9 and 10. The kernel then creates no `/proc/pressure` at all and the check reports that nothing can be measured. Debian 11, 12 and 13, Ubuntu 22.04, 24.04 and 26.04 and Fedora have it switched on out of the box. See [Troubleshooting](#this-kernel-keeps-no-pressure-statistics) for how to switch it on.
* Related checks: `cpu-usage` reports how busy the CPUs are, `load` how long the run queue is, `procs` which processes it consists of. This check is the one that says whether the queueing costs anything.

**Data Collection:**

* Reads `/proc/pressure/cpu`
* Reads the values by name and not by position, so a kernel that adds a field cannot shift a value under the wrong name
* Needs no root and no `sudo`


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/psi-cpu> |
| Nagios/Icinga Check Name              | `check_psi_cpu` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Runs on                               | Linux |
| Compiled for Windows                  | No |


## Help

```text
usage: psi-cpu [-h] [-V] [--always-ok] [-c CRIT] [--critical-avg10 CRIT_AVG10]
               [--no-perfdata] [--severity-no-psi {ok,warn,crit,unknown}]
               [-w WARN] [--warning-avg10 WARN_AVG10]

Reports how much of its time a host loses waiting for a CPU, taken from the
pressure stall information of the Linux kernel. A pressure of 10 percent means
that for a tenth of the time work could not go on because the CPUs were
contended. The check alerts on the share of time in which at least one task
was ready to run and had to wait for a CPU, averaged over the last minute. It
answers what CPU utilization cannot: a host can be busy to the last percent
and serve everything on time, and it can be busy to the same percent while
everything queues up behind it. The ten second average is reported but not
judged, until --warning-avg10 or --critical-avg10 give it a threshold; those
catch a burst that the one minute average smooths away. A host whose kernel
keeps no pressure statistics is reported as OK, because there is nothing to
measure; raise --severity-no-psi to flag it where the statistics are expected.
Alerts when the pressure leaves the warning or critical range.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  -c, --critical CRIT   CRIT threshold for the CPU pressure, in percent of
                        wall clock time, measured over the last minute.
                        Supports Nagios ranges. Example: `80` alerts where
                        work waits for a CPU 80 percent of the time. Default:
                        80
  --critical-avg10 CRIT_AVG10
                        CRIT threshold for the CPU pressure, in percent of
                        wall clock time, measured over the last ten seconds.
                        Catches a burst that the one minute average smooths
                        away, at the price of alerting on a stall that is over
                        before anybody looks. Supports Nagios ranges. Example:
                        `90` alerts where work waited for a CPU for nine of
                        the last ten seconds. Default: no critical threshold
  --no-perfdata         Suppress the performance data section from the output.
                        The status message and the exit code are unaffected,
                        so alerting keeps working while trending data is
                        dropped.
  --severity-no-psi {ok,warn,crit,unknown}
                        Severity for alerting if the kernel keeps no pressure
                        statistics. Default: ok
  -w, --warning WARN    WARN threshold for the CPU pressure, in percent of
                        wall clock time, measured over the last minute.
                        Supports Nagios ranges. Example: `50` alerts where
                        work waits for a CPU 50 percent of the time. Default:
                        50
  --warning-avg10 WARN_AVG10
                        WARN threshold for the CPU pressure, in percent of
                        wall clock time, measured over the last ten seconds.
                        Catches a burst that the one minute average smooths
                        away, at the price of alerting on a stall that is over
                        before anybody looks. Supports Nagios ranges. Example:
                        `80` alerts where work waited for a CPU for eight of
                        the last ten seconds. Default: no warning threshold

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/psi-cpu/
```


## Usage Examples

```bash
./psi-cpu
```

Output on a host that keeps up with its work:

```text
cpu pressure, last minute: some 0.95%
some = at least one task waited for a CPU

Window ! Some 
-------+------
avg10  ! 0.0% 
avg60  ! 0.95%
avg300 ! 2.79%
```

Output on an eight core host running thirty-two busy loops, with the warning threshold lowered to 40:

```text
cpu pressure, last minute: some 47.23% [WARNING]
some = at least one task waited for a CPU
Work is waiting for a CPU. Give the host more of them, move a workload off it, or find what is running: `cpu-usage` reports how busy the CPUs are, `load` how long the run queue is and `procs` which processes it consists of.

Window ! Some            
-------+-----------------
avg10  ! 58.28%          
avg60  ! 47.23% [WARNING]
avg300 ! 17.28%
```

A machine that is supposed to run its CPUs full, a build host or a batch node, wants the pressure graphed and nobody woken. `~:` is the Nagios range for "any value is fine":

```bash
./psi-cpu --warning=~: --critical=~:
```

A latency-sensitive host, a database or a broker, is worth watching far earlier:

```bash
./psi-cpu --warning=10 --critical=25
```

A host where a short queue already hurts wants the 10 second average judged as well. It alerts on its own, while the minute average stays inside its range:

```bash
./psi-cpu --warning-avg10=40
```

```text
cpu pressure, last minute: some 11.74%; last ten seconds: some 47.86% [WARNING]
some = at least one task waited for a CPU
Work is waiting for a CPU. Give the host more of them, move a workload off it, or find what is running: `cpu-usage` reports how busy the CPUs are, `load` how long the run queue is and `procs` which processes it consists of.

Window ! Some            
-------+-----------------
avg10  ! 47.86% [WARNING]
avg60  ! 11.74%          
avg300 ! 8.37%
```


## States

* OK if the `some` pressure over the last minute is within `--warning` and `--critical`.
* OK with an explanation if the kernel keeps no pressure statistics, which is the Red Hat default. `--severity-no-psi` raises that to `warn`, `crit` or `unknown`.
* WARN if the `some` pressure over the last minute leaves the `--warning` range, 50 % by default.
* CRIT if it leaves the `--critical` range, 80 % by default.
* WARN or CRIT if the `some` pressure over the last ten seconds leaves `--warning-avg10` or `--critical-avg10`. Neither is set by default, so that value does not alert until one of them is given. The worst of the two windows wins.
* UNKNOWN if a value in `/proc/pressure/cpu` is not a number, or if the file exists but cannot be read.
* UNKNOWN if the check does not run on Linux.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

Every value is a share of wall clock time in percent, as the kernel reports it. The thresholds sit on `some_avg60`, the value the check judges, and on `some_avg10` once `--warning-avg10` or `--critical-avg10` is given. The kernel's `full` line for the CPU is undefined at the system level and is not reported.

| Name | Type | Description |
|----|----|----|
| some_avg10  | Percentage | Time in which at least one task was ready to run and waited for a CPU, over the last 10 seconds. |
| some_avg60  | Percentage | The same over the last 60 seconds. This is the value the check alerts on. |
| some_avg300 | Percentage | The same over the last 300 seconds. |


## Troubleshooting

### Work is waiting for a CPU

There is more runnable work than the host has cores. See how busy the CPUs are and how long the queue is:

```bash
./cpu-usage
./load
```

Then find what is running. The processes at the top of this list are the ones competing:

```bash
ps --eo pid,pcpu,comm --sort=-pcpu | head
```

From there: give the host more cores, move a workload off it, or lower the priority of what may wait, for example with `CPUWeight` on its systemd unit. Where the machine is a virtual one, check the hypervisor as well: a guest that is not scheduled by its host also queues, and `kvm-cpu-usage` reports how much CPU a libvirt host makes its guests wait for.

### The pressure is high and nothing obvious is running

The values this check reads are system-wide. The kernel keeps the same statistics per cgroup, which names the responsible service directly:

```bash
for f in /sys/fs/cgroup/*.slice/cpu.pressure; do printf '%s %s\n' "$(awk '/^some/{split($3,a,"="); print a[2]}' "$f")" "$f"; done | sort --numeric-sort --reverse | head
```

That prints the 60 second `some` average per slice, highest first. Repeat one level deeper inside the slice that stands out (`/sys/fs/cgroup/system.slice/*/cpu.pressure`) and the answer is a unit name.

### The CPUs are at 100 % and the pressure is zero

Correct and not a defect. Pressure counts waiting, not working. One process per core keeps every CPU busy without anybody queuing, which is a machine used to capacity rather than a machine in trouble. The pressure rises when the work no longer fits, not when it fills the host.

### `This kernel keeps no pressure statistics`

The kernel was built with `CONFIG_PSI_DEFAULT_DISABLED=y` and booted without `psi=1`, so it created no `/proc/pressure` at all. That is the default of Rocky, RHEL and their rebuilds, verified on the shipped kernel configuration of version 8, 9 and 10. Switching it on costs a reboot.

On the Red Hat family:

```bash
grubby --update-kernel=ALL --args="psi=1"
reboot
```

On Debian and Ubuntu, where this is normally not needed because the interface is on by default, add `psi=1` to `GRUB_CMDLINE_LINUX_DEFAULT` in `/etc/default/grub` and run `update-grub` before rebooting.

Afterwards the interface is there:

```bash
cat /proc/pressure/cpu
```

If the directory is still missing after the reboot, the kernel was built without `CONFIG_PSI` altogether. Read what the running kernel was built with:

```bash
grep CONFIG_PSI /boot/config-$(uname --kernel-release)
```

### The pressure looks harmless although users complain

The check alerts on the 60 second average, which needs about a minute of sustained pressure to reach the real level. A burst that lasts ten seconds barely moves it, which is deliberate: a stall that is over before anybody looks is rarely worth an alert. The `some_avg10` metric keep those bursts, so the graph shows what the alert does not.

Where the bursts do matter, give the 10 second average its own threshold with `--warning-avg10` and `--critical-avg10`. Pick it well above the 60 second threshold, because the short window swings much further on the same workload. Expect more alerts that have resolved themselves by the time somebody reads them.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
