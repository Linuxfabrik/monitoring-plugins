# Check wildfly-version


## Overview

Checks whether a newer version of WildFly is available by comparing the installed version, queried from the WildFly HTTP management API, against the latest release from the GitHub releases API. The plugin supports both standalone mode and domain mode.

**Important Notes:**

* `--username` and `--password` of a management user are required (same `ManagementRealm` user the other WildFly plugins use).
* Only stable releases are considered. GitHub's "latest release" endpoint returns the most recent non-prerelease, non-draft release, and WildFly flags its `.Beta`, `.CR` and `.Alpha` tags as prereleases, so they are skipped.
* The comparison ignores the version qualifier (`.Final`), so `40.0.0.Final` is compared as `40.0.0`.

**Data Collection:**

* Queries the WildFly management API for `product-version` (falls back to `release-version` if `product-version` is not available)
* Authenticates via HTTP Digest Auth (`--username`, `--password`)
* Queries the GitHub releases API for the latest release of `wildfly/wildfly`
* Caches the latest version information locally to reduce API calls (default: 24 hours)


## Fact Sheet

| Fact | Value |
|----|---|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/wildfly-version> |
| Nagios/Icinga Check Name              | `check_wildfly_version` |
| Check Interval Recommendation         | Every day |
| Can be called without parameters      | No (`--username` and `--password` are required) |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| Uses SQLite DBs                       | `$TEMP/linuxfabrik-monitoring-plugins-cache.db` |


## Help

```text
usage: wildfly-version [-h] [-V] [--always-ok] [--cache-expire CACHE_EXPIRE]
                       [--insecure] [--instance INSTANCE]
                       [--mode {standalone,domain}] [--no-proxy] [--node NODE]
                       -p PASSWORD [--timeout TIMEOUT] [--url URL]
                       --username USERNAME

Checks if a newer version of WildFly is available by comparing the installed
version, queried from the HTTP management API, against the latest release on
the GitHub releases API. Alerts when the installed version is outdated.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --cache-expire CACHE_EXPIRE
                        The amount of time after which the credential/data
                        cache expires, in minutes. Default: 24
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --instance INSTANCE   WildFly instance (server-config) to check when running
                        in domain mode.
  --mode {standalone,domain}
                        WildFly server mode. Default: standalone
  --no-proxy            Do not use a proxy.
  --node NODE           WildFly node (host) when running in domain mode.
  -p, --password PASSWORD
                        WildFly management API password.
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
  --url URL             WildFly management API URL. Default:
                        http://localhost:9990
  --username USERNAME   WildFly management API username. Default: wildfly-
                        monitoring
```


## Usage Examples

```bash
./wildfly-version --url=http://wildfly:9990 --username=wildfly-monitoring --password=password
```

Output:

```text
WildFly v40.0.0.Final is up to date
```

```text
WildFly v26.1.3.Final installed, WildFly v40.0.0.Final available
```


## States

* OK if the installed version is up to date.
* WARN if a newer version is available.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| wildfly-version | Number | Installed WildFly version as float. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
