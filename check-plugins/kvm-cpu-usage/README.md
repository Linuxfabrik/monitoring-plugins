# Check kvm-cpu-usage

## Overview

Reports how much CPU each virtual machine of a libvirt host consumes, and how much CPU its guests ask for but do not get because the host is busy elsewhere. Alerts if a machine uses more of its assigned virtual CPUs than the thresholds allow, and if the host makes a machine wait for CPU for too large a share of its time. Also reports how many virtual CPUs the running machines were promised against the cores the host really has. Runs without root or sudo.

**What the Steal column means:**

A virtual CPU is not a CPU of its own, it is a claim on one of the host's real CPUs, and steal is the share of time a machine stood ready to work but had to wait because the host was giving that CPU to somebody else. Inside the machine nothing looks broken: its own CPU graph is calm, no process accounts for the delay, and everything is simply slow.

This is the number the guest operating system calls "steal time" and shows as `%st` in `top`, so it matches what an administrator sees when logging into the machine to find out why it feels sluggish. A machine at 20% steal is being kept from a fifth of the work it wanted to do, and no change inside that machine will fix it. The cause is always on the host: too many virtual CPUs handed out for the cores available, or something else on the host eating them.

**Important Notes:**

* **Read the CPU and the Steal column together.** A machine starved of host CPU shows a *lower* CPU usage than a healthy one, because it is not being allowed to run. On a host with a free CPU, a guest saturating its single virtual CPU was measured at 98.4% CPU and 0.2% steal; with three other processes competing for the same host core, the same guest dropped to 24.8% CPU and rose to 74.8% steal. On the CPU column alone, the starved machine looks like the quieter one.
* **The commitment figure is context, not an alert.** Handing out more virtual CPUs than the host has cores is normal and works as long as the machines stay idle. It is the number to look at once the steal column starts moving, which is why it sits on the same line: a host at 300% commitment and 0% steal is fine, and the same host at 300% and 30% steal has run out of room.
* On the first runs, and after a machine was started, the check reports "Waiting for more data." for that machine until `--count` measurements have accumulated. The machines that have been running all along keep being reported meanwhile.
* **A machine that was restarted also goes back to "Waiting for more data."** Its counters start over, so they are lower than the ones recorded before the restart, and no rate can be computed across that. Reporting the difference anyway would put the machine at a negative usage and alert on it. It comes back on its own once the measurements from before the restart have left the `--count` window.
* Only running machines are looked at. A machine that is shut off still reports a CPU time, but libvirt reports the same value for every shut-off machine and it keeps growing between runs, so a rate computed from it would be invented.
* The check connects to libvirt read-only, which needs neither root nor sudo nor membership in the `libvirt` group. Only QEMU/KVM connections report the data it needs; Xen and libvirt-LXC connections are refused with an explanation.
* **`--brief` shortens the table on a busy host.** A host with hundreds of machines produces hundreds of rows, and `--brief` keeps only the machines in a WARN or CRIT state. Performance data and alerting are unaffected: every item still emits its metrics and still drives the overall state, so it is safe to leave on. It combines with `--lengthy`, which decides the columns rather than the rows. When nothing is in a WARN or CRIT state, the check prints its summary line and no table at all.

**Data Collection:**

* Collects the CPU counters of every running machine in a single call, and asks the same connection for the host's core count.
* Keeps the last `--count` measurements per machine in a local SQLite database, so the cumulative nanosecond counters are reported as rates rather than as ever-growing totals, and reports the average over that whole span. A machine has to stay above a threshold for all of it to alert, so a single busy minute does not.
* The span the values cover is `--count` *measurements*, not a fixed stretch of time. Running the check by hand next to the scheduled one therefore shortens it: five measurements taken a second apart average over five seconds, not over five minutes. The numbers stay correct for the span they cover, but the smoothing is gone, so compare a hand-run result with a scheduled one only when nothing else is running the check in a loop.
* **The CPU column and the cores figure count different things.** The percentage is measured against the machine's own virtual CPUs and therefore stays within 0 to 100. The cores figure covers the whole hypervisor process, so it also carries the emulator and I/O threads working on the machine's behalf, and is the number that says what the machine really costs the host. On a guest saturating both of its virtual CPUs, the two were measured at 99.8% and 2.011 cores.
* Machines can be limited with `--match` and excluded with `--ignore` (case-sensitive Python regular expressions; use `(?i)` for case-insensitive matching). A machine hit by `--ignore` is dropped even if it also matches `--match`.
* Virtual CPUs are counted as libvirt assigned them, which stays correct after a hotplug, where libvirt numbers the remaining virtual CPUs with gaps.


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/kvm-cpu-usage> |
| Nagios/Icinga Check Name              | `check_kvm_cpu_usage` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No (runs with Python interpreter) |
| Requirements                          | command-line tool `virsh` (package `libvirt-client` on RHEL and SUSE, `libvirt-clients` on Debian and Ubuntu) |
| Handles Periods                       | Yes (values are averaged over `--count` measurements, default 5) |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-kvm-cpu-usage-<connection>.db`, one per `--url` |


## Help

```text
usage: kvm-cpu-usage [-h] [-V] [--always-ok] [--brief] [--count COUNT]
                     [-c CRIT] [--critical-steal CRIT_STEAL] [--ignore IGNORE]
                     [--match MATCH]
                     [--no-match-severity {ok,warn,crit,unknown}]
                     [--no-perfdata] [--timeout TIMEOUT] [--url URL] [-w WARN]
                     [--warning-steal WARN_STEAL]

Reports how much CPU each virtual machine of a libvirt host consumes, and how
much CPU its guests ask for but do not get because the host is busy elsewhere.
Alerts if a machine uses more of its assigned virtual CPUs than the thresholds
allow, and if the host makes a machine wait for CPU for too large a share of
its time. Also reports how many virtual CPUs the running machines were
promised against the cores the host really has. Runs without root or sudo.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --brief               Hide the rows that are within the thresholds and show
                        only those in a WARN or CRIT state. Perfdata and
                        alerting are unaffected: every item still emits
                        performance data and still drives the overall check
                        state, so this is safe to leave on.
  --count COUNT         Number of measurements the reported values are
                        averaged over. A machine has to stay above a threshold
                        for the whole span to alert, so a single busy minute
                        does not. Default: 5
  -c, --critical CRIT   CRIT threshold for the CPU usage of a machine, in
                        percent of the virtual CPUs assigned to it. Supports
                        Nagios ranges. Default: 90
  --critical-steal CRIT_STEAL
                        CRIT threshold for the share of its time a machine
                        spends waiting for CPU the host is using elsewhere, in
                        percent. Supports Nagios ranges. Default: 25
  --ignore IGNORE       Any item matching this Python regex will be ignored.
                        Can be specified multiple times. Example:
                        `(?i)linuxfabrik` for a case-insensitive match.
  --match MATCH         Filter by this Python regular expression. Case-
                        sensitive by default; use `(?i)` for case-insensitive
                        matching. Can be specified multiple times. If both
                        `--match` and `--ignore` are given, an item must match
                        `--match` AND not match `--ignore` to be reported
                        (include first, exclude second). Examples:
                        `(?i)example` to match "example" regardless of case.
                        `^(?!.*example).*$` to match any string except
                        "example" (negative lookahead).
  --no-match-severity {ok,warn,crit,unknown}
                        State to report when no item matches the filters and
                        nothing is checked. Default: ok
  --no-perfdata         Suppress the performance data section from the output.
                        The status message and the exit code are unaffected,
                        so alerting keeps working while trending data is
                        dropped.
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
  --url URL             libvirt connection URI, passed to `virsh --connect`.
                        Use `qemu+ssh://user@host/system` to check a host that
                        runs no local monitoring agent. Only QEMU/KVM
                        connections report the data this check needs. Default:
                        qemu:///system
  -w, --warning WARN    WARN threshold for the CPU usage of a machine, in
                        percent of the virtual CPUs assigned to it. Supports
                        Nagios ranges. Default: 80
  --warning-steal WARN_STEAL
                        WARN threshold for the share of its time a machine
                        spends waiting for CPU the host is using elsewhere, in
                        percent. Supports Nagios ranges. Default: 10

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/kvm-cpu-usage/
```


## Usage Examples

```bash
./kvm-cpu-usage
```

Output on the first run:

```text
Waiting for more data: mailstore01, nextcloud01
```

Output on the following runs:

```text
2 VMs, 4 vCPUs (50.0% of the host's 8 cores), 0.08 cores used, averaged over 5 measurements

VM Name     ! vCPUs ! CPU  ! Steal ! State
------------+-------+------+-------+------
mailstore01 ! 2     ! 1.1% ! 0.0%  ! [OK]
nextcloud01 ! 2     ! 2.9% ! 0.1%  ! [OK]
```

A machine that has run out of CPU:

```text
1 VM, 1 vCPU (12.5% of the host's 8 cores), 0.93 cores used, averaged over 5 measurements

VM Name     ! vCPUs ! CPU   ! Steal ! State
------------+-------+-------+-------+-----------
nextcloud01 ! 1     ! 92.0% ! 0.1%  ! [CRITICAL]
```

The same machine on a host that no longer has CPU to give it. Note that the CPU column *fell*, which is exactly why the steal is reported next to it:

```text
1 VM, 1 vCPU (12.5% of the host's 8 cores), 0.26 cores used, averaged over 5 measurements. Waiting for host CPU: nextcloud01 (75.4%) [CRITICAL]

VM Name     ! vCPUs ! CPU   ! Steal ! State
------------+-------+-------+-------+-----------
nextcloud01 ! 1     ! 25.8% ! 75.4% ! [CRITICAL]
```

Alerting only on the machines that matter, and leaving the templates alone:

```bash
./kvm-cpu-usage --ignore='^tpl_' --warning=90 --critical=95
```

Checking a hypervisor that runs no local monitoring agent:

```bash
./kvm-cpu-usage --url=qemu+ssh://monitoring@192.0.2.10/system
```


## States

* OK if every machine stays below both thresholds.
* OK with "Waiting for more data." for a machine that has no previous measurement yet, which is the case on the first run and after a machine was started.
* OK with "No running virtual machines found." if no machine on the host is running.
* WARN if a machine uses `--warning` percent or more of its assigned virtual CPUs (default: 80).
* WARN if a machine spends `--warning-steal` percent or more of its time waiting for CPU the host is giving to somebody else (default: 10).
* CRIT if a machine reaches `--critical` (default: 90) or `--critical-steal` (default: 25).
* UNKNOWN if libvirt cannot be reached, if the connection is not a QEMU/KVM one, if `virsh` is missing, or on an invalid `--match` or `--ignore` pattern.
* `--no-match-severity` sets the state reported when `--match` or `--ignore` leave no machine to check (default: `ok`).
* `--brief` hides the rows that are within the thresholds. It changes nothing about the state or the performance data.
* `--always-ok` suppresses all alerts and always returns OK.

The steal defaults come from a measurement rather than from a rule of thumb. A guest saturating its virtual CPU on an uncontended host core waits well under 1% of its time; sharing that core with one other process takes it to 50%, and with three to 75%. A machine losing a tenth of its CPU to the host is worth a look, and losing a quarter is worth acting on.

Both thresholds accept [Nagios ranges](../THRESHOLDS.md), so `--warning=@0:5` alerts on a machine that is suspiciously *idle* rather than busy.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| cpu_cores_total | Number | Cores the host has. |
| cpu_cores_used | Number | Host CPU cores kept busy by all checked machines together, averaged over `--count` measurements. |
| vcpu_commitment | Percentage | Virtual CPUs promised to the checked machines, in percent of the host's cores. Above 100% the host has handed out more than it has, which is normal while the machines stay idle. |
| vcpus_assigned | Number | Virtual CPUs promised to the checked machines. |
| &lt;machine&gt;_cpu_cores | Number | Host CPU cores the machine kept busy, emulator and I/O threads included. |
| &lt;machine&gt;_cpu_steal | Percentage | Share of its time the machine wanted CPU and the host was busy elsewhere, averaged over `--count` measurements. What the guest operating system sees as steal time. |
| &lt;machine&gt;_cpu_steal1 | Percentage | The same, over the last measurement interval alone. |
| &lt;machine&gt;_cpu_usage | Percentage | CPU the machine consumed, in percent of the virtual CPUs assigned to it, averaged over `--count` measurements. This is the value the thresholds judge. |
| &lt;machine&gt;_cpu_usage1 | Percentage | The same, over the last measurement interval alone. Comparing it with the averaged value is how a spike is told apart from a machine that has been busy all along. |


## Troubleshooting

### `Waiting for more data.`

Expected on the first run and whenever a machine has just been started. The check needs two measurements to turn libvirt's cumulative counters into a rate. Wait for the next check interval.

### A machine sits at a high steal

The host cannot give the machine the CPU it asks for. Work through it in this order:

1. Check the host's own CPU usage (`check_cpu_usage`). If the host itself is saturated, the machines are queueing behind everything else running on it.
2. Read the commitment figure on the first line. It already compares the virtual CPUs handed out with the host's cores, and a ratio well above 1:1 is only safe while the machines stay idle.
3. Look for machines pinned to the same host CPUs (`virsh dumpxml <machine>`, the `cputune` section). Pinning several machines onto one core produces exactly this picture while the rest of the host sits idle.
4. Reduce the assigned virtual CPUs of the machines that do not need them. A machine with more virtual CPUs than it uses makes the host schedule threads it never runs.

### A machine reports high CPU usage but the guest says it is idle

The usage is measured on the host, so it includes what the hypervisor spends on the machine's behalf, for example emulating devices for a guest without paravirtualised drivers. Install the virtio drivers in the guest, and compare the two numbers again.

### The check reports no machines while machines are running

The connection reaches a libvirt daemon that does not hold this host's machines, or every machine is filtered out. Compare with `virsh --readonly --connect=qemu:///system list --all --name` on the host itself, and check the `--match` and `--ignore` patterns.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
