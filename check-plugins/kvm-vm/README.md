# Check kvm-vm


## Overview

Lists the virtual machines of a libvirt host and checks the state of each one, together with the reason libvirt gives for it. Alerts if a machine is paused, idle or suspended by guest power management, if a machine that is configured to start together with the host is not running, and if a machine did not end the way somebody asked it to: frozen on a storage error, killed off the host, or never started at all. Runs without root or sudo.

**Important Notes:**

* The check connects to libvirt read-only. libvirt grants read-only access to any local account without asking for a password, so the check needs neither root nor sudo nor membership in the `libvirt` group.
* The connection is always named explicitly (`--url`, default `qemu:///system`). Left to its own devices, libvirt connects an unprivileged account to that account's own session daemon, which knows none of the host's machines and would report an empty list instead of an error.
* Only QEMU/KVM hosts are supported. libvirt reports the statistics this check reads through a call that the Xen (`xen:///`) and libvirt-LXC (`lxc:///`) drivers do not implement and offer no substitute for, so those connections are refused with an explanation rather than half-answered.
* A machine that is shut off is a normal state and does not alert. The check singles out the machines that libvirt is configured to start together with the host: one of those that is not running is reported, which is the case a plain state count cannot show.
* **The state alone does not say whether a machine ended badly, so the reason is read as well.** A machine somebody switched off, one whose hypervisor process was killed off the host, and one whose start never succeeded all sit in `shut off`; a machine somebody suspended and one frozen on a storage error both sit in `paused`. The check reports the reason next to the state and alerts on the ones that mean something went wrong.
* **A crash is usually not the guest panicking.** Only a guest with a panic device reports a panic to the host at all, and `on_crash` then defaults to `destroy`, so even that ends as `shut off (crashed)`. What libvirt records this way in practice is the hypervisor process disappearing without having announced a shutdown: the out-of-memory killer on an overcommitted host, a segfault, or anything else that takes the process down.
* The check can run somewhere other than the hypervisor. Point `--url` at `qemu+ssh://user@host/system` to reach a host that runs no local monitoring agent. `virsh` then has to be present where the check runs, and the account it runs as needs an SSH key on the hypervisor.
* A state that a future libvirt release adds to its enumeration is reported by its number (`state 8`) and treated as a warning, rather than being counted as if everything were fine.
* **`--brief` shortens the table on a busy host.** A host with hundreds of machines produces hundreds of rows, and `--brief` keeps only the machines in a WARN or CRIT state. Performance data and alerting are unaffected: every item still emits its metrics and still drives the overall state, so it is safe to leave on. It combines with `--lengthy`, which decides the columns rather than the rows. When nothing is in a WARN or CRIT state, the check prints its summary line and no table at all.

**Data Collection:**

* Collects the state and its reason for every machine in a single call, and asks separately which machines are configured to start with the host and which ones are persistent.
* Machines can be limited with `--match` and excluded with `--ignore` (case-sensitive Python regular expressions; use `(?i)` for case-insensitive matching). A machine hit by `--ignore` is dropped even if it also matches `--match`.
* Filtering only reshapes the output. Performance data covers every state either way.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/kvm-vm> |
| Nagios/Icinga Check Name              | `check_kvm_vm` |
| Check Interval Recommendation         | Every 15 minutes |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No (runs with Python interpreter) |
| Requirements                          | command-line tool `virsh` (package `libvirt-client` on RHEL and SUSE, `libvirt-clients` on Debian and Ubuntu) |


## Help

```text
usage: kvm-vm [-h] [-V] [--always-ok] [--brief] [--ignore IGNORE]
              [--match MATCH] [--no-match-severity {ok,warn,crit,unknown}]
              [--no-perfdata] [--timeout TIMEOUT] [--url URL]

Lists the virtual machines of a libvirt host and checks the state of each one,
together with the reason libvirt gives for it. Alerts if a machine is paused,
idle or suspended by guest power management, if a machine that is configured
to start together with the host is not running, and if a machine did not end
the way somebody asked it to: frozen on a storage error, killed off the host,
or never started at all. Runs without root or sudo.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --brief               Hide the rows that are within the thresholds and show
                        only those in a WARN or CRIT state. Perfdata and
                        alerting are unaffected: every item still emits
                        performance data and still drives the overall check
                        state, so this is safe to leave on.
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

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/kvm-vm/
```


## Usage Examples

```bash
./kvm-vm
```

Output:

```text
4 VMs: 1 running, 3 shut off

VM Name     ! Autostart ! Persistent ! State
------------+-----------+------------+---------------
debian13    ! no        ! yes        ! shut off [OK]
fedora43    ! no        ! yes        ! shut off [OK]
mailstore01 ! yes       ! yes        ! shut off [OK]
nextcloud01 ! yes       ! yes        ! running [OK]
```

A machine that is set to start with the host and is not running:

```text
2 VMs: 1 paused [WARNING], 1 shut off. Set to start with the host but not running: mailstore01 [WARNING]

VM Name     ! Autostart ! Persistent ! State
------------+-----------+------------+-------------------
mailstore01 ! yes       ! yes        ! shut off [WARNING]
nextcloud01 ! no        ! yes        ! paused [WARNING]
```

Checking a hypervisor that runs no local monitoring agent:

```bash
./kvm-vm --url=qemu+ssh://monitoring@192.0.2.10/system
```

Ignoring the machines whose name starts with `tpl_`:

```bash
./kvm-vm --ignore='^tpl_'
```


## States

* OK if every machine is `running`, `shut off` or `in shutdown`, and every machine configured to start with the host is running.
* OK with "No virtual machines found." if libvirt knows no machine on this host.
* WARN if a machine is `idle`, `paused`, `pmsuspended` or in a state outside libvirt's current enumeration.
* WARN if a machine that is configured to start together with the host is not running.
* WARN if a machine did not end the way anybody asked: `shut off (crashed)`, `shut off (failed)` or `shut off (daemon)`. The machine is already down, so nothing is gained by waking somebody at three in the morning who can do no more then than in the morning.
* WARN if a machine is running but its post-copy migration failed. It serves, and the two hosts it is spread over are not in a state to be left alone.
* CRIT if a machine is `crashed`.
* CRIT if a machine is frozen rather than merely paused: `paused (I/O error)`, `(watchdog)`, `(crashed)`, `(post-copy failed)` or `(api error)`. Frozen is as bad as gone for whatever depends on the machine, and none of the five resolves itself.
* UNKNOWN if libvirt cannot be reached, if the connection is not a QEMU/KVM one, if `virsh` is missing, or on an invalid `--match` or `--ignore` pattern.
* `--no-match-severity` sets the state reported when `--match` or `--ignore` leave no machine to check (default: `ok`); set it to `warn`, `crit`, or `unknown` to alert on an empty selection, for example after a filter typo or a renamed machine. It does not apply to a host that has no machines at all, which stays OK.
* `--brief` hides the rows that are within the thresholds. It changes nothing about the state or the performance data.
* `--always-ok` suppresses all alerts and always returns OK.

The states are libvirt's own:

* `crashed`: The machine has crashed. This can only happen if it is configured not to restart on crash.
* `idle`: The machine is blocked on a resource, so it is neither running nor runnable.
* `in shutdown`: The machine is shutting down; the guest operating system has been asked to stop.
* `no state`: libvirt reports no state for the machine.
* `paused`: The machine has been suspended by an administrator. It still holds its memory but is not scheduled.
* `pmsuspended`: The machine has been suspended by guest power management, for example into S3.
* `running`: The machine is executing on a CPU.
* `shut off`: The machine is not running, either shut down completely or never started.

Every state carries a reason. Most of them describe somebody at work and are reported without alerting: a machine is `shut off` after `shutdown`, `destroyed`, `migrated`, `saved` or `from snapshot`, and `paused` while `migrating`, `saving`, `dumping`, `shutting down`, `creating snapshot`, `starting up` or in `post-copy`. `unknown` is what libvirt answers for a machine it has no history for, which is every machine on the host after the libvirt daemon restarts, and it does not alert either. The reasons that do alert are listed under States above.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| vm_autostart_down | Number | Number of machines configured to start with the host that are not running. |
| vm_crashed | Number | Number of machines in crashed state. |
| vm_ended_badly | Number | Number of machines whose reason says something went wrong, whatever state they are in. The state counters alone never move for a machine that was killed off the host, because it is `shut off` like any other. |
| vm_idle | Number | Number of machines in idle state. |
| vm_in_shutdown | Number | Number of machines in shutdown state. |
| vm_no_state | Number | Number of machines for which libvirt reports no state. |
| vm_paused | Number | Number of machines in paused state. |
| vm_pmsuspended | Number | Number of machines in pmsuspended state. |
| vm_running | Number | Number of machines in running state. |
| vm_shut_off | Number | Number of machines in shut off state. |


## Troubleshooting

### `The "virsh" command was not found.`

Install the libvirt client package: `dnf install libvirt-client` on RHEL and Fedora, `zypper install libvirt-client` on SUSE, `apt install libvirt-clients` on Debian and Ubuntu. It has to be present wherever the check runs, which is not necessarily the hypervisor: with `--url=qemu+ssh://...` the check runs on the monitoring host and only reaches out to the hypervisor.

### Cannot reach the libvirt daemon

The daemon that serves the connection is not running or not reachable. Check `systemctl status virtqemud.socket`, or `systemctl status libvirtd.socket` on hosts that still run the monolithic daemon, and confirm that the URI names the hypervisor this host actually runs. Over `qemu+ssh://`, verify that the account the check runs as can reach the hypervisor without being asked for a password: `virsh --readonly --connect=qemu+ssh://user@host/system list --all`.

### The hypervisor does not report domain statistics

`virConnectGetAllDomainStats`

The connection reaches a libvirt driver that cannot answer the check. libvirt implements the statistics call in its QEMU/KVM and Virtuozzo drivers only; the Xen and libvirt-LXC drivers implement neither it nor a substitute, so there is no version of this check that could work over `xen:///` or `lxc:///`. Point `--url` at a QEMU/KVM host.

### `no polkit agent available to authenticate action 'org.libvirt.unix.manage'`

Something asked libvirt for a read-write connection, which polkit guards with a password prompt that nobody can answer on a server. The check itself always connects read-only, so this points at a `--url` value carrying options that force a read-write connection. Drop them and let the check open the connection.

### A machine is reported as `shut off (crashed)`

The hypervisor process serving that machine disappeared without libvirt having been told to stop it. The guest was running one moment and gone the next, so whatever it was doing was not finished. Work through it in this order:

1. Look for the out-of-memory killer on the host: `journalctl --dmesg --grep='Out of memory'`. On a host that has handed out more memory than it has, the kernel picks the largest process, which is the largest machine. `check_kvm_memory_usage` reports how much of the host is promised.
2. Read the libvirt log of that machine, `/var/log/libvirt/qemu/<machine>.log`. A hypervisor that died of its own accord leaves its last words there.
3. Check whether the host itself restarted underneath the machines: `uptime --since`.
4. Start the machine again once the cause is understood, and check its filesystems. It was not shut down cleanly.

### A machine is reported as `shut off (failed)`

The machine was asked to start and libvirt could not do it. The reason is in `/var/log/libvirt/qemu/<machine>.log` and usually names a resource that is not there: a disk image that has been moved or deleted, a bridge that no longer exists, a passed-through device that another machine holds, or a permission the hypervisor account lacks. Try it by hand with `virsh start <machine>`, which prints the error directly.

### A machine is reported as `paused (I/O error)`

The machine asked its storage for something and did not get it, and it is configured to stop rather than to pass the error into the guest. It is frozen and holds its memory, so nothing is lost yet, but it does nothing until the storage is back.

1. Find out which disk: `virsh domblkerror <machine>`.
2. Repair the storage underneath it. A full filesystem, an NFS or iSCSI target that went away, and a device-mapper path that failed all look the same from inside.
3. Resume the machine with `virsh resume <machine>` once the storage answers again.

### The check reports "No virtual machines found." while machines are running

The connection reaches a libvirt daemon that does not hold this host's machines. The usual cause is a URI naming the wrong hypervisor driver, or a session daemon rather than the system one. Compare with `virsh --readonly --connect=qemu:///system list --all` on the host itself.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
