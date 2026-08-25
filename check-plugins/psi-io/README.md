# Check psi-io


## Overview

Reports how much of its time a host loses waiting for storage, taken from the pressure stall information of the Linux kernel. A pressure of 10 percent means that for a tenth of the time work could not go on because the storage was contended. The check alerts on the share of time in which every task that had work to do was stalled at once, averaged over the last minute. That is the state in which the machine spends its cycles waiting instead of working, and it answers what throughput and utilization cannot: a disk can be busy all day without anybody waiting for it. A host whose kernel keeps no pressure statistics is reported as OK, because there is nothing to measure; raise `--severity-no-psi` to flag it where the statistics are expected. Alerts when the pressure leaves the warning or critical range.

**What the numbers mean:**

The kernel writes two lines, and both are a share of wall clock time, not of the disks:

* `some` is the time in which **at least one** task was stalled on storage. On a working host this is never zero. Something waits for a read now and then, and the machine gets on with other work in the meantime.
* `full` is the time in which **every task that had work to do** was stalled at once. Nothing was accomplished during that time although the CPUs were awake. That is what this check judges.

Storage is the resource where the two numbers separate most clearly. Measured on this reference host, six processes writing with direct I/O produced 18.57 % `some` next to 9.76 % `full` over the same minute: somebody was always waiting, and the machine still got half of that time's work done.

Both lines come as averages over the last 10, 60 and 300 seconds. The check alerts on the 60 second average because that is the window a check running every minute can actually see. All three go into the performance data, so the graph keeps the short spike as well as the long trend.

**Important Notes:**

* **This is not disk utilization.** A device can run at 100 % busy while every task gets its data in time, and it can be nearly idle while one process waits on every single read. `disk-io` reports what the devices do, this check what the waiting costs the host.
* **Paging counts as storage pressure.** The kernel counts a page fault that has to reach the swap device or the filesystem here as well, so a memory shortage shows up as I/O pressure. Where both this check and `psi-memory` alert, memory is the cause and storage is the symptom.
* **The averages need time to rise.** The 60 second average needs about a minute of sustained pressure to reach the real level, so the check reports sustained pressure and not the burst that lasted a moment. The `full_avg10` performance data shows the bursts.
* **The values are system-wide and cover every device together.** There is one figure for the host, not one per disk. Where the pressure is high, `disk-io` says which device is behind it, and the same statistics exist per cgroup and name the guilty service, see [Troubleshooting](#the-pressure-is-high-and-nothing-obvious-is-running).
* **Red Hat ships the interface switched off.** Rocky, RHEL and their rebuilds compile pressure accounting in (`CONFIG_PSI=y`) but disable it by default (`CONFIG_PSI_DEFAULT_DISABLED=y`), verified against the shipped kernel configuration of Rocky 8, 9 and 10. The kernel then creates no `/proc/pressure` at all and the check reports that nothing can be measured. Debian 11, 12 and 13, Ubuntu 22.04, 24.04 and 26.04 and Fedora have it switched on out of the box. See [Troubleshooting](#this-kernel-keeps-no-pressure-statistics) for how to switch it on.
* Related checks: `disk-io` reports throughput, busy time and latency per device, `disk-usage` how full the filesystems are, `memory-paging` whether the traffic is the host paging rather than the workload reading and writing.

**Data Collection:**

* Reads `/proc/pressure/io`
* Reads the values by name and not by position, so a kernel that adds a field cannot shift a value under the wrong name
* Needs no root and no `sudo`


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/psi-io> |
| Nagios/Icinga Check Name              | `check_psi_io` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Runs on                               | Linux |
| Compiled for Windows                  | No |


## Help

```text
usage: psi-io [-h] [-V] [--always-ok] [-c CRIT] [--no-perfdata]
              [--severity-no-psi {ok,warn,crit,unknown}] [-w WARN]

Reports how much of its time a host loses waiting for storage, taken from the
pressure stall information of the Linux kernel. A pressure of 10 percent means
that for a tenth of the time work could not go on because the storage was
contended. The check alerts on the share of time in which every task that had
work to do was stalled at once, averaged over the last minute. That is the
state in which the machine spends its cycles waiting instead of working, and
it answers what throughput and utilization cannot: a disk can be busy all day
without anybody waiting for it. A host whose kernel keeps no pressure
statistics is reported as OK, because there is nothing to measure; raise
--severity-no-psi to flag it where the statistics are expected. Alerts when
the pressure leaves the warning or critical range.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  -c, --critical CRIT   CRIT threshold for the storage pressure, in percent of
                        wall clock time, measured over the last minute.
                        Supports Nagios ranges. Example: `60` alerts where 60
                        percent of the time is lost. Default: 60
  --no-perfdata         Suppress the performance data section from the output.
                        The status message and the exit code are unaffected,
                        so alerting keeps working while trending data is
                        dropped.
  --severity-no-psi {ok,warn,crit,unknown}
                        Severity for alerting if the kernel keeps no pressure
                        statistics. Default: ok
  -w, --warning WARN    WARN threshold for the storage pressure, in percent of
                        wall clock time, measured over the last minute.
                        Supports Nagios ranges. Example: `40` alerts where 40
                        percent of the time is lost. Default: 40

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/psi-io/
```


## Usage Examples

```bash
./psi-io
```

Output on a host whose storage keeps up:

```text
io pressure, last minute: some 0.03%, full 0.03%
some = at least one task stalled, full = every task with work to do stalled

Window ! Some  ! Full 
-------+-------+------
avg10  ! 0.0%  ! 0.0% 
avg60  ! 0.03% ! 0.03%
avg300 ! 1.4%  ! 0.81%
```

Output while six processes wrote with direct I/O:

```text
io pressure, last minute: some 18.57%, full 9.76%
some = at least one task stalled, full = every task with work to do stalled

Window ! Some   ! Full  
-------+--------+-------
avg10  ! 26.3%  ! 13.75%
avg60  ! 18.57% ! 9.76% 
avg300 ! 7.63%  ! 4.22%
```

A host on slow storage that is expected to wait, an archive or a backup target, wants the pressure graphed and nobody woken. `~:` is the Nagios range for "any value is fine":

```bash
./psi-io --warning=~: --critical=~:
```

A latency-sensitive host, a database for example, is worth watching earlier than the default:

```bash
./psi-io --warning=10 --critical=25
```


## States

* OK if the `full` pressure over the last minute is within `--warning` and `--critical`.
* OK with an explanation if the kernel keeps no pressure statistics, which is the Red Hat default. `--severity-no-psi` raises that to `warn`, `crit` or `unknown`.
* WARN if the `full` pressure over the last minute leaves the `--warning` range, 40 % by default.
* CRIT if it leaves the `--critical` range, 60 % by default.
* UNKNOWN if a value in `/proc/pressure/io` is not a number, or if the file exists but cannot be read.
* UNKNOWN if the check does not run on Linux.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

Every value is a share of wall clock time in percent, as the kernel reports it. The thresholds sit on `full_avg60`, the value the check judges.

| Name | Type | Description |
|----|----|----|
| full_avg10  | Percentage | Time in which every task with work to do was stalled on storage, over the last 10 seconds. |
| full_avg60  | Percentage | The same over the last 60 seconds. This is the value the check alerts on. |
| full_avg300 | Percentage | The same over the last 300 seconds. |
| some_avg10  | Percentage | Time in which at least one task was stalled on storage, over the last 10 seconds. |
| some_avg60  | Percentage | The same over the last 60 seconds. |
| some_avg300 | Percentage | The same over the last 300 seconds. |


## Troubleshooting

### The host is stalling on storage

Work is waiting for the disks. Find out which device is behind it and how long it takes to answer:

```bash
./disk-io --lengthy
```

Then find who is reading and writing. Every process keeps its own I/O counters:

```bash
for p in /proc/[0-9]*; do printf '%s %s\n' "$(awk '/^read_bytes:/{r=$2} /^write_bytes:/{print r + $2}' "$p/io" 2>/dev/null)" "$(cat "$p/comm" 2>/dev/null)"; done | sort --numeric-sort --reverse | head
```

Reading that file for a process of another user needs root. From there the answer is one of three: give the workload faster storage, spread it over more devices, or cap what may wait with `IOWeight` or `IOReadBandwidthMax` on its systemd unit.

Rule out memory first, though: a host that is short of memory pages to disk, and that traffic lands in these numbers as well. Where `psi-memory` alerts at the same time, memory is the cause.

### The pressure is high and nothing obvious is running

The values this check reads are system-wide. The kernel keeps the same statistics per cgroup, which names the responsible service directly:

```bash
for f in /sys/fs/cgroup/*.slice/io.pressure; do printf '%s %s\n' "$(awk '/^full/{split($3,a,"="); print a[2]}' "$f")" "$f"; done | sort --numeric-sort --reverse | head
```

That prints the 60 second `full` average per slice, highest first. Repeat one level deeper inside the slice that stands out (`/sys/fs/cgroup/system.slice/*/io.pressure`) and the answer is a unit name.

### The disks are busy and the pressure is low

Correct and not a defect. Pressure counts waiting, not working. A device delivering at full rate to a workload that reads ahead in good time keeps nobody waiting. That is a machine using its storage, not a machine limited by it.

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
cat /proc/pressure/io
```

If the directory is still missing after the reboot, the kernel was built without `CONFIG_PSI` altogether. Read what the running kernel was built with:

```bash
grep CONFIG_PSI /boot/config-$(uname --kernel-release)
```

### The pressure looks harmless although users complain

The check alerts on the 60 second average, which needs about a minute of sustained pressure to reach the real level. A burst that lasts ten seconds barely moves it. The `some_avg10` and `full_avg10` metrics keep those bursts, so the graph shows what the alert deliberately does not.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
