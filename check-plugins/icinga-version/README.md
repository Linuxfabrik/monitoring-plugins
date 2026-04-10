# Check icinga-version


## Overview

Checks the installed Icinga version against the endoflife.date API and alerts if the version is end-of-life or if newer major, minor, or patch releases are available. By default, alerts 30 days before the official EOL date. The offset is configurable.

**Important Notes:**

* Must run on the host where the Icinga2 daemon is installed
* The check returns UNKNOWN if the `icinga2` binary is not found on the system

**Data Collection:**

* Runs `icinga2 --version` locally to determine the installed version
* Queries the endoflife.date API (`https://endoflife.date/api/icinga.json`) for EOL and release information
* Caches API responses in a SQLite database to avoid repeated requests

**Compatibility:**

* Cross-platform


## Fact Sheet

| Fact | Value |
|----|------|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/icinga-version> |
| Nagios/Icinga Check Name              | `check_icinga_version` |
| Check Interval Recommendation         | Once a day |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |
| Uses State File                       | `$TEMP/linuxfabrik-lib-version.db` |


## Help

```text
usage: icinga-version [-h] [-V] [--always-ok] [--check-major] [--check-minor]
                      [--check-patch] [--insecure] [--no-proxy]
                      [--offset-eol OFFSET_EOL] [--timeout TIMEOUT]

Checks the installed Icinga version against the endoflife.date API and alerts
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
./icinga-version --offset-eol=-30
```

Output:

```text
Icinga v2.14.6 (EOL unknown)
```


## States

* OK if the installed version is not EOL and no newer version alerts are configured.
* WARN if the installed version is EOL (or will be within `--offset-eol` days).
* WARN if `--check-major` is set and a newer major version is available.
* WARN if `--check-minor` is set and a newer minor version is available.
* WARN if `--check-patch` is set and a newer patch version is available.
* UNKNOWN if `icinga2` is not found on the system.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| icinga-version | Number | Installed Icinga version as float. For example, "2.14.6" becomes "2.146". |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
