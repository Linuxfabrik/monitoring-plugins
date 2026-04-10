# Check keycloak-stats

## Overview

Reports statistics from a Keycloak server via its HTTP API, including uptime, Java version, JVM details, and enabled/disabled feature flags. This is an informational check that always returns OK.

**Data Collection:**

* Authenticates against the Keycloak OIDC token endpoint using client credentials (`--client-id`, `--username`, `--password`)
* Queries the Keycloak Admin REST API at `/admin/serverinfo` to retrieve system information and feature flags
* Enabled/disabled features are available starting with Keycloak 22; on older versions, only disabled features are reported (from `profileInfo`)

**Compatibility:**

* Tested with Keycloak 18 and later

**Important Notes:**

* See [Creating an API user account to monitor Keycloak](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/PLUGINS-KEYCLOAK.md) for setting up the required API credentials.


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/keycloak-stats> |
| Nagios/Icinga Check Name              | `check_keycloak_stats` |
| Check Interval Recommendation         | Every 15 minutes |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |


## Help

```text
usage: keycloak-stats [-h] [-V] [--client-id CLIENT_ID] [--insecure]
                      [--no-proxy] [-p PASSWORD] [--realm REALM]
                      [--timeout TIMEOUT] [--url URL] [--username USERNAME]

Reports statistics from a Keycloak server via its HTTP API, including realm
count, client count, user count, and active sessions. Tested with Keycloak 18
and later.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --client-id CLIENT_ID
                        Keycloak API Client-ID. Default: admin-cli
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --no-proxy            Do not use a proxy.
  -p, --password PASSWORD
                        Keycloak API password. Default: admin
  --realm REALM         Keycloak API realm. Default: master
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
  --url URL             Keycloak API URL. Default: http://127.0.0.1:8080
  --username USERNAME   Keycloak API username. Default: admin
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

* Always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| uptime | Seconds | Time the Keycloak server has been running. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
