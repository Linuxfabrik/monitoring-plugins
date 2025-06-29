# Check mysql-table-definition-cache

## Overview

Checks the size of the table definition cache in MySQL/MariaDB. Logic is taken from [MySQLTuner script](https://github.com/major/MySQLTuner-perl):mysql_stats().

User account requires:

* Access to INFORMATION_SCHEMA (user with no privileges is sufficient).
* SELECT privileges on all schemas and tables to provide accurate results.

Hints:

* See [additional notes for all mysql monitoring plugins](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/PLUGINS-MYSQL.rst)
* [For most INFORMATION_SCHEMA tables, each MySQL user has the right to access them, but can see only the rows in the tables that correspond to objects for which the user has the proper access privileges.](https://dev.mysql.com/doc/refman/5.7/en/information-schema-introduction.html#information-schema-privileges). [So you can't grant permission to INFORMATION_SCHEMA directly, you have to grant SELECT permission to the tables on your own schemas, and as you do, those tables will start showing up in INFORMATION_SCHEMA queries](https://stackoverflow.com/questions/60499772/cannot-grant-mysql-user-access-to-information-schema-database). Then this check provide correct results.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-table-definition-cache> |
| Check Interval Recommendation         | Once an hour |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |
| 3rd Party Python modules              | `pymysql` |


## Help

```text
usage: mysql-table-definition-cache [-h] [-V] [--always-ok]
                                    [--defaults-file DEFAULTS_FILE]
                                    [--defaults-group DEFAULTS_GROUP]
                                    [--timeout TIMEOUT]

Checks the size of the table definition cache in MySQL/MariaDB.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --defaults-file DEFAULTS_FILE
                        Specifies a cnf file to read parameters like user,
                        host and password from (instead of specifying them on
                        the command line), for example
                        `/var/spool/icinga2/.my.cnf`. Default:
                        /var/spool/icinga2/.my.cnf
  --defaults-group DEFAULTS_GROUP
                        Group/section to read from in the cnf file. Default:
                        client
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
```


## Usage Examples

```bash
./mysql-table-definition-cache --defaults-file=/var/spool/icinga2/.my.cnf
```

Output:

```text
table_definition_cache (400) is lower than number of tables (516) [WARNING]. Set table_definition_cache > 516 or to -1 (autosizing if supported).
```


## States

* WARN if number of table definitions that can be cached is less than the total number of tables.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| mysql_table_definition_cache | Number | Number of table definitions that can be cached. |
| mysql_total_tables | Number | Total number of tables. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)

* License: The Unlicense, see [LICENSE file](https://unlicense.org/).

* Credits:

    * heavily inspired by MySQLTuner (<https://github.com/major/MySQLTuner-perl>)
