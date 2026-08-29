# Check kvm-memory-usage

## Overview

Reports how much memory each virtual machine of a libvirt host has been given, how much of it the guest operating system actually needs, and how much of the host's memory the machine occupies. Alerts if a guest is running out of memory. Also reports how much of the host's memory is promised to the running machines, which is the number that says whether the host can still honour all of those promises. Runs without root or sudo.

**What the three memory figures mean:**

A virtual machine has three different memory sizes at the same time, and confusing them is the usual reason a report gets read wrongly.

* **Assigned** is what the machine currently has. It is the size the guest operating system boots with, minus whatever the host has taken back from it in the meantime.
* **Guest Used** is what the guest operating system cannot free: everything it holds except the memory its kernel would hand to a new process on demand. The page cache is not counted, because a guest gives it back the moment something else needs it. This is the figure the thresholds judge, and it is the one that matches what `free` reports inside the machine.
* **Host Used** is what the machine really occupies on the host right now. It is normally *larger* than Guest Used and *smaller* than Assigned, and both of those gaps are the point: the second is what makes it possible to run machines adding up to more memory than the host has, and the first is why the figure is not a second opinion on how full the guest is. See Troubleshooting for what sits in between.

**Important Notes:**

* **The guest columns are empty unless both sides are set up for them.** libvirt does not ask a guest about its own memory unless the machine is configured to report it, and it does not configure that by itself; the guest in turn only answers with figures while its balloon driver's statistics service runs. Where either is missing, the check reports what the host can see from the outside, says which of the two cases it is, and alerts on neither. Troubleshooting has the fix for each.
* A machine on a workstation may look configured when it is not. A graphical management tool switches guest reporting on for every machine it is watching and off again when it stops, so the numbers appear and disappear with it. On a server nothing does that.
* Only running machines are looked at. A machine that is shut off occupies no memory on the host, and the memory it will be given once it starts is a plan rather than a measurement.
* Machines add up to more memory than the host has on many perfectly healthy hosts. That is what the commitment figure is for: it is a fact, not an alert, and the check does not turn it into one. The host's own memory pressure is what `check_memory_usage` reports.
* The check connects to libvirt read-only, which needs neither root nor sudo nor membership in the `libvirt` group. Only QEMU/KVM connections report the data it needs; Xen and libvirt-LXC connections are refused with an explanation.
* **`--brief` shortens the table on a busy host.** A host with hundreds of machines produces hundreds of rows, and `--brief` keeps only the machines in a WARN or CRIT state. Performance data and alerting are unaffected: every item still emits its metrics and still drives the overall state, so it is safe to leave on. It combines with `--lengthy`, which decides the columns rather than the rows. When nothing is in a WARN or CRIT state, the check prints its summary line and no table at all.

**Data Collection:**

* Collects the memory figures of every running machine in a single call, and asks the same connection for the host's total memory.
* All values are read as they are, so the check keeps no history and needs no state file.
* A guest report that has stopped being refreshed is dropped rather than repeated. A guest updates its report every few seconds, so one that is more than ten minutes old does not describe the machine any more, and the machine is listed as if it reported nothing at all.
* Machines can be limited with `--match` and excluded with `--ignore` (case-sensitive Python regular expressions; use `(?i)` for case-insensitive matching). A machine hit by `--ignore` is dropped even if it also matches `--match`.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/kvm-memory-usage> |
| Nagios/Icinga Check Name              | `check_kvm_memory_usage` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No (runs with Python interpreter) |
| Requirements                          | command-line tool `virsh` (package `libvirt-client` on RHEL and SUSE, `libvirt-clients` on Debian and Ubuntu) |


## Help

```text
usage: kvm-memory-usage [-h] [-V] [--always-ok] [--brief] [-c CRIT]
                        [--critical-commitment CRIT_COMMITMENT]
                        [--ignore IGNORE] [--match MATCH]
                        [--no-match-severity {ok,warn,crit,unknown}]
                        [--no-perfdata] [--timeout TIMEOUT] [--url URL]
                        [-w WARN] [--warning-commitment WARN_COMMITMENT]

Reports how much memory each virtual machine of a libvirt host has been given,
how much of it the guest operating system actually needs, and how much of the
host's memory the machine occupies. Alerts if a guest is running out of
memory. Also reports how much of the host's memory is promised to the running
machines, which is the number that says whether the host can still honour all
of those promises. Runs without root or sudo.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --brief               Hide the rows that are within the thresholds and show
                        only those in a WARN or CRIT state. Perfdata and
                        alerting are unaffected: every item still emits
                        performance data and still drives the overall check
                        state, so this is safe to leave on.
  -c, --critical CRIT   CRIT threshold for the memory a guest operating system
                        needs, in percent of the memory the guest sees.
                        Supports Nagios ranges. Default: 90
  --critical-commitment CRIT_COMMITMENT
                        CRIT threshold for the memory promised to the running
                        machines, in percent of the memory the host has. Above
                        100 the host has promised more memory than it has, and
                        it can only honour that for as long as the guests
                        leave theirs untouched. Supports Nagios ranges.
                        Default: unset, the figure is reported but does not
                        alert. Example: `120`
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
  -w, --warning WARN    WARN threshold for the memory a guest operating system
                        needs, in percent of the memory the guest sees.
                        Supports Nagios ranges. Default: 80
  --warning-commitment WARN_COMMITMENT
                        WARN threshold for the memory promised to the running
                        machines, in percent of the memory the host has. Above
                        100 the host has promised more memory than it has, and
                        it can only honour that for as long as the guests
                        leave theirs untouched. Supports Nagios ranges.
                        Default: unset, the figure is reported but does not
                        alert. Example: `120`

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/kvm-memory-usage/
```


## Usage Examples

```bash
./kvm-memory-usage
```

Output:

```text
2 VMs, 6.0GiB assigned (19.6% of the host's 30.7GiB), 2.8GiB in use on the host

VM Name     ! Assigned ! Guest Used ! Guest % ! Host Used ! State
------------+----------+------------+---------+-----------+------
mailstore01 ! 2.0GiB   ! 291.3MiB   ! 14.9%   ! 533.1MiB  ! [OK]
nextcloud01 ! 4.0GiB   ! 924.3MiB   ! 23.4%   ! 2.3GiB    ! [OK]
```

A machine that is running out of memory:

```text
1 VM, 4.0GiB assigned (13.0% of the host's 30.7GiB), 3.9GiB in use on the host. Low on memory: nextcloud01 (93.0%) [CRITICAL]

VM Name     ! Assigned ! Guest Used ! Guest % ! Host Used ! State
------------+----------+------------+---------+-----------+-----------
nextcloud01 ! 4.0GiB   ! 3.6GiB     ! 93.0%   ! 3.9GiB    ! [CRITICAL]
```

A host where nobody switched guest reporting on. The two guest columns are left out rather than printed as a wall of hyphens, and the machines are still reported with what the host knows about them:

```text
2 VMs, 6.0GiB assigned (19.6% of the host's 30.7GiB), 2.8GiB in use on the host. No guest memory stats: mailstore01, nextcloud01 (enable with `virsh dommemstat NAME --period 10 --live --config`)

VM Name     ! Assigned ! Host Used ! State
------------+----------+-----------+------
mailstore01 ! 2.0GiB   ! 533.1MiB  ! [OK]
nextcloud01 ! 4.0GiB   ! 2.3GiB    ! [OK]
```

A host running three machines of 16 GiB each on 30.7 GiB of memory. Nothing is wrong, and the check says so, but the commitment figure is the one that decides whether a fourth machine can be started:

```text
3 VMs, 48.0GiB assigned (156.6% of the host's 30.7GiB), 7.0GiB in use on the host
```

Alerting only on the machines that matter, and leaving the templates alone:

```bash
./kvm-memory-usage --ignore='^tpl_' --warning=90 --critical=95
```

Checking a hypervisor that runs no local monitoring agent:

```bash
./kvm-memory-usage --url=qemu+ssh://monitoring@192.0.2.10/system
```


## States

* OK if every machine stays below the thresholds.
* OK with "No running virtual machines found." if no machine on the host is running.
* OK, with the machines named, if a guest does not report its own memory or has stopped refreshing that report. The machine is still reported with what the host can see from the outside.
* WARN if a guest operating system holds `--warning` percent or more of the memory it sees (default: 80).
* CRIT if it reaches `--critical` (default: 90).
* UNKNOWN if libvirt cannot be reached, if the connection is not a QEMU/KVM one, if `virsh` is missing, or on an invalid `--match` or `--ignore` pattern.
* `--no-match-severity` sets the state reported when `--match` or `--ignore` leave no machine to check (default: `ok`).
* `--brief` hides the rows that are within the thresholds. It changes nothing about the state or the performance data.
* WARN or CRIT if the memory promised to the machines reaches `--warning-commitment` or `--critical-commitment` percent of the host's memory (both default: unset). Promising more than there is works while the guests leave theirs untouched, so the bound is yours to pick; the host actually running out of memory is what `check_memory_usage` reports.
* `--always-ok` suppresses all alerts and always returns OK.

The thresholds accept [Nagios ranges](../THRESHOLDS.md), so `--warning=@0:5` alerts on a machine that is suspiciously *empty* rather than full, which is how a guest that failed to come up all the way looks.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| memory_assigned | Bytes | Memory promised to all checked machines together. |
| memory_commitment | Percentage | The same, in percent of the host's memory. Above 100% the host has promised more than it has. |
| memory_host_total | Bytes | Memory the host has. |
| memory_host_used | Bytes | Memory all checked machines together really occupy on the host. |
| &lt;machine&gt;_memory_assigned | Bytes | Memory the machine currently has. |
| &lt;machine&gt;_memory_host | Bytes | Memory the machine really occupies on the host. |
| &lt;machine&gt;_memory_usage | Percentage | Memory the guest operating system cannot free, in percent of the memory it sees. This is the value the thresholds judge. Only for machines that report it. |
| &lt;machine&gt;_memory_used | Bytes | The same in absolute terms. Only for machines that report it. |


## Troubleshooting

### `No guest memory stats`

The machine does not tell libvirt about its own memory, so only what the host can see from the outside is reported. Switch the reporting on, once per machine, and the guest columns appear on the next check:

```bash
virsh dommemstat mailstore01 --period 10 --live --config
```

`--live` applies it to the machine that is running now, `--config` keeps it across a reboot of that machine. Both are needed: without `--config` the setting is lost the next time the machine is started, and without `--live` nothing changes until then.

The guest also has to have a virtio balloon device and a driver for it. That is the default for Linux guests; on Windows it comes with the virtio driver package.

### `Answering but reporting no memory`

The collection is switched on and the machine answers, but it sends no memory figures, so there is nothing to report and nothing to alert on. The balloon driver in the guest is replying by itself; what gathers the numbers next to it is not running. Everything to fix is inside the machine.

**On Windows**, this is the state a machine stays in until the balloon service is installed, and it is easy to miss because the driver alone is enough to make the device look fine in the Device Manager. Measured on a Windows Server guest that answered once while booting and stayed quiet afterwards.

Install the virtio guest tools (`virtio-win-guest-tools.exe` from the virtio-win ISO), which brings the driver and the service together. On a machine that already has the driver, the service can be installed on its own from the ISO, from `Balloon\<windows version>\amd64\`:

```text
blnsvr.exe -i
```

Its own usage lists what else it takes:

```text
blnsvr -i        Install service
blnsvr -u        Uninstall service
blnsvr -r        Run service
blnsvr -s        Stop service
blnsvr status    Current status
```

So `blnsvr status` inside the machine answers whether this is the problem, and the guest columns appear on the next check once the service runs.

**On Linux**, the driver is usually built in. If a guest is silent, check that the module is there:

```bash
lsmod | grep virtio_balloon
modprobe virtio_balloon
```

### `Guest memory stats have stopped coming in`

The machine reported its memory at some point and then stopped. The last figures it sent are deliberately not repeated as if they were current. Usual causes, in the order worth checking:

1. The machine is paused or suspended. `check_kvm_vm` reports that state.
2. The guest is hung, or its balloon driver is. Look at the machine's console.
3. Somebody switched the reporting off again with `virsh dommemstat NAME --period 0`.

### Host Used is much larger than Guest Used

Expected, and the two are not two opinions on the same thing.

Guest Used is what the guest operating system currently cannot free. Host Used is every page of host memory that has ever been handed to that machine, plus what the hypervisor process needs for itself. A guest that frees a page does not give it back to the host: the host only takes memory back when the machine is squeezed through its balloon, when free page reporting is switched on for it (off by default), or when the host runs short and starts reclaiming. Until then the page stays with the machine, so Host Used follows the busiest moment the machine has had rather than the current one.

A machine with 1.7 GiB of memory that had briefly used most of it and had settled back to 366 MiB was measured occupying 1.01 GiB on the host, of which 23 MiB were the hypervisor process itself and the rest guest memory that had been touched at some point.

The practical reading: Guest Used answers "does this machine need more memory", Host Used answers "how much of the host can I get back by shutting it down".

### A machine reports low usage while the guest says it is nearly full

The two count differently. The check does not count the page cache as used, because a guest releases it as soon as something else needs the memory. A `free` output inside the machine shows the same thing in its `available` column, which is the number to compare with.

### The host is committed above 100%

Expected on many hosts, and not by itself a problem: machines rarely touch all the memory they were given, which is what the "in use on the host" figure shows. It becomes a problem when the machines do touch it, and the host then has to swap or start killing processes. Compare the commitment with what the machines really occupy, watch the host's own memory (`check_memory_usage`), and reduce the memory assigned to the machines that never use it.

### The check reports no machines while machines are running

The connection reaches a libvirt daemon that does not hold this host's machines, or every machine is filtered out. Compare with `virsh --readonly --connect=qemu:///system list --all --name` on the host itself, and check the `--match` and `--ignore` patterns.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
