# Check rocketchat-version

## Overview

This plugin lets you track if Rocket.Chat is End-of-Life (EOL). To compare against the current/installed version of Rocket.Chat, the check needs URL/API access to the Rocket.Chat server.

This check plugin alerts n days before or after the EOL date is reached. Optionally, it can also alert on available major, minor or patch releases (each independently).

Hints:

* See [Creating an API user account to monitor Rocket.Chat](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/PLUGINS-ROCKETCHAT.md).


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/rocketchat-version> |
| Check Interval Recommendation         | Once a day |
| Can be called without parameters      | No |
| Compiled for Windows                  | No |
| Requirements                          | Requires a user with strong password and 'view-statistics' permission (only). |
| Uses SQLite DBs                       | `$TEMP/linuxfabrik-lib-version.db` |


## Help

```text
usage: rocketchat-version [-h] [-V] [--always-ok] [--check-major]
                          [--check-minor] [--check-patch] [--insecure]
                          [--no-proxy] [--offset-eol OFFSET_EOL] -p PASSWORD
                          [--timeout TIMEOUT] [--url URL] --username USERNAME

Tracks if Rocket.Chat is EOL.

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

* WARN if software is EOL
* Optional: WARN when new major version is available
* Optional: WARN when new minor version is available
* Optional: WARN when new patch version is available


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| rocketchat-version | Number | Installed Rocket.Chat version as float. "6.13.1" becomes "6.131". |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
