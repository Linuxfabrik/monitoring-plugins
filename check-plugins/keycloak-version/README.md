# Check keycloak-version

## Overview

Checks the installed Keycloak version against the endoflife.date API and alerts if the version is end-of-life (EOL) or if newer major, minor, or patch releases are available. By default, the check alerts 30 days before the official EOL date. The offset is configurable via `--offset-eol`.

**Alerting Logic:**

* WARN if the installed version has reached or is approaching its EOL date (configurable via `--offset-eol`, default: -30 days)
* Optionally WARN when a new major (`--check-major`), minor (`--check-minor`), or patch (`--check-patch`) release is available, even if the current version is not yet EOL

**Data Collection:**

* Determines the installed Keycloak version by first trying to read `version.txt` from the local installation directory (`--path`, default: `/opt/keycloak`)
* If the file is not found, falls back to querying the Keycloak Admin REST API at `/admin/serverinfo` (requires `--username`, `--password`, and `--url`)
* Compares the installed version against the endoflife.date API (`https://endoflife.date/api/keycloak.json`)
* Caches the endoflife.date response in a local SQLite database to reduce API calls

**Compatibility:**

* Linux (local file access or API access to the Keycloak server)

**Important Notes:**

* See [Creating an API user account to monitor Keycloak](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/PLUGINS-KEYCLOAK.md) for setting up the required API credentials (only needed if `version.txt` is not available).


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/keycloak-version> |
| Nagios/Icinga Check Name              | `check_keycloak_version` |
| Check Interval Recommendation         | Once a day |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |
| Uses SQLite DBs                       | `$TEMP/linuxfabrik-lib-version.db` |


## Help

```text
usage: keycloak-version [-h] [-V] [--always-ok] [--check-major]
                        [--check-minor] [--check-patch]
                        [--client-id CLIENT_ID] [--insecure] [--no-proxy]
                        [--offset-eol OFFSET_EOL] [-p PASSWORD] [--path PATH]
                        [--realm REALM] [--timeout TIMEOUT] [--url URL]
                        [--username USERNAME]

Checks the installed Keycloak version against the endoflife.date API and
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
  --client-id CLIENT_ID
                        Keycloak API Client-ID. Default: admin-cli
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --no-proxy            Do not use a proxy.
  --offset-eol OFFSET_EOL
                        Alert n days before ("-30") or after an EOL date ("30"
                        or "+30"). Default: -30 days
  -p, --password PASSWORD
                        Keycloak API password. Default: admin
  --path PATH           Local path to your Keycloak installation. Default:
                        /opt/keycloak
  --realm REALM         Keycloak API realm. Default: master
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
  --url URL             Keycloak API URL. Default: http://127.0.0.1:8080
  --username USERNAME   Keycloak API username. Default: admin
```


## Usage Examples

```bash
./keycloak-version --path=/opt/keycloak
./keycloak-version --url=http://keycloak:8080 --username=keycloak-monitoring --password=linuxfabrik --check-major --check-minor --check-patch
```

Output:

```text
Keycloak v21.0.1 (EOL 2023-04-19 -30d [WARNING], major 22.0.4 available, minor 21.1.2 available, patch 21.0.2 available)
```


## States

* OK if the installed version is not EOL and no newer versions are requested to be checked.
* WARN if the installed version is EOL (or approaching EOL within the configured offset).
* WARN if `--check-major` is set and a new major version is available.
* WARN if `--check-minor` is set and a new minor version is available.
* WARN if `--check-patch` is set and a new patch version is available.
* UNKNOWN if the installed version cannot be determined.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| keycloak-version | Number | Installed Keycloak version as float (e.g. "18.0.3" becomes "18.03"). |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
