# Check rocketchat-version

## Overview

Checks the installed Rocket.Chat version against the endoflife.date API and alerts if the version is end-of-life or if newer releases are available.

**Important Notes:**

* Requires a Rocket.Chat user with a strong password and the `view-statistics` permission (only)
* See [Creating an API user account to monitor Rocket.Chat](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/PLUGINS-ROCKETCHAT.md)

**Data Collection:**

* Authenticates against the Rocket.Chat REST API and reads the installed version from the statistics endpoint
* Supports Rocket.Chat versions before and after 3.0.0 (different API response formats)
* Queries the endoflife.date API (<https://endoflife.date/api/rocket-chat.json>) and caches the result in a local SQLite database

**Compatibility:**

* Cross-platform



## Fact Sheet

| Fact | Value |
|----|---|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/rocketchat-version> |
| Nagios/Icinga Check Name              | `check_rocketchat_version` |
| Check Interval Recommendation         | Once a day |
| Can be called without parameters      | No (`--username` and `--password` are required) |
| Compiled for Windows                  | No |
| Requirements                          | Requires a user with strong password and `view-statistics` permission (only). |
| Uses SQLite DBs                       | `$TEMP/linuxfabrik-lib-version.db` |


## Help

```text
usage: rocketchat-version [-h] [-V] [--always-ok] [--check-major]
                          [--check-minor] [--check-patch] [--insecure]
                          [--no-proxy] [--offset-eol OFFSET_EOL] -p PASSWORD
                          [--timeout TIMEOUT] [--url URL] --username USERNAME

Checks the installed Rocket.Chat version against the endoflife.date API and
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
  -p, --password PASSWORD
                        Rocket.Chat API password.
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
  --url URL             Rocket.Chat API URL. Default:
                        http://localhost:3000/api/v1
  --username USERNAME   Rocket.Chat API username. Default: rocket-stats
```


## Usage Examples

```bash
./rocketchat-version --username rocket-stats --password mypassword --url http://rocket:3000/api/v1 --offset-eol=-30
```

Output:

```text
Rocket.Chat v6.13.0 (full support ended on 2024-10-10; EOL 2025-04-30 -30d, major 7.4.0 available, patch 6.13.1 available)
```


## States

* WARN if the installed version is EOL.
* Optional: WARN when a new major version is available.
* Optional: WARN when a new minor version is available.
* Optional: WARN when a new patch version is available.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| rocketchat-version | Number | Installed Rocket.Chat version as float. "6.13.1" becomes "6.131". |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
