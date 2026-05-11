# Check mysql-traffic


## Overview

Reports MySQL/MariaDB traffic statistics including uptime, queries per second, total connections, bytes transferred, and the read/write ratio based on `SELECT`, `INSERT`, `UPDATE`, `DELETE`, and `REPLACE`. Logic taken from [MySQLTuner](https://github.com/major/MySQLTuner-perl):mysql_stats() and verified in sync with MySQLTuner v2.8.41.

**Important Notes:**

* See [additional notes for all mysql monitoring plugins](https://linuxfabrik.github.io/monitoring-plugins/plugins-mysql/)
* This plugin is purely informational and always returns OK
* The single-line summary shows lifetime totals (since `Uptime`) for human reading. Trends are best inspected on the Grafana dashboard, which plots the per-second rates persisted in the local SQLite cache

**Data Collection:**

* Queries `SHOW GLOBAL STATUS` for `Bytes_received`, `Bytes_sent`, `Com_delete`, `Com_insert`, `Com_replace`, `Com_select`, `Com_update`, `Connections`, `Questions`, and `Uptime`
* Calculates queries per second as `Questions / Uptime`
* Calculates the read/write ratio from `SELECT` (reads) and `INSERT` + `UPDATE` + `DELETE` + `REPLACE` (writes)
* Cumulative counters are persisted in a local SQLite cache between runs so the dashboard plots per-second rates without `non_negative_difference()` workarounds


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-traffic> |
| Nagios/Icinga Check Name              | `check_mysql_traffic` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| Requirements                          | User with no privileges, locked down to `127.0.0.1` - for example `monitoring\@127.0.0.1`. Usernames in MySQL/MariaDB are limited to 16 chars in specific versions. |
| 3rd Party Python modules              | `pymysql` |


## Help

```text
usage: mysql-traffic [-h] [-V] [--defaults-file DEFAULTS_FILE]
                     [--defaults-group DEFAULTS_GROUP] [--timeout TIMEOUT]

Reports MySQL/MariaDB traffic statistics: uptime, queries per second, total
connections, bytes transferred, and the SELECT-vs-write ratio. Purely
informational; the plugin always returns OK. Cumulative counters
(`Bytes_received`, `Bytes_sent`, `Connections`, `Questions`, `Com_*`) are
emitted as in-plugin-computed per-second rates so the Grafana dashboard plots
them without `non_negative_difference()` workarounds.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --defaults-file DEFAULTS_FILE
                        MySQL/MariaDB cnf file to read user, host and password
                        from. Example: `--defaults-
                        file=/var/spool/icinga2/.my.cnf`. Default:
                        /var/spool/icinga2/.my.cnf
  --defaults-group DEFAULTS_GROUP
                        Group/section to read from in the cnf file. Default:
                        client
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
```


## Usage Examples

```bash
./mysql-traffic
```

Output:

```text
Up 1W 3D (907.7K q [1.0 qps], 470.0 conn, TX: 560.2M, RX: 96.4M); Read/Write: 65.3%/34.7%
```


## States

* Always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| mysql_bytes_received_per_second | Rate | Per-second rate of `Bytes_received` (cumulative counter delta against the local SQLite cache). Appears from the second run onwards. |
| mysql_bytes_sent_per_second | Rate | Per-second rate of `Bytes_sent`. Appears from the second run onwards. |
| mysql_com_delete_per_second | Rate | Per-second rate of `Com_delete`. Appears from the second run onwards. |
| mysql_com_insert_per_second | Rate | Per-second rate of `Com_insert`. Appears from the second run onwards. |
| mysql_com_replace_per_second | Rate | Per-second rate of `Com_replace`. Appears from the second run onwards. |
| mysql_com_select_per_second | Rate | Per-second rate of `Com_select` (includes queries served from the query cache). Appears from the second run onwards. |
| mysql_com_update_per_second | Rate | Per-second rate of `Com_update`. Appears from the second run onwards. |
| mysql_connections_per_second | Rate | Per-second rate of `Connections` (successful and failed connection attempts). Appears from the second run onwards. |
| mysql_pct_reads | Percentage | `total_reads / (total_reads + total_writes) * 100`. Lifetime ratio, not a per-interval value. |
| mysql_pct_writes | Percentage | `100 - pct_reads`. Lifetime ratio. |
| mysql_qps | Number | Lifetime queries per second (`Questions / Uptime`). |
| mysql_questions_per_second | Rate | Per-second rate of `Questions`. Appears from the second run onwards. |
| mysql_uptime | Seconds | `Uptime` of the server. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
* Credits:

    * heavily inspired by MySQLTuner (<https://github.com/major/MySQLTuner-perl>)
