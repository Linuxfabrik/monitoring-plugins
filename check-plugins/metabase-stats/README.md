# Check metabase-stats

## Overview

Getting some statistics from [Metabase](https://www.metabase.com).

Read the [Metabase API Documentation](https://www.metabase.com/learn/developing-applications/advanced-metabase/metabase-api.html#authenticate-your-requests-with-a-session-token) to note some things about user credentials and sessions. The check plugin caches credentials to reuse them until they expire, because logins to Metabase are rate-limited for security. You must use a Metabase superuser.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/metabase-stats> |
| Check Interval Recommendation         | Once an hour |
| Can be called without parameters      | No |
| Compiled for Windows                  | No |
| Uses SQLite DBs                       | `$TEMP/linuxfabrik-monitoring-plugins-metabase-stats.db` |


## Help

```text
usage: metabase-stats [-h] [-V] [--cache-expire CACHE_EXPIRE] [-c CRIT]
                      [--insecure] [--no-proxy] -p PASSWORD
                      [--timeout TIMEOUT] [--url URL] [--username USERNAME]
                      [-w WARN]

This check gets some recent activity from Metabase.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --cache-expire CACHE_EXPIRE
                        The amount of time after which the credential cache
                        expires, in hours. Default: 335
  -c, --critical CRIT   Set the CRIT threshold as a percentage. Default: >= 90
  --insecure            This option explicitly allows to perform "insecure"
                        SSL connections. Default: False
  --no-proxy            Do not use a proxy. Default: False
  -p, --password PASSWORD
                        Metabase API password.
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
  --url URL             Metabase API URL. Default: http://localhost:3000
  --username USERNAME   Metabase API username. Default: metabase-admin
  -w, --warning WARN    Set the WARN threshold as a percentage. Default: >= 80
```


## Usage Examples

```bash
./metabase-stats  -username user --password pass --url http://metabase:3000
```

Output:

```text
MyCube on Metabase v0.39.1; 8 users, 1 DB analyzed, 55 questions (GUI), 0 alerts, 0 pulses, 13 collections; 6 CPUs, 5462 MiB RAM
Last activity: "card-create/My Card" by John Doe (3D 16h ago)
```


## States

* Always returns OK.


## Perfdata / Metrics

* alerts
* collections
* cpu
* dbs_analyzed
* memory
* pulses
* questions_gui
* users


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
