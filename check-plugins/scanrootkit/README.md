# Check scanrootkit


## Overview

Scans the system for numerous known rootkits by checking for their characteristic files, directories, and kernel symbols. Each finding includes the year the rootkit was first publicly disclosed when known. Additional rootkit definitions can be added by dropping YAML files into the `assets` folder. Alerts when rootkit indicators are found. Requires root or sudo.

**Important Notes:**

* This check is an indicator-of-compromise (IoC) scanner for *known* rootkits. It catches rootkits whose file paths, directory names or kernel symbol names appear in the signature list. It does not catch unknown rootkits, eBPF-based rootkits, in-memory-only implants, or rootkits that only replace existing binaries without creating new files. Treat it as one layer of defense-in-depth, not a complete anti-rootkit solution. Complement it with file integrity monitoring (AIDE, Tripwire), package verification (`rpm --verify`, `debsums`), kernel auditing (auditd), and runtime security (falco, tetragon).
* Rootkit YAML file structure (example from `assets/scanrootkit-kbeast.yml`):

    ```yaml
    name: 'KBeast Rootkit'
    files:
      - '/usr/_h4x_/ipsecs-kbeast-v1.ko'
      - '/usr/_h4x_/_h4x_bd'
      - '/usr/_h4x_/acctlog'
    dirs:
      - '/usr/_h4x_'
    ksyms:
      - 'h4x_delete_module'
      - 'h4x_getdents64'
      - 'h4x_kill'
    cl: 100
    ```

* `weak_paths` is optional and lists those `files` or `dirs` that the source names, but legitimate software might use too. They are reported as weak indicators (state WARN), the rest of the signature keeps its `cl`.
* `cl` is the confidence level in percent. Signatures with `cl < 100` are reported as weak indicators (state WARN). If `cl` is omitted, the signature is treated as 100% confident.
* Kernel symbol matching is exact per symbol (using `/proc/kallsyms`), so a signature like `is_invisible` will not accidentally match an unrelated legitimate symbol named `is_invisible_helper`.
* To test the whole alerting chain on a live host, create the harmless trigger file `/tmp/.cinik`. It matches two historic rkhunter signatures (CiNIK Worm and Slapper Worm), so the next check run reports CRIT (or WARN with `--severity=warn`). Remove the file afterwards. This does not work if the monitoring agent runs with systemd `PrivateTmp=yes`, because the agent then does not see the host's `/tmp`.

    ```bash
    touch /tmp/.cinik
    ```

    ```bash
    rm /tmp/.cinik
    ```

* Feel free to add more rootkit definitions by submitting a pull request.
* Inspired by the [Rootkit Hunter Project](https://rkhunter.sourceforge.net/), which has been inactive since 2018. All rkhunter rootkit definitions have been translated to YAML and made available with this check plugin.

**Data Collection:**

* Loads rootkit definitions from YAML files in the `assets` directory
* Checks for rootkit-specific files, UNIX sockets, named pipes (FIFOs) and directories on the filesystem. Device nodes do not count as file indicators. A symlink at an indicator path is reported as such and never followed, and indicators written as shell patterns (`/tmp/ss0-[0-9]...`) are expanded, as rkhunter does.
* Scans kernel symbols (`/proc/kallsyms` or `/proc/ksyms`) for rootkit indicators

**Extending the Signatures:**

Sources for new rootkit signatures: because rkhunter is no longer updated, file-path and kernel-symbol signatures for rootkits released after ~2018 have to be collected from current threat research. When extending the signature set, prefer sources that publish concrete on-disk indicators (full file paths, directory names, kernel module names, exported symbol names). Good starting points, in alphabetical order:

* [Aqua Nautilus](https://www.aquasec.com/blog/) - cloud-native and Linux threat research, frequent honeypot-based discoveries with file-path IoCs
* [CISA cybersecurity advisories](https://www.cisa.gov/news-events/cybersecurity-advisories) - joint IoC reports, often Linux-specific
* [Elastic Security Labs](https://www.elastic.co/security-labs) - Linux malware analyses with detailed indicator appendices
* [ESET welivesecurity](https://www.welivesecurity.com/) - Linux malware teardowns (Ebury, FontOnLake, Kobalos) typically include an IoC appendix
* [Intezer blog](https://intezer.com/blog/) - Linux threat analyses
* [Kaspersky Securelist](https://securelist.com/) - Symbiote, HiatusRAT and similar
* [MITRE ATT&CK T1014 Rootkit](https://attack.mitre.org/techniques/T1014/) and linked software entries
* [Sandfly Security blog](https://sandflysecurity.com/blog) - specializes in Linux forensics, regularly publishes file-path IoCs
* [Sysdig threat research](https://sysdig.com/blog/topic/threat-research/), [CrowdStrike](https://www.crowdstrike.com/en-us/blog/category/threat-intel-research/), [Mandiant](https://cloud.google.com/security/resources/insights) - mixed IoC quality, worth checking
* [Volexity blog](https://www.volexity.com/blog/) - APT and Linux implant analyses with concrete on-disk indicators

GitHub repositories complement the blogs: their commit history shows exactly what changed since the last review of the signature set. In alphabetical order:

* [elastic/protections-artifacts](https://github.com/elastic/protections-artifacts) - Elastic's YARA rules, including `yara/rules/Linux_Rootkit_*`; mostly strings rather than paths, but a reliable early indicator of new rootkit names
* [eset/malware-ioc](https://github.com/eset/malware-ioc) - the IoC appendices of the ESET welivesecurity reports as plain files
* [fkie-cad/linux-rootkit-iocs](https://github.com/fkie-cad/linux-rootkit-iocs) - Fraunhofer FKIE's file-path, string and network IoCs for 24 Linux rootkits, backed by a research paper
* [milabs/awesome-linux-rootkits](https://github.com/milabs/awesome-linux-rootkits) - curated list of Linux rootkits and their capabilities; no indicators, but useful to discover rootkit names worth researching
* [Neo23x0/signature-base](https://github.com/Neo23x0/signature-base) - YARA rules and `iocs/filename-iocs.txt` with file-name IoCs and their source; filter for Linux

Signatures should be strong enough to avoid false positives on a clean system. Prefer uncommon, rootkit-specific file paths (e.g. `/usr/_h4x_/`) over generic ones (`/tmp/.X11-unix`) and exact kernel symbol names over substrings. If the source names a path that legitimate software could use, which matters most for `/tmp`, `/var/tmp` and `/dev/shm`, keep it and list it in `weak_paths`. If a signature as a whole is only partially reliable, set `cl` below 100 so the plugin reports it as a weak indicator.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/scanrootkit> |
| Nagios/Icinga Check Name              | `check_scanrootkit` |
| Check Interval Recommendation         | Every 15 minutes |
| Can be called without parameters      | Yes |
| Runs on                               | Linux |
| Compiled for Windows                  | No |
| Requirements                          | User with higher permissions |
| 3rd Party Python modules              | `pyyaml` |


## Help

```text
usage: scanrootkit [-h] [-V] [--always-ok] [--no-perfdata]
                   [--severity {warn,crit}]

Scans the system for numerous known rootkits by checking for their
characteristic files, directories, and kernel symbols. Each finding includes
the year the rootkit was first publicly disclosed when known. Additional
rootkit definitions can be added by dropping YAML files into the assets
folder. Alerts when rootkit indicators are found. An indicator is evidence to
investigate, not proof of an infection. Indicators of signatures below full
confidence, paths that legitimate software might use and files a local user
could have created count as weak; weak indicators only warn. Requires root or
sudo.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --no-perfdata         Suppress the performance data section from the output.
                        The status message and the exit code are unaffected,
                        so alerting keeps working while trending data is
                        dropped.
  --severity {warn,crit}
                        Severity for alerts when rootkit indicators are found.
                        One of "warn" or "crit". Default: crit

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/scanrootkit/
```


## Usage Examples

```bash
./scanrootkit
```

Output:

```text
Found indicators of 4 rootkits. Found weak indicators of 2 rootkits. [CRITICAL]

Rootkit Indicators:
* Diamorphine LKM (2013): hacked_kill (Kernel Symbol)
* KBeast Rootkit (2012): /usr/_h4x_ (Dir)
* PUMAKIT LKM rootkit with Kitsune userland component (2024): /usr/share/zov_f/zov_latest (File)
* Reptile LKM rootkit (2018): /lib/udev/reptile (File)

Weak Rootkit Indicators:
* Components for Backdoors: /usr/info/.clib (File)
* Symbiote userland Linux rootkit (2022): /usr/include/certbot.h (File)
```

Each finding lists the rootkit name followed by the year it was first publicly disclosed in parentheses (when known), the matched indicator, and the indicator type (`File`, `Socket`, `FIFO`, `Symlink`, `Dir`, or `Kernel Symbol`). The summary line counts distinct rootkits, so two indicator hits for the same rootkit count once. An indicator is evidence to investigate, not proof of an infection: one match is enough, because signatures list the indicators of all known variants and attackers clean up after themselves.

Weak indicators are listed in a separate section and produce a WARN state instead of CRIT, regardless of `--severity`. An indicator is weak if its signature has `cl < 100` (e.g. broad component groups or modern rootkits whose paths could collide with legitimate software), if the signature lists it in `weak_paths`, or if a local user could have created it: it does not belong to root and lies in a directory anybody can write to, such as `/tmp`, or in one that belongs to a user. These hits are marked `not owned by root`. A root-owned file at the same path keeps the confidence of its signature.


## States

* OK if no rootkit indicators are found.
* WARN or CRIT (depending on `--severity`, default: CRIT) if rootkit indicators are found.
* WARN if only weak rootkit indicators are found (confidence level below 100%, a path that legitimate software might use, or a file a local user could have created), regardless of the selected severity.
* UNKNOWN if no rootkit definition files are found in the `assets` directory.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| rootkit_items | Number | The number of distinct rootkits with at least one indicator hit that is not weak. The `max` field carries the total number of rootkit signatures the plugin currently scans for, so admins see the upper bound and can graph signature-database growth via the max field. |
| rootkit_possible | Number | The number of distinct rootkits with weak indicator hits only. Same `max` semantics as above. |


## Troubleshooting

### A rootkit indicator on a host that looks clean

An indicator is a file with a known name, nothing more. Generic names such as `/tmp/.a` or `/tmp/update` are reported as weak indicators, because scripts use them as well.

1. See who owns the file, when it was created and what it contains: `stat /tmp/.a` and `file /tmp/.a`.
2. See if a process still has it open: `sudo lsof /tmp/.a`
3. Check where it came from: `sudo ausearch --file /tmp/.a` if auditd runs, the crontabs and the scripts of the owner otherwise.
4. Treat the host as compromised if the file is an executable you cannot explain, if a process you do not know holds it, or if the check reports further indicators of the same rootkit. Otherwise, remove the file, and fix the script that leaves it behind.

### `Python module "yaml" is not installed.`

Install `pyyaml`: `pip install pyyaml` or `dnf install python3-pyyaml`.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
* Credits: [Rootkit Hunter Project](https://rkhunter.sourceforge.net/): We took the rootkit definitions and ported them into separate YAML files.
