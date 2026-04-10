# Check gitlab-readiness

## Overview

Checks whether the GitLab instance is ready to accept traffic by querying the `/-/readiness` endpoint. Validates the status of all dependent services (database, Redis, Gitaly, etc.) and reports each individually. Alerts when the instance or any dependent service is not ready.

**Data Collection:**

* Queries the GitLab readiness endpoint (`/-/readiness?all=1`) via HTTP(S) to retrieve the health status of each dependent service
* Checks the following services: cache, chat, cluster_cache, cluster_shared_state, db, db_load_balancing, feature_flag, gitaly, master, queues, rate_limiting, repository_cache, sessions, shared_state, trace_chunks
* If any service reports a status other than "ok", the check alerts with the configured severity and truncates the error message to 46 characters

**Compatibility:**

* Requires GitLab 9.1.0+

**Important Notes:**

* To access monitoring resources, the requesting client IP needs to be included in the allowlist. For details, see [how to add IPs to the allowlist for the monitoring endpoints](https://docs.gitlab.com/ee/administration/monitoring/ip_allowlist.html).
* This check is exempt from Rack Attack.
* GitLab Health Checks: <https://docs.gitlab.com/ee/administration/monitoring/health_check.html>


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/gitlab-readiness> |
| Nagios/Icinga Check Name              | `check_gitlab_readiness` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |


## Help

```text
usage: gitlab-readiness [-h] [-V] [--always-ok] [--insecure] [--no-proxy]
                        [--severity {warn,crit}] [--test TEST]
                        [--timeout TIMEOUT] [--url URL]

Checks whether the GitLab instance is ready to accept traffic by querying the
/-/readiness endpoint. Validates the status of all dependent services
(database, Redis, Gitaly, etc.) and reports each individually. Alerts when the
instance or any dependent service is not ready.

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
  --url URL             GitLab readiness URL endpoint. Default:
                        http://localhost/-/readiness?all=1
```


## Usage Examples

```bash
./gitlab-readiness --severity warn --timeout 3 --url http://localhost/-/readiness
```

Output:

```text
There are issues with gitaly_check. Run `curl http://localhost/-/readiness?all=1` for full results.

Service           ! Message                                                     
------------------+-------------------------------------------------------------
cache             ! Running                                                     
chat              ! Running                                                     
cluster_cache     ! Running                                                     
db                ! Running                                                     
db_load_balancing ! Running                                                     
feature_flag      ! Running                                                     
gitaly            ! [WARNING] 14:connections to all backends failing; last e... 
master            ! Running                                                     
queues            ! Running                                                     
rate_limiting     ! Running                                                     
repository_cache  ! Running                                                     
sessions          ! Running                                                     
shared_state      ! Running                                                     
trace_chunks      ! Running
```


## States

* OK if all dependent services report status "ok".
* WARN (default) or CRIT (with `--severity=crit`) if the GitLab instance or any dependent service is not ready.
* UNKNOWN on unexpected API responses or connection errors.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| gitlab-readiness | Number | The current state (0 = OK, 1 = WARN, 2 = CRIT, 3 = UNKNOWN). |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
