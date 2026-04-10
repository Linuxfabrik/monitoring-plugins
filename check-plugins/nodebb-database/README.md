# Check nodebb-database


## Overview

Monitors NodeBB database statistics via the admin API, including memory usage and connection counts. Alerts when thresholds are exceeded.

**Important Notes:**

* You need to issue a bearer token of type "user" in the NodeBB admin panel: Settings > API Access > Create Token > Specify your User ID and Description (for example "Linuxfabrik API Token"). In NodeBB, a user token is associated with a specific uid, and all calls are made in the name of that user.
* NodeBB Read API: <https://docs.nodebb.org/api/read/>
* Requires NodeBB v1.14.4+.

**Data Collection:**

* Queries the NodeBB Read API endpoint `/api/admin/advanced/database` using Bearer Authentication
* Reports MongoDB database name, filesystem disk usage, collection count, index count, and object count


## Fact Sheet

| Fact | Value |
|----|----| 
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/nodebb-database> |
| Nagios/Icinga Check Name              | `check_nodebb_database` |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | No (`--token` is required) |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |


## Help

```text
usage: nodebb-database [-h] [-V] [--always-ok] [-c CRIT] [--insecure]
                       [--no-proxy] [--severity {warn,crit}] [--test TEST]
                       [--timeout TIMEOUT] -p TOKEN [--url URL] [-w WARN]

Monitors NodeBB database statistics via the admin API, including memory usage
and connection counts. Alerts when thresholds are exceeded.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  -c, --critical CRIT   CRIT threshold in percent. Default: >= 95
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --no-proxy            Do not use a proxy.
  --severity {warn,crit}
                        Severity for alerts that do not depend on thresholds.
                        One of "warn" or "crit". Default: warn
  --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                        stderr-file,expected-retc".
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
  -p, --token TOKEN     NodeBB API bearer token.
  --url URL             NodeBB API URL. Default: http://localhost:4567/forum
  -w, --warning WARN    WARN threshold in percent. Default: >= 90
```


## Usage Examples

```bash
./nodebb-database --token edd956be-9ea5-4f2a-94ca-3948a1b9d184 --severity warn
```

Output:

```text
MongoDB "myforum": 20.9% Disk Usage (41.3GiB/197.4GiB), 5 collections, 11 indexes, 330.1K objects
```


## States

* OK if the database connection is ok and filesystem usage is below the warning threshold.
* WARN if the database connection is not ok (configurable via `--severity`).
* WARN if filesystem usage is >= `--warning` (default: 90).
* CRIT if filesystem usage is >= `--critical` (default: 95).
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| db_collections | Number | Number of MongoDB collections. |
| db_fs_total | Bytes | Total filesystem size from MongoDB's perspective. |
| db_fs_used | Bytes | Used filesystem space from MongoDB's perspective. |
| db_fs_used_percent | Percentage | Filesystem usage in percent. |
| db_indexes | Number | Number of MongoDB indexes. |
| db_objects | Number | Number of MongoDB objects. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
