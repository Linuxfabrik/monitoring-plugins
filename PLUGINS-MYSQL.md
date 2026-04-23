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
* `mysql-innodb-buffer-pool-instances`: InnoDB buffer-pool instance count.
* `mysql-innodb-buffer-pool-size`: InnoDB buffer-pool sizing vs. hit rate.
* `mysql-innodb-log-waits`: InnoDB log wait rate.
* `mysql-joins`: joins without indexes.
* `mysql-logfile`: grep-like pattern check against the MySQL error log.
* `mysql-memory`: server memory metrics.
* `mysql-open-files`: open-files vs. `open_files_limit`.
* `mysql-perf-metrics`: general performance counters.
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


## Service Sets in the Icinga Director Basket

The shipped basket slices MySQL monitoring into six Service Sets, each
activated by its own tag on the host. Pick the subset that fits the server's
role; activate several sets on the same host when appropriate.

* **MySQL Service Set**: baseline health (connections, memory, uptime,
  version). Activate for every monitored MySQL/MariaDB server.
* **MySQL InnoDB Service Set**: InnoDB-specific counters (buffer pool, log
  waits). For servers using InnoDB as the main engine.
* **MySQL Metrics Service Set**: query-level metrics (joins, sorts, slow
  queries, temp tables, thread and table caches).
* **MySQL Replication Service Set**: replica health. Activate on asynchronous
  replicas.
* **MySQL Schemas Service Set**: per-database size and index quality
  (database metrics, table indexes, table locks).
* **MySQL Security Service Set**: account hygiene and the server-side error
  log (`mysql-user-security`, `mysql-logfile`).
