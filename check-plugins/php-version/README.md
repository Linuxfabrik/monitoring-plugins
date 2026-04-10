# Check php-version

## Overview

Checks the installed PHP version against the endoflife.date API and alerts if the version is end-of-life or if newer major, minor, or patch releases are available. By default, alerts 30 days before the official EOL date. The offset is configurable.

**Data Collection:**

* Executes `php --version` locally to determine the installed version
* Queries the endoflife.date API to get the EOL date and latest available releases
* Caches the API response in a local SQLite database to avoid excessive requests

**Compatibility:**

* Linux only
* Must run on the PHP server itself


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/php-version> |
| Nagios/Icinga Check Name              | `check_php_version` |
| Check Interval Recommendation         | Once a day |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |
| Uses SQLite DBs                       | `$TEMP/linuxfabrik-lib-version.db` |


## Help

```text
usage: php-version [-h] [-V] [--always-ok] [--check-major] [--check-minor]
                   [--check-patch] [--insecure] [--no-proxy]
                   [--offset-eol OFFSET_EOL] [--path PATH] [--timeout TIMEOUT]

Checks the installed PHP version against the endoflife.date API and alerts if
the version is end-of-life or if newer major, minor, or patch releases are
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
  --path PATH           Local path to your PHP binary. Default: /usr/bin/php
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
```


## Usage Examples

```bash
./php-version --offset-eol=-30
```

Output:

```text
PHP v7.3.1 (EOL 2021-12-06 -30d [WARNING], major 8.2.11 available, minor 7.4.33 available, patch 7.3.33 available)
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
| php-version | Number | Installed PHP version as float. "7.4.33" becomes "7.433". |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
