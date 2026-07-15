# Check kdump


## Overview

Checks the kernel crash dump (kdump) subsystem. Verifies that the system is ready to capture the next kernel panic (crash kernel memory reserved and the capture kernel loaded), and scans the dump directory for crash dumps that a previous panic left behind. Unlike the volatile kernel ring buffer, these dumps persist across the reboot that follows a panic. For a found dump the plugin provides a first analysis of the panic reason from the captured dmesg and tells the admin how to remove the dump so the check returns to OK. When kdump is not ready, it surfaces the failure reason from the service journal. Alerts if kdump is not ready to capture a panic, or if one or more crash dumps are present. Requires root or sudo.

**Why two things in one check:** both answer the single operational question "is kernel crash dumping healthy?". A readiness gap means the *next* panic is lost silently, while a captured dump means a panic already happened and is waiting to be investigated. This differs from the `dmesg` check, which reads the live kernel ring buffer and loses its contents on the reboot that a panic triggers.

**Important Notes:**

* Requires root or sudo, but only for the first analysis: kdump writes `vmcore` and `vmcore-dmesg.txt` as mode 0600 owned by root. Without root the plugin still checks readiness and detects the presence of crash dumps (and still alerts), it just cannot read the captured dmesg to show the panic reason
* Crash dumps (`vmcore`) are large, often several GiB, and contain a full image of kernel memory, which may include sensitive data such as passwords or keys. Handle and archive them accordingly. After investigating a dump, remove its directory so the check returns to OK; the plugin prints the exact `rm -rf` command for the newest dump
* `/etc/kdump.conf` controls where and how the dump is written (dump target, core collector), not the amount of reserved memory. The memory reservation itself is a kernel boot parameter (`crashkernel=`); on RHEL/Fedora the `auto_reset_crashkernel` directive in `/etc/kdump.conf` keeps that boot parameter in sync when the kernel is updated

**Data Collection:**

* Reads `/sys/kernel/kexec_crash_size` (bytes reserved for the capture kernel) and `/sys/kernel/kexec_crash_loaded` (1 once the capture kernel is loaded and would run on the next panic). Both files are exposed by mainline Linux, so the readiness check is distribution-neutral; if a kernel is built without kdump support and the files are absent, the plugin reports that kdump is not available instead of failing
* On RHEL/Fedora and Debian/Ubuntu the kdump service state (`kdump.service` or `kdump-tools.service`) is additionally queried via `systemctl is-active` to add a human-readable reason such as `failed`. On any other distribution the plugin relies on the sysfs signals alone
* When kdump is not ready, the actual failure reason is read from the service journal (`journalctl --unit <unit> --boot --grep=...`), for example `Could not unlock the LUKS device`, out of memory, or an unreachable dump target. This works for any failure cause, not just a specific one
* On RHEL/Fedora, if no memory is reserved on the running kernel but a `crashkernel=` is already configured in the bootloader (for example right after `kdumpctl reset-crashkernel`), the plugin reports that a reboot is pending to apply the reservation, instead of claiming kdump is unconfigured
* Scans the dump directory for crash dumps. The directory defaults to `/var/crash` and is read from the distribution kdump configuration (`/etc/kdump.conf` on RHEL/Fedora, `/etc/default/kdump-tools` on Debian/Ubuntu) when present, or can be overridden with `--path`
* For the newest dump, a short first analysis is extracted from the captured dmesg (`vmcore-dmesg.txt` or Debian `dmesg.<timestamp>`): the crash section starting at the panic reason, shortened to its first and last lines when the call trace is long. The output leads with the `less <file>` command so the admin can read the full log


## Fact Sheet

| Fact | Value |
|----|----| 
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/kdump> |
| Nagios/Icinga Check Name              | `check_kdump` |
| Check Interval Recommendation         | Every 15 minutes |
| Can be called without parameters      | Yes |
| Runs on                               | Linux |
| Compiled for Windows                  | No |
| Requirements                          | command-line tools `systemctl`, `journalctl`, `grubby` (RHEL/Fedora); User with higher permissions (root or sudo) |


## Help

```text
usage: kdump [-h] [-V] [--always-ok] [--no-perfdata] [--path PATH]
             [--timeout TIMEOUT]

Checks the kernel crash dump (kdump) subsystem. Verifies that the system is
ready to capture the next kernel panic (crash kernel memory reserved and the
capture kernel loaded), and scans the dump directory for crash dumps that a
previous panic left behind. Unlike the volatile kernel ring buffer, these
dumps persist across the reboot that follows a panic. For a found dump the
plugin provides a first analysis of the panic reason from the captured dmesg
and tells the admin how to remove the dump so the check returns to OK. When
kdump is not ready, it surfaces the failure reason from the service journal.
Alerts if kdump is not ready to capture a panic, or if one or more crash dumps
are present. Requires root or sudo.

options:
  -h, --help         show this help message and exit
  -V, --version      show program's version number and exit
  --always-ok        Always returns OK.
  --no-perfdata      Suppress the performance data section from the output.
                     The status message and the exit code are unaffected, so
                     alerting keeps working while trending data is dropped.
  --path PATH        Directory to scan for kernel crash dumps. If not
                     specified, the plugin reads the configured dump directory
                     from the distribution kdump configuration and falls back
                     to "/var/crash". Example: `--path=/var/crash`
  --timeout TIMEOUT  Network timeout in seconds. Default: 8 (seconds)
```


## Usage Examples

Run with the bundled defaults (reads the dump directory from the kdump configuration, falls back to `/var/crash`):

```bash
sudo ./kdump
```

Scan a custom dump directory:

```bash
sudo ./kdump --path=/srv/crash
```

Sample output on a healthy host (kdump armed, no crash dumps):

```text
kdump is active (164.0MiB reserved, capture kernel loaded). No crash dumps found in /var/crash.
```

Sample output on a host where the capture kernel is not loaded because the encrypted dump target's key handling fails at boot (the reason comes straight from the service journal):

```text
256.0MiB crash kernel memory reserved, but the capture kernel is not loaded, so a kernel panic would not be captured. Check the kdump service. The kdump.service service reports "failed". No crash dumps found in /var/crash.

Most recent kdump service log:
kdump: Error: Could not unlock the LUKS device.
kdump: Failed to get logon key kdump-cryptsetup:vk-00000000-0000-0000-0000-000000000000. Run 'kdumpctl restart' manually to start kdump.
kdump: kexec: failed to prepare for a LUKS target
kdump: Starting kdump: [FAILED]
```

Sample output on a host with captured crash dumps (the full inventory is always listed when at least one dump is present):

```text
2 kernel crash dumps in /var/crash [WARNING], newest 18m 3s ago (2026-07-15 11:07:59).

Dump                          ! Size     ! State    
------------------------------+----------+----------
127.0.0.1-2026-07-15-11:07:59 ! 87.6MiB  ! [WARNING]
127.0.0.1-2026-07-15-10:56:21 ! 102.6MiB ! [WARNING]

`less /var/crash/127.0.0.1-2026-07-15-11:07:59/vmcore-dmesg.txt`
[  688.748794] Kernel panic - not syncing: sysrq triggered crash
[  688.748830] CPU: 0 UID: 0 PID: 1553 Comm: bash Kdump: loaded Not tainted 6.12.0-55.12.1.el10_0.x86_64 #1
[  688.748885] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS edk2-20260508-6.fc44 05/08/2026
[  688.748943] Call Trace:
[  688.748964]  &lt;TASK&gt;
...
[  688.749912] RDX: 0000000000000002 RSI: 000055b687757760 RDI: 0000000000000001
[  688.749949] RBP: 000055b687757760 R08: 0000000000000073 R09: 00000000ffffffff
[  688.749987] R10: 0000000000000000 R11: 0000000000000202 R12: 0000000000000002
[  688.750024] R13: 00007ff3986415c0 R14: 0000000000000002 R15: 00007ff39863ef00
[  688.750067]  &lt;/TASK&gt;

After investigating, remove the dump directory to clear this alert (dumps are large): rm -rf /var/crash/127.0.0.1-2026-07-15-11:07:59 (and the 1 older one(s) in /var/crash)

kdump is active (256.0MiB reserved, capture kernel loaded).
```


## States

* OK if kdump is ready to capture the next panic (crash kernel memory reserved and the capture kernel loaded) and no crash dumps are present.
* WARN if kdump is not ready to capture a panic (no crash kernel memory reserved, the capture kernel not loaded, or the kdump interface missing on the kernel), or if one or more crash dumps are found.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name    | Type   | Description                                                                          |
|---------|--------|-------------------------------------------------------------------------------------|
| `dumps` | Number | Number of kernel crash dumps found in the dump directory.                           |
| `ready` | Number | 1 if kdump is ready to capture a panic (memory reserved and capture kernel loaded), else 0. |


## Troubleshooting

### kdump is not ready to capture a panic

The plugin reports that no crash kernel memory is reserved, or that the capture kernel is not loaded. Enable kdump so the next panic is captured:

1. RHEL/Fedora: reserve crash kernel memory with `kdumpctl reset-crashkernel` (or set `crashkernel=` on the kernel command line), then `systemctl enable --now kdump`.
2. Debian/Ubuntu: install the `kdump-tools` package (it adds `crashkernel=` to the GRUB command line and enables `kdump-tools.service`), then `update-grub`.
3. Reboot, because the memory reservation only takes effect at boot. When the plugin says a reboot is pending, the `crashkernel=` is already configured and a reboot is all that is left.
4. Verify: `cat /sys/kernel/kexec_crash_loaded` must read `1`.

### `Could not unlock the LUKS device`

The dump target (for example `/var/crash`) lives on a LUKS-encrypted volume, and kdump cannot stage the volume key into the crash kernel keyring at boot, so the capture kernel fails to load. Retry once with `kdumpctl restart`; if it keeps failing, the encrypted dump target cannot be written from the crash kernel on this setup. Point kdump at a target that does not depend on the encrypted volume (a separate unencrypted partition, or an SSH/NFS dump target configured in `/etc/kdump.conf`), then `kdumpctl restart` and re-check.

### A crash dump was found

A previous kernel panic was captured. Read the full captured dmesg with the `less` command the plugin prints (or open `vmcore` with the `crash` utility for a deeper analysis). Once the incident is understood and the dump is archived, remove the dump directory with the `rm -rf` command the plugin prints; the check returns to OK on the next run.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
