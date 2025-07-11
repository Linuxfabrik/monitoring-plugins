# Check scanrootkit

## Overview

This monitoring plugin scans for round about 100 rootkits, from "55808 Trojan - Variant A" to "ZK Rootkit". New rootkit definitions can be easily added by dropping a <span class="title-ref">scanrootkit-NAME</span> YAML file into the <span class="title-ref">assets</span> folder.

Rootkit YAML file structure, example taken from `assets/scanrootkit-kbeast.yml`:

```yaml
# human-readable name of the rootkit
name: 'KBeast Rootkit'
files:
  # list of files that identify the rootkit
  - '/usr/_h4x_/ipsecs-kbeast-v1.ko'
  - '/usr/_h4x_/_h4x_bd'
  - '/usr/_h4x_/acctlog'
dirs:
  # list of directories that identify the rootkit
  - '/usr/_h4x_'
ksyms:
  # list of items in the kernel symbols file that identify the rootkit
  - 'h4x_delete_module'
  - 'h4x_getdents64'
  - 'h4x_kill'
  - 'h4x_open'
  - 'h4x_read'
  - 'h4x_rename'
  - 'h4x_rmdir'
  - 'h4x_tcp4_seq_show'
  - 'h4x_write'
# optional "confidence level". if omitted, cl is 100. 100 means 100%. anything below 100%
# confidence level currently just raises a warning.
cl: 100
```

Feel free to add more rootkit definitions by submitting a pull request.

Credits:

* This check plugin is heavily inspired by the [Rootkit Hunter Project](https://rkhunter.sourceforge.net/), which unfortunately seems to be inactive since 2018. :-( Therefore, we have taken all the rkhunter rootkit definitions, translated them to YAML and made them available with this check plugin.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/scanrootkit> |
| Check Interval Recommendation         | Every 15 minutes |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |
| 3rd Party Python modules              | `pyyaml` |


## Help

```text
usage: scanrootkit [-h] [-V] [--severity {warn,crit}]

This monitoring plugin scans for round about 100 rootkits, from "55808 Trojan
- Variant A" to "ZK Rootkit". New rootkit definitions can easily be added by
dropping a `scanrootkit-<name>` YAML file into the `assets` folder.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --severity {warn,crit}
                        Severity for alerts. One of "warn" or "crit". Default:
                        crit
```


## Usage Examples

```bash
./scanrootkit
```

Output:

```text
Found 1 rootkit item and 0 extra items. 3 possible rootkit items found. 
Rootkits:
* ENYE LKM v1.1, v1.2: /etc/.enyelkmHIDE^IT.ko (File)
Possible Rootkits:
* Components for Backdoors: /usr/info/.clib (File)
* Components for BillGates botnet: /etc/ksapd (File)
* Components for BillGates botnet: /etc/kysapd (File)
```


## States

* WARN or CRIT if rootkit items are found, depending on the severity (default: CRIT)
* WARN if only possible rootkit items are found, regardless of the selected severity.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| rootkit_items | Number | The number of rootkit items found on the system. |
| rootkit_extra | Number | Number of rootkit items found by a specific deep scan. |
| rootkit_possible | Number | Number of possible rootkit items found on the system. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
* Credits: [Rootkit Hunter Project](https://rkhunter.sourceforge.net/): We took the rootkit definitions and ported them into separate YAML files.
