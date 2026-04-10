# Check matomo-version


## Overview

Checks the installed Matomo version against the endoflife.date API and alerts if the version is end-of-life or if newer major, minor, or patch releases are available. By default, alerts 30 days before the official EOL date. The offset is configurable.

**Data Collection:**

* Reads the installed Matomo version from `core/Version.php` in the local installation directory (default: `/var/www/html/matomo`)
* Compares the installed version against the [endoflife.date API](https://endoflife.date/api/matomo.json) to determine EOL status and available updates
* Uses SQLite to cache API responses between runs

**Compatibility:**

* Cross-platform


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/matomo-version> |
| Nagios/Icinga Check Name              | `check_matomo_version` |
| Check Interval Recommendation         | Once a day |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |
| Uses State File                       | `$TEMP/linuxfabrik-lib-version.db` |


## Help

```text
usage: matomo-version [-h] [-V] [--always-ok] [--check-major] [--check-minor]
                      [--check-patch] [--insecure] [--no-proxy]
                      [--offset-eol OFFSET_EOL] [--path PATH]
                      [--timeout TIMEOUT]

Checks the installed Matomo version against the endoflife.date API and alerts
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
  --path PATH           Local path to your Matomo/Piwik installation,
                        typically within your Webserver's Document Root.
                        Default: /var/www/html/matomo
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
```


## Usage Examples

```bash
./matomo-version --path=/var/www/html/matomo
./matomo-version --path=/var/www/html/matomo --offset-eol=-30
```

Output:

```text
Matomo v5.3.2 (EOL unknown)
```


## States

* OK if the installed version is not EOL and no relevant updates are available.
* WARN if the installed version is EOL.
* WARN if `--check-major` is set and a new major version is available.
* WARN if `--check-minor` is set and a new minor version is available.
* WARN if `--check-patch` is set and a new patch version is available.
* UNKNOWN if the Matomo installation or version information cannot be found.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| matomo-version | Float | Installed Matomo version as a floating-point number. For example, "5.3.2" becomes "5.32". |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
