# Check mysql-version

## Overview

Checks the installed MySQL/MariaDB version against the endoflife.date API and alerts if the version is end-of-life or if newer major, minor, or patch releases are available. By default, alerts 30 days before the official EOL date. The offset is configurable.

**Alerting Logic:**

* WARN if the installed version has reached its EOL date (considering the configured offset)
* Optional: WARN when a new major version is available (`--check-major`)
* Optional: WARN when a new minor version is available (`--check-minor`)
* Optional: WARN when a new patch version is available (`--check-patch`)

**Data Collection:**

* Detects the installed version by running `mysqld --version`, `mariadb --version`, or `mysql --version`
* Queries the [endoflife.date API](https://endoflife.date/) for MySQL or MariaDB lifecycle data
* Caches the API response in a local SQLite database to reduce API calls

**Compatibility:**

* Must run on the MySQL/MariaDB server itself to detect the installed version


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-version> |
| Nagios/Icinga Check Name              | `check_mysql_version` |
| Check Interval Recommendation         | Once a day |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |
| Uses SQLite DBs                       | `$TEMP/linuxfabrik-lib-version.db` |


## Help

```text
usage: mysql-version [-h] [-V] [--always-ok] [--check-major] [--check-minor]
                     [--check-patch] [--insecure] [--no-proxy]
                     [--offset-eol OFFSET_EOL] [--timeout TIMEOUT]

Checks the installed MySQL/MariaDB version against the endoflife.date API and
alerts if the version is end-of-life or if newer major, minor, or patch
releases are available. By default, alerts 30 days before the official EOL
date. The offset is configurable.

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
./mysql-version --offset-eol=-30
```

Output:

```text
MariaDB v10.5.21 (EOL 2025-06-24 -30d, major 11.1.2 available, minor 10.11.5 available, patch 10.5.22 available)
```


## States

* OK if the installed version is not EOL and no newer versions are requested to be checked.
* WARN if the software is EOL.
* Optional: WARN when a new major version is available.
* Optional: WARN when a new minor version is available.
* Optional: WARN when a new patch version is available.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| mysql-version | Number | Installed MySQL/MariaDB version as float. "10.6.12" becomes "10.612". |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
