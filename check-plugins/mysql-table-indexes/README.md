# Check mysql-table-indexes


## Overview

Checks user schemas in MySQL/MariaDB for two replication- and performance-relevant defects: base tables with no index at all, and InnoDB base tables without a user-defined `PRIMARY KEY`. The first check mirrors mysqltuner v2.8.41's `mysql_tables()`. The second is a Linuxfabrik addition motivated by a well-documented ROW-based-replication hotspot.

**Important Notes:**

* Requires MySQL/MariaDB v5.5+
* See [additional notes for all mysql monitoring plugins](https://linuxfabrik.github.io/monitoring-plugins/plugins-mysql/)
* The InnoDB-without-`PRIMARY KEY` check is the more actionable of the two on modern schemas. Without a user-defined `PRIMARY KEY`, InnoDB synthesises a hidden 6-byte clustered index. The replica cannot use the hidden index to look up rows for ROW-based binlog events, so it falls back to a full table scan per row event. Symptoms: replication lag, high CPU on the replica during writes. See the [MySQL reference manual: Indexes and Index Algorithms](https://dev.mysql.com/doc/refman/8.0/en/innodb-physical-structure.html) and [Percona Blog: The Importance of PRIMARY KEYs in InnoDB tables](https://www.percona.com/blog/the-importance-of-primary-keys-in-innodb-tables/)
* By default, only the first 10 affected tables per category are listed in the output. Use `--lengthy` (also enabled by default in the shipped Director Basket) to print the full list
* User account requires access to `INFORMATION_SCHEMA` (user with no privileges is sufficient) and SELECT privileges on all schemas and tables to provide accurate results
* [For most INFORMATION_SCHEMA tables, each MySQL user has the right to access them, but can see only the rows in the tables that correspond to objects for which the user has the proper access privileges.](https://dev.mysql.com/doc/refman/5.7/en/information-schema-introduction.html#information-schema-privileges) [So you can't grant permission to INFORMATION_SCHEMA directly, you have to grant SELECT permission to the tables on your own schemas, and as you do, those tables will start showing up in INFORMATION_SCHEMA queries.](https://stackoverflow.com/questions/60499772/cannot-grant-mysql-user-access-to-information-schema-database)

**Data Collection:**

* Single `LEFT JOIN` query against `information_schema.tables` and `information_schema.statistics` to find base tables with zero entries in `statistics` (no index at all). Replaces the previous O(schemas * tables) per-table query storm
* Single `NOT EXISTS` query against `information_schema.statistics` filtered on `INDEX_NAME = 'PRIMARY'` to find InnoDB base tables without a user-defined `PRIMARY KEY`
* `count(*)` against `information_schema.tables` for the total base-table count emitted as perfdata
* Logic for the "no indexes" check taken from [MySQLTuner](https://github.com/major/MySQLTuner-perl):mysql_tables() and verified in sync with MySQLTuner v2.8.41. The InnoDB-without-`PRIMARY KEY` check is a Linuxfabrik addition


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-table-indexes> |
| Nagios/Icinga Check Name              | `check_mysql_table_indexes` |
| Check Interval Recommendation         | Every day |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| Requirements                          | User with `SELECT` privilege (typically `GRANT SELECT ON *.*`), locked down to `127.0.0.1` - for example `monitoring\@127.0.0.1`. Usernames in MySQL/MariaDB are limited to 16 chars in specific versions. |
| 3rd Party Python modules              | `pymysql` |


## Help

```text
usage: mysql-table-indexes [-h] [-V] [--always-ok] [-c CRITICAL]
                           [--defaults-file DEFAULTS_FILE]
                           [--defaults-group DEFAULTS_GROUP]
                           [--ignore-schemas IGNORE_SCHEMAS]
                           [--ignore-tables IGNORE_TABLES] [--lengthy]
                           [--timeout TIMEOUT] [-w WARNING]

Checks user schemas in MySQL/MariaDB for two replication- and performance-
relevant defects: base tables with no index at all (mysqltuner v2.8.41's
`mysql_tables()` check) and InnoDB base tables without a user-defined `PRIMARY
KEY`. The second case is a documented hotspot for ROW-based replication: the
replica has to materialise each row event against an internal hidden 6-byte
index, which can degrade to a full table scan per row event. Alerts when
either count crosses `--warning` / `--critical`.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  -c, --critical CRITICAL
                        CRIT threshold for the number of bad tables (per
                        category: missing indexes / missing primary key).
                        Supports Nagios ranges. Default: 9
  --defaults-file DEFAULTS_FILE
                        MySQL/MariaDB cnf file to read user, host and password
                        from. Example: `--defaults-
                        file=/var/spool/icinga2/.my.cnf`. Default:
                        /var/spool/icinga2/.my.cnf
  --defaults-group DEFAULTS_GROUP
                        Group/section to read from in the cnf file. Default:
                        client
  --ignore-schemas IGNORE_SCHEMAS
                        Regex of schema names to exclude from the check.
                        Evaluated by MySQL via `NOT REGEXP`. Example:
                        `--ignore-schemas=^icinga`. Default: <none>
  --ignore-tables IGNORE_TABLES
                        Regex of table names to exclude from the check.
                        Evaluated by MySQL via `NOT REGEXP`. Example:
                        `--ignore-tables=^tmp_`. Default: <none>
  --lengthy             Extended reporting. Default: False
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
  -w, --warning WARNING
                        WARN threshold for the number of bad tables (per
                        category: missing indexes / missing primary key).
                        Supports Nagios ranges. Default: 0
```


## Usage Examples

```bash
./mysql-table-indexes --defaults-file=/var/spool/icinga2/.my.cnf
```

OK output:

```text
Everything is ok. 132 base tables across user schemas.
```

WARN output:

```text
132 base tables across user schemas.

3 tables without any index [WARNING]:
* `employees`.`current_dept_emp`
* `employees`.`dept_emp_latest_date`
* `legacy`.`audit_log`

5 InnoDB tables without a user-defined `PRIMARY KEY` [WARNING]:
* `legacy`.`audit_log`
* `legacy`.`sessions`
* `staging`.`import_buffer`
* `staging`.`migration_old`
* `tmp`.`workspace`

Recommendations:
* Add at least a `PRIMARY KEY` (or any secondary index) on each of the listed tables. A heap table without any index forces every query against it into a full table scan
* Add a `PRIMARY KEY` to each of the listed InnoDB tables. Without a user-defined `PRIMARY KEY`, InnoDB falls back to a hidden 6-byte clustered index that ROW-based replication cannot use efficiently (worst case: full table scan per row event on the replica). Symptoms: replication lag, high CPU on replicas during writes
```


## States

* WARN if the number of tables without any index is at or above `--warning` (default: 1). CRIT at `--critical` (default: 10).
* WARN if the number of InnoDB tables without a user-defined `PRIMARY KEY` is at or above `--warning`. CRIT at `--critical`.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| mysql_innodb_tables_without_primary_key | Number | Number of InnoDB base tables in user schemas without a user-defined `PRIMARY KEY`. |
| mysql_tables_without_index | Number | Number of base tables in user schemas with zero entries in `information_schema.statistics`. |
| mysql_total_tables | Number | Total number of base tables across user schemas (excludes system schemas and tables matched by `--ignore-schemas` / `--ignore-tables`). |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
* Credits:

    * heavily inspired by MySQLTuner (<https://github.com/major/MySQLTuner-perl>)
