# Check mysql-replica-status


## Overview

Checks the replication status of a MySQL/MariaDB replica: I/O thread state, SQL thread state, replication lag (`Seconds_Behind_Master` / `Seconds_Behind_Source`), `read_only` mode, semi-synchronous replication mode and (on MariaDB 10.5+) parallel replication settings. Also reports whether this server is a Galera node and how many downstream replicas it is feeding. Can safely be run against standalone servers; it reports "This is a standalone server."

**Important Notes:**

* See [additional notes for all mysql monitoring plugins](https://linuxfabrik.github.io/monitoring-plugins/plugins-mysql/)
* On MariaDB 10.5+, `REPLICATION CLIENT` was split. `SHOW REPLICA STATUS` / `SHOW SLAVE STATUS` requires `SLAVE MONITOR` (or its MariaDB 11+ alias `REPLICA MONITOR`); plain `REPLICATION CLIENT` alone is not enough on those versions. Grant `SLAVE MONITOR` (or `REPLICA MONITOR`) to be safe.

**Data Collection:**

* Queries `SHOW GLOBAL VARIABLES` for replication-related settings (`binlog_format`, `read_only`, `rpl_semi_sync_*`, `slave_parallel_threads` / `replica_parallel_threads`, `slave_parallel_mode` / `replica_parallel_mode`, `wsrep_on`, `wsrep_provider_options`).
* Executes `SHOW REPLICA STATUS` (or `SHOW SLAVE STATUS` on older versions) and `SHOW SLAVE HOSTS`.
* The IO/SQL thread state, lag, parallel-replication and semi-sync checks use the MariaDB 10.5+ field names first (`Replica_*`, `replica_parallel_*`, `rpl_semi_sync_source_enabled`, etc.) and fall back to the legacy `Slave_*` / `*master*` names. Whichever the server exposes is used.
* Logic is taken from [MySQLTuner script](https://github.com/major/MySQLTuner-perl):get_replication_status(), verified in sync with v2.8.41.


## Fact Sheet

| Fact | Value |
|----|---|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-replica-status> |
| Nagios/Icinga Check Name              | `check_mysql_replica_status` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| Requirements                          | User with `REPLICATION CLIENT` (or `SLAVE MONITOR` / `REPLICA MONITOR` on MariaDB 10.5+), locked down to `127.0.0.1` - for example `monitoring\@127.0.0.1`. Usernames in MySQL/MariaDB are limited to 16 chars in specific versions. |
| 3rd Party Python modules              | `pymysql` |


## Help

```text
usage: mysql-replica-status [-h] [-V] [--always-ok]
                            [--defaults-file DEFAULTS_FILE]
                            [--defaults-group DEFAULTS_GROUP]
                            [--lag-warning LAG_WARN] [--lag-critical LAG_CRIT]
                            [--severity {warn,crit}] [--timeout TIMEOUT]

Checks the replication status of a MySQL/MariaDB replica: I/O thread state,
SQL thread state, replication lag (`Seconds_Behind_Master` /
`Seconds_Behind_Source`), `read_only` mode, semi-synchronous replication mode
and (on MariaDB 10.5+) parallel replication settings. Also reports whether
this server is a Galera node and how many downstream replicas it is feeding.
Alerts when replication is broken, configured but not running, or lagging
behind.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --defaults-file DEFAULTS_FILE
                        MySQL/MariaDB cnf file to read user, host and password
                        from. Example: `--defaults-
                        file=/var/spool/icinga2/.my.cnf`. Default:
                        /var/spool/icinga2/.my.cnf
  --defaults-group DEFAULTS_GROUP
                        Group/section to read from in the cnf file. Default:
                        client
  --lag-warning LAG_WARN
                        Seconds of replication lag at which the WARN flag is
                        raised. A value of 0 means any lag (the historic
                        default; matches the mysqltuner cut-off). Default: 0
  --lag-critical LAG_CRIT
                        Seconds of replication lag at which the CRIT flag is
                        raised. If omitted, lag never escalates to CRIT.
  --severity {warn,crit}
                        Severity for alerts that do not depend on thresholds
                        (IO/SQL thread not running, `read_only` disabled). One
                        of `warn` or `crit`. Default: warn
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
```


## Usage Examples

```bash
./mysql-replica-status --defaults-file=/var/spool/icinga2/.my.cnf
```

Output (OK, standalone server):

```text
Everything is ok. Galera synchronous replication: NO. `binlog_format` is `ROW`. `innodb_support_xa` is `ON`. Semi-sync primary: not activated. Semi-sync replica: not activated. This is a standalone server.
```

Output (WARN, replica not running):

```text
Galera synchronous replication: NO. `binlog_format` is `ROW`. `innodb_support_xa` is `ON`. Semi-sync primary: not activated. Semi-sync replica: not activated. Replica is not running but seems to be configured (IO: `No`, SQL: `Yes`) [WARNING]. Parallel replication: disabled.

Recommendations:
* Investigate the IO/SQL thread errors via `SHOW REPLICA STATUS` (look at `Last_IO_Error`, `Last_SQL_Error`)
* Set `replica_parallel_threads` to the number of vCPUs to enable parallel replication
```


## States

* WARN or CRIT (per `--severity`) if the replica is configured but the IO or SQL thread is not running.
* WARN or CRIT (per `--severity`) if the replica is running with `read_only` = `OFF`.
* Lag (`Seconds_Behind_Master` / `Seconds_Behind_Source`):
    * WARN when lag > `--lag-warning` seconds (default 0, i.e. any lag).
    * CRIT when lag >= `--lag-critical` seconds (no default; lag never escalates to CRIT unless this is set).
    * WARN when both `Seconds_Behind_Master` and `Seconds_Behind_Source` are NULL (replication thread reports unknown lag, usually a sign of recovery).
* WARN or CRIT (per `--severity`) on MariaDB 10.5+ if parallel replication is enabled with a non-`optimistic` mode.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| mysql_replication_io_running | Number | `1` if the IO thread is running, `0` otherwise (also `0` on standalone servers). |
| mysql_replication_seconds_behind | Seconds | Replication lag from `Seconds_Behind_Master` / `Seconds_Behind_Source`. Only emitted when a replica is configured and reports a numeric value. |
| mysql_replication_slave_count | Number | Number of downstream replicas reading from this server (from `SHOW SLAVE HOSTS`). |
| mysql_replication_sql_running | Number | `1` if the SQL thread is running, `0` otherwise (also `0` on standalone servers). |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
* Credits:
    * heavily inspired by MySQLTuner (<https://github.com/major/MySQLTuner-perl>)
