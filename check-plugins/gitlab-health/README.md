# Check gitlab-health

## Overview

Checks whether the GitLab application server is running by querying the `/-/health` endpoint. This is a lightweight probe that does not hit the database or verify other backend services. A successful response confirms that the application server is processing requests, but does not guarantee that the database or other services are ready.

**Important Notes:**

* GitLab 9.1.0 or later
* The requesting client IP must be included in the GitLab monitoring allowlist. See [how to add IPs to the allowlist](https://docs.gitlab.com/ee/administration/monitoring/ip_allowlist.html).
* GitLab Health Checks documentation: <https://docs.gitlab.com/ee/administration/monitoring/health_check.html>


**Data Collection:**

* Sends an HTTP GET request to the GitLab health endpoint (default: `http://localhost/-/health`)
* Expects the plain-text response "GitLab OK"

**Compatibility:**

* Cross-platform


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/gitlab-health> |
| Nagios/Icinga Check Name              | `check_gitlab_health` |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |


## Help

```text
usage: gitlab-health [-h] [-V] [--always-ok] [--insecure] [--no-proxy]
                     [--severity {warn,crit}] [--test TEST]
                     [--timeout TIMEOUT] [--url URL]

Checks whether the GitLab application server is running by querying the
/-/health endpoint. This is a lightweight probe that does not hit the database
or verify other backend services. Alerts when the server does not respond or
reports unhealthy.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --no-proxy            Do not use a proxy.
  --severity {warn,crit}
                        Severity for alerting. Default: warn
  --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                        stderr-file,expected-retc".
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
  --url URL             GitLab health URL endpoint. Default:
                        http://localhost/-/health
```


## Usage Examples

```bash
./gitlab-health --severity warn --timeout 3 --url http://localhost/-/health
```

Output:

```text
The GitLab application server is processing requests, but this does not mean that the database or other services are ready.
```


## States

* OK if the `/-/health` endpoint returns "GitLab OK".
* WARN or CRIT (depending on `--severity`, default: WARN) if the endpoint does not return "GitLab OK".
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| gitlab-health | Number | The current state (0 = OK, 1 = WARN, 2 = CRIT, 3 = UNKNOWN). |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
