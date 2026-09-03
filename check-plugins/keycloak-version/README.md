# Check keycloak-version


## Overview

Checks the installed Keycloak version against the endoflife.date API and alerts if the version is end-of-life (EOL) or if newer major, minor, or patch releases are available. By default, the check alerts 30 days before the official EOL date. The offset is configurable via `--offset-eol`.

**Important Notes:**

* Verified against Keycloak 17 to 26
* All API paths are relative to `--url`. An instance that serves below a context path (Keycloak 16 and older by default, or a Quarkus instance started with `--http-relative-path=/auth`) needs that path in `--url`, for example `--url=http://127.0.0.1:8080/auth`
* See [Creating an API user account to monitor Keycloak](https://linuxfabrik.github.io/monitoring-plugins/plugins-keycloak/) for setting up the required API credentials (only needed if `version.txt` is not available).
* On that fallback path the account needs the client role `manage-realm` of the `master-realm` client. Keycloak 26.7 and later report the `systemInfo` section of `/admin/serverinfo` only to an account holding that role

**Data Collection:**

* Determines the installed Keycloak version by first trying to read `version.txt` from the local installation directory (`--path`, default: `/opt/keycloak`)
* If the file is not found, falls back to querying the Keycloak Admin REST API at `/admin/serverinfo` (requires `--username`, `--password`, and `--url`)
* Compares the installed version against the endoflife.date API (`https://endoflife.date/api/keycloak.json`)
* Caches the endoflife.date response in a local SQLite database to reduce API calls


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/keycloak-version> |
| Nagios/Icinga Check Name              | `check_keycloak_version` |
| Check Interval Recommendation         | Every day |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No (runs with Python interpreter) |
| Uses State File                       | `$TEMP/linuxfabrik-lib-version.db` |


## Help

```text
usage: keycloak-version [-h] [-V] [--always-ok] [--check-major]
                        [--check-minor] [--check-patch]
                        [--client-id CLIENT_ID] [--insecure] [--no-perfdata]
                        [--no-proxy] [--offset-eol OFFSET_EOL] [-p PASSWORD]
                        [--path PATH] [--proxy PROXY] [--realm REALM]
                        [--timeout TIMEOUT]
                        [--unreachable-severity {ok,warn,crit,unknown}]
                        [--url URL] [--username USERNAME]

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
  --no-perfdata         Suppress the performance data section from the output.
                        The status message and the exit code are unaffected,
                        so alerting keeps working while trending data is
                        dropped.
  --no-proxy            Do not use a proxy, not even one the environment
                        names. Overrides `--proxy`.
  --offset-eol OFFSET_EOL
                        Alert n days before ("-30") or after an EOL date ("30"
                        or "+30"). Default: -30 days
  -p, --password PASSWORD
                        Keycloak API password. Default: admin
  --path PATH           Local path to your Keycloak installation. Default:
                        /opt/keycloak
  --proxy PROXY         Proxy to reach the target through. The scheme defaults
                        to `http` when omitted. Overrides the proxy the
                        environment names (`http_proxy`, `https_proxy`,
                        `all_proxy`) together with the exceptions it lists in
                        `no_proxy`, and is itself overridden by `--no-proxy`.
                        Without either parameter the environment applies.
                        Credentials belong into the environment variable
                        rather than here, because a command-line argument is
                        visible to every user on the host. Example:
                        `--proxy=http://proxy.example.com:3128`.
  --realm REALM         Keycloak API realm. Default: master
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
  --unreachable-severity {ok,warn,crit,unknown}
                        State to report when the online source is unreachable.
                        What is used instead - bundled offline data, a cached
                        copy, or nothing at all - is named in the output, and
                        a clean result then only covers what that fallback
                        could confirm. Default: ok
  --url URL             Keycloak API URL. Default: http://127.0.0.1:8080
  --username USERNAME   Keycloak API username. Default: admin

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/keycloak-version/
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

* UNKNOWN if the installed version cannot be determined, for example because `version.txt` is missing and the account the check authenticates with may not read the system information.

The end-of-life verdict, the `--check-major` / `--check-minor` / `--check-patch` alerts, `--offset-eol`, `--always-ok` and what happens when endoflife.date cannot be reached work the same way in every endoflife.date-based version plugin. They are described in [Version Plugins](https://linuxfabrik.github.io/monitoring-plugins/plugins-version/).


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| keycloak-version | Number | Installed Keycloak version as float (e.g. "18.0.3" becomes "18.03"). |


## Troubleshooting

### `Keycloak reports no "systemInfo" for this account.`

`version.txt` was not readable below `--path`, so the check asked the API for the version, and Keycloak answered without the section that carries it. It hands that section out only to an account holding the client role `manage-realm` of the `master-realm` client. Point `--path` at the installation directory so the check reads the file instead, or assign that role to the account named in `--username`. See [Creating an API user account to monitor Keycloak](https://linuxfabrik.github.io/monitoring-plugins/plugins-keycloak/) for the full account setup.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
