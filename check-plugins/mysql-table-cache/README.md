# Check mysql-table-cache

## Overview

Checks the hit rate for open table cache lookups in MySQL/MariaDB. A low hit rate indicates that `table_open_cache` may need to be increased. Logic is taken from [MySQLTuner script](https://github.com/major/MySQLTuner-perl):mysql_stats(), v1.9.8.

**Data Collection:**

* Queries `SHOW GLOBAL VARIABLES` for `open_files_limit` and `table_open_cache`
* Queries `SHOW GLOBAL STATUS` for `Open_tables`, `Opened_tables`, `Table_open_cache_hits`, and `Table_open_cache_misses`
* If `Table_open_cache_hits` is available, the hit rate is calculated as `Table_open_cache_hits / (Table_open_cache_hits + Table_open_cache_misses) * 100`. Otherwise falls back to `Open_tables / Opened_tables * 100`.

**Compatibility:**

* Cross-platform


**