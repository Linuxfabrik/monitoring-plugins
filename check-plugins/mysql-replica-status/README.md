# Check mysql-replica-status

## Overview

Checks the replication status of a MySQL/MariaDB replica, including I/O thread state, SQL thread state, seconds behind master, and replication errors. Can also be run against standalone servers (reports that no replication is configured). Reports Galera synchronous replication state, binlog format, semi-synchronous replication configuration, and XA support.

**Alerting Logic:**

* Alerts with the configured severity (`--severity`, default: WARN) if the replica is not running but seems to be configured
* Alerts with the configured severity if the replica is running with `read_only` disabled
* Alerts with the configured severity if the replica is lagging behind the primary

**Data Collection:**

* Queries `SHOW GLOBAL VARIABLES` for replication-related settings (`binlog_format`, `read_only`, `rpl_semi_sync_*`, `wsrep_on`, `wsrep_provider_options`, etc.)
* Executes `SHOW REPLICA STATUS` (or `SHOW SLAVE STATUS` on older versions) and `SHOW SLAVE HOSTS`
* Logic is taken from [MySQLTuner script](https://github.com/major/MySQLTuner-perl):get_replication_status(), v1.9.8

**Important Notes:**

* See [additional notes for all mysql monitoring plugins](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/PLUGINS-MYSQL.md)
* User account requires SUPER, REPLICATION CLIENT, and REPLICATION SLAVE privileges
* Can safely be run against standalone servers; it will report "This is a standalone server."


## Fact Sheet

| Fact | Value |
|----|---|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-replica-status> |
| Nagios/Icinga Check Name              | `check_mysql_replica_status` |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |
| 3rd Party Python modules              | `pymysql` |


## Help

```text
usage: mysql-replica-status [-h] [-V] [--always-ok]
                            [--defaults-file DEFAULTS_FILE]
                            [--defaults-group DEFAULTS_GROUP]
                            [--severity {warn,crit}] [--timeout TIMEOUT]

Checks the replication status of a MySQL/MariaDB replica, including I/O thread
state, SQL thread state, seconds behind master, and replication errors. Alerts
when replication is broken or lagging.

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
                        Severity for alerts that do not depend on thresholds.
                        One of "warn" or "crit". Default: warn
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
```


## Usage Examples

```bash
./mysql-replica-status --defaults-file=/var/spool/icinga2/.my.cnf
```

Output:

```text
Galera Synchronous replication: NO. Binlog format: ROW, XA support enabled: ON. Semi synchronous Primary: Not Activated. Semi synchronous Replica: Not Activated. This Replica is not running but seems to be configured [WARNING].
```


## States

* WARN or CRIT (depending on `--severity`) if the replica is not running but seems to be configured.
* WARN or CRIT (depending on `--severity`) if the replica is running with `read_only` disabled.
* WARN or CRIT (depending on `--severity`) if the replica is lagging behind the primary.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

There is no perfdata.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
* Credits:
    * heavily inspired by MySQLTuner (<https://github.com/major/MySQLTuner-perl>)
