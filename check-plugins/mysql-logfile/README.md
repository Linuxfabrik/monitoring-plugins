# Check mysql-logfile


## Overview

Scans the MySQL/MariaDB error log for errors, warnings, startups and shutdowns. On MySQL 8.0.22+ the plugin prefers the `performance_schema.error_log` table (reachable over the network, no shell access to the log file needed). Otherwise it reads the on-disk log file, or fetches recent log lines from a container (`docker:`/`podman:`/`kubectl:`) or systemd unit (`systemd:`). The on-disk file path is taken from MySQL/MariaDB's `log_error` variable, with common fallback locations probed when that variable is empty, and the journal of the database unit is read along with it, because a server that fails to start writes why to its standard error and never reaches the error log. What both hold is counted once. The discovered path is cached so the check still works briefly when the database is down. The most recent rotated file is read along with the live one, so the window does not end where logrotate last ran. Severity is detected from the bracketed log tags (`[ERROR]`, `[Warning]`), which matches MySQL/MariaDB output and avoids false positives on lines that merely mention "error" or "warning". Two of those lines are counted by how often they arrive within `--lookback` instead, per client host, because they are written in ones and twos on a host where nothing is wrong and only say something in bulk: a login the server turned away, and a connection a client dropped without saying goodbye. Counting either by its level would leave the check permanently yellow on an ordinary application server. Recommendations are grouped under a single block at the end of the output. Reading the on-disk log file usually requires root/sudo (typical mysql logs are owned by `mysql:mysql` mode `0640`). The `performance_schema.error_log` path needs SELECT on that table but no filesystem access.

**Important Notes:**

* **A line is counted once.** A login the server turned away and a connection a client dropped are `[Warning]` lines on MariaDB, and both are written all day on a host where nothing is wrong. They are counted by how often they arrive within `--lookback`, per client host, and not by their level as well - otherwise one mistyped password or one application that never closes cleanly would leave the check yellow until the line ages out of the window.

* See [additional notes for all mysql monitoring plugins](https://linuxfabrik.github.io/monitoring-plugins/plugins-mysql/)
* Severity is detected from MySQL/MariaDB's bracketed log tags (`[ERROR]`, `[Warning]`); lines that only mention the words "error" / "warning" elsewhere are not counted.
* **A login the server turned away is counted, not reported.** `Access denied for user 'root'@'198.51.100.7'` is the one line in this log that is about somebody working on the server rather than about the server being unwell, so it is judged by how often it arrives within `--lookback` and per source address. It is deliberately kept out of the error and warning counts: MariaDB writes it as `[Warning]`, and counting it there would leave the check yellow for every mistyped password.
* **The two servers have to be told to write that line.** MariaDB writes it at `log_warnings = 2`, which is its default, so nothing has to be done there. MySQL keeps it at `log_error_verbosity = 3` while its default is `2`, so on MySQL the line is missing until somebody raises it. Where the check reached the server it reads that setting and says so as the first thing in its output, without raising a state for it.
* **The rate thresholds assume an intrusion prevention system in front of this check.** A host reachable from the internet collects failed logins and probes around the clock, and the answer to those is a system that reads the same log, counts what a single source fails within a few minutes and blocks it. Such a system commonly lets five failures per source through before it steps in, so the defaults here sit just above that: what this check reports is what got past the blocking, not what the blocking is already handling. The window is `--lookback`, ten minutes by default, which is the same window those systems count in. On a host without one, the counters see every attempt of every source and the defaults are far too tight - raise them until they sit clear of what the host collects on a quiet day, and keep the ratio rather than the absolute number: a threshold is useful when it is a multiple of the normal rate, not when it is a fraction of it. `0` switches a threshold off entirely.
* **A client does not get to choose which source it is counted under.** Parts of the lines this check reads are the client's own text - the account it asked for, the identification string it sent - and a client that writes an address into them would otherwise move its own lines into somebody else's count, or spread them out to stay below a threshold. The address is therefore taken from where the server writes the peer and nowhere else, and the two spellings of one client (`198.51.100.7` and `::ffff:198.51.100.7`) are counted as the one client they are.
* **A rate is counted per source address, not as a total.** Six failures from one address within the window is somebody working on this host; six failures spread over six addresses is the open network going past, and only the first is worth reporting. What the state follows is therefore the busiest single source, which is also the quantity an intrusion prevention system counts before it blocks one - so the thresholds compare against the same thing that system does. The summary names that source and, where they differ, the total and how many addresses it came from. Lines that name no source are counted together as one, so a burst of unattributable lines still reports. `--no-per-source` goes back to judging everything that arrived, for a log that reaches this check through something that rewrites or drops the address of the peer. Counters that are not about who caused them - a backend that could not be reached, connections refused for want of slots - always judge the total, because the address on such a line says nothing about the cause.
* **The window spans the last rotation.** logrotate moves the old file aside and MySQL/MariaDB starts a fresh one, so a check reading the live file alone would lose every error from before it the moment the rotation runs. The most recent rotated file is therefore read along with the live one, gzip, xz and bzip2 included, and the last section names every file it read. A rotator told to compress with something else, or to move its output to another directory, is out of reach; an event older than one rotation is too. The `performance_schema.error_log` path is not affected, since the table has no rotation of its own.
* When reading from an on-disk log file, the check usually needs root/sudo (typical log files are owned by `mysql:mysql`, mode `0640`). The `performance_schema.error_log` path needs only SELECT on that table.
* `--server-log` is confined to `/var/log` and `/var/lib/mysql`. The check runs as root via sudo, so it refuses a path that resolves outside those directories, which stops it from being turned into an arbitrary root file read. The data directory reported by the server is deliberately not trusted here, since an attacker controls which server the check connects to. To read a log stored elsewhere (for example a custom data directory), bind-mount that location under `/var/log` (a symlink is rejected); see the [Troubleshooting section](https://github.com/Linuxfabrik/monitoring-plugins#troubleshooting).
* Depending on your site's policy, you may want to silence noisy patterns like `aborted connection` or `access denied for user` via `--ignore-pattern` / `--ignore-regex`.
* Both `--ignore-pattern` and `--ignore-regex` are matched against the lowercased log line, so write your patterns in lowercase (or use the `(?i)` flag in a regex).

**Data Collection:**

* On MySQL 8.0.22+, the plugin prefers `performance_schema.error_log` when the table exists and is visible to this user. Works over the network without shell access to the log file.
* Otherwise it determines the log file location automatically via `SHOW GLOBAL VARIABLES` (`log_error`, `hostname`, `datadir`), falling back to several well-known paths.
* Supports reading from a file path, `docker:CONTAINER`, `podman:CONTAINER`, `kubectl:CONTAINER` or `systemd:UNITNAME` via `--server-log`, which can be given several times; everything named is read as one window. A wildcard is not expanded, so name each file.
* Reads the journal of the database unit along with the file where `--server-log` names nothing, and counts an event the two share once.
* Reads `log_error_verbosity` (MySQL) and `log_warnings` (MariaDB) along with the log location, to tell whether the server writes the logins it turns away at all.
* Caches the on-disk log file location in a local SQLite database so the check can still work briefly when the database is down.
* Lines can be filtered out using `--ignore-pattern` (simple string match) or `--ignore-regex` (Python regular expression).
* Logic is taken from [MySQLTuner script](https://github.com/major/MySQLTuner-perl):log_file_recommendations(), verified in sync with v2.8.41.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-logfile> |
| Nagios/Icinga Check Name              | `check_mysql_logfile` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | No |
| Runs on                               | Linux |
| Compiled for Windows                  | No |
| 3rd Party Python modules              | `pymysql` |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-mysql-logfile.db` |


## Help

```text
usage: mysql-logfile [-h] [-V]
                     [--aborted-connections-critical ABORTED_CONNECTIONS_CRITICAL]
                     [--aborted-connections-warning ABORTED_CONNECTIONS_WARNING]
                     [--access-denied-critical ACCESS_DENIED_CRITICAL]
                     [--access-denied-warning ACCESS_DENIED_WARNING]
                     [--always-ok] [--cache-expire CACHE_EXPIRE]
                     [--defaults-file DEFAULTS_FILE]
                     [--defaults-group DEFAULTS_GROUP] [-H HOSTNAME]
                     [--icinga-callback] [--icinga-password ICINGA_PASSWORD]
                     [--icinga-service-name ICINGA_SERVICE_NAME]
                     [--icinga-url ICINGA_URL]
                     [--icinga-username ICINGA_USERNAME] [--insecure]
                     [--no-insecure] [--ignore IGNORE] [--lookback LOOKBACK]
                     [--match MATCH]
                     [--no-match-severity {ok,warn,crit,unknown}]
                     [--no-per-source] [--no-perfdata] [--no-proxy]
                     [--proxy PROXY] [--per-source] [--port PORT]
                     [--server-log SERVER_LOG] [--timeout TIMEOUT]

Scans the MySQL/MariaDB error log for errors, warnings, startups and
shutdowns. On MySQL 8.0.22+ the plugin prefers the
`performance_schema.error_log` table (reachable over the network, no shell
access to the log file needed). Otherwise it reads the on-disk log file, or
fetches recent log lines from a container (`docker:`/`podman:`/`kubectl:`) or
systemd unit (`systemd:`). The on-disk file path is taken from MySQL/MariaDB's
`log_error` variable, with common fallback locations probed when that variable
is empty, and the journal of the database unit is read along with it, because
a server that fails to start writes why to its standard error and never
reaches the error log. What both hold is counted once. The discovered path is
cached so the check still works briefly when the database is down. The most
recent rotated file is read along with the live one, so the window does not
end where logrotate last ran. Severity is detected from the bracketed log tags
(`[ERROR]`, `[Warning]`), which matches MySQL/MariaDB output and avoids false
positives on lines that merely mention "error" or "warning". Two of those
lines are counted by how often they arrive within `--lookback` instead, per
client host, because they are written in ones and twos on a host where nothing
is wrong and only say something in bulk: a login the server turned away, and a
connection a client dropped without saying goodbye. Counting either by its
level would leave the check permanently yellow on an ordinary application
server. Recommendations are grouped under a single block at the end of the
output. Reading the on-disk log file usually requires root/sudo (typical mysql
logs are owned by `mysql:mysql` mode `0640`). The
`performance_schema.error_log` path needs SELECT on that table but no
filesystem access.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --aborted-connections-critical ABORTED_CONNECTIONS_CRITICAL
                        Number of connections the clients dropped within
                        `--lookback` that returns CRITICAL. Counted per client
                        host, so one application falling over reaches it while
                        the same number spread over a fleet does not. 0 turns
                        the threshold off. Example: `--aborted-connections-
                        critical=500`. Default: 200
  --aborted-connections-warning ABORTED_CONNECTIONS_WARNING
                        Number of connections the clients dropped within
                        `--lookback` that returns WARNING. Counted per client
                        host, so one application falling over reaches it while
                        the same number spread over a fleet does not. 0 turns
                        the threshold off. Example: `--aborted-connections-
                        warning=50`. Default: 20
  --access-denied-critical ACCESS_DENIED_CRITICAL
                        Number of logins the server turned away within
                        `--lookback` that returns CRITICAL. 0 turns the
                        threshold off. Example: `--access-denied-
                        critical=200`. Default: 60
  --access-denied-warning ACCESS_DENIED_WARNING
                        Number of logins the server turned away within
                        `--lookback` that returns WARNING. Counted per source
                        address, so a run against one account from one host
                        reaches it while the same number of typos across a
                        fleet does not. 0 turns the threshold off. Example:
                        `--access-denied-warning=1`. Default: 6
  --always-ok           Always returns OK.
  --cache-expire CACHE_EXPIRE
                        The amount of time after which the credential/data
                        cache expires, in minutes. Default: 7200
  --defaults-file DEFAULTS_FILE
                        MySQL/MariaDB cnf file to read user, host and password
                        from. Example: `--defaults-
                        file=/var/spool/icinga2/.my.cnf`. Default:
                        /var/spool/icinga2/.my.cnf
  --defaults-group DEFAULTS_GROUP
                        Group/section to read from in the cnf file. Default:
                        client
  -H, --hostname HOSTNAME
                        MySQL/MariaDB hostname or IP address. Default:
                        127.0.0.1
  --icinga-callback     Ask the monitoring server whether the service running
                        this check is acknowledged. Where it is, what this run
                        reports is remembered as already handled, so it no
                        longer raises an alert on the following runs. Requires
                        `--icinga-url`, `--icinga-username`, `--icinga-
                        password` and `--icinga-service-name`. Default: False
  --icinga-password ICINGA_PASSWORD
                        Monitoring server API password.
  --icinga-service-name ICINGA_SERVICE_NAME
                        Unique name of the service running this check, as the
                        monitoring server knows it. Take it from the `__name`
                        service attribute. Example: `monitoring-server!my-
                        service-name`.
  --icinga-url ICINGA_URL
                        Monitoring server API URL. Example:
                        `https://monitoring.example.com:5665`.
  --icinga-username ICINGA_USERNAME
                        Monitoring server API username.
  --insecure            Applies to the connection to the monitoring server
                        that `--icinga-callback` makes. This option explicitly
                        allows insecure SSL connections.
  --no-insecure         Applies to the connection to the monitoring server
                        that `--icinga-callback` makes. Verify the TLS
                        certificate against the system trust store, overriding
                        the insecure default of this check. Use it once the
                        endpoint presents a publicly trusted certificate, or
                        once its CA has been added to the system trust store.
  --ignore IGNORE       Ignore a log line matching this Python regular
                        expression. The log line is lowercased before
                        matching, so write the pattern in lowercase (or use
                        the `(?i)` flag). Can be specified multiple times.
                        Example: `--ignore='(?i)linuxfabrik'`.
  --lookback LOOKBACK   Logins the server turned away are counted within this
                        window rather than reported one by one. Time window in
                        seconds to look back over, ending at the moment of the
                        run. Only what falls within it is counted, so what is
                        reported is how often something happened lately rather
                        than a total that keeps growing for as long as the
                        source is kept. Example: `--lookback=3600`. Default:
                        600 (seconds)
  --match MATCH         Only consider a log line matching this Python regular
                        expression. The log line is lowercased before
                        matching, so write the pattern in lowercase (or use
                        the `(?i)` flag). Can be specified multiple times. If
                        both `--match` and `--ignore` are given, an item must
                        match `--match` AND not match `--ignore` to be
                        reported (include first, exclude second). Example:
                        `--match='innodb'`.
  --no-match-severity {ok,warn,crit,unknown}
                        State to report when no item matches the filters and
                        nothing is checked. Default: ok
  --no-per-source       Judge a rate by everything that arrived within the
                        window, whatever source the lines name. Use this where
                        the log reaches this check through something that
                        rewrites or drops the address of the peer, or where
                        every source is as interesting as the next.
  --no-perfdata         Suppress the performance data section from the output.
                        The status message and the exit code are unaffected,
                        so alerting keeps working while trending data is
                        dropped.
  --no-proxy            Applies to the connection to the monitoring server
                        that `--icinga-callback` makes. Do not use a proxy,
                        not even one the environment names. Overrides
                        `--proxy`.
  --proxy PROXY         Applies to the connection to the monitoring server
                        that `--icinga-callback` makes. Proxy to reach the
                        target through. The scheme defaults to `http` when
                        omitted. Overrides the proxy the environment names
                        (`http_proxy`, `https_proxy`, `all_proxy`) together
                        with the exceptions it lists in `no_proxy`, and is
                        itself overridden by `--no-proxy`. Without either
                        parameter the environment applies. Credentials belong
                        into the environment variable rather than here,
                        because a command-line argument is visible to every
                        user on the host. Example:
                        `--proxy=http://proxy.example.com:3128`.
  --per-source          Judge a rate by the busiest single source address
                        rather than by everything that arrived. A handful of
                        failures from one address within the window is
                        somebody working on this host; the same number spread
                        over as many addresses is the background of an open
                        network going past, and only the first is worth
                        reporting. Lines that name no source are counted
                        together as one, so a burst of those still reports.
                        Default: True
  --port PORT           MySQL/MariaDB port number. Default: 3306
  --server-log SERVER_LOG
                        Log source to read from. Accepts a file path,
                        `docker:CONTAINER`, `podman:CONTAINER`,
                        `kubectl:CONTAINER` or `systemd:UNITNAME`. Can be
                        specified multiple times, and everything named is then
                        read as one window; a source named twice is read once.
                        If omitted, the check first probes
                        `performance_schema.error_log` (MySQL 8.0.22+) and
                        then falls back to the file from `log_error`, read
                        along with the journal of the database unit; what the
                        two share is counted once.
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/mysql-logfile/
```


## Usage Examples

```bash
./mysql-logfile --defaults-file=/var/spool/icinga2/.my.cnf --server-log=systemd:mariadb
./mysql-logfile --ignore-pattern='aborted connection' --ignore-pattern='access denied'
./mysql-logfile --server-log=docker:mariadb

# Silence only the harmless idle-connection timeout (server closes an idle connection
# after wait_timeout, the client's pool reconnects). Real connection errors like
# "got an error reading communication packets" stay visible.
./mysql-logfile --ignore-regex='aborted connection.*got timeout reading communication packets'
```

Output:

```text
2 errors found [CRITICAL] (last: 220503 11:21:43 [ERROR] Aborting). 1 warning found [WARNING] (last: 220502 14:59:58 [Warning] Plugin 'FEEDBACK' is disabled.). 2 startups detected (last: 220503 11:24:54). 4 shutdowns detected (last: 220503 11:21:48). Read 61 lines from `/var/log/mariadb/mariadb.log` (size: 5.8KiB < 32.0MiB).

Errors:
* 220503 11:21:43 [ERROR] /usr/libexec/mysqld: unknown variable 'myvar2=myvalue2'
* 220503 11:21:43 [ERROR] Aborting

Warnings:
* 220502 14:59:58 [Warning] Plugin 'FEEDBACK' is disabled.

Startups:
* 220503 11:07:38 [Note] /usr/libexec/mysqld: ready for connections.
* 220503 11:24:54 [Note] /usr/libexec/mysqld: ready for connections.

Shutdowns:
* 220503 11:07:07 [Note] /usr/libexec/mysqld: Shutdown complete
* 220503 11:07:12 [Note] /usr/libexec/mysqld: Shutdown complete
* 220503 11:21:42 [Note] /usr/libexec/mysqld: Shutdown complete
* 220503 11:21:48 [Note] /usr/libexec/mysqld: Shutdown complete

Recommendations:
* Check the errors in `/var/log/mariadb/mariadb.log`
* Check the warning in `/var/log/mariadb/mariadb.log`
```


## States

* CRIT if the log contains `[ERROR]`-tagged lines.
* WARN if the log contains `[Warning]`-tagged lines. A login the server turned away and a connection a client dropped are not among them, however MariaDB tags them; those are counted below instead.
* WARN or CRIT if more logins were turned away within `--lookback` than `--access-denied-warning` / `--access-denied-critical` allow, counted per source address. A single mistyped password never alerts.
* WARN or CRIT if more connections were dropped by their clients within `--lookback` than `--aborted-connections-warning` / `--aborted-connections-critical` allow, counted per client host. A handful of them is what every application that lets a connection fall out of scope produces.
* A `log_error_verbosity` or `log_warnings` too low for the server to write a denied login at all is reported as the first thing in the output and never alerts, because it says what the rest of the output is worth rather than that something is wrong.
* WARN if a log file is configured but does not exist.
* WARN if a log this check was told to read could not be read at all. The run goes on with the other sources rather than reporting the state of the ones that happened to work.
* WARN if an on-disk log file is `>= 32 MiB` (mysqltuner's cutoff; treat as a hint to set up log rotation).
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| mysql_access_denied | Number | Number of logins the server turned away, from the busiest single source, within the lookback window. |
| mysql_error_lines | Number | Number of error lines found in the log. |
| mysql_logfile_size | Bytes | Log file size. |
| mysql_shutdowns | Number | Number of shutdown events found in the log. |
| mysql_startups | Number | Number of startup events found in the log. |
| mysql_warning_lines | Number | Number of warning lines found in the log. |


## Troubleshooting

### No log file found

`No log file set (set log_error in MySQL/MariaDB config or use the check's --server-log parameter).`

The check tried to get information from an error logfile, but was unable to do so. All possible error logfile locations were tried, but no logfile was found. You have to help by configuring the MySQL/MariaDB system variable `log_error` accordingly, or by providing the `--server-log` parameter to the check.

### `proxies_priv` entry ignored in `--skip-name-resolve` mode

`'proxies_priv' entry '@% root@mariadb-server' ignored in --skip-name-resolve mode.`

```text
select * from mysql.proxies_priv;
delete from `mysql`.`proxies_priv`
where (`host` = 'mariadb-server') and (`user` = 'root') and (`proxied_host` = '') and (`proxied_user` = '');
```


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
* Credits:
    * heavily inspired by MySQLTuner (<https://github.com/major/MySQLTuner-perl>)
