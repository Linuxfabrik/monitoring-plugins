# Check mysql-table-indexes

## Overview

Checks for tables without indexes in MySQL/MariaDB. Missing indexes on base tables can cause replication and performance issues. Logic is taken from [MySQLTuner script](https://github.com/major/MySQLTuner-perl):mysql_tables(), v1.9.8.

**Alerting Logic:**

* WARN if any user tables (base tables) without indexes are found
* System schemas (`mysql`, `information_schema`, `performance_schema`, `percona`, `sys`) are excluded from the check

**Data Collection:**

* Queries `INFORMATION_SCHEMA.tables` to discover user schemas and base tables
* Queries `INFORMATION_SCHEMA.statistics` to check for indexes on each table

**Compatibility:**

* Requires MySQL/MariaDB v5.5+

**Important Notes:**

* See [additional notes for all mysql monitoring plugins](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/PLUGINS-MYSQL.md)
* User account requires access to `INFORMATION_SCHEMA` (user with no privileges is sufficient) and SELECT privileges on all schemas and tables to provide accurate results
* [For most INFORMATION_SCHEMA tables, each MySQL user has the right to access them, but can see only the rows in the tables that correspond to objects for which the user has the proper access privileges.](https://dev.mysql.com/doc/refman/5.7/en/information-schema-introduction.html#information-schema-privileges) [So you can't grant permission to INFORMATION_SCHEMA directly, you have to grant SELECT permission to the tables on your own schemas, and as you do, those tables will start showing up in INFORMATION_SCHEMA queries.](https://stackoverflow.com/questions/60499772/cannot-grant-mysql-user-access-to-information-schema-database)


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-table-indexes> |
| Nagios/Icinga Check Name              | `check_mysql_table_indexes` |
| Check Interval Recommendation         | Once a day |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |
| 3rd Party Python modules              | `pymysql` |


## Help

```text
usage: mysql-table-indexes [-h] [-V] [--always-ok]
                           [--defaults-file DEFAULTS_FILE]
                           [--defaults-group DEFAULTS_GROUP]
                           [--timeout TIMEOUT]

Checks for tables without primary keys or with duplicate indexes in
MySQL/MariaDB. Missing primary keys can cause replication and performance
issues. Alerts when tables without primary keys or with duplicate indexes are
found.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --defaults-file DEFAULTS_FILE
                        MySQL/MariaDB cnf file to read parameters like user,
                        host and password from (instead of specifying them on
                        the command line). Example:
                        `/var/spool/icinga2/.my.cnf`. Default:
                        /var/spool/icinga2/.my.cnf
  --defaults-group DEFAULTS_GROUP
                        Group/section to read from in the cnf file. Default:
                        client
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
```


## Usage Examples

```bash
./mysql-table-indexes --defaults-file=/var/spool/icinga2/.my.cnf
```

Output:

```text
Tables without indexes [WARNING]:
* employees.current_dept_emp
* employees.dept_emp_latest_date
```


## States

* OK if all user tables have at least one index.
* WARN if tables without indexes are found.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

There is no perfdata.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
* Credits:

    * heavily inspired by MySQLTuner (<https://github.com/major/MySQLTuner-perl>)
