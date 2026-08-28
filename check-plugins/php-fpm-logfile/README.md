# Check php-fpm-logfile


## Overview

Scans the PHP-FPM error log for the events an administrator has to act on: rejected configurations, worker crashes, requests that ran into `request_terminate_timeout` or `request_slowlog_timeout`, pools that hit `pm.max_children`, and the emergency reload PHP-FPM performs after repeated worker failures. Startups, reloads and shutdowns are counted alongside them, so a pool that keeps restarting is visible. Alerts CRITICAL on `ALERT` and `ERROR` lines, and WARNING on `WARNING` lines; the levels PHP-FPM itself puts at the head of every line decide the state, so a message that merely contains the word "error" does not trip the count. The log is read either from a file, from a systemd unit (`systemd:`) or from a container (`docker:`/`podman:`/`kubectl:`). Without `--server-log` the file path is taken from the `error_log` directive of the PHP-FPM configuration, with the common locations of the distributions probed when that yields nothing. Note that PHP-FPM discards everything its workers write unless `catch_workers_output = yes` is set, so an error log that only ever shows master events is the default behaviour rather than a quiet application. Requires root or sudo.

**Important Notes:**

* **The error log holds master events only, unless workers are told to speak up.** Without `catch_workers_output = yes` in the pool configuration, PHP-FPM redirects the workers' standard output and error to `/dev/null`, so a fatal error in the application never reaches this log. Turn the setting on to see them, and expect them wrapped in a `WARNING` line of the form `[pool www] child 1234 said into stderr: "…"`.
* **The application's own error log is a different file.** The RHEL family ships `php_admin_value[error_log] = /var/log/php-fpm/www-error.log` in the default pool, which sends PHP's own messages there in PHP's own format instead of into the file this check reads. Point the generic [logfile](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/logfile.md) check at that file if you want the application's errors monitored too.
* **The window ends at the last rotation.** The check reads the live log file only. logrotate moves the old file aside (`error.log-20260828`, then `.gz`) and PHP-FPM starts a fresh one, so an event from before the rotation is no longer reported from that moment on, and an unacknowledged one stops alerting. Where that matters, watch the rotated files with the generic [logfile](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/logfile.md) check as well, or shorten the check interval so an event is seen while it is still in the live file.
* **A reload counts as a startup as well.** PHP-FPM reloads by re-executing its master process, so a reload shows up under both counters.
* The check reads a window of the log on every run and reports what that window holds, rather than only what is new. The summary names how many lines that window holds, because everything else is counted within it: right after logrotate the window is a single line, and a run reporting no startup at all is then telling the truth about that one line rather than about the day. That is what makes the startup, reload and shutdown counts meaningful, and it means an event keeps being reported until it leaves the window or the service is acknowledged (see `--icinga-callback`).
* Reading the error log needs root or sudo. The RHEL family installs it as `root:root` mode `0600`.
* `--server-log` is confined to `/var/log`. The check runs as root via sudo, so it refuses a path that resolves outside that directory, which stops it from being turned into an arbitrary root file read. This also applies to the path the PHP-FPM configuration names, because a pool file that an unprivileged user may edit must not be able to steer the check. To read a log stored elsewhere, bind-mount that location under `/var/log` (a symlink is rejected).
* Both `--ignore` and `--match` are matched against the lowercased log line, so write the patterns in lowercase (or use the `(?i)` flag).

**Data Collection:**

* Determines the log file automatically from the `error_log` directive in `/etc/php-fpm.conf`, `/etc/php/*/fpm/php-fpm.conf` or `/usr/local/etc/php-fpm.conf`. The directive is global-only in PHP-FPM, so the pool files are not read.
* Falls back to probing `/var/log/php-fpm/error.log`, `/var/log/php-fpm.log`, `/var/log/php*-fpm.log` and `/usr/local/var/log/php-fpm.log` when the configuration yields nothing.
* Supports reading from a file path, `docker:CONTAINER`, `podman:CONTAINER`, `kubectl:CONTAINER` or `systemd:UNITNAME` via `--server-log`.
* Reads at most the last 30000 lines of the source, and reports how many lines it actually saw and how often the log was rotated within them.
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
usage: php-fpm-logfile [-h] [-V] [--always-ok] [--icinga-callback]
                       [--icinga-password ICINGA_PASSWORD]
                       [--icinga-service-name ICINGA_SERVICE_NAME]
                       [--icinga-url ICINGA_URL]
                       [--icinga-username ICINGA_USERNAME] [--ignore IGNORE]
                       [--insecure] [--match MATCH] [--no-insecure]
                       [--no-match-severity {ok,warn,crit,unknown}]
                       [--no-perfdata] [--no-proxy] [--proxy PROXY]
                       [--server-log SERVER_LOG] [--timeout TIMEOUT]

Scans the PHP-FPM error log for the events an administrator has to act on:
rejected configurations, worker crashes, requests that ran into
`request_terminate_timeout` or `request_slowlog_timeout`, pools that hit
`pm.max_children`, and the emergency reload PHP-FPM performs after repeated
worker failures. Startups, reloads and shutdowns are counted alongside them,
so a pool that keeps restarting is visible. Alerts CRITICAL on `ALERT` and
`ERROR` lines, and WARNING on `WARNING` lines; the levels PHP-FPM itself puts
at the head of every line decide the state, so a message that merely contains
the word "error" does not trip the count. The log is read either from a file,
from a systemd unit (`systemd:`) or from a container
(`docker:`/`podman:`/`kubectl:`). Without `--server-log` the file path is
taken from the `error_log` directive of the PHP-FPM configuration, with the
common locations of the distributions probed when that yields nothing. Note
that PHP-FPM discards everything its workers write unless
`catch_workers_output = yes` is set, so an error log that only ever shows
master events is the default behaviour rather than a quiet application.
Requires root or sudo.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
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
  --server-log SERVER_LOG
                        Log source to read from. Accepts a file path,
                        `docker:CONTAINER`, `podman:CONTAINER`,
                        `kubectl:CONTAINER` or `systemd:UNITNAME`. If omitted,
                        the check reads the `error_log` directive of the PHP-
                        FPM configuration and falls back to the common
                        locations of the distributions. Example: `--server-
                        log=systemd:php-fpm.service`.
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)

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
```

Output of a healthy host:

```text
Source: `/var/log/php-fpm/error.log` (size: 185.0B, 3 lines). No alerts found. No errors found. No warnings found. 1 startup detected (last: [28-Aug-2026 15:21:20] NOTICE: fpm is running, pid 205). No reloads detected. No shutdowns detected.
```

Output of a host whose pool ran out of workers and whose application crashed a worker:

```text
Source: `/var/log/php-fpm/error.log` (size: 3.1KiB, 33 lines). No alerts found. No errors found. 14 warnings found [WARNING] (last: [28-Aug-2026 15:20:21] WARNING: [pool www] child 184 said into stderr: "  thrown in /srv/fatal.php on line 3"). Among them: 2 worker crashes, 2 request timeouts, 3 slow requests, 1 pool saturation. 2 startups detected (last: [28-Aug-2026 15:20:22] NOTICE: fpm is running, pid 194). 1 reload detected (last: [28-Aug-2026 15:20:22] NOTICE: reloading: execvp("/usr/sbin/php-fpm", {"/usr/sbin/php-fpm", "--daemonize"})). 1 shutdown detected (last: [28-Aug-2026 15:20:25] NOTICE: exiting, bye-bye!).

Warnings:
* [28-Aug-2026 15:20:09] WARNING: [pool www] server reached pm.max_children setting (2), consider raising it
* [28-Aug-2026 15:20:10] WARNING: [pool www] child 171, script '/srv/slow.php' (request: "GET /srv/slow.php") executing too slow (2.641780 sec), logging
* [28-Aug-2026 15:20:12] WARNING: [pool www] child 171, script '/srv/slow.php' (request: "GET /srv/slow.php") execution timed out (5.308568 sec), terminating
* [28-Aug-2026 15:20:12] WARNING: [pool www] child 171 exited on signal 15 (SIGTERM) after 7.334101 seconds from start
* ...
* [28-Aug-2026 15:20:17] WARNING: [pool www] child 178 exited on signal 11 (SIGSEGV - core dumped) after 4.769535 seconds from start
* [28-Aug-2026 15:20:19] WARNING: [pool www] child 179 exited on signal 9 (SIGKILL) after 5.345946 seconds from start
* [28-Aug-2026 15:20:21] WARNING: [pool www] child 184 said into stderr: "NOTICE: PHP message: PHP Fatal error:  Uncaught Error: Call to undefined function undefined_function_call() in /srv/fatal.php:3"

Recommendations:
* Workers died on a signal PHP-FPM did not send them; look for a core dump, a faulty PHP extension, or the OOM killer in the kernel log
* Requests were terminated after `request_terminate_timeout`; profile the scripts named above or raise the timeout for that pool
* Requests ran longer than `request_slowlog_timeout`; the backtrace of each one is in the pool `slowlog`
* A pool ran out of workers; raise `pm.max_children` (or `process.max`) or shorten the requests, otherwise clients wait in the listen queue
```


## States

* CRIT if the window holds `ALERT` lines. PHP-FPM only writes those when it rejects its own configuration, and it refuses to start afterwards.
* CRIT if the window holds `ERROR` lines.
* WARN if the window holds `WARNING` lines. Worker crashes, request timeouts, slow requests, pool saturation, spawn pressure and the emergency reload all arrive at this level and are named individually in the summary.
* WARN if the log file is configured but is not an existing regular file.
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
| php_fpm_error_lines | Number | Number of `ERROR` lines found in the log. |
| php_fpm_log_rotations | Number | Number of times PHP-FPM re-opened the error log, which is what logrotate makes it do. |
| php_fpm_logfile_size | Bytes | Log file size. |
| php_fpm_pool_saturations | Number | Number of times a pool reached `pm.max_children` or `process.max`. |
| php_fpm_reloads | Number | Number of reloads found in the log. |
| php_fpm_request_timeouts | Number | Number of requests terminated after `request_terminate_timeout`. |
| php_fpm_shutdowns | Number | Number of shutdowns found in the log. |
| php_fpm_slow_requests | Number | Number of requests that ran longer than `request_slowlog_timeout`. |
| php_fpm_spawn_pressure | Number | Number of times a pool had to spawn workers in bursts. |
| php_fpm_startups | Number | Number of startups found in the log. |
| php_fpm_warning_lines | Number | Number of `WARNING` lines found in the log. |
| php_fpm_worker_crashes | Number | Number of workers that died on a signal PHP-FPM did not send them. |


## Troubleshooting

### The check reports a healthy log while the application is throwing errors

PHP-FPM sends the standard output and error of its workers to `/dev/null` unless the pool sets `catch_workers_output = yes`, so nothing the application writes reaches the error log. On the RHEL family the default pool additionally sets `php_admin_value[error_log]`, which sends PHP's own messages to `/var/log/php-fpm/www-error.log` instead.

1. Set `catch_workers_output = yes` in the pool and reload PHP-FPM to have the workers' output appear here, wrapped in `WARNING` lines.
2. Or leave the split as it is and watch the pool's own error log with the generic [logfile](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/logfile.md) check.

### Every counter reads zero right after the nightly logrotate

The distributions rotate this log daily, and PHP-FPM writes a single `error log file re-opened` line into the fresh file. Until something else happens, that one line is the whole window, which is why the summary reports no startup, no reload and no shutdown. The `Source:` fact says so outright, as in `(size: 56.0B, 1 line, rotated once in this window)`, so a freshly rotated log is not mistaken for a silent PHP-FPM. Use [systemd-unit](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/systemd-unit.md) to know whether PHP-FPM is running at all; this check reports on what the log says.

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
