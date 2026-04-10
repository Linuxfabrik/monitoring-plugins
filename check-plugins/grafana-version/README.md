# Check grafana-version

## Overview

Checks the installed Grafana version against the endoflife.date API and alerts if the version is end-of-life or if newer major, minor, or patch releases are available. By default, alerts 30 days before the official EOL date. The offset is configurable.

**Data Collection:**

* Determines the installed Grafana version by executing `grafana-server -v`
* Compares against the [endoflife.date API](https://endoflife.date/api/grafana.json) to determine EOL status and available updates
* Caches API responses locally for 24 hours to reduce external requests

**Compatibility:**

* Cross-platform (must run on the Grafana server itself)

**Important Notes:**

* The check must run locally on the Grafana server because it executes `grafana-server -v` to determine the installed version.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/grafana-version> |
| Nagios/Icinga Check Name              | `check_grafana_version` |
| Check Interval Recommendation         | Every day |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |
| Uses State File                       | `$TEMP/linuxfabrik-lib-version.db` |


## Help

```text
usage: grafana-version [-h] [-V] [--always-ok] [--check-major] [--check-minor]
                       [--check-patch] [--insecure] [--no-proxy]
                       [--offset-eol OFFSET_EOL] [--timeout TIMEOUT]

Checks the installed Grafana version against the endoflife.date API and alerts
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
./grafana-version --offset-eol=-30
```

Output:

```text
Grafana v9.3.6 (EOL 2023-04-06 -30d [WARNING], major 10.1.4 available, minor 9.5.12 available, patch 9.3.16 available)
```


## States

* OK if the installed version is not EOL and no update alerts are configured.
* WARN if the installed version is EOL (considering `--offset-eol`, default: -30 days).
* WARN if `--check-major` is set and a new major version is available.
* WARN if `--check-minor` is set and a new minor version is available.
* WARN if `--check-patch` is set and a new patch version is available.
* UNKNOWN if Grafana is not found or the version cannot be determined.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| grafana-version | Number | Installed Grafana version as float. For example, "9.3.6" becomes "9.36". |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
