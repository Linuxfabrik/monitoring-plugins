# Check mastodon-version

## Overview

Checks the installed Mastodon version against the endoflife.date API and alerts if the version is end-of-life or if newer major, minor, or patch releases are available. By default, alerts 30 days before the official EOL date. The offset is configurable.

**Important Notes:**

* Requires root or sudo to access the Mastodon installation directory
* Does not use the `tootctl` command (which requires a working Ruby environment and extra environment variables), but instead parses the Docker Compose file directly


**Data Collection:**

* Reads the Mastodon version from `docker-compose.yml` in the local installation directory (default: `/home/mastodon/live/docker-compose.yml`)
* Compares the installed version against the [endoflife.date API](https://endoflife.date/api/mastodon.json) to determine EOL status and available updates
* Uses SQLite to cache API responses between runs

**Compatibility:**

* Cross-platform


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mastodon-version> |
| Nagios/Icinga Check Name              | `check_mastodon_version` |
| Check Interval Recommendation         | Once a day |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |
| Uses State File                       | `$TEMP/linuxfabrik-lib-version.db` |


## Help

```text
usage: mastodon-version [-h] [-V] [--always-ok] [--check-major]
                        [--check-minor] [--check-patch] [--insecure]
                        [--no-proxy] [--offset-eol OFFSET_EOL] [--path PATH]
                        [--timeout TIMEOUT]

Checks the installed Mastodon version against the endoflife.date API and
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
  --path PATH           Local path to your Mastodon installation. Default:
                        /home/mastodon
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
```


## Usage Examples

```bash
./mastodon-version --path /home/mastodon
```

Output:

```text
Mastodon v4.2.10 (EOL unknown)
```


## States

* OK if the installed version is not EOL and no relevant updates are available.
* WARN if the installed version is EOL.
* WARN if `--check-major` is set and a new major version is available.
* WARN if `--check-minor` is set and a new minor version is available.
* WARN if `--check-patch` is set and a new patch version is available.
* UNKNOWN if the Mastodon installation or version information cannot be found.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| mastodon-version | Float | Installed Mastodon version as a floating-point number. For example, "4.2.10" becomes "4.21". |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
