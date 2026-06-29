# Check redis-version


## Overview

Checks the installed Redis version against the endoflife.date API and alerts if the version is end-of-life or if newer releases are available.

**Data Collection:**

* Runs `redis-server --version` locally to determine the installed version
* Queries the endoflife.date API (<https://endoflife.date/api/redis.json>) and caches the result in a local SQLite database
* Must run on the Redis server itself


## Fact Sheet

| Fact | Value |
|----|---|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/redis-version> |
| Nagios/Icinga Check Name              | `check_redis_version` |
| Check Interval Recommendation         | Every day |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| Uses SQLite DBs                       | `$TEMP/linuxfabrik-lib-version.db` |


## Help

```text
usage: redis-version [-h] [-V] [--always-ok] [--check-major] [--check-minor]
                     [--check-patch] [--insecure] [--no-proxy]
                     [--offset-eol OFFSET_EOL] [--timeout TIMEOUT]

Checks the installed Redis version against the endoflife.date API and alerts
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
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
```


## Usage Examples

```bash
./redis-version --offset-eol=-30
```

Output:

```text
Redis v7.0.13 (EOL unknown, minor 7.2.1 available)
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
| redis-version | Number | Installed Redis version as float. "3.3.22" becomes "3.322". |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
