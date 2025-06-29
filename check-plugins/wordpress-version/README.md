# Check wordpress-version

## Overview

This plugin lets you track if WordPress is End-of-Life (EOL). To compare against the current/installed version of WordPress, the check has to run on the WordPress server itself and needs access to the WordPress installation directory.

This check plugin alerts n days before or after the EOL date is reached. Optionally, it can also alert on available major, minor or patch releases (each independently).


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/wordpress-version> |
| Check Interval Recommendation         | Once a day |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |
| Uses SQLite DBs                       | `$TEMP/linuxfabrik-lib-version.db` |


## Help

```text
usage: wordpress-version [-h] [-V] [--always-ok] [--check-major]
                         [--check-minor] [--check-patch] [--insecure]
                         [--no-proxy] [--offset-eol OFFSET_EOL] [--path PATH]
                         [--timeout TIMEOUT]

Tracks if WordPress is EOL.

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
  --path PATH           Local path to your WordPress installation, typically
                        within your Webserver's Document Root. Default:
                        /var/www/html/wordpress
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
```


## Usage Examples

```bash
./wordpress-version --path /var/www/html/wordpress
```

Output:

```text
WordPress v4.0.37 (EOL 2022-12-01 -30d [WARNING], major 6.3.1 available, minor 4.9.23 available, patch 4.0.38 available)
```


## States

* WARN if software is EOL
* Optional: WARN when new major version is available
* Optional: WARN when new minor version is available
* Optional: WARN when new patch version is available


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| wordpress-version | Number | Installed WordPress version as float. "4.0.38" becomes "4.038". |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
