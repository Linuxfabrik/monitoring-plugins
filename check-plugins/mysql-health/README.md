# Check mysql-health


## Overview

Produces a single 0-100 health score for a MySQL/MariaDB server, modelled on mysqltuner v2.8.41's weighted KPI. Useful as a top-level Icinga alert ("is the database healthy overall?") and as a Grafana KPI panel. The individual `mysql-*` plugins still own the detailed findings and fix advice; `mysql-health` only aggregates.

**Important Notes:**

* See [additional notes for all mysql monitoring plugins](https://linuxfabrik.github.io/monitoring-plugins/plugins-mysql/)
* Score breakdown: Performance 40 pts (buffer pool hit rate, temp tables on disk, thread cache hit rate, connection usage), Security 30 pts (anonymous accounts, empty passwords, wildcard hosts), Resilience 30 pts (replication lag, redo-log sizing, schema metadata)
* This plugin does not produce per-issue fix advice; the output lists each component score plus a pointer to the underlying `mysql-*` plugin for fixes
* Output format mirrors mysqltuner's "Health Score KPI" section
* Components without data (e.g. `Innodb_buffer_pool_*` on a freshly-booted server with no I/O yet) award half the points (5/10), the same fallback mysqltuner uses
* The plugin runs every 5 minutes by default; per-component metrics that require longer baselines (replication lag is meaningful only on a real replica) just contribute their default points when there is nothing to evaluate

**Data Collection:**

* `SHOW GLOBAL STATUS` and `SHOW GLOBAL VARIABLES` in one round trip each (via `lib.db_mysql.get_all_status()` and `get_all_variables()`)
* `SHOW REPLICA STATUS` (or the legacy `SHOW SLAVE STATUS`) for replication lag (via `lib.db_mysql.get_replica_status()`)
* `mysql.user` for security findings (anonymous accounts, empty passwords, wildcard hosts), with role-aware filtering on MariaDB 10.0.5+
* `information_schema.tables` joined to `information_schema.statistics` for the metadata health component (InnoDB tables without a user-defined `PRIMARY KEY`)
* Logic for the weighted score is ported from [MySQLTuner](https://github.com/major/MySQLTuner-perl):calculate_health_score() and verified in sync with MySQLTuner v2.8.41


## Fact Sheet

| Fact | Value |
|----|---|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-health> |
| Nagios/Icinga Check Name              | `check_mysql_health` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| Requirements                          | User with `SELECT` privilege (typically `GRANT SELECT ON *.*`), locked down to `127.0.0.1` - for example `monitoring\@127.0.0.1`. Usernames in MySQL/MariaDB are limited to 16 chars in specific versions. |
| 3rd Party Python modules              | `pymysql` |


## Help

```text
usage: mysql-health [-h] [-V] [--always-ok] [-c CRITICAL]
                    [--defaults-file DEFAULTS_FILE]
                    [--defaults-group DEFAULTS_GROUP] [--timeout TIMEOUT]
                    [-w WARNING]

Single-number health score for a MySQL/MariaDB server, modelled on mysqltuner
v2.8.41's weighted KPI. Combines four performance metrics (buffer pool hit
rate, temp tables on disk, thread cache hit rate, connection usage), a
security count (anonymous accounts, empty passwords, wildcard hosts) and
three resilience metrics (replication lag, redo-log sizing, schema metadata)
into a 0-100 score. Useful as a top-level Icinga alert and Grafana KPI panel;
the individual `mysql-*` plugins still own the detailed findings and fix
advice.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  -c, --critical CRITICAL
                        CRIT threshold in percent. Supports Nagios ranges.
                        Default: 50:
  --defaults-file DEFAULTS_FILE
                        MySQL/MariaDB cnf file to read user, host and password
                        from. Example: `--defaults-
                        file=/var/spool/icinga2/.my.cnf`. Default:
                        /var/spool/icinga2/.my.cnf
  --defaults-group DEFAULTS_GROUP
                        Group/section to read from in the cnf file. Default:
                        client
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
  -w, --warning WARNING
                        WARN threshold in percent. Supports Nagios ranges.
                        Default: 70:
```


## Usage Examples

```bash
./mysql-health --defaults-file=/var/spool/icinga2/.my.cnf
```

OK output:

```text
Everything is ok. Health Score: 95/100 (Performance 40/40, Security 25/30, Resilience 30/30).

Component breakdown:
* Buffer pool hit rate: 99.4% (10/10) - aim for > 95%
* Temp tables on disk: 4.2% (10/10) - aim for < 10%
* Thread cache hit rate: 98.7% (10/10) - aim for > 90%
* Connection usage: 22.0% (10/10) - aim for < 80%
* Security issues: 1 (25/30) - see `mysql-user-security` for fixes
* Replication lag: n/a (10/10) - see `mysql-replica-status` for fixes
* Log safety: redo cap 1024MiB (10/10) - see `mysql-innodb-buffer-pool-size` for fixes
* Metadata: 0 InnoDB tables without `PRIMARY KEY` (10/10) - see `mysql-table-indexes` for fixes
```

WARN output:

```text
Health Score: 60/100 (Performance 25/40, Security 25/30, Resilience 10/30) [WARNING].

Component breakdown:
* Buffer pool hit rate: 92.3% (5/10) - aim for > 95%
* Temp tables on disk: 38.5% (0/10) - aim for < 10%
* Thread cache hit rate: 88.0% (5/10) - aim for > 90%
* Connection usage: 45.0% (10/10) - aim for < 80%
* Security issues: 1 (25/30) - see `mysql-user-security` for fixes
* Replication lag: 180s (0/10) - see `mysql-replica-status` for fixes
* Log safety: redo cap 128MiB (5/10) - see `mysql-innodb-buffer-pool-size` for fixes
* Metadata: 7 InnoDB tables without `PRIMARY KEY` (5/10) - see `mysql-table-indexes` for fixes
```


## States

* WARN if the overall health score is at or below `--warning` (default: `70:`, alerts below 70).
* CRIT if the score is at or below `--critical` (default: `50:`, alerts below 50).
* Defaults match mysqltuner v2.8.41's colour-coding (yellow zone below 80, red zone below 50; we use 70 as WARN to surface degradation slightly earlier).
* Both `--warning` and `--critical` accept Nagios range expressions, see [THRESHOLDS.md](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/THRESHOLDS.md).
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| mysql_health_performance | Number | Performance component score (0-40). Buffer pool hit rate, temp tables on disk, thread cache hit rate, connection usage. |
| mysql_health_resilience | Number | Resilience component score (0-30). Replication lag, redo-log sizing, schema metadata. |
| mysql_health_score | Number | Overall weighted health score (0-100). |
| mysql_health_security | Number | Security component score (0-30). Starts at 30 and drops 5 per finding (anonymous account, empty password, wildcard host). |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
* Credits:
    * heavily inspired by MySQLTuner (<https://github.com/major/MySQLTuner-perl>)
