# Check mysql-storage-engines


## Overview

Checks storage engine health in MySQL/MariaDB. Lists per-engine table counts and sizes, flags InnoDB being enabled but no `InnoDB` tables existing, hunts fragmented tables, and warns when an `AUTO_INCREMENT` value approaches its column-type maximum. The fragmentation rule mirrors mysqltuner: only tables larger than 100 MiB with more than 10% `DATA_FREE` count.

**Important Notes:**

* See [additional notes for all mysql monitoring plugins](https://linuxfabrik.github.io/monitoring-plugins/plugins-mysql/)
* The `AUTO_INCREMENT` check compares each column to its own type ceiling (`TINYINT`/`SMALLINT`/`MEDIUMINT`/`INT`/`BIGINT`, signed/unsigned), not always to `BIGINT UNSIGNED` like mysqltuner does. This is an intentional deviation, because mysqltuner's `BIGINT`-only comparison is effectively dead code for tables on `INT UNSIGNED` (4-byte) AUTO_INCREMENT columns, the single most common case in modern schemas: a table about to hit the 4.3 billion limit shows up as less than 1% of `BIGINT UNSIGNED` and never alerts
* Fragmented `InnoDB` tables are only hunted when `innodb_file_per_table = ON`. When everything lives in `ibdata1` per-table `OPTIMIZE` is meaningless and the plugin skips that case (matches mysqltuner)
* The fragmentation `OPTIMIZE TABLE` advice for non-InnoDB engines and `ALTER TABLE ... FORCE` advice for InnoDB are mysqltuner's recommendations. On modern MySQL/MariaDB, `OPTIMIZE TABLE` on InnoDB is internally mapped to `ALTER TABLE FORCE` anyway, but the explicit form avoids the misleading "Table does not support optimize, doing recreate + analyze instead" warning
* User account requires access to INFORMATION_SCHEMA (user with no privileges is sufficient) and SELECT privileges on all schemas and tables to provide accurate results
* [For most INFORMATION_SCHEMA tables, each MySQL user has the right to access them, but can see only the rows in the tables that correspond to objects for which the user has the proper access privileges.](https://dev.mysql.com/doc/refman/5.7/en/information-schema-introduction.html#information-schema-privileges) [So you can't grant permission to INFORMATION_SCHEMA directly, you have to grant SELECT permission to the tables on your own schemas, and as you do, those tables will start showing up in INFORMATION_SCHEMA queries.](https://stackoverflow.com/questions/60499772/cannot-grant-mysql-user-access-to-information-schema-database)

**Data Collection:**

* Queries `SHOW GLOBAL VARIABLES` for `innodb_file_per_table`
* Queries `information_schema.engines` for available storage engines
* Queries `information_schema.tables` grouped by `ENGINE` for per-engine counts and data/index sizes
* Queries `information_schema.tables` for fragmentation candidates (`DATA_LENGTH > 100 MiB` and `DATA_FREE / (DATA_LENGTH + INDEX_LENGTH + DATA_FREE) > 10%`)
* Joins `information_schema.tables` against `information_schema.columns` (filtered by `EXTRA = 'auto_increment'`) so the `AUTO_INCREMENT` percentage can be computed against the actual column ceiling
* Logic taken from [MySQLTuner](https://github.com/major/MySQLTuner-perl):check_storage_engines() and verified in sync with MySQLTuner


## Fact Sheet

| Fact | Value |
|----|---|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-storage-engines> |
| Nagios/Icinga Check Name              | `check_mysql_storage_engines` |
| Check Interval Recommendation         | Every day |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| Requirements                          | User with `SELECT` privilege (typically `GRANT SELECT ON *.*`), locked down to `127.0.0.1` - for example `monitoring\@127.0.0.1`. Usernames in MySQL/MariaDB are limited to 16 chars in specific versions. |
| 3rd Party Python modules              | `pymysql` |


## Help

```text
usage: mysql-storage-engines [-h] [-V] [--always-ok]
                             [--critical-autoincrement-pct CRITICAL_AI]
                             [--critical-fragmented-tables CRITICAL_FRAG]
                             [--defaults-file DEFAULTS_FILE]
                             [--defaults-group DEFAULTS_GROUP]
                             [--ignore-schemas IGNORE_SCHEMAS]
                             [--ignore-tables IGNORE_TABLES] [--lengthy]
                             [--timeout TIMEOUT]
                             [--warning-autoincrement-pct WARNING_AI]
                             [--warning-fragmented-tables WARNING_FRAG]

Checks storage engine health in MySQL/MariaDB. Lists per-engine table counts
and sizes, flags InnoDB-enabled-but-no-InnoDB-tables, hunts fragmented tables,
and warns when an `AUTO_INCREMENT` value approaches its column-type maximum.
The fragmentation rule mirrors mysqltuner: only tables larger than 100 MiB
with more than 10% `DATA_FREE` count. The `AUTO_INCREMENT` check goes beyond
mysqltuner by comparing each column to its own type ceiling (`TINYINT` to
`BIGINT`, signed/unsigned), so tables using `INT UNSIGNED` are caught long
before they hit the duplicate-key error.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --critical-autoincrement-pct CRITICAL_AI
                        CRIT threshold for the percentage of the column-type
                        maximum an `AUTO_INCREMENT` value uses. Supports
                        Nagios ranges. Default: 90
  --critical-fragmented-tables CRITICAL_FRAG
                        CRIT threshold for the number of fragmented tables.
                        Supports Nagios ranges. Default: 4
  --defaults-file DEFAULTS_FILE
                        MySQL/MariaDB cnf file to read user, host and password
                        from. Example: `--defaults-
                        file=/var/spool/icinga2/.my.cnf`. Default:
                        /var/spool/icinga2/.my.cnf
  --defaults-group DEFAULTS_GROUP
                        Group/section to read from in the cnf file. Default:
                        client
  --ignore-schemas IGNORE_SCHEMAS
                        Regex of schema names to exclude from every check (no
                        aggregate contribution, no per-schema alerts).
                        Evaluated by MySQL via `NOT REGEXP`. Example:
                        `--ignore-schemas=^icinga`. Default: <none>
  --ignore-tables IGNORE_TABLES
                        Regex of table names to exclude from every check.
                        Evaluated by MySQL via `NOT REGEXP`. Example:
                        `--ignore-tables=^tmp_`. Default: <none>
  --lengthy             Extended reporting. Default: False
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
  --warning-autoincrement-pct WARNING_AI
                        WARN threshold for the percentage of the column-type
                        maximum an `AUTO_INCREMENT` value uses. Supports
                        Nagios ranges. Default: 75
  --warning-fragmented-tables WARNING_FRAG
                        WARN threshold for the number of fragmented tables.
                        Supports Nagios ranges. Default: 0
```


## Usage Examples

```bash
./mysql-storage-engines --defaults-file=/var/spool/icinga2/.my.cnf --lengthy
```

OK output:

```text
Everything is ok. 1042 tables across 2 engines (8.4GiB total). highest `AUTO_INCREMENT` usage: 12.3% on `accounting`.`contact` (`int(11) unsigned`).

Engine ! Tables ! Total  ! Data   ! Index
-------+--------+--------+--------+-------
InnoDB ! 1040   ! 8.4GiB ! 7.9GiB ! 491MiB
MyISAM ! 2      ! 1.1MiB ! 1.0MiB ! 100KiB
```

WARN output:

```text
3 tables across 2 engines (2.6GiB total). highest `AUTO_INCREMENT` usage: 81.2% on `accounting`.`contact` (`int(11) unsigned`).

3 fragmented tables, 2.6GiB reclaimable [WARNING].

`accounting`.`contact` `AUTO_INCREMENT` is at 81.2% of `int(11) unsigned` capacity [WARNING].

Recommendations:
* ALTER TABLE `backup20190815`.`docs` FORCE; -- can free 2.6GiB
* OPTIMIZE TABLE `legacy`.`audit_log`; -- can free 56.0MiB
* OPTIMIZE TABLE `tmp`.`stage`; -- can free 12.0MiB
* Migrate `accounting`.`contact` to a wider integer type (or archive old rows) before `AUTO_INCREMENT` exhausts the current `int(11) unsigned` ceiling
```


## States

* WARN if `InnoDB` is enabled but no `InnoDB` tables exist.
* WARN if the number of fragmented tables crosses `--warning-fragmented-tables` (default: 1). CRIT at `--critical-fragmented-tables` (default: 5).
* WARN if any table's `AUTO_INCREMENT` value is at `--warning-autoincrement-pct` (default: 75%) or more of the column-type maximum. CRIT at `--critical-autoincrement-pct` (default: 90%).
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| mysql_autoincrement_max_pct | Percentage | Highest `AUTO_INCREMENT` percentage across all tables, computed against each column's type ceiling. |
| mysql_fragmented_data_free | Bytes | Total `DATA_FREE` across fragmented tables (reclaimable disk space). |
| mysql_fragmented_tables | Number | Count of fragmented tables that pass the size and percentage cutoffs. |
| mysql_table_count | Number | Total tables across all non-system schemas. |
| mysql_total_size | Bytes | Sum of `DATA_LENGTH + INDEX_LENGTH` across all non-system tables. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
* Credits:
    * heavily inspired by MySQLTuner (<https://github.com/major/MySQLTuner-perl>)
