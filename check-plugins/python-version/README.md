# Check python-version

## Overview

Checks the installed Python version against the endoflife.date API and alerts if the version is end-of-life or if newer major, minor, or patch releases are available. By default, alerts 30 days before the official EOL date. The offset is configurable.

**Alerting Logic:**

* WARN if the installed version is EOL (considering the configured offset)
* Optional: WARN when a new major, minor, or patch version is available (`--check-major`, `--check-minor`, `--check-patch`)
* `--always-ok` suppresses all alerts and always returns OK

**Data Collection:**

* Executes `python3 --version` locally to determine the installed version
* Queries the endoflife.date API to get the EOL date and latest available releases
* Caches the API response in a local SQLite database to avoid excessive requests

**Compatibility:**

* Linux only
* Must run on the server where Python is installed


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/python-version> |
| Nagios/Icinga Check Name              | `check_python_version` |
| Check Interval Recommendation         | Once a day |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |
| Uses SQLite DBs                       | `$TEMP/linuxfabrik-lib-version.db` |


## Help

```text
usage: python-version [-h] [-V] [--always-ok] [--check-major] [--check-minor]
                      [--check-patch] [--insecure] [--no-proxy]
                      [--offset-eol OFFSET_EOL] [--path PATH]
                      [--timeout TIMEOUT]

Checks the installed Python version against the endoflife.date API and alerts
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
  --path PATH           Local path to your Python binary. Default:
                        /usr/bin/python3
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
```


## Usage Examples

```bash
./python-version --offset-eol=-30
```

Output:

```text
Python v3.11.4 (EOL 2027-10-24 -30d, minor 3.12.0 available, patch 3.11.6 available)
```


## States

* OK if the installed version is not EOL (considering the configured offset).
* WARN if the installed version is EOL.
* Optional: WARN when a new major version is available.
* Optional: WARN when a new minor version is available.
* Optional: WARN when a new patch version is available.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| python-version | Number | Installed Python version as float. "3.11.4" becomes "3.114". |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
