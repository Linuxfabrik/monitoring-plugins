# Check scanrootkit

## Overview

Scans the system for approximately 100 known rootkits by checking for their characteristic files, directories, and kernel symbols. New rootkit definitions can be added by dropping YAML files into the `assets` folder. Additionally performs in-depth checks for the Suckit rootkit (link count of `/sbin/init` and hidden file detection).

**Important Notes:**

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

* Feel free to add more rootkit definitions by submitting a pull request
* Inspired by the [Rootkit Hunter Project](https://rkhunter.sourceforge.net/), which has been inactive since 2018. All rkhunter rootkit definitions have been translated to YAML and made available with this check plugin.

**Data Collection:**

* Loads rootkit definitions from YAML files in the `assets` directory
* Checks for rootkit-specific files and directories on the filesystem
* Scans kernel symbols (`/proc/kallsyms` or `/proc/ksyms`) for rootkit indicators
* Performs extra checks for Suckit rootkit (link count of `/sbin/init`, hidden file detection via `.xrk` and `.mem` suffixes)

**Compatibility:**

* Linux



## Fact Sheet

| Fact | Value |
|----|---|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/scanrootkit> |
| Nagios/Icinga Check Name              | `check_scanrootkit` |
| Check Interval Recommendation         | Every 15 minutes |
| Can be called without parameters      | Yes |
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
Found 1 rootkit item and 0 extra items. 3 possible rootkit items found. 
Rootkits:
* ENYE LKM v1.1, v1.2: /etc/.enyelkmHIDE^IT.ko (File)
Possible Rootkits:
* Components for Backdoors: /usr/info/.clib (File)
* Components for BillGates botnet: /etc/ksapd (File)
* Components for BillGates botnet: /etc/kysapd (File)
```


## States

* OK if no rootkit indicators are found.
* WARN or CRIT (depending on `--severity`, default: CRIT) if confirmed rootkit items or in-depth scan items are found.
* WARN if only possible rootkit items are found (confidence level below 100%), regardless of the selected severity.
* UNKNOWN if no rootkit definition files are found in the `assets` directory.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| rootkit_extra | Number | Number of rootkit items found by the in-depth scan. |
| rootkit_items | Number | The number of confirmed rootkit items found on the system. |
| rootkit_possible | Number | Number of possible rootkit items found on the system. |


## Troubleshooting

`Python module "yaml" is not installed.`  
Install `pyyaml`: `pip install pyyaml` or `dnf install python3-pyyaml`.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
* Credits: [Rootkit Hunter Project](https://rkhunter.sourceforge.net/): We took the rootkit definitions and ported them into separate YAML files.
