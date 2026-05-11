# Check mysql-user-security


## Overview

Checks MySQL/MariaDB user security: anonymous accounts, empty passwords, accounts whose password matches the username (`root/root` weak-password pattern), accounts accepting connections from any host (`'%'` wildcard), and accounts still on the legacy SHA1-based `mysql_native_password` (or `sha256_password` on MySQL 8.0+) authentication plugin. Logic taken from [MySQLTuner](https://github.com/major/MySQLTuner-perl):security_recommendations() and check_auth_plugins(), verified in sync with MySQLTuner v2.8.41.

**Important Notes:**

* See [additional notes for all mysql monitoring plugins](https://linuxfabrik.github.io/monitoring-plugins/plugins-mysql/)
* The username-as-password check is skipped when MySQL's `validate_password` plugin is active, because `PASSWORD(user)` calls inside the comparison fail in that case ([MySQL Bug #80860](https://bugs.mysql.com/bug.php?id=80860)). mysqltuner does the same
* Roles (MariaDB 10.0.5+, `mysql.user.IS_ROLE = 'Y'`) are excluded from the anonymous-user and username-as-password checks because a role legitimately has no password and an empty `host`
* The basic-password dictionary check that mysqltuner runs from a local word-list is intentionally not ported - it does not fit a recurring monitoring plugin
* SQL recommendations show `<replace-with-strong-password>` as a placeholder. Substitute a strong password before running the statements; the literal placeholder is self-evidently not a usable value

**Data Collection:**

* Queries `mysql.user` and `mysql.global_priv` (on MariaDB 10.4+) to identify insecure accounts
* Reads `SHOW VARIABLES` to detect MySQL 8.0+ vs MariaDB 10.4+ for version-aware recommendations
* The system users `mysql.sys` and `mariadb.sys` are excluded because they intentionally use invalid passwords as a security measure
* `validate_password` plugin status is read from `information_schema.plugins` (skip the username-as-password check when active)


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-user-security> |
| Nagios/Icinga Check Name              | `check_mysql_user_security` |
| Check Interval Recommendation         | Every day |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| Requirements                          | User with `SELECT` privilege on `mysql.*` (or `*.*`), locked down to `127.0.0.1` - for example `monitoring\@127.0.0.1`. Usernames in MySQL/MariaDB are limited to 16 chars in specific versions. |
| 3rd Party Python modules              | `pymysql` |


## Help

```text
usage: mysql-user-security [-h] [-V] [--always-ok]
                           [--defaults-file DEFAULTS_FILE]
                           [--defaults-group DEFAULTS_GROUP]
                           [--severity {warn,crit}] [--timeout TIMEOUT]

Checks MySQL/MariaDB user security: anonymous accounts (empty user name),
accounts with empty passwords, accounts whose password matches the username
(the classic `root/root` weak-password pattern), accounts that accept
connections from any host (`'%'` wildcard) and accounts still on the legacy
SHA1-based `mysql_native_password` (or `sha256_password` on MySQL 8.0+)
authentication plugin. Each finding maps to a copy-pasteable SQL
recommendation.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --defaults-file DEFAULTS_FILE
                        MySQL/MariaDB cnf file to read user, host and password
                        from. Example: `--defaults-
                        file=/var/spool/icinga2/.my.cnf`. Default:
                        /var/spool/icinga2/.my.cnf
  --defaults-group DEFAULTS_GROUP
                        Group/section to read from in the cnf file. Default:
                        client
  --severity {warn,crit}
                        Severity for the threshold-less security findings
                        (anonymous accounts, empty passwords, weak passwords,
                        wildcard hosts). One of `warn` or `crit`. Default:
                        warn
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
```


## Usage Examples

```bash
./mysql-user-security --defaults-file=/var/spool/icinga2/.my.cnf
```

OK output:

```text
Everything is ok. 12 non-system user accounts, 3 roles. 0 anonymous accounts. 0 users without password. 0 users with username as password. 0 accounts without hostname restriction. 0 users on a legacy authentication plugin.
```

WARN output:

```text
6 non-system user accounts, 0 roles. 0 anonymous accounts. 0 users without password. 1 user with username as password [WARNING]. 2 accounts without hostname restriction [WARNING]. 1 user on a legacy authentication plugin [WARNING].

Recommendations:
* `SET PASSWORD FOR 'test'@'%' = PASSWORD('<replace-with-strong-password>');`
* `RENAME USER 'root'@'%' TO 'root'@'LimitedIPRangeOrLocalhost';`
* `RENAME USER 'test'@'%' TO 'test'@'LimitedIPRangeOrLocalhost';`
* `ALTER USER 'test'@'%' IDENTIFIED WITH caching_sha2_password BY '<replace-with-strong-password>';`
```


## States

* OK if no insecure accounts are found.
* `--severity warn` (default) or `--severity crit` controls the state returned for each of the five findings:
    * accounts on a legacy authentication plugin (`mysql_native_password`, plus `sha256_password` on MySQL 8.0+)
    * accounts whose password equals the username (skipped when the `validate_password` plugin is active)
    * accounts with empty passwords
    * accounts with host `'%'` (no hostname restriction)
    * anonymous accounts (`user = ''`)
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| mysql_anonymous_users | Number | Count of accounts with an empty user name. |
| mysql_role_count | Number | Count of MariaDB roles (`mysql.user.IS_ROLE = 'Y'`). Always 0 on MySQL and on MariaDB without the `IS_ROLE` column. |
| mysql_user_count | Number | Total non-system user accounts. System users `mariadb.sys` and `mysql.sys` are excluded; roles are excluded when the `IS_ROLE` column is present. Useful for trending: a spike here means someone added (or, less likely, removed) accounts. |
| mysql_users_on_legacy_auth_plugin | Number | Count of accounts on `mysql_native_password` (SHA1-based, deprecated on both branches). On MySQL 8.0+ also counts `sha256_password` (deprecated by Oracle). |
| mysql_users_with_username_as_password | Number | Count of accounts whose stored password equals the username, uppercase username, or capitalised username. Always 0 on MySQL 8+ and on servers with the `validate_password` plugin active. |
| mysql_users_with_wildcard_host | Number | Count of accounts with `host = '%'`. |
| mysql_users_without_password | Number | Count of accounts whose `authentication_string` is empty (and not locked or expired). |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
* Credits:

    * heavily inspired by MySQLTuner (<https://github.com/major/MySQLTuner-perl>)
