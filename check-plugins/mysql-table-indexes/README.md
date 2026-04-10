# Check mysql-table-indexes

## Overview

Checks for tables without indexes in MySQL/MariaDB. Missing indexes on base tables can cause replication and performance issues. Logic is taken from [MySQLTuner script](https://github.com/major/MySQLTuner-perl):mysql_tables(), v1.9.8.

**Data Collection:**

* Queries `INFORMATION_SCHEMA.tables` to discover user schemas and base tables
* Queries `INFORMATION_SCHEMA.statistics` to check for indexes on each table

**Compatibility:**

* Cross-platform


**