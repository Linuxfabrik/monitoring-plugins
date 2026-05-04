# Check scanrootkit


## Overview

Scans the system for approximately 170 known rootkits by checking for their characteristic files, directories, and kernel symbols. New rootkit definitions can be added by dropping YAML files into the `assets` folder.

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

Scans the system for approximately 170 known rootkits by checking for their
characteristic files, directories, and kernel symbols. Each finding includes
the year the rootkit was first publicly disclosed when known. New rootkit
definitions can be added by dropping YAML files into the assets folder. Alerts
when rootkit indicators are found.

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
Found 4 rootkits. 2 possible rootkits found. [CRITICAL]

Rootkits:
* Diamorphine LKM (2013): diamorphine_init (Kernel Symbol)
* KBeast Rootkit (2012): /usr/_h4x_ (Dir)
* PUMAKIT LKM rootkit with Kitsune userland component (2024): /usr/share/zov_f/zov_latest (File)
* Reptile LKM rootkit (2018): /lib/udev/reptile (File)

Possible Rootkits:
* Components for Backdoors: /usr/info/.clib (File)
* Symbiote userland Linux rootkit (2022): /usr/include/certbot.h (File)
```

Each finding lists the rootkit name followed by the year it was first publicly disclosed in parentheses (when known), the matched indicator, and the indicator type (`File`, `Dir`, or `Kernel Symbol`). The summary line counts distinct rootkits, so two indicator hits for the same rootkit count once. Possible findings (signatures with `cl < 100`, e.g. broad component groups or modern rootkits whose paths could collide with legitimate software) are listed in a separate section and produce a WARN state instead of CRIT, regardless of `--severity`.


## States

* OK if no rootkit indicators are found.
* WARN or CRIT (depending on `--severity`, default: CRIT) if confirmed rootkit items are found.
* WARN if only possible rootkit items are found (confidence level below 100%), regardless of the selected severity.
* UNKNOWN if no rootkit definition files are found in the `assets` directory.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| rootkit_items | Number | The number of distinct rootkits with at least one confirmed indicator hit (`cl: 100`). The `max` field carries the total number of rootkit signatures the plugin currently scans for, so admins see the upper bound and can graph signature-database growth via the max field. |
| rootkit_possible | Number | The number of distinct rootkits with at least one possible indicator hit (`cl < 100`). Same `max` semantics as above. |


## Troubleshooting

`Python module "yaml" is not installed.`  
Install `pyyaml`: `pip install pyyaml` or `dnf install python3-pyyaml`.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
* Credits: [Rootkit Hunter Project](https://rkhunter.sourceforge.net/): We took the rootkit definitions and ported them into separate YAML files.
