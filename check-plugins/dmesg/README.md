# Check dmesg

## Overview

Checks the kernel ring buffer (dmesg) for messages at severity levels emerg, alert, crit, and err. Known false positives and hardware-specific noise are filtered out by default. To clear reported messages after resolving the underlying issue, run "dmesg --clear". Requires root or sudo.

**Data Collection:**

* Executes `dmesg --level=emerg,alert,crit,err --ctime` to read the kernel ring buffer
* Known false positives are filtered out by default, including common harmless messages such as "Assuming drive cache: write through", "ioctl error in smb2_get_dfs_refer rc=-5", and various KVM/EFI/SMBus messages
* Additional messages can be excluded using the `--ignore` parameter (case-sensitive, repeatable)
* If more than 10 error lines are found, the output is shortened to the first 5 and last 5 lines

**Compatibility:**

* Linux only

**Important Notes:**

* The reported timestamps may be inaccurate. The time source used for dmesg is not updated after system SUSPEND/RESUME. Timestamps are adjusted according to the current delta between boottime and monotonic clocks, which only works for messages printed after the last resume
* The kernel ring buffer is a fixed-size circular buffer. Over time, newer messages overwrite older ones, so errors that have been resolved and whose messages have been overwritten will no longer be reported


## Fact Sheet

| Fact | Value |
|----|----| 
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/dmesg> |
| Nagios/Icinga Check Name              | `check_dmesg` |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |


## Help

```text
usage: dmesg [-h] [-V] [--always-ok] [--ignore IGNORE]
             [--severity {warn,crit}] [--test TEST]

Checks the kernel ring buffer (dmesg) for messages at severity levels emerg,
alert, crit, and err. Known false positives and hardware-specific noise are
filtered out by default. To clear reported messages after resolving the
underlying issue, run "dmesg --clear". Requires root or sudo.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --ignore IGNORE       Ignore a kernel message (case-sensitive, repeating).
                        Default: [' Asking for cache data failed', ' Assuming
                        drive cache: write through', ' brcmfmac:
                        brcmf_c_preinit_dcmds: Firmware: BCM4345/6', '
                        brcmfmac: brcmf_fw_alloc_request: using
                        brcm/brcmfmac43455-sdio for chip BCM4345/6', ' CIFS
                        VFS: Free previous auth_key.response = ', ' cpufreq:
                        __cpufreq_add_dev: ->get() failed', ' EFI MOKvar
                        config table is not in EFI runtime memory', ' ERST:
                        Failed to get Error Log Address Range.', ' flip_done
                        timed out', ' i8042: No controller found', ' Ignoring
                        unsafe software power cap!', ' integrity: Problem
                        loading X.509 certificate -126', ' ioctl error in
                        smb2_get_dfs_refer rc=-5', ' kvm_set_msr_common:
                        MSR_IA32_DEBUGCTLMSR ', ' mokvar: EFI MOKvar config
                        table is not in EFI runtime memory', ' No Caching mode
                        page found', ' SMBus base address uninitialized -
                        upgrade BIOS or use ', ' SMBus Host Controller not
                        enabled!', ' tsc: Fast TSC calibration failed', '
                        unhandled rdmsr: ', ' unhandled wrmsr: ', ' vcpu0
                        disabled perfctr wrmsr', ' Warning: Deprecated Driver
                        is detected', ' Warning: Unmaintained driver is
                        detected']
  --severity {warn,crit}
                        Severity for alerting. Default: crit
  --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                        stderr-file,expected-retc".
```


## Usage Examples

```bash
./dmesg --ignore ' unhandled wrmsr: ' --severity crit
```

Output:

```text
5 errors in Kernel Ring Buffer.

[Mon May 31 18:27:14 2021] x86/cpu: SGX disabled by BIOS
[Sat Jun  5 18:49:50 2021] ACPI Error: Thread 2495397888 cannot release Mutex [ECMX] acquired by thread 1817575424 (20210105/exmutex-378)
[Sat Jun  5 18:49:50 2021] ACPI Error: Aborting method \_SB.PCI0.LPCB.ECDV._Q66 due to previous error (AE_AML_NOT_OWNER) (20210105/psparse-529)
[Tue Jun  8 18:54:41 2021] usb usb2-port1: Cannot enable. Maybe the USB cable is bad?
[Tue Jun  8 18:54:41 2021] usb usb2-port1: unable to enumerate USB device
```


## States

* OK if no emerg, alert, crit, or err messages are found in the kernel ring buffer (after filtering).
* CRIT (or the severity given by `--severity`) if any such messages are found.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

There is no perfdata.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
