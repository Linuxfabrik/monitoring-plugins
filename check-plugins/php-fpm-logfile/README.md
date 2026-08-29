# Check php-fpm-logfile


## Overview

Scans the PHP-FPM error log for the events an administrator has to act on: rejected configurations, worker crashes, requests that ran into `request_terminate_timeout` or `request_slowlog_timeout`, pools that hit `pm.max_children`, and the emergency reload PHP-FPM performs after repeated worker failures. Startups, reloads and shutdowns are counted alongside them, so a pool that keeps restarting is visible. Alerts when one of those events shows up, when the lines a slow site provokes cross the rates the thresholds set, and when a line arrives at a level `--critical-level` or `--warning-level` covers. Requests that ran long and a pool spawning workers in bursts are counted within `--lookback` and judged by how many of them arrived, not by the fact that they did: one slow page is nobody's night, dozens within ten minutes say the pool is mis-sized. Those lines are counted there and nowhere else, so a site with one heavy report page does not leave the check permanently yellow. What is left is counted by the level PHP-FPM writes at the head of the line: `ALERT` and `ERROR` return CRITICAL and `WARNING` returns WARNING, which `--critical-level` and `--warning-level` move. The events named above carry their own state and are counted there and nowhere else, because the level says nothing about what happened. A message that merely contains the word "error" never counts. The log is read either from a file, from a systemd unit (`systemd:`) or from a container (`docker:`/`podman:`/`kubectl:`). `--server-log` may be given several times, and everything named is then read as one window. Without it the file path is taken from the `error_log` directive of the PHP-FPM configuration, with the common locations of the distributions probed when that yields nothing, and the journal of the PHP-FPM unit is read along with it, because a master that fails to start writes why to its standard error and never reaches the error log. What both hold is counted once. The most recent rotated file is read along with the live one, so the window does not end where logrotate last ran. Note that PHP-FPM discards everything its workers write unless `catch_workers_output = yes` is set, so an error log that only ever shows master events is the default behaviour rather than a quiet application. Requires root or sudo.

**Important Notes:**

* **A line is counted once.** A named event (a worker crash, a saturated pool, an emergency restart) carries its own state and is counted as that event, not as a `WARNING` or `ERROR` line as well; the same holds for the rate-counted request lines. What the per-level counts hold are the lines no catalog claimed, which is what `--critical-level` and `--warning-level` act on.
* **The error log holds master events only, unless workers are told to speak up.** Without `catch_workers_output = yes` in the pool configuration, PHP-FPM redirects the workers' standard output and error to `/dev/null`, so a fatal error in the application never reaches this log. Turn the setting on to see them, and expect them wrapped in a `WARNING` line of the form `[pool www] child 1234 said into stderr: "…"`.
* **A pool spawning in bursts is counted, not reported.** `seems busy (you may need to increase pm.start_servers...)` is written on every maintenance tick for as long as the pressure lasts, so roughly once a second, and only once the spawn rate has doubled its way to 8. A traffic peak therefore leaves a run of them behind and then silence. Filtering them away would throw the tuning signal out with the noise, so they are counted against `--spawn-pressure-warning` over `--lookback` instead. The same holds for requests that ran into `request_slowlog_timeout` or `request_terminate_timeout`.
* **What is genuinely broken keeps its own state.** A worker that died on a signal, a pool that reached `pm.max_children` and the emergency reload raise their state whatever the levels are set to, because those are the three the level alone does not tell apart from an ordinary warning.
* **The application's own error log is a different file.** The RHEL family ships `php_admin_value[error_log] = /var/log/php-fpm/www-error.log` in the default pool, which sends PHP's own messages there in PHP's own format instead of into the file this check reads. Point the generic [logfile](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/logfile.md) check at that file if you want the application's errors monitored too.
* **The window spans the last rotation.** logrotate moves the old file aside (`error.log.1`, `error.log-20260828`, then `.gz`) and PHP-FPM starts a fresh one, so a check reading the live file alone would report a healthy PHP-FPM an hour after it failed to start. The most recent rotated file is therefore read along with the live one, gzip, xz and bzip2 included, and the last section names every file it read. A rotator told to compress with something else, or to move its output to another directory, is out of reach; an event older than one rotation is too.
* **A reload counts as a startup as well.** PHP-FPM reloads by re-executing its master process, so a reload shows up under both counters.
* The check reads a window of the log on every run and reports what that window holds, rather than only what is new. The summary names how many lines that window holds, because everything else is counted within it: right after logrotate the window is a single line, and a run reporting no startup at all is then telling the truth about that one line rather than about the day. That is what makes the startup, reload and shutdown counts meaningful, and it means an event keeps being reported until it leaves the window or the service is acknowledged (see `--icinga-callback`).
* Reading the error log needs root or sudo. The RHEL family installs it as `root:root` mode `0600`.
* `--server-log` is confined to `/var/log`. The check runs as root via sudo, so it refuses a path that resolves outside that directory, which stops it from being turned into an arbitrary root file read. This also applies to the path the PHP-FPM configuration names, because a pool file that an unprivileged user may edit must not be able to steer the check. To read a log stored elsewhere, bind-mount that location under `/var/log` (a symlink is rejected).
* Both `--ignore` and `--match` are matched against the lowercased log line, so write the patterns in lowercase (or use the `(?i)` flag).

**Data Collection:**

* Determines the log file automatically from the `error_log` directive in `/etc/php-fpm.conf`, `/etc/php/*/fpm/php-fpm.conf` or `/usr/local/etc/php-fpm.conf`. The directive is global-only in PHP-FPM, so the pool files are not read.
* Falls back to probing `/var/log/php-fpm/error.log`, `/var/log/php-fpm.log`, `/var/log/php*-fpm.log` and `/usr/local/var/log/php-fpm.log` when the configuration yields nothing.
* Supports reading from a file path, `docker:CONTAINER`, `podman:CONTAINER`, `kubectl:CONTAINER` or `systemd:UNITNAME` via `--server-log`, which can be given several times; everything named is read as one window. A wildcard is not expanded, so name each file.
* Reads the journal of the PHP-FPM unit along with the file where `--server-log` names nothing, and counts an event the two share once.
* Reads at most the last 30000 lines of the source, the most recent rotated file included, and reports how many lines it actually saw, which files they came from, whether it stopped at that cap, and which stretch of time they cover.
* Lines can be narrowed down with `--match` and filtered out with `--ignore`, both Python regular expressions.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/php-fpm-logfile> |
| Nagios/Icinga Check Name              | `check_php_fpm_logfile` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | Yes |
| Runs on                               | Linux |
| Compiled for Windows                  | No |
| Requirements                          | User with higher permissions |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-php-fpm-logfile-*.db` (only with `--icinga-callback`) |


## Help

```text
usage: php-fpm-logfile [-h] [-V] [--always-ok]
                       [--critical-level {ALERT,ERROR,WARNING,none}]
                       [--icinga-callback] [--icinga-password ICINGA_PASSWORD]
                       [--icinga-service-name ICINGA_SERVICE_NAME]
                       [--icinga-url ICINGA_URL]
                       [--icinga-username ICINGA_USERNAME] [--ignore IGNORE]
                       [--insecure] [--lookback LOOKBACK] [--match MATCH]
                       [--no-insecure]
                       [--no-match-severity {ok,warn,crit,unknown}]
                       [--no-perfdata] [--no-proxy] [--proxy PROXY]
                       [--request-timeouts-critical REQUEST_TIMEOUTS_CRITICAL]
                       [--request-timeouts-warning REQUEST_TIMEOUTS_WARNING]
                       [--server-log SERVER_LOG]
                       [--slow-requests-critical SLOW_REQUESTS_CRITICAL]
                       [--slow-requests-warning SLOW_REQUESTS_WARNING]
                       [--spawn-pressure-critical SPAWN_PRESSURE_CRITICAL]
                       [--spawn-pressure-warning SPAWN_PRESSURE_WARNING]
                       [--timeout TIMEOUT]
                       [--warning-level {ALERT,ERROR,WARNING,none}]

Scans the PHP-FPM error log for the events an administrator has to act on:
rejected configurations, worker crashes, requests that ran into
`request_terminate_timeout` or `request_slowlog_timeout`, pools that hit
`pm.max_children`, and the emergency reload PHP-FPM performs after repeated
worker failures. Startups, reloads and shutdowns are counted alongside them,
so a pool that keeps restarting is visible. Alerts when one of those events
shows up, when the lines a slow site provokes cross the rates the thresholds
set, and when a line arrives at a level `--critical-level` or
`--warning-level` covers. Requests that ran long and a pool spawning workers
in bursts are counted within `--lookback` and judged by how many of them
arrived, not by the fact that they did: one slow page is nobody's night,
dozens within ten minutes say the pool is mis-sized. Those lines are counted
there and nowhere else, so a site with one heavy report page does not leave
the check permanently yellow. What is left is counted by the level PHP-FPM
writes at the head of the line: `ALERT` and `ERROR` return CRITICAL and
`WARNING` returns WARNING, which `--critical-level` and `--warning-level`
move. The events named above carry their own state and are counted there and
nowhere else, because the level says nothing about what happened. A message
that merely contains the word "error" never counts. The log is read either
from a file, from a systemd unit (`systemd:`) or from a container
(`docker:`/`podman:`/`kubectl:`). `--server-log` may be given several times,
and everything named is then read as one window. Without it the file path is
taken from the `error_log` directive of the PHP-FPM configuration, with the
common locations of the distributions probed when that yields nothing, and the
journal of the PHP-FPM unit is read along with it, because a master that fails
to start writes why to its standard error and never reaches the error log.
What both hold is counted once. The most recent rotated file is read along
with the live one, so the window does not end where logrotate last ran. Note
that PHP-FPM discards everything its workers write unless
`catch_workers_output = yes` is set, so an error log that only ever shows
master events is the default behaviour rather than a quiet application.
Requires root or sudo.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --critical-level {ALERT,ERROR,WARNING,none}
                        Least severe PHP-FPM log level that returns CRITICAL.
                        Each level includes everything more severe than
                        itself, so `WARNING` covers `ERROR` and `ALERT` as
                        well. Case-sensitive. `none` lets no level return
                        CRITICAL, which leaves the events this check names as
                        the only way to reach it. Example: `--critical-
                        level=WARNING`. Default: ERROR
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
  --ignore IGNORE       Ignore a log line matching this Python regular
                        expression. The log line is lowercased before
                        matching, so write the pattern in lowercase (or use
                        the `(?i)` flag). Can be specified multiple times.
                        Example: `--ignore='(?i)linuxfabrik'`.
  --insecure            Applies to the connection to the monitoring server
                        that `--icinga-callback` makes, which is the only
                        network connection this check opens. This option
                        explicitly allows insecure SSL connections.
  --lookback LOOKBACK   Request timeouts, slow requests and spawn pressure are
                        counted within this window rather than reported one by
                        one. Time window in seconds to look back over, ending
                        at the moment of the run. Only what falls within it is
                        counted, so what is reported is how often something
                        happened lately rather than a total that keeps growing
                        for as long as the source is kept. Example:
                        `--lookback=3600`. Default: 600 (seconds)
  --match MATCH         Only consider a log line matching this Python regular
                        expression. The log line is lowercased before
                        matching, so write the pattern in lowercase (or use
                        the `(?i)` flag). Can be specified multiple times. If
                        both `--match` and `--ignore` are given, an item must
                        match `--match` AND not match `--ignore` to be
                        reported (include first, exclude second). Example:
                        `--match='\[pool www\]'`.
  --no-insecure         Applies to the connection to the monitoring server
                        that `--icinga-callback` makes, which is the only
                        network connection this check opens. Verify the TLS
                        certificate against the system trust store, overriding
                        the insecure default of this check. Use it once the
                        endpoint presents a publicly trusted certificate, or
                        once its CA has been added to the system trust store.
  --no-match-severity {ok,warn,crit,unknown}
                        State to report when no item matches the filters and
                        nothing is checked. Default: ok
  --no-perfdata         Suppress the performance data section from the output.
                        The status message and the exit code are unaffected,
                        so alerting keeps working while trending data is
                        dropped.
  --no-proxy            Applies to the connection to the monitoring server
                        that `--icinga-callback` makes, which is the only
                        network connection this check opens. Do not use a
                        proxy, not even one the environment names. Overrides
                        `--proxy`.
  --proxy PROXY         Applies to the connection to the monitoring server
                        that `--icinga-callback` makes, which is the only
                        network connection this check opens. Proxy to reach
                        the target through. The scheme defaults to `http` when
                        omitted. Overrides the proxy the environment names
                        (`http_proxy`, `https_proxy`, `all_proxy`) together
                        with the exceptions it lists in `no_proxy`, and is
                        itself overridden by `--no-proxy`. Without either
                        parameter the environment applies. Credentials belong
                        into the environment variable rather than here,
                        because a command-line argument is visible to every
                        user on the host. Example:
                        `--proxy=http://proxy.example.com:3128`.
  --request-timeouts-critical REQUEST_TIMEOUTS_CRITICAL
                        Number of terminated requests within `--lookback` that
                        returns CRITICAL. 0 turns the threshold off. Example:
                        `--request-timeouts-critical=20`. Default: 50
  --request-timeouts-warning REQUEST_TIMEOUTS_WARNING
                        Number of terminated requests within `--lookback` that
                        returns WARNING. 0 turns the threshold off. Example:
                        `--request-timeouts-warning=1`. Default: 5
  --server-log SERVER_LOG
                        Log source to read from. Accepts a file path,
                        `docker:CONTAINER`, `podman:CONTAINER`,
                        `kubectl:CONTAINER` or `systemd:UNITNAME`. Can be
                        specified multiple times, and everything named is then
                        read as one window; a source named twice is read once.
                        If omitted, the check reads the `error_log` directive
                        of the PHP-FPM configuration, falls back to the common
                        locations of the distributions, and reads the journal
                        of the PHP-FPM unit along with it; what the two share
                        is counted once. Example: `--server-log=systemd:php-
                        fpm.service`.
  --slow-requests-critical SLOW_REQUESTS_CRITICAL
                        Number of slow requests within `--lookback` that
                        returns CRITICAL. 0 turns the threshold off. Example:
                        `--slow-requests-critical=100`. Default: 200
  --slow-requests-warning SLOW_REQUESTS_WARNING
                        Number of slow requests within `--lookback` that
                        returns WARNING. 0 turns the threshold off. Example:
                        `--slow-requests-warning=5`. Default: 20
  --spawn-pressure-critical SPAWN_PRESSURE_CRITICAL
                        Number of spawn pressure warnings within `--lookback`
                        that returns CRITICAL. 0 turns the threshold off.
                        Example: `--spawn-pressure-critical=50`. Default: 100
  --spawn-pressure-warning SPAWN_PRESSURE_WARNING
                        Number of spawn pressure warnings within `--lookback`
                        that returns WARNING. A pool logs one of these per
                        second while it is spawning in bursts, so this counts
                        how many arrived rather than that any did. 0 turns the
                        threshold off. Example: `--spawn-pressure-warning=30`.
                        Default: 10
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
  --warning-level {ALERT,ERROR,WARNING,none}
                        Least severe PHP-FPM log level that returns WARNING.
                        Each level includes everything more severe than
                        itself, and a level that `--critical-level` already
                        covers returns CRITICAL instead. Case-sensitive.
                        `none` lets no level return WARNING, which leaves the
                        events this check names as the only way to reach it.
                        Example: `--warning-level=none`. Default: WARNING

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/php-fpm-logfile/
```


## Usage Examples

```bash
./php-fpm-logfile
./php-fpm-logfile --server-log=/var/log/php8.2-fpm.log
./php-fpm-logfile --server-log=systemd:php-fpm.service
./php-fpm-logfile --server-log=podman:php-fpm

# Watch a single pool on a host that runs several of them.
./php-fpm-logfile --match='\[pool shop\]'

# Silence the ptrace failure a container host produces when `request_slowlog_timeout`
# is set but the container may not trace its own children. Everything else stays visible.
./php-fpm-logfile --ignore='failed to ptrace'

# A site with one heavy report page, where a handful of slow requests an hour is normal
# and the pool is only worth a look once they pile up.
./php-fpm-logfile --lookback=3600 --slow-requests-warning=50

# A pool that is being tuned: report every burst of spawning, however small.
./php-fpm-logfile --spawn-pressure-warning=1
```

Output of a healthy host:

```text
2026-08-28 15:21 .. 2026-08-28 15:21 (0s): No errors or warnings found. 1 startup detected (last: [28-Aug-2026 15:21:20] NOTICE: fpm is running, pid 205).

Read 3 lines from 1 source:
* `/var/log/php-fpm/error.log` (size: 185.0B)|'php_fpm_logfile_size'=185B;;;0 'php_fpm_alert_lines'=0;;0;0 'php_fpm_error_lines'=0;;0;0 'php_fpm_warning_lines'=0;0;;0 'php_fpm_worker_crashes'=0;0;;0 'php_fpm_pool_saturations'=0;;0;0 'php_fpm_emergency_restarts'=0;;0;0 'php_fpm_request_timeouts'=0;5;50;0 'php_fpm_slow_requests'=0;20;200;0 'php_fpm_spawn_pressure'=0;10;100;0 'php_fpm_startups'=1;;;0 'php_fpm_reloads'=0;;;0 'php_fpm_shutdowns'=0;;;0 'php_fpm_log_rotations'=0;;;0
```

Output of a host whose pool ran out of workers and whose application crashed a worker:

```text
2026-08-28 15:20 .. 2026-08-28 15:20 (20s): 3 ERROR lines found [CRITICAL] (last: [28-Aug-2026 15:20:15] ERROR: failed to ptrace(ATTACH) child 178: Operation not permitted (1)). 6 WARNING lines found [WARNING] (last: [28-Aug-2026 15:20:21] WARNING: [pool www] child 184 said into stderr: "  thrown in /srv/fatal.php on line 3"). Found 2 worker crashes [WARNING], 1 pool saturation [CRITICAL]. 0 request timeouts in the last 10m (2 in the window read). 0 slow requests in the last 10m (3 in the window read). 2 startups detected (last: [28-Aug-2026 15:20:22] NOTICE: fpm is running, pid 194). 1 reload detected (last: [28-Aug-2026 15:20:22] NOTICE: reloading: execvp("/usr/sbin/php-fpm", {"/usr/sbin/php-fpm", "--daemonize"})). 1 shutdown detected (last: [28-Aug-2026 15:20:25] NOTICE: exiting, bye-bye!).

Error lines:
* [28-Aug-2026 15:20:10] ERROR: failed to ptrace(ATTACH) child 171: Operation not permitted (1)
* [28-Aug-2026 15:20:10] ERROR: failed to ptrace(ATTACH) child 177: Operation not permitted (1)
* [28-Aug-2026 15:20:15] ERROR: failed to ptrace(ATTACH) child 178: Operation not permitted (1)

Warning lines:
* [28-Aug-2026 15:20:12] WARNING: [pool www] child 171 exited on signal 15 (SIGTERM) after 7.334101 seconds from start
* [28-Aug-2026 15:20:14] WARNING: [pool www] child 177 exited on signal 15 (SIGTERM) after 5.663659 seconds from start
* [28-Aug-2026 15:20:21] WARNING: [pool www] child 184 said into stderr: "NOTICE: PHP message: PHP Fatal error:  Uncaught Error: Call to undefined function undefined_function_call() in /srv/fatal.php:3"
* [28-Aug-2026 15:20:21] WARNING: [pool www] child 184 said into stderr: "Stack trace:"
* [28-Aug-2026 15:20:21] WARNING: [pool www] child 184 said into stderr: "#0 {main}"
* [28-Aug-2026 15:20:21] WARNING: [pool www] child 184 said into stderr: "  thrown in /srv/fatal.php on line 3"

Read 33 lines from 1 source:
* `/var/log/php-fpm/error.log` (size: 3.1KiB)

Recommendations:
* Workers died on a signal PHP-FPM did not send them; look for a core dump, a faulty PHP extension, or the OOM killer in the kernel log
* A pool ran out of workers; raise `pm.max_children` (or `process.max`) or shorten the requests, otherwise clients wait in the listen queue|'php_fpm_logfile_size'=3152B;;;0 'php_fpm_alert_lines'=0;;0;0 'php_fpm_error_lines'=3;;0;0 'php_fpm_warning_lines'=6;0;;0 'php_fpm_worker_crashes'=2;0;;0 'php_fpm_pool_saturations'=1;;0;0 'php_fpm_emergency_restarts'=0;;0;0 'php_fpm_request_timeouts'=0;5;50;0 'php_fpm_slow_requests'=0;20;200;0 'php_fpm_spawn_pressure'=0;10;100;0 'php_fpm_startups'=2;;;0 'php_fpm_reloads'=1;;;0 'php_fpm_shutdowns'=1;;;0 'php_fpm_log_rotations'=0;;;0
```

## States

* CRIT if the window holds `ALERT` lines. PHP-FPM only writes those when it rejects its own configuration, and it refuses to start afterwards.
* CRIT if the window holds `ERROR` lines, and with `--critical-level` also on `WARNING`.
* WARN if the window holds `WARNING` lines, which `--warning-level` moves. Everything a pool reports about a single request has a counter of its own and is not counted here.
* CRIT if a pool reached `pm.max_children`, or reloaded itself after repeated worker failures. WARN if a worker died on a signal. PHP-FPM logs all three at `WARNING`, so none of them would stand out by level alone.
* WARN or CRIT if more request timeouts, slow requests or spawn pressure warnings arrived within `--lookback` than `--request-timeouts-warning` / `--request-timeouts-critical`, `--slow-requests-warning` / `--slow-requests-critical` and `--spawn-pressure-warning` / `--spawn-pressure-critical` allow.
* WARN if the log file is configured but is not an existing regular file.
* WARN if a log this check was told to read could not be read at all. The run goes on with the other sources rather than reporting the state of the ones that happened to work.
* UNKNOWN if not a single line in the window carries a PHP-FPM log level. The source is then something else, the pool `slowlog` or the access log for example.
* UNKNOWN if no log file could be determined at all, or if `error_log` is set to `syslog`, which is not a file the check can open.
* OK if the log file is empty, which is what a log looks like right after logrotate ran.
* OK with `--no-match-severity` at its default when `--match` dropped every line; set it to `warn`, `crit` or `unknown` to have a filter that matches nothing reported instead.
* The size of the log file is reported and trended but never alerted on. PHP-FPM defines no cutoff of its own, and an unrotated log is the business of `logrotate` and of the [disk-usage](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/disk-usage.md) check.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| php_fpm_alert_lines | Number | Number of `ALERT` lines found in the log. |
| php_fpm_emergency_restarts | Number | Number of times PHP-FPM reloaded itself after `emergency_restart_threshold` worker failures. |
| php_fpm_error_lines | Number | Number of `ERROR` lines found in the log; what a pool reported about a single request is counted separately. |
| php_fpm_log_rotations | Number | Number of times PHP-FPM re-opened the error log, which is what logrotate makes it do. |
| php_fpm_logfile_size | Bytes | Log file size. |
| php_fpm_pool_saturations | Number | Number of times a pool reached `pm.max_children` or `process.max`. |
| php_fpm_reloads | Number | Number of reloads found in the log. |
| php_fpm_request_timeouts | Number | Number of requests terminated after `request_terminate_timeout`, within the lookback window. |
| php_fpm_shutdowns | Number | Number of shutdowns found in the log. |
| php_fpm_slow_requests | Number | Number of requests that ran longer than `request_slowlog_timeout`, within the lookback window. |
| php_fpm_spawn_pressure | Number | Number of times a pool had to spawn workers in bursts, within the lookback window. |
| php_fpm_startups | Number | Number of startups found in the log. |
| php_fpm_warning_lines | Number | Number of `WARNING` lines found in the log; what a pool reported about a single request is counted separately. |
| php_fpm_worker_crashes | Number | Number of workers that died on a signal PHP-FPM did not send them. |


## Troubleshooting

### The check reports a healthy log while the application is throwing errors

PHP-FPM sends the standard output and error of its workers to `/dev/null` unless the pool sets `catch_workers_output = yes`, so nothing the application writes reaches the error log. On the RHEL family the default pool additionally sets `php_admin_value[error_log]`, which sends PHP's own messages to `/var/log/php-fpm/www-error.log` instead.

1. Set `catch_workers_output = yes` in the pool and reload PHP-FPM to have the workers' output appear here, wrapped in `WARNING` lines.
2. Or leave the split as it is and watch the pool's own error log with the generic [logfile](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/logfile.md) check.

### Every counter reads zero right after the nightly logrotate

The distributions rotate this log daily, and PHP-FPM writes a single `error log file re-opened` line into the fresh file. The check reads the rotated predecessor along with it, so the window normally reaches back beyond that point and the last section names every file it read, one per line with its size. A window that really is one line means the predecessor is gone or unreadable, not that PHP-FPM is silent. Use [systemd-unit](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/systemd-unit.md) to know whether PHP-FPM is running at all; this check reports on what the log says.

### `does not look like a PHP-FPM error log`

Not one line in the window carried a PHP-FPM log level, so the source holds something other than the error log. The three files that get mixed up with it are the pool `slowlog`, the access log, and the application's own error log. Check `--server-log` and the `error_log` directive of the PHP-FPM configuration; `php-fpm --test` prints the configuration PHP-FPM actually loads.

### `error_log` is set to syslog

PHP-FPM then hands its messages to the syslog daemon and writes no file of its own. Point the check at the unit instead, with `--server-log=systemd:php-fpm.service`, or at the file the syslog daemon writes them to.

### `failed to ptrace(ATTACH) child N: Operation not permitted`

PHP-FPM attaches to a worker to write the backtrace of a slow request into the `slowlog`, and the kernel refused it. In a container this is the missing `CAP_SYS_PTRACE` capability; on a host it is usually a hardened `kernel.yama.ptrace_scope`. The slow request itself is still logged, only its backtrace is missing. Grant the capability, or silence the message with `--ignore='failed to ptrace'` if the backtraces are not wanted.

### `Refusing to read "…": resolved path is outside the allowed roots`

The check runs as root and therefore only opens a log that resolves inside `/var/log`. Bind-mount the directory holding the log under `/var/log`; a symlink is rejected, because the confinement resolves symlinks before it decides.

### A pool keeps reaching `pm.max_children`

Every request that arrives while all workers are busy waits in the listen queue, and the visible symptom is a slow site rather than an error page.

1. Look at [php-fpm-status](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/php-fpm-status.md) for how saturated the pool runs on an ordinary day.
2. Raise `pm.max_children` only as far as the memory of the host allows: multiply the value by the resident size of a worker and keep the result well below the memory available.
3. Where the requests themselves are slow, raising the limit only buys time. The slow requests in the pool `slowlog` name the scripts to profile.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
