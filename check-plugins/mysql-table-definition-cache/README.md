# Check mysql-table-definition-cache

## Overview

Checks the table definition cache size in MySQL/MariaDB. A cache that is too small to hold definitions for all tables causes repeated disk reads. Logic is taken from [MySQLTuner script](https://github.com/major/MySQLTuner-perl):mysql_stats(), v1.9.8.

**Data Collection:**

* Queries `SHOW GLOBAL VARIABLES` for `table_definition_cache`
* Counts total tables via `SELECT COUNT(*) FROM information_schema.tables`

**Compatibility:**

* Cross-platform


**