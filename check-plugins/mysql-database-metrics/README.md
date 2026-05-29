# Check mysql-database-metrics


## Overview

Checks index sizes, fragmentation, and consistent engine and collation usage across all schemas in MySQL/MariaDB, and lists the largest tables by combined data and index size so storage growth can be traced before raising memory settings such as the InnoDB buffer pool. Detects schemas where mixed storage engines, collations, charsets, or table engines are in use, which can indicate configuration drift or migration issues.

The top-tables list is the fast way to find cleanup candidates. Bumping `innodb_buffer_pool_size` blindly only papers over a few oversized tables that dominate the working set; identifying and pruning them first is usually the cheaper fix.

**Important Notes:**

* See [additional notes for all mysql monitoring plugins](https://linuxfabrik.github.io/monitoring-plugins/plugins-mysql/)
* User account requires access to INFORMATION_SCHEMA (user with no privileges is sufficient) and SELECT privileges on all schemas and tables to provide accurate results
* [For most INFORMATION_SCHEMA tables, each MySQL user has the right to access them, but can see only the rows in the tables that correspond to objects for which the user has the proper access privileges.](https://dev.mysql.com/doc/refman/5.7/en/information-schema-introduction.html#information-schema-privileges) [So you can't grant permission to INFORMATION_SCHEMA directly, you have to grant SELECT permission to the tables on your own schemas, and as you do, those tables will start showing up in INFORMATION_SCHEMA queries.](https://stackoverflow.com/questions/60499772/cannot-grant-mysql-user-access-to-information-schema-database)

**Data Collection:**

* Queries `information_schema.schemata` for all non-system schemas. The system schemas `information_schema`, `mysql`, `percona`, `performance_schema`, and `sys` are skipped.
* For each schema, queries `information_schema.tables` for row counts, data/index sizes, storage engine counts, and collation counts
* Queries `information_schema.tables` once more for the largest `--top` base tables across all scanned schemas, ranked by `DATA_LENGTH + INDEX_LENGTH` (descending). `--ignore-schemas` and `--ignore-tables` apply to this list as well. Views are excluded.
* Queries `information_schema.COLUMNS` for distinct character sets and collations per schema
* Empty schemas (no tables) are surfaced as an info note in the output but do not change the state - they are common in fresh installs and lazy-init applications.
* Logic is taken from [MySQLTuner](https://github.com/major/MySQLTuner-perl):mysql_databases() and has been verified in sync with MySQLTuner. Intentional deviation: the index-vs-data-size check additionally requires one of the two sizes to exceed 10 MiB, otherwise tiny schemas (where indices proportionally dwarf data) generate constant noise.


## Fact Sheet

| Fact | Value |
|----|---|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-database-metrics> |
| Nagios/Icinga Check Name              | `check_mysql_database_metrics` |
| Check Interval Recommendation         | Every day |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| Requirements                          | User with `SELECT` privilege (typically `GRANT SELECT ON *.*`), locked down to `127.0.0.1` - for example `monitoring\@127.0.0.1`. Usernames in MySQL/MariaDB are limited to 16 chars in specific versions. |
| 3rd Party Python modules              | `pymysql` |


## Help

```text
usage: mysql-database-metrics [-h] [-V] [--always-ok] [-c CRITICAL]
                              [--defaults-file DEFAULTS_FILE]
                              [--defaults-group DEFAULTS_GROUP]
                              [--ignore-schemas IGNORE_SCHEMAS]
                              [--ignore-tables IGNORE_TABLES] [--lengthy]
                              [--timeout TIMEOUT] [--top TOP] [-w WARNING]

Checks index sizes, fragmentation, and consistent engine and collation usage
across all schemas in MySQL/MariaDB, and lists the largest tables by combined
data and index size so storage growth can be traced before raising memory
settings such as the InnoDB buffer pool. Alerts on mixed storage engines or
collations within a single schema, and on table sizes that cross the optional
--warning / --critical thresholds. Supports extended reporting via --lengthy.

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
  --ignore-schemas IGNORE_SCHEMAS
                        Regular expression matched against `SCHEMA_NAME`
                        (case-sensitive). Schemas whose name matches are
                        skipped entirely (no aggregate contribution, no
                        checks). Useful for known-mixed schemas that the admin
                        cannot or does not want to fix (common with Icinga
                        Director / Icinga Web 2 / Icinga DB schemas, which mix
                        utf8 / utf8mb4 collations by design). System schemas
                        are skipped unconditionally. Default: . Example:
                        `--ignore-
                        schemas="^(icinga_director|icingaweb2|icingadb)$"`
  --ignore-tables IGNORE_TABLES
                        Regular expression matched against `TABLE_NAME` (case-
                        sensitive). Tables whose name matches are excluded
                        from every aggregate and every per-schema check.
                        Useful for muting noisy temporary or backup tables
                        that legitimately differ from the schema-wide
                        engine/collation. Default: . Example: `--ignore-
                        tables="^(tmp_|backup_)"`
  --lengthy             Extended reporting. Default: False
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
  --top TOP             Number of largest tables (by data + index size) to
                        list. Default: 10
  -w, --warning WARNING
                        WARN threshold for the size of a single table (data +
                        index). Supports Nagios ranges with size qualifiers,
                        for example `10G`, `5G:`, `@1G:10G`. Default: report
                        only (no alerting).
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

The Director Basket activates `--lengthy` by default and pre-fills `--ignore-schemas` with `^icinga`, so admins running the shipped `MySQL Schemas Service Set` get the verbose table without the well-known Icinga-ecosystem mixed-collation noise (Icinga Director, Icinga Web 2 and Icinga DB ship schemas with mixed utf8/utf8mb4 collations by design).


## States

* WARN if the index size is larger than the data size (and at least one of them exceeds 10 MiB).
* WARN if more than one storage engine is used within a schema.
* WARN if more than one table collation is used within a schema.
* WARN if more than one charset is used across the text-like columns of a schema.
* WARN if more than one collation is used across the text-like columns of a schema.
* WARN/CRIT if a single table's combined data + index size crosses `--warning` / `--critical`. These thresholds are unset by default, so the top-tables list is reported without alerting unless you set them.
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
