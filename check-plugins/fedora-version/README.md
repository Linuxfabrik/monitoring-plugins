# Check fedora-version

## Overview

This plugin lets you track if Fedora is End-of-Life (EOL). To compare against the current/installed version of Fedora, the check has to run on the Fedora server itself.

This check plugin alerts n days before or after the EOL date is reached. Optionally, it can also alert on available major, minor or patch releases (each independently).


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/fedora-version> |
| Check Interval Recommendation         | Once a day |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |
| Uses SQLite DBs                       | `$TEMP/linuxfabrik-lib-version.db` |


## Help

```text
usage: fedora-version [-h] [-V] [--always-ok] [--check-major] [--check-minor]
                      [--check-patch] [--insecure] [--no-proxy]
                      [--offset-eol OFFSET_EOL] [--timeout TIMEOUT]

Tracks if Fedora is EOL.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --check-major         Alert me when there is a new major release available,
                        even if the current version of my product is not EOL.
                        Example: Notify when I run v26 (not yet EOL) and v27
                        is available. Default: False
  --check-minor         Alert me when there is a new major.minor release
                        available, even if the current version of my product
                        is not EOL. Example: Notify when I run v26.2 (not yet
                        EOL) and v26.3 is available. Default: False
  --check-patch         Alert me when there is a new major.minor.patch release
                        available, even if the current version of my product
                        is not EOL. Example: Notify when I run v26.2.7 (not
                        yet EOL) and v26.2.8 is available. Default: False
  --insecure            This option explicitly allows to perform "insecure"
                        SSL connections. Default: False
  --no-proxy            Do not use a proxy. Default: False
  --offset-eol OFFSET_EOL
                        Alert me n days before ("-30") or after an EOL date
                        ("30" or "+30"). Default: -30 days
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
```


## Usage Examples

```bash
./fedora-version --offset-eol=-30
```

Output:

```text
Fedora Linux 37 (Workstation Edition) (EOL 2023-12-15 -30d, major 38 available)
```


## States

* WARN if software is EOL
* Optional: WARN when new major version is available
* Optional: WARN when new minor version is available
* Optional: WARN when new patch version is available


## Perfdata / Metrics

| Name           | Type   | Description               |
|----------------|--------|---------------------------|
| fedora-version | Number | Installed Fedora version. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
