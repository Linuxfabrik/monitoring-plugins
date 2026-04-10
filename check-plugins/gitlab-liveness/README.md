# Check gitlab-liveness

## Overview

Checks whether the GitLab application server is alive by querying the `/-/liveness` endpoint. This probe detects deadlocked Rails controllers caused by multi-threading issues. A successful response confirms that no controllers are deadlocked.

**Alerting Logic:**

* Alerts with the configured `--severity` (default: WARN) if the endpoint returns an error or does not contain a "status" field

**Data Collection:**

* Sends an HTTP GET request to the GitLab liveness endpoint (default: `http://localhost/-/liveness`)
* Expects a JSON response containing a "status" field and no "error" field

**Compatibility:**

* GitLab 12.4 or later

**Important Notes:**

* The requesting client IP must be included in the GitLab monitoring allowlist. See [how to add IPs to the allowlist](https://docs.gitlab.com/ee/administration/monitoring/ip_allowlist.html).
* This check is exempt from Rack Attack rate limiting.
* GitLab Health Checks documentation: <https://docs.gitlab.com/ee/administration/monitoring/health_check.html>


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/gitlab-liveness> |
| Nagios/Icinga Check Name              | `check_gitlab_liveness` |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |


## Help

```text
usage: gitlab-liveness [-h] [-V] [--always-ok] [--insecure] [--no-proxy]
                       [--severity {warn,crit}] [--test TEST]
                       [--timeout TIMEOUT] [--url URL]

Checks whether the GitLab application server is alive by querying the
/-/liveness endpoint. This probe detects deadlocked Rails controllers caused
by multi-threading issues. Requires GitLab 12.4 or later. Alerts when the
server does not respond or reports a deadlock.

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
  --url URL             GitLab liveness URL endpoint. Default:
                        http://localhost/-/liveness
```


## Usage Examples

```bash
./gitlab-liveness --severity warn --timeout 3 --url http://localhost/-/liveness
```

Output:

```text
The GitLab application server is running. No Rails Controllers are deadlocked.
```


## States

* OK if the `/-/liveness` endpoint returns a valid status without errors.
* WARN or CRIT (depending on `--severity`, default: WARN) if the endpoint returns an error or a deadlock is detected.
* UNKNOWN if the response does not contain a "status" field and no "error" field.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| gitlab-liveness | Number | The current state (0 = OK, 1 = WARN, 2 = CRIT, 3 = UNKNOWN). |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
