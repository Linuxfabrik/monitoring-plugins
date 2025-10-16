# Check mysql-user-security

## Overview

Check user's security in MySQL/MariaDB. Logic is taken from [MySQLTuner script](https://github.com/major/MySQLTuner-perl), v1.9.8.

The users `mysql.sys` and `mariadb.sys`, which are system users used as the definer for view, procedures, and functions in the sys schema, are ignored, because they use an invalid password. This ensures that should these accounts get unlocked by mistake, it is still impossible to login. It is thus recommended not to reset the password. These users are required as long as a sys schema is installed.

Hints:

* See [additional notes for all mysql monitoring plugins](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/PLUGINS-MYSQL.md)


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-user-security> |
| Check Interval Recommendation         | Once a day |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |
| Requirements                          | User with SELECT privileges on mysql.user, locked down to `127.0.0.1` - for example `monitoring\@127.0.0.1`. Usernames in MySQL/MariaDB are limited to 16 chars in specific versions. |
| 3rd Party Python modules              | `pymysql` |


## Help

```text
usage: mysql-user-security [-h] [-V] [--always-ok]
                           [--defaults-file DEFAULTS_FILE]
                           [--defaults-group DEFAULTS_GROUP]
                           [--severity {warn,crit}] [--timeout TIMEOUT]

Check user's security in MySQL/MariaDB.

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

* WARN if anonymous users are found
* WARN if users having empty passwords are found
* WARN if users with user / uppercase / capitalise user as password are found (does not work on MySQL 8, ignored)
* WARN if users without hostname restriction are found


## Perfdata / Metrics

There is no perfdata.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)

* License: The Unlicense, see [LICENSE file](https://unlicense.org/).

* Credits:

    * heavily inspired by MySQLTuner (<https://github.com/major/MySQLTuner-perl>)
