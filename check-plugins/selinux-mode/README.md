# Check selinux-mode

## Overview

Verifies that the current SELinux mode (enforcing, permissive, or disabled) matches the expected setting. Returns WARN if the actual mode differs from the desired one.

**Alerting Logic:**

* WARN if the current SELinux mode does not match the expected mode (default: enforcing)
* If SELinux is not in enforcing mode, the message "Make SELinux Enforcing Again." is appended as a reminder
* `--always-ok` suppresses all alerts and always returns OK

**Data Collection:**

* Executes `getenforce` to determine the current SELinux mode

**Compatibility:**

* Linux (distributions with SELinux support)


## Fact Sheet

| Fact | Value |
|----|---|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/selinux-mode> |
| Nagios/Icinga Check Name              | `check_selinux_mode` |
| Check Interval Recommendation         | Every 15 minutes |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |


## Help

```text
usage: selinux-mode [-h] [-V] [--always-ok]
                    [--mode {enforcing,permissive,disabled}]

Verifies that the current SELinux mode (enforcing, permissive, or disabled)
matches the expected setting. Returns WARN if the actual mode differs from the
desired one.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --mode {enforcing,permissive,disabled}
                        Expected SELinux mode, one of "enforcing",
                        "permissive" or "disabled" (case-insensitive).
                        Default: enforcing
```


## Usage Examples

```bash
./selinux-mode --mode permissive
```

Output:

```text
SELinux mode is "permissive", but supposed to be "enforcing".
Make SELinux Enforcing Again.
```


## States

* OK if the current SELinux mode matches the expected mode.
* WARN if the current SELinux mode does not match the expected mode.
* UNKNOWN if SELinux is not applicable to the system (e.g., `getenforce` is not available).
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

There is no perfdata.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
