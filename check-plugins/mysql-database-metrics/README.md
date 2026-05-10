# Check mysql-database-metrics


## Overview

Checks index sizes, fragmentation, and consistent engine and collation usage across all schemas in MySQL/MariaDB. Detects schemas where mixed storage engines, collations, charsets, or table engines are in use, which can indicate configuration drift or migration issues.

**Important Notes:**

* See [additional notes for all mysql monitoring plugins](https://linuxfabrik.github.io/monitoring-plugins/plugins-mysql/)
* User account requires access to INFORMATION_SCHEMA (user with no privileges is sufficient) and SELECT privileges on all schemas and tables to provide accurate results
* [For most INFORMATION_SCHEMA tables, each MySQL user has the right to access them, but can see only the rows in the tables that correspond to objects for which the user has the proper access privileges.](https://dev.mysql.com/doc/refman/5.7/en/information-schema-introduction.html#information-schema-privileges) [So you can't grant permission to INFORMATION_SCHEMA directly, you have to grant SELECT permission to the tables on your own schemas, and as you do, those tables will start showing up in INFORMATION_SCHEMA queries.](https://stackoverflow.com/questions/60499772/cannot-grant-mysql-user-access-to-information-schema-database)

**Data Collection:**

* Queries `information_schema.schemata` for all non-system schemas. The system schemas `information_schema`, `mysql`, `percona`, `performance_schema`, and `sys` are skipped.
* For each schema, queries `information_schema.tables` for row counts, data/index sizes, storage engine counts, and collation counts
* Queries `information_schema.COLUMNS` for distinct character sets and collations per schema
* Empty schemas (no tables) are surfaced as an info note in the output but do not change the state - they are common in fresh installs and lazy-init applications.
* Logic is taken from [MySQLTuner](https://github.com/major/MySQLTuner-perl):mysql_databases() and has been verified in sync with MySQLTuner v2.8.41. Intentional deviation: the index-vs-data-size check additionally requires one of the two sizes to exceed 10 MiB, otherwise tiny schemas (where indices proportionally dwarf data) generate constant noise.


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
usage: mysql-database-metrics [-h] [-V] [--always-ok]
                              [--defaults-file DEFAULTS_FILE]
                              [--defaults-group DEFAULTS_GROUP]
                              [--ignore-schemas IGNORE_SCHEMAS]
                              [--ignore-tables IGNORE_TABLES] [--lengthy]
                              [--timeout TIMEOUT]

Checks index sizes, fragmentation, and consistent engine and collation usage
across all schemas in MySQL/MariaDB. Alerts on mixed storage engines or
collations within a single schema.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
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
```


## Usage Examples

```bash
./mysql-database-metrics --defaults-file=/var/spool/icinga2/.my.cnf
```

Output:

```text
There are warnings.

* Index size is larger than data size: xca (11.4MiB / 5.4MiB)
* Mixed storage engines (use one engine for all tables in a schema): appldb (2x)
* Mixed table collations (use one collation for all tables in a schema): accounting (2x), piwik (2x), wordpress-www (2x)
* Mixed column charsets (use one charset for all text-like columns if possible): accounting (2x), piwik (2x), django-mvc (2x), wordpress-www (2x), django-mvc-devel (2x)
* Mixed column collations (use one collation for all text-like columns if possible): accounting (3x), piwik (2x), django-mvc (2x), wordpress-www (2x), django-mvc-devel (2x)
```

When everything is clean:

```text
8 user schema(s) scanned, 246 table(s), 12.4M rows, 1.2GiB data, 384.0MiB indices. Everything is ok.
```

With `--lengthy`, the output additionally includes a per-schema breakdown table mirroring what `mysqltuner --dbstat` prints (Schema, Tables, Rows, Data, Index, Total, Engines, Table Collations, Column Charsets, Column Collations).

The Director Basket activates `--lengthy` by default and pre-fills `--ignore-schemas` with `^icinga`, so admins running the shipped `MySQL Schemas Service Set` get the verbose table without the well-known Icinga-ecosystem mixed-collation noise (Icinga Director, Icinga Web 2 and Icinga DB ship schemas with mixed utf8/utf8mb4 collations by design).


## States

* WARN if the index size is larger than the data size (and at least one of them exceeds 10 MiB).
* WARN if more than one storage engine is used within a schema.
* WARN if more than one table collation is used within a schema.
* WARN if more than one charset is used across the text-like columns of a schema.
* WARN if more than one collation is used across the text-like columns of a schema.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| mysql_database_count | Number | Number of user schemas scanned (system schemas excluded). |
| mysql_total_data_size | Bytes | Sum of `DATA_LENGTH` across all scanned tables. |
| mysql_total_index_size | Bytes | Sum of `INDEX_LENGTH` across all scanned tables. |
| mysql_total_rows | Number | Sum of `TABLE_ROWS` across all scanned tables. Note: for InnoDB this is an estimate, not an exact count. |
| mysql_total_tables | Number | Total number of tables across all scanned schemas. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
* Credits:
    * heavily inspired by MySQLTuner (<https://github.com/major/MySQLTuner-perl>)
