# Check openvpn-version

## Overview

Checks the installed OpenVPN version against the endoflife.date API and alerts if the version is end-of-life or if newer major, minor, or patch releases are available. By default, alerts 30 days before the official EOL date. The offset is configurable.

**Data Collection:**

* Executes `openvpn --version` (at the configured `--path`) to determine the installed version
* Queries the endoflife.date API at `https://endoflife.date/api/openvpn.json` to compare against known EOL dates and available releases
* Caches the API response in a local SQLite database to reduce network requests

**Compatibility:**

* Cross-platform

**Important Notes:**

* The check must run on the machine running OpenVPN itself to detect the installed version



## Fact Sheet

| Fact | Value |
|----|----| 
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/openvpn-version> |
| Nagios/Icinga Check Name              | `check_openvpn_version` |
| Check Interval Recommendation         | Once a day |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |
| Uses SQLite DBs                       | `$TEMP/linuxfabrik-lib-version.db` |


## Help

```text
usage: openvpn-version [-h] [-V] [--always-ok] [--check-major] [--check-minor]
                       [--check-patch] [--insecure] [--no-proxy]
                       [--offset-eol OFFSET_EOL] [--path PATH]
                       [--timeout TIMEOUT]

Checks the installed OpenVPN version against the endoflife.date API and alerts
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
  --path PATH           Local path to your OpenVPN binary. Default:
                        /usr/sbin/openvpn
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
```


## Usage Examples

```bash
./openvpn-version --offset-eol=-30
```

Output:

```text
OpenVPN v2.4.12 (full support ended on 2022-03-17; EOL 2023-03-31 -30d [WARNING], minor 2.6.13 available)
```


## States

* OK if the installed version is not EOL and no newer versions are requested.
* WARN if the installed version is EOL (or approaching EOL within `--offset-eol` days).
* Optional: WARN when a new major version is available (`--check-major`).
* Optional: WARN when a new minor version is available (`--check-minor`).
* Optional: WARN when a new patch version is available (`--check-patch`).
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| openvpn-version | Number | Installed OpenVPN version as a float. `2.5.11` becomes `2.511`. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
