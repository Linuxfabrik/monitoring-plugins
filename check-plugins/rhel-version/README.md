# Check rhel-version

## Overview

This plugin lets you track if RHEL (and compatible) is End-of-Life (EOL). To compare against the current/installed version of RHEL, the check has to run on the RHEL server itself.

This check plugin alerts n days before or after the EOL date is reached. Optionally, it can also alert on available major, minor or patch releases (each independently).

Hints:

* Also works for Alma, CentOS, CentOS Stream, Oracle, Rocky, etc., but reports the EOL date for RHEL.
* On Fedora Workstation or Fedora Server, use <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/fedora-version>.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/rhel-version> |
| Check Interval Recommendation         | Once a day |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |
| Uses SQLite DBs                       | `$TEMP/linuxfabrik-lib-version.db` |


## Help

```text
usage: rhel-version [-h] [-V] [--always-ok] [--check-major] [--check-minor]
                    [--check-patch] [--extended-support] [--insecure]
                    [--no-proxy] [--offset-eol OFFSET_EOL] [--timeout TIMEOUT]

Checks the installed Red Hat Enterprise Linux version against the
endoflife.date API and alerts if the version is end-of-life or if newer major,
minor, or patch releases are available. By default, alerts 30 days before the
official EOL date. The offset is configurable.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --check-major         Alert when a new major release is available, even if
                        the current version is not yet EOL. Example: running
                        v26 (not yet EOL) and v27 is available.
  --check-minor         Alert when a new major.minor release is available,
                        even if the current version is not yet EOL. Example:
                        running v26.2 (not yet EOL) and v26.3 is available.
  --check-patch         Alert when a new major.minor.patch release is
                        available, even if the current version is not yet EOL.
                        Example: running v26.2.7 (not yet EOL) and v26.2.8 is
                        available.
  --extended-support    Instead of "Maintenance Support" EOL (default), check
                        for "Extended Life Cycle Support" EOL.
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --no-proxy            Do not use a proxy.
  --offset-eol OFFSET_EOL
                        Alert n days before ("-30") or after an EOL date ("30"
                        or "+30"). Default: -30 days
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
```


## Usage Examples

```bash
./rhel-version --offset-eol=-30
```

Output:

```text
Rocky Linux 8.9 (Green Obsidian) (full support ended on 2024-05-31; EOL 2029-05-31 -30d, major 9.5 available, minor 8.10 available)
```


## States

* WARN if software is EOL
* Optional: WARN when new major version is available
* Optional: WARN when new minor version is available
* Optional: WARN when new patch version is available


## Perfdata / Metrics

| Name         | Type   | Description                                          |
|--------------|--------|------------------------------------------------------|
| rhel-version | Number | Installed RHEL version as float. "8.7" becomes "87". |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
