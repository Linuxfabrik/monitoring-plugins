# Check apache-httpd-version


## Overview

Checks the installed Apache httpd version against the endoflife.date API and alerts if the version is end-of-life or if newer major, minor, or patch releases are available. By default, alerts 30 days before the official EOL date. The offset is configurable.

**Important Notes:**

* Runs on all systems where the Apache binary is named either `httpd` or `apache2`
* Must run on the Apache httpd server itself to detect the installed version

**Data Collection:**

* Detects the installed Apache httpd version by running `httpd -v` (RHEL) or `apache2 -v` (Debian-based systems)
* Queries the [endoflife.date API](https://endoflife.date/api/apache.json) to determine EOL status and available releases
* Caches the API response in a local SQLite database to reduce network calls


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/apache-httpd-version> |
| Nagios/Icinga Check Name              | `check_apache_httpd_version` |
| Check Interval Recommendation         | Every day |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| Uses State File                       | `$TEMP/linuxfabrik-lib-version.db` |


## Help

```text
usage: apache-httpd-version [-h] [-V] [--always-ok] [--check-major]
                            [--check-minor] [--check-patch] [--insecure]
                            [--no-proxy] [--offset-eol OFFSET_EOL]
                            [--timeout TIMEOUT]

Checks the installed Apache httpd version against the endoflife.date API and
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
./apache-httpd-version --offset-eol=-30
```

Output:

```text
Apache httpd v2.4.37 (EOL unknown, patch 2.4.57 available)
```


## States

* OK if the installed version is not EOL and no newer releases are flagged.
* WARN if the installed version is EOL (or will be within `--offset-eol` days, default: -30).
* WARN if `--check-major` is set and a newer major version is available.
* WARN if `--check-minor` is set and a newer minor version is available.
* WARN if `--check-patch` is set and a newer patch version is available.
* UNKNOWN if Apache httpd is not found.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| apache-httpd-version | Number | Installed Apache httpd version as float, e.g. "2.4.57" becomes "2.457". |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
