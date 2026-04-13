# Check scanrootkit


## Overview

Scans the system for approximately 100 known rootkits by checking for their characteristic files, directories, and kernel symbols. New rootkit definitions can be added by dropping YAML files into the `assets` folder.

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

* `cl` is the confidence level in percent. Signatures with `cl < 100` are reported as "possible" rootkit items (state WARN) instead of confirmed findings. If `cl` is omitted, the signature is treated as 100% confident.
* Kernel symbol matching is exact per symbol (using `/proc/kallsyms`), so a signature like `is_invisible` will not accidentally match an unrelated legitimate symbol named `is_invisible_helper`.
* Feel free to add more rootkit definitions by submitting a pull request.
* Inspired by the [Rootkit Hunter Project](https://rkhunter.sourceforge.net/), which has been inactive since 2018. All rkhunter rootkit definitions have been translated to YAML and made available with this check plugin.

**Note for maintainers - sources for new rootkit signatures:**

Because rkhunter is no longer updated, file-path and kernel-symbol signatures for rootkits released after ~2018 have to be collected from current threat research. When extending the signature set, prefer sources that publish concrete on-disk indicators (full file paths, directory names, kernel module names, exported symbol names). Good starting points, in alphabetical order:

* [CISA cybersecurity advisories](https://www.cisa.gov/news-events/cybersecurity-advisories) - joint IoC reports, often Linux-specific
* [ESET welivesecurity](https://www.welivesecurity.com/) - Linux malware teardowns (Ebury, FontOnLake, Kobalos) typically include an IoC appendix
* [Intezer blog](https://intezer.com/blog/) - Linux threat analyses
* [Kaspersky Securelist](https://securelist.com/) - Symbiote, HiatusRAT and similar
* [MITRE ATT&CK T1014 Rootkit](https://attack.mitre.org/techniques/T1014/) and linked software entries
* [Sandfly Security blog](https://sandflysecurity.com/blog) - specializes in Linux forensics, regularly publishes file-path IoCs
* [Sysdig threat research](https://sysdig.com/blog/topic/threat-research/), [CrowdStrike](https://www.crowdstrike.com/en-us/blog/category/threat-intel-research/), [Mandiant](https://cloud.google.com/security/resources/insights) - mixed IoC quality, worth checking

Signatures should be strong enough to avoid false positives on a clean system. Prefer uncommon, rootkit-specific file paths (e.g. `/usr/_h4x_/`) over generic ones (`/tmp/.X11-unix`) and exact kernel symbol names over substrings. If a signature is only partially reliable, set `cl` below 100 so the plugin reports it as "possible" instead of "confirmed".

**Data Collection:**

* Loads rootkit definitions from YAML files in the `assets` directory
* Checks for rootkit-specific files and directories on the filesystem
* Scans kernel symbols (`/proc/kallsyms` or `/proc/ksyms`) for rootkit indicators


## Fact Sheet

| Fact | Value |
|----|---|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/scanrootkit> |
| Nagios/Icinga Check Name              | `check_scanrootkit` |
| Check Interval Recommendation         | Every 15 minutes |
| Can be called without parameters      | Yes |
| Runs on                               | Linux |
| Compiled for Windows                  | No |
| 3rd Party Python modules              | `pyyaml` |


## Help

```text
usage: scanrootkit [-h] [-V] [--severity {warn,crit}]

Scans the system for approximately 100 known rootkits by checking for their
characteristic files, directories, and kernel modules. New rootkit definitions
can be added by dropping YAML files into the assets folder. Alerts when
rootkit indicators are found.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --severity {warn,crit}
                        Severity for alerts when rootkit indicators are found.
                        One of "warn" or "crit". Default: crit
```


## Usage Examples

```bash
./scanrootkit
```

Output:

```text
Found 1 rootkit item. 3 possible rootkit items found. [CRITICAL]
Rootkits:
* ENYE LKM v1.1, v1.2: /etc/.enyelkmHIDE^IT.ko (File)
Possible Rootkits:
* Components for Backdoors: /usr/info/.clib (File)
* Components for BillGates botnet: /etc/ksapd (File)
* Components for BillGates botnet: /etc/kysapd (File)
```


## States

* OK if no rootkit indicators are found.
* WARN or CRIT (depending on `--severity`, default: CRIT) if confirmed rootkit items are found.
* WARN if only possible rootkit items are found (confidence level below 100%), regardless of the selected severity.
* UNKNOWN if no rootkit definition files are found in the `assets` directory.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| rootkit_items | Number | The number of confirmed rootkit items found on the system. |
| rootkit_possible | Number | Number of possible rootkit items found on the system. |


## Troubleshooting

`Python module "yaml" is not installed.`  
Install `pyyaml`: `pip install pyyaml` or `dnf install python3-pyyaml`.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
* Credits: [Rootkit Hunter Project](https://rkhunter.sourceforge.net/): We took the rootkit definitions and ported them into separate YAML files.
