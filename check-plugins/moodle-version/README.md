# Check moodle-version


## Overview

Checks whether the installed Moodle version is end-of-life (EOL) by comparing the local version against the endoflife.date API. Optionally alerts on available major, minor, or patch releases (each independently configurable).

**Important Notes:**

* Requires local file system access to the Moodle installation directory

**Data Collection:**

* Reads the installed Moodle version from `version.php` in the local Moodle installation directory (default: `/var/www/html/moodle`)
* Queries the endoflife.date API for the latest EOL and release information
* Caches API responses in a local SQLite database to reduce network calls


## Fact Sheet

| Fact | Value |
|----|---|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/moodle-version> |
| Nagios/Icinga Check Name              | `check_moodle_version` |
| Check Interval Recommendation         | Every day |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| Uses SQLite DBs                       | `$TEMP/linuxfabrik-lib-version.db` |


## Help

```text
usage: moodle-version [-h] [-V] [--always-ok] [--check-major] [--check-minor]
                      [--check-patch] [--insecure] [--no-proxy]
                      [--offset-eol OFFSET_EOL] [--path PATH]
                      [--timeout TIMEOUT]

Checks the installed Moodle version against the endoflife.date API and alerts
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
  --path PATH           Local path to your Moodle installation, typically
                        within your Webserver's Document Root. Default:
                        /var/www/html/moodle
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
```


## Usage Examples

```bash
./moodle-version --path /var/www/html/moodle
```

Output:

```text
Moodle v4.1.11 (EOL 2025-12-08 -30d, minor 4.4.1 available)
```


## States

* WARN if the installed version is EOL (or approaching EOL within the configured offset).
* Optional: WARN when a new major version is available (`--check-major`).
* Optional: WARN when a new minor version is available (`--check-minor`).
* Optional: WARN when a new patch version is available (`--check-patch`).
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| moodle-version | Number | Installed Moodle version as float. "4.1.11" becomes "4.111". |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
