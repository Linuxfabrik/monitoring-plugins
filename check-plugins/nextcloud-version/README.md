# Check nextcloud-version

## Overview

Checks the installed Nextcloud version against the endoflife.date API and alerts if the version is end-of-life or if newer major, minor, or patch releases are available. By default, alerts 30 days before the official EOL date. The offset is configurable. Requires root or sudo.

**Important Notes:**

* Must run on the Nextcloud server itself to access the installation directory



**Data Collection:**

* Requires sudo permissions for the UID under which the Nextcloud application runs
* Runs Nextcloud `occ config:list` via sudo to determine the installed version
* Queries the [endoflife.date API](https://endoflife.date/) for Nextcloud lifecycle data
* Caches the API response in a local SQLite database to reduce API calls

**Compatibility:**

* Cross-platform


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/nextcloud-version> |
| Nagios/Icinga Check Name              | `check_nextcloud_version` |
| Check Interval Recommendation         | Once a day |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |
| Uses SQLite DBs                       | `$TEMP/linuxfabrik-lib-version.db` |


## Help

```text
usage: nextcloud-version [-h] [-V] [--always-ok] [--check-major]
                         [--check-minor] [--check-patch] [--insecure]
                         [--no-proxy] [--offset-eol OFFSET_EOL] [--path PATH]
                         [--timeout TIMEOUT]

Checks the installed Nextcloud version against the endoflife.date API and
alerts if the version is end-of-life or if newer major, minor, or patch
releases are available. By default, alerts 30 days before the official EOL
date. The offset is configurable. Requires root or sudo.

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
  --path PATH           Local path to the Nextcloud installation, typically
                        the web server document root. Default:
                        /var/www/html/nextcloud
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
```


## Usage Examples

```bash
./nextcloud-version --path=/var/www/html/nextcloud
```

Output:

```text
Nextcloud v22.1.7 (EOL 2022-07-01 -30d [WARNING], major 27.1.2 available, minor 22.2.10 available)
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
| nextcloud-version | Number | Installed Nextcloud version as float. "23.0.12" becomes "23.012". |


## Troubleshooting

`Error running sudo -u \#48 /var/www/html/nextcloud/occ config:list: rc=1 sudo: /var/www/html/nextcloud/occ: command not found`
Permission for `/var/www/html/nextcloud/occ` must be `0755`.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
