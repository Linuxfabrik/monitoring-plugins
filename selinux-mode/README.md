# Check "selinux-mode" - Overview

Checks the current mode of SELinux against a desired mode, and returns a warning on a non-match. If `--mode` is ommited, we suppose SELinux is in `Enforcing` mode.

We recommend to run this check every 15 minutes.


# Installation and Usage

Requirements:
* `getenforce`

```bash
./selinux-mode
./selinux-mode --mode permissive
./selinux-mode --help
```


# States

* WARN if selinux mode is not as expected.


# Perfdata

There is no perfdata.


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.