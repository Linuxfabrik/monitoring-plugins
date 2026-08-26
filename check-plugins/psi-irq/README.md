# Check psi-irq


## Overview

Reports how much of its time a host loses to interrupt handling, taken from the pressure stall information of the Linux kernel. A pressure of 10 percent means that for a tenth of the time no task could get on, because the CPUs were busy servicing hardware and software interrupts instead. The check alerts on that share, averaged over the last minute. It answers what neither CPU utilization nor packet counters can: whether the interrupt load is costing the workload its time on the CPU. The ten second average is reported but not judged, until `--warning-avg10` or `--critical-avg10` give it a threshold; those catch a burst that the one minute average smooths away. A host whose kernel does not account for interrupt pressure is reported as OK, because there is nothing to measure; raise `--severity-no-psi` to flag it where the statistics are expected. Alerts when the pressure leaves the warning or critical range.

**What the numbers mean:**

The value is a share of wall clock time, not of the interrupts:

* `full` is the time in which **every task that had work to do** waited for the CPUs to finish servicing interrupts. Nothing was accomplished during that time although the CPUs were awake. That is what this check judges.

Interrupts are the one resource the kernel reports with a `full` line only. The other three pressure files also carry a `some` line, for the time in which at least one task waited while the rest got on. An interrupt does not work that way: it takes the CPU away from whatever was running on it, so there is no partial state to report.

The line comes as averages over the last 10, 60 and 300 seconds. The check alerts on the 60 second average because that is the window a check running every minute can actually see: 10 seconds is gone again before the next run, 300 seconds smears a burst until it no longer stands out. All three go into the performance data, so the graph keeps the short spike as well as the long trend.

**Important Notes:**

* **Most kernels do not account for interrupt pressure at all.** It needs the interrupt time accounting compiled in, and the check reports plainly when a host does not have it. Measured against the shipped kernels: Rocky 9 and 10 and Fedora have it, Rocky 8 does not, and Debian 11, 12 and 13 as well as Ubuntu 22.04 and 24.04 do not build it in. See [Troubleshooting](#this-kernel-accounts-for-pressure-but-not-for-interrupts).
* **Red Hat ships the pressure interface itself switched off.** Rocky, RHEL and their rebuilds compile pressure accounting in (`CONFIG_PSI=y`) but disable it by default (`CONFIG_PSI_DEFAULT_DISABLED=y`), verified against the shipped kernel configuration of Rocky 8, 9 and 10. The kernel then creates no `/proc/pressure` at all. See [Troubleshooting](#this-kernel-keeps-no-pressure-statistics) for how to switch it on.
* **This is not the interrupt count.** `/proc/interrupts` counts events; a host can service millions of them per second without anybody waiting, and it can lose real time to far fewer of them on a slow handler. This check reports what the servicing costs the workload.
* **The averages need time to rise.** The 60 second average needs about a minute of sustained pressure to reach the real level, so by default the check alerts on sustained pressure and not on the burst that lasted a moment. `--warning-avg10` and `--critical-avg10` put a threshold on the 10 second average where the bursts matter too; without them that value is graphed but never alerts.
* **The values are system-wide and cover every device together.** There is one figure for the host, not one per interrupt line. Where the pressure is high, `/proc/interrupts` says which device is behind it.
* Related checks: `cpu-usage` reports how much of each CPU goes into hard and soft interrupt handling, `network-io` the packet rate that usually drives it, `network-errors` whether the interface is dropping what it cannot keep up with.

**Data Collection:**

* Reads `/proc/pressure/irq`
* Reads the values by name and not by position, so a kernel that adds a field cannot shift a value under the wrong name
* Needs no root and no `sudo`


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/psi-irq> |
| Nagios/Icinga Check Name              | `check_psi_irq` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Runs on                               | Linux |
| Compiled for Windows                  | No |


## Help

```text
usage: psi-irq [-h] [-V] [--always-ok] [-c CRIT] [--critical-avg10 CRIT_AVG10]
               [--no-perfdata] [--severity-no-psi {ok,warn,crit,unknown}]
               [-w WARN] [--warning-avg10 WARN_AVG10]

Reports how much of its time a host loses to interrupt handling, taken from
the pressure stall information of the Linux kernel. A pressure of 10 percent
means that for a tenth of the time no task could get on, because the CPUs were
busy servicing hardware and software interrupts instead. The check alerts on
that share, averaged over the last minute. It answers what neither CPU
utilization nor packet counters can: whether the interrupt load is costing the
workload its time on the CPU. The ten second average is reported but not
judged, until --warning-avg10 or --critical-avg10 give it a threshold; those
catch a burst that the one minute average smooths away. A host whose kernel
does not account for interrupt pressure is reported as OK, because there is
nothing to measure; raise --severity-no-psi to flag it where the statistics
are expected. Alerts when the pressure leaves the warning or critical range.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  -c, --critical CRIT   CRIT threshold for the interrupt pressure, in percent
                        of wall clock time, measured over the last minute.
                        Supports Nagios ranges. Example: `25` alerts where 25
                        percent of the time is lost. Default: 25
  --critical-avg10 CRIT_AVG10
                        CRIT threshold for the interrupt pressure, in percent
                        of wall clock time, measured over the last ten
                        seconds. Catches a burst that the one minute average
                        smooths away, at the price of alerting on a stall that
                        is over before anybody looks. Supports Nagios ranges.
                        Example: `60` alerts where interrupt handling took six
                        of the last ten seconds. Default: no critical
                        threshold
  --no-perfdata         Suppress the performance data section from the output.
                        The status message and the exit code are unaffected,
                        so alerting keeps working while trending data is
                        dropped.
  --severity-no-psi {ok,warn,crit,unknown}
                        Severity for alerting if the kernel keeps no pressure
                        statistics. Default: ok
  -w, --warning WARN    WARN threshold for the interrupt pressure, in percent
                        of wall clock time, measured over the last minute.
                        Supports Nagios ranges. Example: `10` alerts where 10
                        percent of the time is lost. Default: 10
  --warning-avg10 WARN_AVG10
                        WARN threshold for the interrupt pressure, in percent
                        of wall clock time, measured over the last ten
                        seconds. Catches a burst that the one minute average
                        smooths away, at the price of alerting on a stall that
                        is over before anybody looks. Supports Nagios ranges.
                        Example: `40` alerts where interrupt handling took
                        four of the last ten seconds. Default: no warning
                        threshold

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/psi-irq/
```


## Usage Examples

```bash
./psi-irq
```

Output on a host whose interrupt load costs it nothing:

```text
irq pressure, last minute: full 0.0%
full = every task with work to do waited for interrupt handling to finish

Window ! Full 
-------+------
avg10  ! 0.0% 
avg60  ! 0.0% 
avg300 ! 0.78%
```

Output while thirty-two loopback connections wrote a kibibyte at a time, which saturates the machine on software interrupts:

```text
irq pressure, last minute: full 16.44% [WARNING]
full = every task with work to do waited for interrupt handling to finish
The CPUs are busy servicing interrupts instead of running work. `/proc/interrupts` names the device behind them, `network-io` reports the packet rate that usually drives them and `cpu-usage` how much of each CPU goes into interrupt handling.

Window ! Full            
-------+-----------------
avg10  ! 19.12%          
avg60  ! 16.44% [WARNING]
avg300 ! 6.97%
```

A host that is expected to carry a heavy packet rate, a router or a firewall, wants the pressure graphed and nobody woken. `~:` is the Nagios range for "any value is fine":

```bash
./psi-irq --warning=~: --critical=~:
```

A host where a short interrupt storm already hurts wants the 10 second average judged as well. It alerts on its own, while the minute average stays inside its range:

```bash
./psi-irq --warning-avg10=10
```

```text
irq pressure, last minute: full 4.36%; last ten seconds: full 16.2% [WARNING]
full = every task with work to do waited for interrupt handling to finish
The CPUs are busy servicing interrupts instead of running work. `/proc/interrupts` names the device behind them, `network-io` reports the packet rate that usually drives them and `cpu-usage` how much of each CPU goes into interrupt handling.

Window ! Full           
-------+----------------
avg10  ! 16.2% [WARNING]
avg60  ! 4.36%          
avg300 ! 1.7%
```

Where interrupt pressure is expected on every host, a kernel that does not report it is worth flagging instead of passing as OK:

```bash
./psi-irq --severity-no-psi=warn
```


## States

* OK if the pressure over the last minute is within `--warning` and `--critical`.
* OK with an explanation if the kernel keeps no pressure statistics, or keeps them but does not account for interrupts. `--severity-no-psi` raises both to `warn`, `crit` or `unknown`.
* WARN if the pressure over the last minute leaves the `--warning` range, 10 % by default.
* CRIT if it leaves the `--critical` range, 25 % by default.
* WARN or CRIT if the pressure over the last ten seconds leaves `--warning-avg10` or `--critical-avg10`. Neither is set by default, so that value does not alert until one of them is given. The worst of the two windows wins.
* UNKNOWN if a value in `/proc/pressure/irq` is not a number, or if the file exists but cannot be read.
* UNKNOWN if the check does not run on Linux.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

Every value is a share of wall clock time in percent, as the kernel reports it. The thresholds sit on `full_avg60`, the value the check judges, and on `full_avg10` once `--warning-avg10` or `--critical-avg10` is given.

| Name | Type | Description |
|----|----|----|
| full_avg10  | Percentage | Time in which every task with work to do waited for interrupt handling, over the last 10 seconds. |
| full_avg60  | Percentage | The same over the last 60 seconds. This is the value the check alerts on. |
| full_avg300 | Percentage | The same over the last 300 seconds. |


## Troubleshooting

### The CPUs are busy servicing interrupts instead of running work

The host is losing a measurable share of its wall clock to hard and soft interrupt handling. Work through it in this order:

1. `cat /proc/interrupts` and read it twice a few seconds apart. The line whose counters climb fastest names the device.
2. Check the packet rate with `network-io`. An interrupt storm on a network card is by far the most common cause, and it usually comes with a matching rise in packets per second.
3. Look at how the interrupts are spread with `cat /proc/irq/<number>/smp_affinity_list`. A device whose interrupts all land on one CPU saturates that CPU while the rest of the machine idles.
4. Check the interface for drops with `network-errors`. A card that cannot keep up drops what it cannot service, and both numbers rise together.
5. Where the device is a network card, interrupt coalescing is the usual remedy: `ethtool --show-coalesce <interface>` reads the current setting, `ethtool --coalesce <interface> rx-usecs <value>` raises it.

A virtual machine can also show this without any device of its own being at fault, when the host it runs on is oversubscribed. `cpu-usage` reports the steal time that goes with it.

### `This kernel accounts for pressure, but not for interrupts`

The kernel publishes `/proc/pressure` but no `irq` file in it, so there is nothing to measure. This is a property of how the kernel was built and cannot be switched on at runtime.

Measured against the shipped kernels: Rocky 9, Rocky 10 and Fedora carry the accounting, Rocky 8 does not, and Debian 11, 12 and 13 as well as Ubuntu 22.04 and 24.04 do not build it in. On a host that does have it, the `tsc=noirqtime` boot parameter switches it off again; drop that parameter and reboot to get the statistics back.

Where the check runs on hosts of both kinds, leave `--severity-no-psi` at its default so the ones without it stay quiet. Where every host is expected to report interrupt pressure, raise it to `warn` so a kernel that does not is visible.

### `This kernel keeps no pressure statistics`

The kernel creates no `/proc/pressure` at all, which is what the whole Red Hat family boots into: pressure accounting is compiled in but disabled by default.

Check first whether this host can report interrupt pressure at all, because switching pressure accounting on does not add it. Rocky 8 and the Debian family gain `psi-cpu`, `psi-io` and `psi-memory` from the reboot below and still not this check.

Add `psi=1` to the kernel command line and reboot:

```bash
grubby --update-kernel=ALL --args="psi=1"
reboot
```

Afterwards the directory is there:

```bash
ls /proc/pressure/
```

```text
cpu  io  irq  memory
```

If `irq` is missing while the other three are present, the kernel does not carry the interrupt accounting, see above.

### The interrupt count is high and the pressure is low

Correct and not a defect. Pressure counts the time the servicing costs the workload, not the number of events. A card delivering a million interrupts a second through a fast handler on a machine with cores to spare keeps nobody waiting. That is a machine using its hardware, not a machine limited by it.

### The pressure looks harmless although users complain

The check alerts on the 60 second average, which needs about a minute of sustained pressure to reach the real level. A burst that lasts ten seconds barely moves it, which is deliberate: a stall that is over before anybody looks is rarely worth an alert. The `full_avg10` metric keeps those bursts, so the graph shows what the alert does not.

Where the bursts do matter, give the 10 second average its own threshold with `--warning-avg10` and `--critical-avg10`. Pick it well above the 60 second threshold, because the short window swings much further on the same workload. Expect more alerts that have resolved themselves by the time somebody reads them.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
