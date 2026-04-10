# Check mysql-version

## Overview

Checks the installed MySQL/MariaDB version against the endoflife.date API and alerts if the version is end-of-life or if newer major, minor, or patch releases are available. By default, alerts 30 days before the official EOL date. The offset is configurable.

**Data Collection:**

* Detects the installed version by running `mysqld --version`, `mariadb --version`, or `mysql --version`
* Queries the [endoflife.date API](https://endoflife.date/) for MySQL or MariaDB lifecycle data
* Caches the API response in a local SQLite database to reduce API calls

**Compatibility:**

* Cross-platform

**Important Notes:**

* Must run on the MySQL/MariaDB server itself to detect the installed version


## 