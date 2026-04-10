# Check metabase-stats

## Overview

Retrieves recent activity and usage statistics from a Metabase instance via its API. Reports active users, executed queries, dashboards, and other operational metrics. Credentials are cached to reduce API calls.

**Data Collection:**

* Authenticates against the Metabase API using username/password and caches the session token in SQLite (default expiry: ~14 days, matching Metabase's default session lifetime)
* Queries `/api/activity` for the most recent activity entry and `/api/util/stats` for aggregated usage statistics
* Reports site name, Metabase version, user count, analyzed databases, GUI questions, alerts, pulses, collections, CPUs, and RAM

**Compatibility:**

* Cross-platform: runs wherever the Metabase API is reachable (does not need to run on the Metabase server itself)

**Important Notes:**

* Requires a Metabase superuser account. Logins are rate-limited by Metabase for security, which is why credentials are cached. See the [Metabase API documentation](https://www.metabase.com/learn/developing-applications/advanced-metabase/metabase-api.html#authenticate-your-requests-with-a-session-token) for details


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/metabase-stats> |
| Nagios/Icinga Check Name              | `check_metabase_stats` |
| Check Interval Recommendation         | Once an hour |
| Can be called without parameters      | No (`--password` is required) |
| Compiled for Windows                  | No |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-metabase-stats.db` |


## Help

```text
usage: metabase-stats [-h] [-V] [--cache-expire CACHE_EXPIRE] [-c CRIT]
                      [--insecure] [--no-proxy] -p PASSWORD
                      [--timeout TIMEOUT] [--url URL] [--username USERNAME]
                      [-w WARN]

Retrieves recent activity and usage statistics from a Metabase instance via
its API. Reports active users, executed queries, dashboards, and other
operational metrics. Credentials are cached to reduce API calls.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --cache-expire CACHE_EXPIRE
                        Time after which the credential cache expires, in
                        hours. Default: 335
  -c, --critical CRIT   CRIT threshold in percent. Default: >= 90
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --no-proxy            Do not use a proxy.
  -p, --password PASSWORD
                        Password for authenticating against the Metabase API.
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
  --url URL             Base URL of the Metabase instance. Default:
                        http://localhost:3000
  --username USERNAME   Username for authenticating against the Metabase API.
                        Default: metabase-admin
  -w, --warning WARN    WARN threshold in percent. Default: >= 80
```


## Usage Examples

```bash
./metabase-stats --username user --password pass --url http://metabase:3000
```

Output:

```text
MyCube on Metabase v0.39.1; 8 users, 1 DB analyzed, 55 questions (GUI), 0 alerts, 0 pulses, 13 collections; 6 CPUs, 5462 MiB RAM
Last activity: "card-create/My Card" by John Doe (3D 16h ago)
```


## States

* Always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| alerts | Number | Number of configured alerts. |
| collections | Number | Number of collections. |
| cpu | Number | Number of CPUs available to the Metabase instance. |
| dbs_analyzed | Number | Number of analyzed databases. |
| pulses | Number | Number of configured pulses. |
| questions_gui | Number | Number of questions created via the GUI. |
| ram | MiB | RAM available to the Metabase instance. |
| users | Number | Total number of users. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
