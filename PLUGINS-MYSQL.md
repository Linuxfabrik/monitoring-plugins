# MySQL Plugins

The MySQL plugins talk to any MySQL or MariaDB server over the standard
protocol. They read credentials from a MySQL option file (`.my.cnf`) instead
of taking them on the command line, which keeps passwords out of process
listings and the monitoring host's shell history.


## Plugins in this group

* `mysql-aria`: MariaDB Aria storage engine counters.
* `mysql-binlog-cache`: binlog cache hit/miss rate.
* `mysql-connections`: current and max connections.
* `mysql-database-metrics`: per-database size and object counts.
* `mysql-health`: single-number 0-100 health score for a MySQL/MariaDB server.
* `mysql-innodb-buffer-pool-size`: InnoDB buffer-pool sizing vs. hit rate.
* `mysql-innodb-log-waits`: InnoDB log wait rate.
* `mysql-joins`: joins without indexes.
* `mysql-logfile`: bracket-tag check against the MySQL/MariaDB error log. Prefers `performance_schema.error_log` on MySQL 8.0.22+, falls back to the on-disk file (or `docker:`/`podman:`/`kubectl:`/`systemd:` source).
* `mysql-long-queries`: in-flight queries that have been running longer than the configured threshold.
* `mysql-memory`: server memory metrics.
* `mysql-open-files`: open-files vs. `open_files_limit`.
* `mysql-perf-metrics`: general performance counters and explicitly-set deprecated config variables.
* `mysql-query`: run an arbitrary SQL query and alert on the returned value.
* `mysql-replica-status`: replica status for asynchronous replication.
* `mysql-slow-queries`: slow-query counter and rate.
* `mysql-sorts`: sort counters.
* `mysql-storage-engines`: which storage engines are in use.
* `mysql-system`: server uptime and basic stats.
* `mysql-table-cache`: `table_open_cache` hit rate.
* `mysql-table-definition-cache`: `table_definition_cache` hit rate.
* `mysql-table-indexes`: tables without primary keys.
* `mysql-table-locks`: table-lock waits.
* `mysql-temp-tables`: on-disk vs. in-memory temp tables.
* `mysql-thread-cache`: thread-cache hit rate.
* `mysql-tls`: TLS/SSL posture (`have_ssl`, `require_secure_transport`, TLS versions, cert expiry, remote users without `REQUIRE SSL`).
* `mysql-traffic`: bytes sent and received.
* `mysql-user-security`: accounts without password, wildcard hosts, etc.
* `mysql-version`: installed MySQL/MariaDB version, EOL check.


## Authentication

Specifying a password on the command line is insecure: it shows up in
`ps auxf` and in shell history. Use a MySQL option file instead.

A minimal option file (typically `~/.my.cnf` of the user running the plugins,
e.g. `/var/spool/icinga2/.my.cnf` on Icinga):

```text
[client]
user = monitoring
password = linuxfabrik
```

Restrict the file's permissions so no one else can read it:

```bash
chmod 0400 /var/spool/icinga2/.my.cnf
chown icinga:icinga /var/spool/icinga2/.my.cnf
```

Point the plugin at the file with `--defaults-file`:

```bash
./mysql-aria --defaults-file=/var/spool/icinga2/.my.cnf
```

PyMySQL is used for the connection and is packaged with the RPM and DEB
builds. For source-installed plugins, install it into the user's venv:

```bash
python3 -m pip install pymysql
```


## Recommended option-file locations

1. `$HOME/.my.cnf` of the user running the plugins. Typical paths:
   `/var/spool/icinga2/.my.cnf` (Icinga), `/var/lib/nagios/.my.cnf` (Nagios).
2. `/etc/my.cnf.d/icinga.cnf` for a site-wide Icinga-only secret. Use a file
   name that names its consumer, not `client.cnf`.

Avoid these, they leak credentials to every MySQL client on the host:

* `/etc/my.cnf.d/client.cnf`
* `/etc/my.cnf`


## Option-file example with all supported options

The plugins read the `[client]` group by default. Use `--defaults-group` to
pick a different group name.

```text
[client]
user = root
password = linuxfabrik
host = 127.0.0.1
port = 3306

# Database to use, leave empty to not pick one.
database =

# Connect through a UNIX socket instead of TCP/IP.
unix_socket = /var/lib/mysql/mysql.sock

# Bind to a specific local interface (hostname or IP address).
bind_address =

# Charset for the connection.
charset =

# Path to the CA certificate file (PEM) used to verify the server.
ssl-ca =
# Directory of CA certificate files (PEM).
ssl-capath =
# Client certificate (PEM).
ssl-cert =
# Client private key (PEM), >= 2048 bits RSA recommended.
ssl-key =
# Allowed ciphers.
ssl-cipher =
```


## Common parameters

Shared across all MySQL plugins (run `<plugin> --help` for the full list):

* `--defaults-file`: path to the option file.
* `--defaults-group`: option-file group to read. Default `client`.
* `--timeout`: network/query timeout.

Thresholds (`--warning` / `--critical`) and plugin-specific selectors are per
plugin — check the individual READMEs.


## Required database privileges

Most MySQL plugins only call `SHOW GLOBAL VARIABLES` and `SHOW GLOBAL STATUS`,
which work with `GRANT USAGE` (login-only). A handful of plugins read from
`information_schema` or `mysql.*` and need `SELECT`; `mysql-replica-status`
needs a replication-monitoring grant.

The first row of the table is the **union for one shared monitoring user**
that covers every plugin in this group. The remaining rows show the per-plugin
minimum.

| Scope | Minimum grant on `*.*` |
|----|----|
| **One shared monitoring user (covers all MySQL plugins)** | Baseline: `GRANT SELECT, PROCESS ON *.* TO 'monitoring'@'127.0.0.1'`. `SELECT` covers `information_schema`, `mysql.*` and `performance_schema.*` reads; `PROCESS` covers `information_schema.processlist` (mysql-long-queries) and `SHOW ENGINE PERFORMANCE_SCHEMA STATUS` (mysql-memory's PFS footprint). For `mysql-replica-status` add `REPLICATION CLIENT` on MySQL and MariaDB <10.5, or `SLAVE MONITOR` on MariaDB 10.5+ (alias `REPLICA MONITOR` on MariaDB 11+). `USAGE` is implicit in every GRANT |
| `mysql-aria`, `mysql-database-metrics`, `mysql-innodb-buffer-pool-size`, `mysql-storage-engines`, `mysql-table-definition-cache`, `mysql-table-indexes` | `GRANT SELECT ON *.*` (needed to see all rows in `information_schema`) |
| `mysql-replica-status` | `GRANT REPLICATION CLIENT ON *.*` on MySQL and MariaDB <10.5. **On MariaDB 10.5+** plain `REPLICATION CLIENT` is no longer enough for `SHOW REPLICA STATUS` / `SHOW SLAVE STATUS`; grant `SLAVE MONITOR` (or its MariaDB 11+ alias `REPLICA MONITOR`) instead |
| `mysql-long-queries` | `GRANT PROCESS ON *.*` so the user sees other sessions' queries in `information_schema.processlist`. Without `PROCESS`, the plugin only sees its own connection and will silently miss long-running queries from application users |
| `mysql-tls` | `GRANT SELECT ON mysql.*` (queries `mysql.user` and `mysql.global_priv` for remote users without `REQUIRE SSL`). For the local certificate expiry check the OS user running the plugin must additionally be able to read `ssl_cert` / `ssl_ca` from disk |
| `mysql-user-security` | `GRANT SELECT ON mysql.*` (queries `mysql.user` and `mysql.global_priv`) |
| `mysql-logfile` | `GRANT USAGE ON *.*` is enough for on-disk / container / systemd sources. To additionally use `performance_schema.error_log` (MySQL 8.0.22+), `GRANT SELECT ON performance_schema.error_log` is needed; without it the plugin transparently falls back to file mode |
| All other `mysql-*` plugins | `GRANT USAGE ON *.*` (login-only, no further privileges) |
| `mysql-query` | depends entirely on the SQL passed via `--query` |

Every MySQL plugin that opens a database connection verifies the grants
up front via `SHOW GRANTS FOR CURRENT_USER()` and exits `UNKNOWN` with a
message that names the missing privilege if a grant is absent. `ALL
PRIVILEGES` and `SUPER` short-circuit the check.

`mysql-system` and `mysql-version` open no database connection and therefore
need no grants; they read uptime and package-version facts from the operating
system.


## Service Sets in the Icinga Director Basket

The shipped basket slices MySQL monitoring into six Service Sets, each
activated by its own tag on the host. Pick the subset that fits the server's
role; activate several sets on the same host when appropriate.

* **MySQL Service Set**: baseline health (uptime, version, binlog
  cache). Activate for every monitored MySQL/MariaDB server. The binlog
  cache check covers any server with binary logging enabled, including
  standalone masters/sources, so it lives here rather than under
  Replication.
* **MySQL InnoDB Service Set**: InnoDB-specific counters (buffer pool, log
  waits). For servers using InnoDB as the main engine.
* **MySQL Metrics Service Set**: server-wide metrics (connections,
  memory, open files, perf metrics, storage engines, traffic, logfile,
  thread cache).
* **MySQL Replication Service Set**: replica-specific health
  (`mysql-replica-status`). Activate on asynchronous replicas.
* **MySQL Schemas Service Set**: per-database / per-query metrics
  (database metrics, joins, long-running queries, slow queries, sorts,
  table cache, table definition cache, table indexes, table locks,
  temp tables).
* **MySQL Security Service Set**: account hygiene, TLS posture and the
  server-side error log (`mysql-user-security`, `mysql-tls`,
  `mysql-logfile`).
