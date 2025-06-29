# Check selinux-mode

## Overview

Checks the current mode of SELinux against a desired mode, and returns a warning on a non-match. If `--mode` is ommited, we suppose SELinux is in `Enforcing` mode.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/selinux-mode> |
| Check Interval Recommendation         | Every 15 minutes |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |


## Help

```text
usage: selinux-mode [-h] [-V] [--always-ok]
                    [--mode {enforcing,permissive,disabled}]

Checks the current mode of SELinux against a desired mode, and returns a
warning on a non-match.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --mode {enforcing,permissive,disabled}
                        The expected SELinux mode, one of "enforcing",
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

* WARN if selinux mode is in a state not as expected.


## Perfdata / Metrics

There is no perfdata.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
