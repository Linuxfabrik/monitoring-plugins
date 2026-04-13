# Check composer-version


## Overview

Checks the installed Composer version against the endoflife.date API and alerts if the version is end-of-life or if newer major, minor, or patch releases are available. By default, alerts 30 days before the official EOL date. The offset is configurable.

**Important Notes:**

* The check must run on the machine where Composer is installed
* Optionally alerts on available major, minor, or patch releases independently of EOL status via `--check-major`, `--check-minor`, and `--check-patch`

**Data Collection:**

* Runs `composer --version` at the configured `--path` (default: `/usr/bin/composer`) to determine the installed version
* Queries the endoflife.date API (`https://endoflife.date/api/composer.json`) for lifecycle data
* Caches API responses locally in an SQLite database to reduce network requests


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/composer-version> |
| Nagios/Icinga Check Name              | `check_composer_version` |
| Check Interval Recommendation         | Every day |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| Uses State File                       | `$TEMP/linuxfabrik-lib-version.db` |


## Help

```text
usage: composer-version [-h] [-V] [--always-ok] [--check-major]
                        [--check-minor] [--check-patch] [--insecure]
                        [--no-proxy] [--offset-eol OFFSET_EOL] [--path PATH]
                        [--test TEST] [--timeout TIMEOUT]

Checks the installed Composer version against the endoflife.date API and
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
  --path PATH           Local path to your composer binary. Default:
                        /usr/bin/composer
  --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                        stderr-file,expected-retc".
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
```


## Usage Examples

```bash
./composer-version --offset-eol=-30
```

Output:

```text
composer v2.6.4 (EOL 2024-02-08 -30d [WARNING], minor 2.7.2 available, patch 2.6.6 available)
```


## States

* OK if the installed version is not EOL and no newer releases are flagged.
* WARN if the installed version is EOL (including the `--offset-eol` window, default: 30 days before EOL date).
* WARN if `--check-major` is set and a newer major version is available.
* WARN if `--check-minor` is set and a newer minor version is available.
* WARN if `--check-patch` is set and a newer patch version is available.
* UNKNOWN if the Composer binary is not found at `--path`.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| composer-version | Number | Installed Composer version as float. For example, "2.7.1" becomes "2.71". |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
