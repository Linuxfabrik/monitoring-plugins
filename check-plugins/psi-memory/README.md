# Check psi-memory


## Overview

Reports how much of its time a host loses waiting for memory, taken from the pressure stall information of the Linux kernel. A pressure of 10 percent means that for a tenth of the time work could not go on because memory was contended. The check alerts on the share of time in which every task that had work to do was stalled at once, averaged over the last minute. That is the state in which the machine spends its cycles waiting instead of working, and it answers what neither memory usage nor swap usage can: whether the shortage costs anything. The ten second average is reported but not judged, until `--warning-avg10` or `--critical-avg10` give it a threshold; those catch a burst that the one minute average smooths away. A host whose kernel keeps no pressure statistics is reported as OK, because there is nothing to measure; raise `--severity-no-psi` to flag it where the statistics are expected. Alerts when the pressure leaves the warning or critical range.

**What the numbers mean:**

The kernel writes two lines per resource, and both are a share of wall clock time, not of memory:

* `some` is the time in which **at least one** task waited for memory. On a working host this is never zero. Something waits for a page now and then, and the machine gets on with other work in the meantime.
* `full` is the time in which **every task that had work to do** waited at once. Nothing was accomplished during that time although the CPUs were awake. The kernel documentation calls this thrashing, and it is what this check judges.

Both lines come as averages over the last 10, 60 and 300 seconds. The check alerts on the 60 second average because that is the window a check running every minute can actually see: 10 seconds is gone again before the next run, 300 seconds smears a burst until it no longer stands out. All three go into the performance data, so the graph keeps the short spike as well as the long trend.

**Important Notes:**

* **The averages need time to rise.** Measured on this reference host: fourteen seconds into a heavy load the 10 second average had reached 40 % while the 60 second average was still at 10 %. The check therefore reports sustained pressure, not the burst that lasted a moment. The `avg10` performance data shows the bursts.
* **On a quiet host `some` and `full` are the same number.** If only one task has work to do, then that one task stalling is by definition every non-idle task stalling. The two values separate as soon as several things run at once, which is exactly when `full` starts to mean something.
* **The values are system-wide.** A single container thrashing against its own memory limit barely moves them, because the kernel averages over the whole machine. Where the pressure is high and the cause is unclear, the same statistics exist per cgroup and name the guilty service, see [Troubleshooting](#the-pressure-is-high-and-nothing-obvious-is-running).
* **Red Hat ships the interface switched off.** Rocky, RHEL and their rebuilds compile pressure accounting in (`CONFIG_PSI=y`) but disable it by default (`CONFIG_PSI_DEFAULT_DISABLED=y`), verified against the shipped kernel configuration of Rocky 8, 9 and 10. The kernel then creates no `/proc/pressure` at all and the check reports that nothing can be measured. Debian 11, 12 and 13, Ubuntu 22.04, 24.04 and 26.04 and Fedora have it switched on out of the box. See [Troubleshooting](#this-kernel-keeps-no-pressure-statistics) for how to switch it on.
* Related checks: `memory-usage` reports how much memory is in use, `swap-usage` how full swap is, `memory-paging` how much traffic goes to and from swap. This check is the one that says whether any of it is hurting.

**Data Collection:**

* Reads `/proc/pressure/memory`
* Reads the values by name and not by position, so a kernel that adds a field cannot shift a value under the wrong name
* Needs no root and no `sudo`


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/psi-memory> |
| Nagios/Icinga Check Name              | `check_psi_memory` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Runs on                               | Linux |
| Compiled for Windows                  | No |


## Help

```text
usage: psi-memory [-h] [-V] [--always-ok] [-c CRIT]
                  [--critical-avg10 CRIT_AVG10] [--no-perfdata]
                  [--severity-no-psi {ok,warn,crit,unknown}] [-w WARN]
                  [--warning-avg10 WARN_AVG10]

Reports how much of its time a host loses waiting for memory, taken from the
pressure stall information of the Linux kernel. A pressure of 10 percent means
that for a tenth of the time work could not go on because memory was
contended. The check alerts on the share of time in which every task that had
work to do was stalled at once, averaged over the last minute. That is the
state in which the machine spends its cycles waiting instead of working, and
it answers what neither memory usage nor swap usage can: whether the shortage
costs anything. The ten second average is reported but not judged, until
--warning-avg10 or --critical-avg10 give it a threshold; those catch a burst
that the one minute average smooths away. A host whose kernel keeps no
pressure statistics is reported as OK, because there is nothing to measure;
raise --severity-no-psi to flag it where the statistics are expected. Alerts
when the pressure leaves the warning or critical range.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  -c, --critical CRIT   CRIT threshold for the memory pressure, in percent of
                        wall clock time, measured over the last minute.
                        Supports Nagios ranges. Example: `10` alerts where 10
                        percent of the time is lost. Default: 10
  --critical-avg10 CRIT_AVG10
                        CRIT threshold for the memory pressure, in percent of
                        wall clock time, measured over the last ten seconds.
                        Catches a burst that the one minute average smooths
                        away, at the price of alerting on a stall that is over
                        before anybody looks. Supports Nagios ranges. Example:
                        `90` alerts where work waited for memory for nine of
                        the last ten seconds. Default: no critical threshold
  --no-perfdata         Suppress the performance data section from the output.
                        The status message and the exit code are unaffected,
                        so alerting keeps working while trending data is
                        dropped.
  --severity-no-psi {ok,warn,crit,unknown}
                        Severity for alerting if the kernel keeps no pressure
                        statistics. Default: ok
  -w, --warning WARN    WARN threshold for the memory pressure, in percent of
                        wall clock time, measured over the last minute.
                        Supports Nagios ranges. Example: `5` alerts where 5
                        percent of the time is lost. Default: 5
  --warning-avg10 WARN_AVG10
                        WARN threshold for the memory pressure, in percent of
                        wall clock time, measured over the last ten seconds.
                        Catches a burst that the one minute average smooths
                        away, at the price of alerting on a stall that is over
                        before anybody looks. Supports Nagios ranges. Example:
                        `80` alerts where work waited for memory for eight of
                        the last ten seconds. Default: no warning threshold

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/psi-memory/
```


## Usage Examples

```bash
./psi-memory
```

Output on a host with memory to spare:

```text
memory pressure, last minute: some 0.0%, full 0.0%
some = at least one task waited for memory, full = every task with work to do waited for memory

Window ! Some  ! Full 
-------+-------+------
avg10  ! 0.0%  ! 0.0% 
avg60  ! 0.0%  ! 0.0% 
avg300 ! 0.57% ! 0.57%
```

Output on a host whose working set no longer fits, measured while a workload walked a 900 MiB buffer against a 150 MiB limit:

```text
memory pressure, last minute: some 20.23%, full 20.23% [CRITICAL]
some = at least one task waited for memory, full = every task with work to do waited for memory
Work is stalling on memory. Add memory, move a workload off the host, or cap the process that grew. `memory-usage` reports how much memory is in use, `memory-paging` whether the host is already paying for the shortage with paging traffic.

Window ! Some   ! Full             
-------+--------+------------------
avg10  ! 27.42% ! 27.42%           
avg60  ! 20.23% ! 20.23% [CRITICAL]
avg300 ! 6.34%  ! 6.34%
```

A host that is expected to run at its memory limit, a batch node or a build machine, wants the pressure graphed and nobody woken. `~:` is the Nagios range for "any value is fine":

```bash
./psi-memory --warning=~: --critical=~:
```

A host where a short stall already hurts wants the 10 second average judged as well. It alerts on its own, while the minute average stays inside its range:

```bash
./psi-memory --warning-avg10=5
```

```text
memory pressure, last minute: some 1.65%, full 1.65%; last ten seconds: full 6.23% [WARNING]
some = at least one task waited for memory, full = every task with work to do waited for memory
Work is stalling on memory. Add memory, move a workload off the host, or cap the process that grew. `memory-usage` reports how much memory is in use, `memory-paging` whether the host is already paying for the shortage with paging traffic.

Window ! Some  ! Full           
-------+-------+----------------
avg10  ! 6.23% ! 6.23% [WARNING]
avg60  ! 1.65% ! 1.65%          
avg300 ! 0.37% ! 0.37%
```

Where pressure statistics are expected on every host, an unswitched interface is worth reporting instead of passing as OK:

```bash
./psi-memory --severity-no-psi=warn
```


## States

* OK if the `full` pressure over the last minute is within `--warning` and `--critical`.
* OK with an explanation if the kernel keeps no pressure statistics, which is the Red Hat default. `--severity-no-psi` raises that to `warn`, `crit` or `unknown`.
* WARN if the `full` pressure over the last minute leaves the `--warning` range, 5 % by default.
* CRIT if it leaves the `--critical` range, 10 % by default.
* WARN or CRIT if the `full` pressure over the last ten seconds leaves `--warning-avg10` or `--critical-avg10`. Neither is set by default, so that value does not alert until one of them is given. The worst of the two windows wins.
* UNKNOWN if a value in `/proc/pressure/memory` is not a number, or if the file exists but cannot be read.
* UNKNOWN if the check does not run on Linux.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

Every value is a share of wall clock time in percent, as the kernel reports it. The thresholds sit on `full_avg60`, the value the check judges, and on `full_avg10` once `--warning-avg10` or `--critical-avg10` is given.

| Name | Type | Description |
|----|----|----|
| full_avg10  | Percentage | Time in which every task with work to do waited for memory, over the last 10 seconds. |
| full_avg60  | Percentage | The same over the last 60 seconds. This is the value the check alerts on. |
| full_avg300 | Percentage | The same over the last 300 seconds. |
| some_avg10  | Percentage | Time in which at least one task waited for memory, over the last 10 seconds. |
| some_avg60  | Percentage | The same over the last 60 seconds. |
| some_avg300 | Percentage | The same over the last 300 seconds. |


## Troubleshooting

### The host is stalling on memory

The machine is spending a measurable share of its time waiting for memory instead of working. Find out first whether it is already paying with paging traffic, and how much memory is actually in use:

```bash
./memory-paging --lengthy
free --human
```

Then find the process that grew. Every process reports its own memory in its status file, and the biggest consumer is usually obvious:

```bash
ps --eo pid,rss,comm --sort=-rss | head
```

From there the answer is one of three: add memory, move a workload off the host, or cap the process with `MemoryHigh` on its systemd unit. Note that a `MemoryHigh` cap does not remove the pressure, it moves it into that unit's cgroup, which is usually what you want: the rest of the machine keeps working.

### The pressure is high and nothing obvious is running

The values this check reads are system-wide, so a service that thrashes inside its own cgroup shows up as a modest number for the whole machine. The kernel keeps the same statistics per cgroup, which names the culprit directly:

```bash
for f in /sys/fs/cgroup/*.slice/memory.pressure; do printf '%s %s\n' "$(awk '/^full/{split($3,a,"="); print a[2]}' "$f")" "$f"; done | sort --numeric-sort --reverse | head
```

That prints the 60 second `full` average per slice, highest first. Repeat one level deeper inside the slice that stands out (`/sys/fs/cgroup/system.slice/*/memory.pressure`) and the answer is a unit name.

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
cat /proc/pressure/memory
```

If the directory is still missing after the reboot, the kernel was built without `CONFIG_PSI` altogether. Read what the running kernel was built with:

```bash
grep CONFIG_PSI /boot/config-$(uname --kernel-release)
```

### `some` and `full` show the same number

Expected on a host with one busy workload. `full` counts the time in which every task that had work to do waited, so when only one task has work, its stall is by definition a full stall. The two numbers separate as soon as several things run at once, and the gap between them is then worth reading: a large `some` next to a small `full` means the machine is still getting work done.

### The pressure looks harmless although users complain

The check alerts on the 60 second average, which needs about a minute of sustained pressure to reach the real level. A burst that lasts ten seconds barely moves it, which is deliberate: a stall that is over before anybody looks is rarely worth an alert. The `some_avg10` and `full_avg10` metrics keep those bursts, so the graph shows what the alert does not.

Where the bursts do matter, give the 10 second average its own threshold with `--warning-avg10` and `--critical-avg10`. Pick it well above the 60 second threshold, because the short window swings much further on the same workload. Expect more alerts that have resolved themselves by the time somebody reads them.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
