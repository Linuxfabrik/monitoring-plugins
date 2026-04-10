# Check kvm-vm

## Overview

Lists all virtual machines on a KVM host using `virsh list --all` and checks their states. Alerts on VMs that are in unexpected states such as crashed, idle, paused, or pmsuspended.

**Data Collection:**

* Executes `virsh list --all` to obtain the list of all VMs and their current states
* Reports VM ID, name, and state for each virtual machine
* Requires root or sudo privileges

**Compatibility:**

* Linux

**Important Notes:**

* The possible VM states are:

    * `running`: The domain is currently running on a CPU.
    * `idle`: The domain is idle, not running or runnable (waiting on IO or nothing to do).
    * `paused`: The domain has been paused (e.g. via `virsh suspend`). It still consumes allocated resources like memory but is not eligible for scheduling.
    * `in shutdown`: The domain is in the process of shutting down (the guest OS has been notified).
    * `shut off`: The domain is not running (has been shut down completely or has not been started).
    * `crashed`: The domain has crashed. This can only occur if the domain has been configured not to restart on crash.
    * `pmsuspended`: The domain has been suspended by guest power management (e.g. entered S3 state).


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/kvm-vm> |
| Nagios/Icinga Check Name              | `check_kvm_vm` |
| Check Interval Recommendation         | Every 15 minutes |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |


## Help

```text
usage: kvm-vm [-h] [-V] [--always-ok]

Lists all virtual machines on a KVM host using "virsh list" and checks their
states. Alerts on VMs that are not in the expected running state. Reports VM
name, state, autostart configuration, and persistent status. Requires root or
sudo.

options:
  -h, --help     show this help message and exit
  -V, --version  show program's version number and exit
  --always-ok    Always returns OK.
```


## Usage Examples

```bash
./kvm-vm
```

Output:

```text
VMs: 5 running, 1 shut_off

ID ! VM Name     ! State
---+-------------+---------
2  ! nextcloud   ! running
9  ! mon02       ! running
10 ! infra02     ! running
11 ! mon01       ! shut_off
13 ! mailstore01 ! running
```


## States

* OK if all VMs are in `running`, `shut off`, or `in shutdown` state, or if no VMs exist.
* WARN if any VM is in `idle`, `paused`, or `pmsuspended` state.
* CRIT if any VM is in `crashed` state.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| vm_crashed | Number | Number of VMs in crashed state. |
| vm_idle | Number | Number of VMs in idle state. |
| vm_in_shutdown | Number | Number of VMs in shutdown state. |
| vm_paused | Number | Number of VMs in paused state. |
| vm_pmsuspended | Number | Number of VMs in pmsuspended state. |
| vm_running | Number | Number of VMs in running state. |
| vm_shut_off | Number | Number of VMs in shut off state. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
