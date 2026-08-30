# Check mysql-database-metrics


## Overview

Checks index sizes, fragmentation, and consistent engine and collation usage across all schemas in MySQL/MariaDB, and lists the largest tables by combined data and index size so storage growth can be traced before raising memory settings such as the InnoDB buffer pool. Detects schemas where mixed storage engines, collations, charsets, or table engines are in use, which can indicate configuration drift or migration issues.

The top-tables list is the fast way to find cleanup candidates. Bumping `innodb_buffer_pool_size` blindly only papers over a few oversized tables that dominate the working set; identifying and pruning them first is usually the cheaper fix.

**Important Notes:**

* See [additional notes for all mysql monitoring plugins](https://linuxfabrik.github.io/monitoring-plugins/plugins-mysql/)
* User account requires access to INFORMATION_SCHEMA (user with no privileges is sufficient) and SELECT privileges on all schemas and tables to provide accurate results
* [For most INFORMATION_SCHEMA tables, each MySQL user has the right to access them, but can see only the rows in the tables that correspond to objects for which the user has the proper access privileges.](https://dev.mysql.com/doc/refman/5.7/en/information-schema-introduction.html#information-schema-privileges) [So you can't grant permission to INFORMATION_SCHEMA directly, you have to grant SELECT permission to the tables on your own schemas, and as you do, those tables will start showing up in INFORMATION_SCHEMA queries.](https://stackoverflow.com/questions/60499772/cannot-grant-mysql-user-access-to-information-schema-database)
* `--match` and `--ignore` take Python regular expressions and are matched against the fully qualified table identifier `schema.table`, so the same parameter scopes the check to a schema (`^shop\.`) or to a single table (`^shop\.orders$`). Both filter before anything is counted or aggregated, so a filtered check reports only what it was asked to look at
* `--ignore-schemas` and `--ignore-tables` still work but are deprecated and no longer shown in `--help`. They match the bare schema resp. table name; move them to `--ignore`
* A schema without any table cannot match `--match`, so it drops out of the report while `--match` is given

**Data Collection:**

* Queries `information_schema.schemata` for all non-system schemas. The system schemas `information_schema`, `mysql`, `percona`, `performance_schema`, and `sys` are skipped.
* Queries `information_schema.tables` for the row counts, data/index sizes, storage engines and collations of every table in those schemas
* Queries `information_schema.COLUMNS` for the distinct character sets and collations per table
* The largest `--top` base tables are ranked by `DATA_LENGTH + INDEX_LENGTH` (descending) across all scanned schemas. Views are excluded from that list
* Empty schemas (no tables) are surfaced as an info note in the output but do not change the state - they are common in fresh installs and lazy-init applications.
* Logic is taken from [MySQLTuner](https://github.com/major/MySQLTuner-perl):mysql_databases() and has been verified in sync with MySQLTuner. Intentional deviation: the index-vs-data-size check additionally requires one of the two sizes to exceed 10 MiB, otherwise tiny schemas (where indices proportionally dwarf data) generate constant noise.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-database-metrics> |
| Nagios/Icinga Check Name              | `check_mysql_database_metrics` |
| Check Interval Recommendation         | Every day |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No (runs with Python interpreter) |
| Requirements                          | User with `SELECT` privilege (typically `GRANT SELECT ON *.*`), locked down to `127.0.0.1` - for example `monitoring@127.0.0.1`. Usernames in MySQL/MariaDB are limited to 16 chars in specific versions. |
| 3rd Party Python modules              | `pymysql` |


## Help

```text
usage: mysql-database-metrics [-h] [-V] [--always-ok] [-c CRITICAL]
                              [--defaults-file DEFAULTS_FILE]
                              [--defaults-group DEFAULTS_GROUP]
                              [--ignore IGNORE] [--lengthy] [--match MATCH]
                              [--no-perfdata] [--timeout TIMEOUT] [--top TOP]
                              [-w WARNING]

Checks index sizes, fragmentation, and consistent engine and collation usage
across all schemas in MySQL/MariaDB, and lists the largest tables by combined
data and index size so storage growth can be traced before raising memory
settings such as the InnoDB buffer pool. Alerts on mixed storage engines or
collations within a single schema, and on table sizes that cross the optional
--warning / --critical thresholds. `--match` and `--ignore` narrow every
aggregate and every check down to a single schema or table. Supports extended
reporting via --lengthy.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  -c, --critical CRITICAL
                        CRIT threshold for the size of a single table (data +
                        index). Supports Nagios ranges with size qualifiers,
                        for example `10G`, `5G:`, `@1G:10G`. Default: report
                        only (no alerting).
  --defaults-file DEFAULTS_FILE
                        MySQL/MariaDB cnf file to read user, host and password
                        from (instead of specifying them on the command line).
                        Example: `/var/spool/icinga2/.my.cnf`. Default:
                        /var/spool/icinga2/.my.cnf
  --defaults-group DEFAULTS_GROUP
                        Group/section to read from in the cnf file. Default:
                        client
  --ignore IGNORE       Ignore tables whose name matches this Python regular
                        expression. Matched against the fully qualified table
                        identifier `schema.table`, so one pattern can drop a
                        whole schema or a single table. Excluded tables
                        contribute to no aggregate and to no check; system
                        schemas are skipped unconditionally. Case-sensitive by
                        default; use `(?i)` for case-insensitive matching. Can
                        be specified multiple times. Default: None. Example:
                        `--ignore="^(icinga_director|icingaweb2|icingadb)\."`
                        to skip the schemas that mix utf8 / utf8mb4 collations
                        by design. Example: `--ignore="\.(tmp_|backup_)"` to
                        mute noisy temporary and backup tables that
                        legitimately differ from the schema-wide engine or
                        collation.
  --lengthy             Extended reporting.
  --match MATCH         Only check tables whose name matches this Python
                        regular expression. Matched against the fully
                        qualified table identifier `schema.table`. A schema
                        without any table cannot match, so it drops out of the
                        report while this is given. Case-sensitive by default;
                        use `(?i)` for case-insensitive matching. Can be
                        specified multiple times. If both `--match` and
                        `--ignore` are given, an item must match `--match` AND
                        not match `--ignore` to be reported (include first,
                        exclude second). Default: None. Example:
                        `--match="^shop\."` to check the `shop` schema only.
                        Example: `--match="^shop\.orders$"` to check one table
                        only.
  --no-perfdata         Suppress the performance data section from the output.
                        The status message and the exit code are unaffected,
                        so alerting keeps working while trending data is
                        dropped.
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
  --top TOP             Number of largest tables (by data + index size) to
                        list. Default: 10
  -w, --warning WARNING
                        WARN threshold for the size of a single table (data +
                        index). Supports Nagios ranges with size qualifiers,
                        for example `10G`, `5G:`, `@1G:10G`. Default: report
                        only (no alerting).

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/mysql-database-metrics/
```


## Usage Examples

```bash
./mysql-database-metrics --defaults-file=/var/spool/icinga2/.my.cnf --lengthy
```

Output against the MySQL `sakila` sample database. The Director Basket enables `--lengthy` by default, so this is the verbose form including the per-schema breakdown that mirrors `mysqltuner --dbstat`:

```text
There are warnings.

* Mixed column collations (use one collation for all text-like columns if possible): sakila (2x)

Top 10 tables by size:

Schema ! Table      ! Data     ! Index    ! Total
-------+------------+----------+----------+---------
sakila ! rental     ! 1.5MiB   ! 1.2MiB   ! 2.7MiB
sakila ! payment    ! 1.5MiB   ! 736.0KiB ! 2.2MiB
sakila ! inventory  ! 160.0KiB ! 144.0KiB ! 304.0KiB
sakila ! film       ! 176.0KiB ! 80.0KiB  ! 256.0KiB
sakila ! film_actor ! 176.0KiB ! 80.0KiB  ! 256.0KiB
sakila ! film_text  ! 176.0KiB ! 16.0KiB  ! 192.0KiB
sakila ! customer   ! 80.0KiB  ! 48.0KiB  ! 128.0KiB
sakila ! address    ! 80.0KiB  ! 16.0KiB  ! 96.0KiB
sakila ! staff      ! 64.0KiB  ! 32.0KiB  ! 96.0KiB
sakila ! city       ! 48.0KiB  ! 16.0KiB  ! 64.0KiB

Schema ! Tables ! Rows  ! Data   ! Index  ! Total  ! Engines ! Table Collations   ! Column Charsets ! Column Collations
-------+--------+-------+--------+--------+--------+---------+--------------------+-----------------+--------------------------------
sakila ! 23     ! 47372 ! 4.1MiB ! 2.4MiB ! 6.5MiB ! InnoDB  ! utf8mb4_general_ci ! utf8mb4         ! utf8mb4_bin, utf8mb4_general_ci
```

When everything is clean, the verdict leads with `Everything is ok.` followed by the scanned-scope summary, then the top-tables list.

Without size thresholds the plugin only reports the list. Set `--warning` / `--critical` (Nagios ranges with size qualifiers) to alert on individual tables; the state marker sits on the `Total` column. Without `--lengthy` the per-schema breakdown collapses to the compact `Schema | Tables | Size | Issues` form:

```bash
./mysql-database-metrics --defaults-file=/var/spool/icinga2/.my.cnf --warning=2M --critical=10M
```

```text
There are warnings. (warn=2M crit=10M)

* Mixed column collations (use one collation for all text-like columns if possible): sakila (2x)

Top 10 tables by size (warn=2M crit=10M):

Schema ! Table      ! Data     ! Index    ! Total
-------+------------+----------+----------+-----------------
sakila ! rental     ! 1.5MiB   ! 1.2MiB   ! 2.7MiB [WARNING]
sakila ! payment    ! 1.5MiB   ! 736.0KiB ! 2.2MiB [WARNING]
sakila ! inventory  ! 160.0KiB ! 144.0KiB ! 304.0KiB
sakila ! film       ! 176.0KiB ! 80.0KiB  ! 256.0KiB
sakila ! film_actor ! 176.0KiB ! 80.0KiB  ! 256.0KiB
sakila ! film_text  ! 176.0KiB ! 16.0KiB  ! 192.0KiB
sakila ! customer   ! 80.0KiB  ! 48.0KiB  ! 128.0KiB
sakila ! address    ! 80.0KiB  ! 16.0KiB  ! 96.0KiB
sakila ! staff      ! 64.0KiB  ! 32.0KiB  ! 96.0KiB
sakila ! city       ! 48.0KiB  ! 16.0KiB  ! 64.0KiB

Schema ! Tables ! Size   ! Issues
-------+--------+--------+--------------------
sakila ! 23     ! 6.5MiB ! 2 column collations
```

`rental` (2.7MiB) and `payment` (2.2MiB) cross the 2M warning threshold; none reaches 10M, so the overall state is WARN.

Scope the check to one schema, or mute a noisy one:

```bash
./mysql-database-metrics --match="^sakila\."
./mysql-database-metrics --ignore="^icinga" --ignore="\.(tmp_|backup_)"
```

The Director Basket activates `--lengthy` by default and pre-fills `--ignore` with `^icinga`, so admins running the shipped `MySQL Schemas Service Set` get the verbose table without the well-known Icinga-ecosystem mixed-collation noise (Icinga Director, Icinga Web 2 and Icinga DB ship schemas with mixed utf8/utf8mb4 collations by design).


## States

* WARN if the index size is larger than the data size (and at least one of them exceeds 10 MiB).
* WARN if more than one storage engine is used within a schema.
* WARN if more than one table collation is used within a schema.
* WARN if more than one charset is used across the text-like columns of a schema.
* WARN if more than one collation is used across the text-like columns of a schema.
* WARN/CRIT if a single table's combined data + index size crosses `--warning` / `--critical`. These thresholds are unset by default, so the top-tables list is reported without alerting unless you set them.
* Tables dropped by `--match` / `--ignore` contribute to no aggregate and to no check, so a check filtered down to nothing reports OK.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| mysql_database_count | Number | Number of user schemas scanned (system schemas excluded). |
| mysql_total_data_size | Bytes | Sum of `DATA_LENGTH` across all scanned tables. |
| mysql_total_index_size | Bytes | Sum of `INDEX_LENGTH` across all scanned tables. |
| mysql_total_rows | Number | Sum of `TABLE_ROWS` across all scanned tables. Note: for InnoDB this is an estimate, not an exact count. |
| mysql_total_tables | Number | Total number of tables across all scanned schemas. |
| `<schema>_<table>_size` | Bytes | Combined `DATA_LENGTH + INDEX_LENGTH` of one of the `--top` largest tables. One metric per listed table; the label is sanitized (non-alphanumeric characters become `_`). |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
* Credits:
    * heavily inspired by MySQLTuner (<https://github.com/major/MySQLTuner-perl>)
