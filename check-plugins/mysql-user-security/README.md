# Check mysql-user-security


## Overview

Checks MySQL/MariaDB user security settings, including accounts with empty passwords, accounts accessible from any host, and accounts with excessive privileges. Logic is taken from [MySQLTuner script](https://github.com/major/MySQLTuner-perl):security_recommendations(), v1.9.8.

**Important Notes:**

* See [additional notes for all mysql monitoring plugins](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/PLUGINS-MYSQL.md)

**Data Collection:**

* Queries `mysql.user` and `mysql.global_priv` (on MariaDB 10.4+) to identify insecure accounts
* The system users `mysql.sys` and `mariadb.sys` are excluded because they intentionally use invalid passwords as a security measure


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-user-security> |
| Nagios/Icinga Check Name              | `check_mysql_user_security` |
| Check Interval Recommendation         | Once a day |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| Requirements                          | User with SELECT privileges on mysql.user, locked down to `127.0.0.1` - for example `monitoring\@127.0.0.1`. Usernames in MySQL/MariaDB are limited to 16 chars in specific versions. |
| 3rd Party Python modules              | `pymysql` |


## Help

```text
usage: mysql-user-security [-h] [-V] [--always-ok]
                           [--defaults-file DEFAULTS_FILE]
                           [--defaults-group DEFAULTS_GROUP]
                           [--severity {warn,crit}] [--timeout TIMEOUT]

Checks MySQL/MariaDB user security settings, including accounts with empty
passwords, accounts accessible from any host, and accounts with excessive
privileges. Alerts on insecure account configurations.

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
  --severity {warn,crit}
                        Severity for alerts that do not depend on thresholds.
                        One of "warn" or "crit". Default: warn
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
```


## Usage Examples

```bash
./mysql-user-security --defaults-file=/var/spool/icinga2/.my.cnf
```

Output:

```text
1 anonymous user account [WARNING]. 1 user with username as password [WARNING]. 1 account without hostname restriction [WARNING]. 

Remove anonymous users:
* DROP USER ''@'centos7.loc';

Change user passwords:
* SET PASSWORD FOR 'root'@'localhost' = PASSWORD("I9n2eSGZ8u9MrScx0ckWYhGpQk6ouKh1yMn7Jnwj");

Restrict users:
* RENAME USER 'mariadb-admin'@'%' TO 'mariadb-admin'@'LimitedIPRangeOrLocalhost';
```


## States

* OK if no insecure accounts are found.
* WARN (default) or CRIT (via `--severity`) if anonymous users are found.
* WARN (default) or CRIT (via `--severity`) if users having empty passwords are found.
* WARN (default) or CRIT (via `--severity`) if users with user / uppercase / capitalise user as password are found (does not work on MySQL 8, ignored).
* WARN (default) or CRIT (via `--severity`) if users without hostname restriction are found.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

There is no perfdata.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
* Credits:

    * heavily inspired by MySQLTuner (<https://github.com/major/MySQLTuner-perl>)
