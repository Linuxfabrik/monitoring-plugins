# Check fortios-version

## Overview

Checks the installed FortiOS version against the endoflife.date API and alerts if the version is end-of-life or if newer major, minor, or patch releases are available. By default, alerts 30 days before the official EOL date. The offset is configurable.

**Data Collection:**

* Queries the FortiOS REST API endpoint `/api/v2/monitor/system/firmware/` to determine the installed version
* Compares the installed version against the endoflife.date API (`https://endoflife.date/api/fortios.json`) to determine EOL status and available updates
* Caches the endoflife.date API response in a local SQLite database (`$TEMP/linuxfabrik-lib-version.db`)

**Compatibility:**

* FortiGate appliances running FortiOS with REST API enabled


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/fortios-version> |
| Nagios/Icinga Check Name              | `check_fortios_version` |
| Check Interval Recommendation         | Once a day |
| Can be called without parameters      | No (`--hostname` and `--password` are required) |
| Compiled for Windows                  | No |
| Uses State File                       | `$TEMP/linuxfabrik-lib-version.db` |


## Help

```text
usage: fortios-version [-h] [-V] [--always-ok] [--check-major] [--check-minor]
                       [--check-patch] -H HOSTNAME [--insecure] [--no-proxy]
                       [--offset-eol OFFSET_EOL] --password PASSWORD
                       [--timeout TIMEOUT]

Checks the installed FortiOS version against the endoflife.date API and alerts
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
  -H, --hostname HOSTNAME
                        FortiOS-based Appliance address, optional including
                        port ("192.0.2.1:443").
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --no-proxy            Do not use a proxy.
  --offset-eol OFFSET_EOL
                        Alert n days before ("-30") or after an EOL date ("30"
                        or "+30"). Default: -30 days
  --password PASSWORD   FortiOS REST API access token.
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
```


## Usage Examples

```bash
./fortios-version --hostname fortigate-cluster.example.com --password mypass
```

Output:

```text
FortiOS v6.0.1 (EOL 2022-09-29 -30d [WARNING])
```


## States

* OK if the installed FortiOS version is not EOL and no newer release is flagged.
* WARN if the installed version has reached or is approaching EOL (within `--offset-eol` days, default: -30).
* WARN if `--check-major` is set and a newer major release is available.
* WARN if `--check-minor` is set and a newer minor release is available.
* WARN if `--check-patch` is set and a newer patch release is available.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| fortios-version | Number | Installed FortiOS version as float. For example, "6.0.1" becomes "6.01". |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
