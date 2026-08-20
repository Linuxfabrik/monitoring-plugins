# Check keycloak-stats


## Overview

Reports runtime facts of a Keycloak server via its HTTP API: uptime, the account the service runs under, its Java runtime, and which Keycloak features are enabled and disabled. Alerts if the server does not report this data to the account the check authenticates with, which Keycloak grants only to an account holding the "manage-realm" role in its administration realm. Tested with Keycloak 17 and later.

**Important Notes:**

* Verified against Keycloak 17 to 26
* The account the check authenticates with needs the client role `manage-realm` of the `master-realm` client. Keycloak 26.7 and later report the `systemInfo` section of `/admin/serverinfo` only to an account holding that role, so an account set up with a narrower role reports UNKNOWN after the server is upgraded
* All API paths are relative to `--url`. An instance that serves below a context path (Keycloak 16 and older by default, or a Quarkus instance started with `--http-relative-path=/auth`) needs that path in `--url`, for example `--url=http://127.0.0.1:8080/auth`
* See [Creating an API user account to monitor Keycloak](https://linuxfabrik.github.io/monitoring-plugins/plugins-keycloak/) for setting up the required API credentials.

**Data Collection:**

* Authenticates against the Keycloak OIDC token endpoint using client credentials (`--client-id`, `--username`, `--password`)
* Queries the Keycloak Admin REST API at `/admin/serverinfo` to retrieve system information and feature flags
* Enabled/disabled features are available starting with Keycloak 22; on older versions, only disabled features are reported (from `profileInfo`)


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/keycloak-stats> |
| Nagios/Icinga Check Name              | `check_keycloak_stats` |
| Check Interval Recommendation         | Every 15 minutes |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |


## Help

```text
usage: keycloak-stats [-h] [-V] [--always-ok] [--client-id CLIENT_ID]
                      [--insecure] [--no-perfdata] [--no-proxy] [-p PASSWORD]
                      [--realm REALM] [--timeout TIMEOUT] [--url URL]
                      [--username USERNAME]

Reports runtime facts of a Keycloak server via its HTTP API: uptime, the
account the service runs under, its Java runtime, and which Keycloak features
are enabled and disabled. Alerts if the server does not report this data to
the account the check authenticates with, which Keycloak grants only to an
account holding the "manage-realm" role in its administration realm. Tested
with Keycloak 17 and later.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --client-id CLIENT_ID
                        Keycloak API Client-ID. Default: admin-cli
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --no-perfdata         Suppress the performance data section from the output.
                        The status message and the exit code are unaffected,
                        so alerting keeps working while trending data is
                        dropped.
  --no-proxy            Do not use a proxy.
  -p, --password PASSWORD
                        Keycloak API password. Default: admin
  --realm REALM         Keycloak API realm. Default: master
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
  --url URL             Keycloak API URL. Default: http://127.0.0.1:8080
  --username USERNAME   Keycloak API username. Default: admin

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/keycloak-stats/
```


## Usage Examples

```bash
./keycloak-stats --username=keycloak-monitoring --password=linuxfabrik --url=http://keycloak:8080
```

Output (enabled features available with Keycloak 22+):

```text
Up 5m 12s, running under user `keycloak`; Java v21.0.5, OpenJDK 64-Bit Server VM, /usr/lib/jvm/java-21-openjdk-21.0.5.0.11-2.el9.x86_64

Enabled Features:
* ACCOUNT_API (default)
* ACCOUNT_V3 (default)
* ADMIN_API (default)
* ADMIN_V2 (default)
* AUTHORIZATION (default)
* CIBA (default)
...

Disabled Features:
* ADMIN_FINE_GRAINED_AUTHZ (preview)
* CACHE_EMBEDDED_REMOTE_STORE (experimental)
* CLIENT_SECRET_ROTATION (preview)
...
```


## States

* OK once Keycloak reports its runtime facts. The check has no thresholds.
* UNKNOWN if the account the check authenticates with may not read the system information, or on API connection errors.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| uptime | Seconds | Time the Keycloak server has been running. |


## Troubleshooting

### `Keycloak reports no "systemInfo" for this account.`

Keycloak answered without the section that carries uptime, service account and Java runtime. It hands that section out only to an account holding the client role `manage-realm` of the `master-realm` client, and only in the administration realm (`master`). Assign that role to the account named in `--username`, or point `--username` at an account that already has it. See [Creating an API user account to monitor Keycloak](https://linuxfabrik.github.io/monitoring-plugins/plugins-keycloak/) for the full account setup.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
