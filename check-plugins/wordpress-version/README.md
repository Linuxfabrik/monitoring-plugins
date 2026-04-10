# Check wordpress-version


## Overview

Checks the installed WordPress version against the endoflife.date API and alerts if the version is end-of-life or if newer releases are available. The check must run on the WordPress server itself, as it reads the version from the WordPress installation directory (`wp-includes/version.php`).

**Data Collection:**

* Reads the WordPress version from `<path>/wp-includes/version.php` using a regex match on `$wp_version`
* Queries the [endoflife.date API](https://endoflife.date/api/wordpress.json) to fetch EOL dates and latest available versions
* Caches API responses in a SQLite database to reduce network calls


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/wordpress-version> |
| Nagios/Icinga Check Name              | `check_wordpress_version` |
| Check Interval Recommendation         | Every day |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| Uses SQLite DBs                       | `$TEMP/linuxfabrik-lib-version.db` |


## Help

```text
usage: wordpress-version [-h] [-V] [--always-ok] [--check-major]
                         [--check-minor] [--check-patch] [--insecure]
                         [--no-proxy] [--offset-eol OFFSET_EOL] [--path PATH]
                         [--timeout TIMEOUT]

Checks the installed WordPress version against the endoflife.date API and
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
  --path PATH           Local path to your WordPress installation, typically
                        within your Webserver's Document Root. Default:
                        /var/www/html/wordpress
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
```


## Usage Examples

```bash
./wordpress-version --path=/var/www/html/wordpress
```

Output:

```text
WordPress v4.0.37 (EOL 2022-12-01 -30d [WARNING], major 6.3.1 available, minor 4.9.23 available, patch 4.0.38 available)
```


## States

* WARN if the installed version is EOL (or within the configured offset).
* Optional: WARN when a new major version is available (`--check-major`).
* Optional: WARN when a new minor version is available (`--check-minor`).
* Optional: WARN when a new patch version is available (`--check-patch`).
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| wordpress-version | Number | Installed WordPress version as float. "4.0.38" becomes "4.038". |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
