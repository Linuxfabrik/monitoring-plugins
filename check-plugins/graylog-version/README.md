# Check graylog-version

## Overview

Checks the installed Graylog version against the endoflife.date API and alerts if the version is end-of-life or if newer major, minor, or patch releases are available. By default, alerts 30 days before the official EOL date. The offset is configurable.

**Important Notes:**

* The check must run locally on the Graylog server because it queries the local package manager for the installed version.


**Data Collection:**

* Determines the installed Graylog version from the package manager (`yum` on RHEL, `dpkg` on Debian)
* Compares against the [endoflife.date API](https://endoflife.date/api/graylog.json) to determine EOL status and available updates
* Caches API responses locally for 24 hours to reduce external requests

**Compatibility:**

* Linux


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/graylog-version> |
| Nagios/Icinga Check Name              | `check_graylog_version` |
| Check Interval Recommendation         | Every day |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |
| Uses State File                       | `$TEMP/linuxfabrik-lib-version.db` |


## Help

```text
usage: graylog-version [-h] [-V] [--always-ok] [--check-major] [--check-minor]
                       [--check-patch] [--insecure] [--no-proxy]
                       [--offset-eol OFFSET_EOL] [--timeout TIMEOUT]

Checks the installed Graylog version against the endoflife.date API and alerts
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
./graylog-version --offset-eol=-30
```

Output:

```text
Graylog v5.0.13 (EOL 2023-10-30 -30d [WARNING], major 6.0.4 available, minor 5.2.9 available)
```


## States

* OK if the installed version is not EOL and no update alerts are configured.
* WARN if the installed version is EOL (considering `--offset-eol`, default: -30 days).
* WARN if `--check-major` is set and a new major version is available.
* WARN if `--check-minor` is set and a new minor version is available.
* WARN if `--check-patch` is set and a new patch version is available.
* UNKNOWN if Graylog is not found or the platform is not supported.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| graylog-version | Number | Installed Graylog version as float. For example, "5.0.13" becomes "5.013". |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
