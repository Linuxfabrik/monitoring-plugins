# Check cpu-vulnerabilities


## Overview

Reports which of the CPU vulnerabilities the kernel knows about are left without a mitigation on this host. The kernel publishes its own verdict per vulnerability, so the check reports what the running kernel, the microcode and the boot parameters together actually achieve, and not what the CPU model would allow. This works in a virtual machine as well, where the answer additionally depends on what the hypervisor hands through. A vulnerability the kernel cannot decide on is reported separately and does not alert by default, because a guest regularly cannot see what its host does; raise `--unknown-severity` to flag it where the answer is expected. Alerts when a vulnerability the CPU is affected by has no mitigation in effect.

**What the kernel reports:**

The kernel keeps one file per vulnerability, named after its code name (`meltdown`, `spectre_v2`, `mds`, `retbleed` and so on), and writes a line into each that says where this machine stands. There are four verdicts:

| Verdict | Meaning |
|----|----|
| `Not affected` | This CPU does not have the flaw. |
| `Mitigation: <how>` | It has it, and something is holding it off. The text names what. |
| `Vulnerable[: <why>]` | It has it and nothing is holding it off. The text names what is missing, most often the microcode. |
| `Unknown[: <why>]` | The kernel cannot decide. Practically always a guest whose answer belongs to its hypervisor. |

Two files word their verdict differently, and the check reads both. `itlb_multihit` speaks for the KVM side only and puts the component in front, so it reports `KVM: Vulnerable` or `KVM: Mitigation: VMX unsupported`; on a kernel built without KVM support it reports `Processor vulnerable` instead.

**Important Notes:**

* **The verdict is the first word of the line, never a word somewhere in it.** Several files append markers that describe a residual risk *inside* an applied mitigation, for example `; SMT vulnerable`, `; BHI: Vulnerable` or `; PBRSB-eIBRS: Vulnerable`. A host reporting `Mitigation: Enhanced / Automatic IBRS; IBPB: conditional; BHI: Vulnerable` is mitigated in the kernel's own judgement, and a check that greps for the word "Vulnerable" calls it the opposite. The full line is in the output, so the residual markers stay visible to anyone reading it.
* **Two states contradict their own prefix, and both read as vulnerable.** Booted with `indirect_target_selection=vmexit` the kernel writes `Mitigation: Vulnerable, KVM: Not affected` into `indirect_target_selection`; its own documentation calls that state "System is vulnerable to intra-mode BTI, but not affected by eIBRS guest/host isolation", so only the guests are covered and the host is not. And the kernel documentation lists `Mitigation: None` for `spectre_v2` and explains it as "Vulnerable, no mitigation", although no kernel from 4.15 to 7.1 actually writes it. These are the only two places where the check does not follow the leading word.
* **In a virtual machine the answer is only half the truth.** A guest sees the CPU model and the microcode its hypervisor hands through, and nothing of what the hypervisor itself does. That is why `srbds` and `gather_data_sampling` report `Unknown: Dependent on hypervisor status` on an affected CPU under a hypervisor. Run the check on the hypervisor as well; that host is the one that can answer.
* **`Vulnerable: No microcode` is often not the administrator's fault.** The vendor may never have shipped microcode for that CPU generation. Where nothing can be done about it, silence that one vulnerability with `--ignore` instead of switching the whole check off, so the rest keeps alerting.
* **The check is about posture, not about traffic.** Its result changes on a reboot, a microcode update, a kernel update or a change to the kernel command line, and at no other time, which is why the Director template runs it once a day.
* **Every vulnerability is always listed**, with the kernel's own wording, below the summary line. How many there are is a property of the kernel, not of the host: a 7.1 kernel publishes nineteen entries, the 4.18 kernel of RHEL 8 fifteen. The check reads whatever is there, so a flaw that gets a name tomorrow is covered by a kernel update alone.
* Related checks: `about-me` reports what the machine is, `rpm-updates` and `deb-updates` whether the kernel and microcode packages are current, and `needs-restarting` whether a reboot is still pending after they were installed.

**Data Collection:**

* Reads every file below `/sys/devices/system/cpu/vulnerabilities`
* Reads the verdict from the beginning of each line and never from a substring
* Reads whatever code names the running kernel publishes instead of a built-in list
* Needs no root and no `sudo`


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/cpu-vulnerabilities> |
| Nagios/Icinga Check Name              | `check_cpu_vulnerabilities` |
| Check Interval Recommendation         | Every day |
| Can be called without parameters      | Yes |
| Runs on                               | Linux |
| Compiled for Windows                  | No |


## Help

```text
usage: cpu-vulnerabilities [-h] [-V] [--always-ok] [--ignore IGNORE]
                           [--match MATCH]
                           [--no-match-severity {ok,warn,crit,unknown}]
                           [--no-perfdata] [--severity {ok,warn,crit,unknown}]
                           [--unknown-severity {ok,warn,crit,unknown}]

Reports which of the CPU vulnerabilities the kernel knows about are left
without a mitigation on this host. The kernel publishes its own verdict per
vulnerability, so the check reports what the running kernel, the microcode and
the boot parameters together actually achieve, and not what the CPU model
would allow. This works in a virtual machine as well, where the answer
additionally depends on what the hypervisor hands through. A vulnerability the
kernel cannot decide on is reported separately and does not alert by default,
because a guest regularly cannot see what its host does; raise
--unknown-severity to flag it where the answer is expected. Alerts when a
vulnerability the CPU is affected by has no mitigation in effect.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
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
  --severity {ok,warn,crit,unknown}
                        Severity for alerting. Applies to a vulnerability the
                        CPU is affected by that has no mitigation in effect.
                        Default: warn
  --unknown-severity {ok,warn,crit,unknown}
                        State to report for a vulnerability whose state cannot
                        be determined, and for a kernel that publishes no
                        vulnerability information at all. A guest sees only
                        what its hypervisor hands through and regularly cannot
                        decide, which is why this defaults to not alerting.
                        Default: ok

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/cpu-vulnerabilities/
```


## Usage Examples

```bash
./cpu-vulnerabilities
```

Output on a host where everything the CPU is affected by is held off:

```text
No CPU vulnerability is left without a mitigation. 4 mitigated, 15 not affected.
```

Output on a virtual machine on an older Intel host, without a current microcode and with `nx_huge_pages` switched off on the hypervisor:

```text
5 of 19 CPU vulnerabilities have no mitigation in effect: itlb_multihit, mds, mmio_stale_data, retbleed, spec_store_bypass.
2 CPU vulnerabilities the kernel could not decide on: gather_data_sampling, srbds.
Install the current microcode package, rebuild the initial ramdisk and reboot, run a current kernel, and check whether the kernel command line switches mitigations off (`mitigations=off`, `nopti`, `nospectre_v2` and the like).
On a virtual machine the guest sees only the CPU features and the microcode its hypervisor hands through, so run this check on the hypervisor as well.
```

The table below the summary lists every vulnerability with the kernel's own words, which is where the residual markers inside an applied mitigation become visible:

```text
No CPU vulnerability is left without a mitigation. 4 mitigated, 15 not affected.

Vulnerability             ! Kernel Report                                                                                       ! State
--------------------------+-----------------------------------------------------------------------------------------------------+-------------
gather_data_sampling      ! Not affected                                                                                        ! not affected
ghostwrite                ! Not affected                                                                                        ! not affected
indirect_target_selection ! Not affected                                                                                        ! not affected
itlb_multihit             ! Not affected                                                                                        ! not affected
l1tf                      ! Not affected                                                                                        ! not affected
mds                       ! Not affected                                                                                        ! not affected
meltdown                  ! Not affected                                                                                        ! not affected
mmio_stale_data           ! Not affected                                                                                        ! not affected
old_microcode             ! Not affected                                                                                        ! not affected
reg_file_data_sampling    ! Not affected                                                                                        ! not affected
retbleed                  ! Not affected                                                                                        ! not affected
spec_rstack_overflow      ! Not affected                                                                                        ! not affected
spec_store_bypass         ! Mitigation: Speculative Store Bypass disabled via prctl                                             ! mitigated
spectre_v1                ! Mitigation: usercopy/swapgs barriers and __user pointer sanitization                                ! mitigated
spectre_v2                ! Mitigation: Enhanced / Automatic IBRS; IBPB: conditional; PBRSB-eIBRS: Not affected; BHI: BHI_DIS_S ! mitigated
srbds                     ! Not affected                                                                                        ! not affected
tsa                       ! Not affected                                                                                        ! not affected
tsx_async_abort           ! Not affected                                                                                        ! not affected
vmscape                   ! Mitigation: IBPB before exit to userspace                                                           ! mitigated
```

Accept the one vulnerability nobody can do anything about on this hardware and keep alerting on the rest:

```bash
./cpu-vulnerabilities --ignore='^srbds$'
```

On a host where an unmitigated CPU is a reason to act at night:

```bash
./cpu-vulnerabilities --severity=crit
```

On a hypervisor, where a verdict the kernel cannot reach is worth looking into rather than accepting:

```bash
./cpu-vulnerabilities --unknown-severity=warn
```


## States

* OK if every vulnerability the CPU is affected by has a mitigation in effect, and everything else is reported as not affected.
* WARN if at least one vulnerability the CPU is affected by has no mitigation in effect. `--severity` lowers that to `ok` or raises it to `crit` or `unknown`.
* OK with an explanation if the kernel cannot decide on a vulnerability, or reports it in wording this check does not know. `--unknown-severity` raises that to `warn`, `crit` or `unknown`.
* OK with an explanation if the kernel publishes no vulnerability information at all, which means it was built without `CONFIG_GENERIC_CPU_VULNERABILITIES`. `--unknown-severity` applies here as well.
* OK if `--match` and `--ignore` leave nothing to check. `--no-match-severity` raises that.
* UNKNOWN if `--match` or `--ignore` is not a valid Python regular expression.
* UNKNOWN if the check does not run on Linux.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

All values are counts of vulnerabilities after `--match` and `--ignore` have been applied, so silencing one with `--ignore` takes it out of the graph as well.

| Name | Type | Description |
|----|----|----|
| checked      | Number | Vulnerabilities the kernel publishes and the filters kept. The sum of the four below. |
| mitigated    | Number | The CPU is affected and something is holding the vulnerability off. |
| not_affected | Number | The CPU does not have the flaw. |
| unknown      | Number | The kernel cannot decide, or words its verdict in a way this check does not know. |
| vulnerable   | Number | The CPU is affected and nothing is holding the vulnerability off. This is the value the check alerts on. |


## Troubleshooting

### A vulnerability has no mitigation in effect

Work through the four things that decide the answer, in this order.

1. Install the current microcode and reboot. Most `Vulnerable: No microcode`, `Vulnerable: Safe RET, no microcode` and `Vulnerable: Clear CPU buffers attempted, no microcode` lines disappear with it. The package differs per vendor and per distribution:

    ```bash
    dnf install microcode_ctl          # Red Hat family, Intel
    dnf install linux-firmware         # RHEL, Rocky and rebuilds, AMD
    dnf install amd-ucode-firmware     # Fedora, AMD
    apt install intel-microcode        # Debian family, Intel
    apt install amd64-microcode        # Debian family, AMD
    reboot
    ```

    **On an AMD host in the Red Hat family, installing the package is not enough.** The processor takes its microcode from the initial ramdisk before anything else runs, and dracut builds that with `early_microcode="yes"` by default, copying `/lib/firmware/amd-ucode` into the image. `microcode_ctl` regenerates the ramdisk itself after an update, but `linux-firmware`, which carries the AMD microcode there, does not. Regenerate it by hand, otherwise the reboot comes up with the old microcode and the check keeps reporting the same thing:

    ```bash
    dracut --force
    reboot
    ```

    Add `--regenerate-all` to cover every installed kernel rather than only the running one.

    On Debian both packages sit in the `non-free-firmware` component, which is not enabled on a minimal installation. Where `apt` claims the package does not exist, add that component to `/etc/apt/sources.list.d/debian.sources` and run `apt update` first. Both packages rebuild the initial ramdisk on their own.

2. Run a current kernel. A mitigation that does not exist in the running kernel cannot be in effect, however new the microcode is.

    ```bash
    uname --kernel-release
    ```

3. Read the kernel command line. A single `mitigations=off` switches every mitigation off at once, and the per-vulnerability switches (`nopti`, `nospectre_v1`, `nospectre_v2`, `nospec_store_bypass_disable`, `mds=off`, `tsx_async_abort=off`, `no_stf_barrier` and their relatives) do it one at a time. They frequently arrive as a performance tweak somebody applied years ago and nobody removed.

    ```bash
    cat /proc/cmdline
    ```

    Remove what you find and reboot:

    ```bash
    grubby --update-kernel=ALL --remove-args="mitigations=off"    # Red Hat family
    reboot
    ```

4. On a virtual machine, repeat all of the above on the hypervisor. The guest gets the CPU features and the microcode the hypervisor hands it, so a guest cannot mitigate what its host does not expose. A CPU model pinned for live migration (`Nehalem`, `Westmere`, `Skylake-Client` and the like) hides the feature bits several mitigations need.

Where the answer is that this hardware will never get a mitigation, keep the rest of the check alive and silence the one entry:

```bash
./cpu-vulnerabilities --ignore='^srbds$'
```

### `Unknown: Dependent on hypervisor status`

The CPU is affected and the mitigation lives outside this machine, so the guest kernel refuses to guess. `srbds` and `gather_data_sampling` report this on an affected Intel CPU under any hypervisor.

Run the same check on the hypervisor. That host has the microcode, sees the real CPU and gives a real verdict:

```bash
./cpu-vulnerabilities
```

The guest cannot be fixed from inside; a hypervisor that is clean makes the guest safe without changing what the guest reports.

### `This kernel publishes no CPU vulnerability information`

The kernel was built without `CONFIG_GENERIC_CPU_VULNERABILITIES`, so it created no `/sys/devices/system/cpu/vulnerabilities` at all. Every distribution kernel on x86, arm64 and powerpc has it, so this points at a self-built or an embedded kernel. Read what the running kernel was built with:

```bash
grep CONFIG_GENERIC_CPU_VULNERABILITIES /boot/config-$(uname --kernel-release)
```

Where the file is not shipped, the same setting is readable through `/proc/config.gz` on a kernel built with `CONFIG_IKCONFIG_PROC`:

```bash
zgrep CONFIG_GENERIC_CPU_VULNERABILITIES /proc/config.gz
```

### `reported in wording this check does not know`

The kernel wrote a verdict that starts with none of the four words the interface has used since it was introduced. No verdict is derived from it, because guessing one would be the wrong kind of answer for a security property, and the raw line is printed instead. Please open an issue with that line so the check learns the wording.

### The output says mitigated although the line contains "Vulnerable"

Correct and not a defect. A mitigation line may end in `; SMT vulnerable`, `; BHI: Vulnerable` or `; PBRSB-eIBRS: Vulnerable`, and each of those names a residual risk inside a mitigation that is in effect, not a missing mitigation. The kernel's verdict for the file is its first word, and that is what this check reports.

The most common of them, `; SMT vulnerable`, says that the mitigation covers everything except what a sibling hyperthread can reach. Where that matters, the answer is to switch simultaneous multithreading off, which costs throughput on every workload that used those siblings:

```bash
cat /sys/devices/system/cpu/smt/control
echo off > /sys/devices/system/cpu/smt/control
```

The file answers `on`, `off`, `forceoff`, `notsupported` or `notimplemented`, and rejects a write in the last three states. Make the change survive a reboot with `nosmt` on the kernel command line.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
