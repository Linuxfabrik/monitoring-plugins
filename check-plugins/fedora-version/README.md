# Check fedora-version


## Overview

Checks the installed Fedora version against the endoflife.date API and alerts if the version is end-of-life or if newer major, minor, or patch releases are available. By default, alerts 30 days before the official EOL date. The offset is configurable.

**Important Notes:**

* The `--offset-eol` parameter accepts negative values (e.g. `-30`) to alert *before* the EOL date, and positive values (e.g. `30` or `+30`) to alert *after* the EOL date
* The `--check-major`, `--check-minor`, and `--check-patch` options each independently trigger a WARN when a newer release of the respective type is available, even if the installed version is not yet EOL

**Data Collection:**

* Reads the installed Fedora version from the local system via `/etc/os-release`
* Queries the [endoflife.date](https://endoflife.date) API to determine the EOL date and available releases
* Caches the API response in a local SQLite database to avoid repeated network requests


## Fact Sheet

| Fact | Value |
|----|------|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/fedora-version> |
| Nagios/Icinga Check Name              | `check_fedora_version` |
| Check Interval Recommendation         | Every day |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| Uses State File                       | `$TEMP/linuxfabrik-lib-version.db` |


## Help

```text
usage: fedora-version [-h] [-V] [--always-ok] [--check-major] [--check-minor]
                      [--check-patch] [--insecure] [--no-proxy]
                      [--offset-eol OFFSET_EOL] [--timeout TIMEOUT]

Checks the installed Fedora version against the endoflife.date API and alerts
if the version is end-of-life or if newer major, minor, or patch releases are
available. By default, alerts 30 days before the official EOL date. The offset
is configurable.

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
./fedora-version --offset-eol=-30
```

Output:

```text
Fedora Linux 37 (Workstation Edition) (EOL 2023-12-15 -30d, major 38 available)
```


## States

* WARN if the installed Fedora version is EOL (respecting `--offset-eol`, default: -30 days).
* WARN if `--check-major` is set and a newer major release is available.
* WARN if `--check-minor` is set and a newer minor release is available.
* WARN if `--check-patch` is set and a newer patch release is available.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| fedora-version | Number | Installed Fedora version as a float. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
