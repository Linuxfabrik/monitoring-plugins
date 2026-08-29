# Check apache-httpd-logfile


## Overview

Scans the Apache HTTP Server error log for the events an administrator has to act on: children that died on a signal, a server that ran out of workers, processes it failed to fork, backends a reverse proxy could not reach, and stapling switched on for a certificate it cannot work for. Startups, restarts and shutdowns are counted alongside them, so a server that keeps restarting is visible. What Apache logged about one request and one client - a denied access, a password that did not match, a request line it refused to parse - is counted within `--lookback` and judged by how many of them arrived, not by the fact that they did: one is a bot or a bad link, hundreds within ten minutes is somebody walking the site or guessing passwords. Those lines are counted there and nowhere else, so the background noise every internet-facing server produces does not keep the check permanently yellow. What is left is what Apache said about itself, and that is counted by the level it wrote at the head of the line: `emerg`, `alert` and `crit` return CRITICAL, `error` returns WARNING, and `--critical-level` and `--warning-level` move that split. The events named above raise their own state either way, because Apache logs some of them at `notice`. A message that merely contains the word "error" never counts, and a `LogLevel` below `warn` hides a line from this check just as it hides it from the file. The log is read either from a file, from a systemd unit (`systemd:`) or from a container (`docker:`/`podman:`/`kubectl:`). Without `--server-log` the file path is taken from the `ErrorLog` directive of the main configuration file, with the common locations of the distributions probed when that yields nothing. The most recent rotated file is read along with the live one, so the window does not end where logrotate last ran. Note that a server which fails to start writes to its standard error instead of into the error log, so a rejected configuration or an address already in use shows up only when the unit is read (`--server-log=systemd:httpd.service`). Requires root or sudo.

**Important Notes:**

* **A server that never started is invisible in the error log.** Apache writes a rejected configuration, a port it could not bind and a log it could not open to its standard error and then gives up, so none of it reaches the file. Under systemd that output lands in the journal. Point the check at the unit (`--server-log=systemd:httpd.service`) to see those, and use [systemd-unit](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/systemd-unit.md) to know whether Apache is running at all. The other direction holds as well: everything a running Apache logs goes into the file and not into the journal, so a check reading the unit reports no startups, no restarts and no shutdowns however healthy the server is. Reading the unit and reading the file answer different questions, and a host that matters is worth both as two services.
* **Apache's error log holds two different kinds of line, and this check treats them differently.** Apache adds a `[client 198.51.100.7:4000]` field whenever the line is about one request, and never otherwise - that is not a guess but the boundary in its own logging API. A line carrying that field says something went wrong with one request: a bot denied access to a protected path, a scanner posting `/cgi-bin/.%2e/.%2e/bin/sh`, a client sending one host name in SNI and another in the `Host` header. Those are counted within `--lookback` and reported as a rate, because one of them is worth nothing and hundreds of them within ten minutes are worth knowing about. A line without that field is Apache talking about itself, and that one is judged by its level. Deliberately independent of the message code, because the code moves: the same scanner request is `AH00126` on httpd 2.4.37 and `AH10244` on 2.4.62, while both are a `[core:error]` about one client.
* **What is genuinely the server's fault keeps its own state, even when it arrives per request.** A child that died on a signal, a server out of workers and a start Apache refused all raise their own state, whatever their scope and whatever their level; the named events take precedence over the rate.
* **A client does not get to choose which source it is counted under.** Parts of the lines this check reads are the client's own text - the account it asked for, the identification string it sent - and a client that writes an address into them would otherwise move its own lines into somebody else's count, or spread them out to stay below a threshold. The address is therefore taken from where the server writes the peer and nowhere else, and the two spellings of one client (`198.51.100.7` and `::ffff:198.51.100.7`) are counted as the one client they are.
* **A rate is counted per source address, not as a total.** Six failures from one address within the window is somebody working on this host; six failures spread over six addresses is the open network going past, and only the first is worth reporting. What the state follows is therefore the busiest single source, which is also the quantity an intrusion prevention system counts before it blocks one - so the thresholds compare against the same thing that system does. The summary names that source and, where they differ, the total and how many addresses it came from. Lines that name no source are counted together as one, so a burst of unattributable lines still reports. `--no-per-source` goes back to judging everything that arrived, for a log that reaches this check through something that rewrites or drops the address of the peer. Counters that are not about who caused them - a backend that could not be reached, connections refused for want of slots - always judge the total, because the address on such a line says nothing about the cause.
* **The rate thresholds assume an intrusion prevention system in front of this check.** A host reachable from the internet collects failed logins and probes around the clock, and the answer to those is a system that reads the same log, counts what a single source fails within a few minutes and blocks it. Such a system commonly lets five failures per source through before it steps in, so the defaults here sit just above that: what this check reports is what got past the blocking, not what the blocking is already handling. The window is `--lookback`, ten minutes by default, which is the same window those systems count in. On a host without one, the counters see every attempt of every source and the defaults are far too tight - raise them until they sit clear of what the host collects on a quiet day, and keep the ratio rather than the absolute number: a threshold is useful when it is a multiple of the normal rate, not when it is a fraction of it. `0` switches a threshold off entirely.
* **An unreachable backend is counted, not reported.** A `systemctl reload php-fpm` leaves exactly one `AH02454: attempt to connect to Unix domain socket ... failed` behind, and a backend that is really gone writes one per request. Six of them across four days is a handful of reloads and must not page anybody; thirty within a minute is an outage. They are therefore judged by `--proxy-failures-warning` and `--proxy-failures-critical` over `--lookback`. Whether the site answers at all is the job of an HTTP check, not of a log check.
* **Only `crit` and above ignore the scope split.** Across the whole of Apache barely two dozen request-scoped messages are logged that high, and they are a broken LDAP, Lua or FastCGI backend rather than anything a client can provoke. A request-scoped `emerg`, `alert` or `crit` line therefore still alerts by its level.
* **The error log is not the access log.** `ErrorLog` and `CustomLog` are two different files in two different formats, and only the first one is what this check reads. Watch the access log with the generic [logfile](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/logfile.md) check, or the server's own state with [apache-httpd-status](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/apache-httpd-status.md).
* **A virtual host writes its own log.** The RHEL family ships `ErrorLog logs/ssl_error_log` inside the TLS virtual host of `conf.d/ssl.conf`, and the Debian family ships one inside every site under `sites-enabled/`. Those belong to that host and are not read here; only the `ErrorLog` outside any `<VirtualHost>` in the main configuration file counts. Name a virtual host's log with `--server-log` to watch it as a service of its own.
* **The window spans the last rotation.** logrotate moves the old file aside (`error_log-20260828` on the RHEL family, `error.log.1` on the Debian family, then `.gz`) and reloads Apache, which opens a fresh one. A check reading the live file alone would report a healthy server an hour after it broke. The most recent rotated file is therefore read along with the live one, gzip, xz and bzip2 included, and the first fact names the files it read. A rotator told to compress with something else, or to move its output to another directory, is out of reach; an event older than one rotation is too.
* **A restart counts as a startup as well.** Apache logs `resuming normal operations` after every restart and every graceful reload, so both counters move. The nightly logrotate reloads Apache and therefore shows up as a restart.
* **Apache reports a saturated server once per generation.** `AH00484: server reached MaxRequestWorkers setting` is written once and then suppressed until the next restart, so the counter says how often the situation returned rather than how many requests waited for a worker. [apache-httpd-status](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/apache-httpd-status.md) is what shows how close to the limit the server runs on an ordinary day.
* The check reads a window of the log on every run and reports what that window holds, rather than only what is new. The summary names how many lines that window holds, because everything else is counted within it: right after logrotate the window is the restart alone, and a run reporting no startup at all is then telling the truth about that handful of lines rather than about the day. It also means an event keeps being reported until it leaves the window or the service is acknowledged (see `--icinga-callback`). The counted events are the exception: their state follows `--lookback` and falls back on its own as the burst ages out.
* Reading the error log needs root or sudo. The RHEL family installs `/var/log/httpd` as `root:root` mode `0700`.
* `--server-log` is confined to `/var/log`. The check runs as root via sudo, so it refuses a path that resolves outside that directory, which stops it from being turned into an arbitrary root file read. This also applies to the path the Apache configuration names. The RHEL family's `ErrorLog logs/error_log` passes because `/etc/httpd/logs` is a symlink to `/var/log/httpd`, which resolves inside. To read a log stored elsewhere, bind-mount that location under `/var/log`.
* Both `--ignore` and `--match` are matched against the lowercased log line, so write the patterns in lowercase (or use the `(?i)` flag).

**Data Collection:**

* Determines the log file automatically from the `ErrorLog` directive in `/etc/httpd/conf/httpd.conf`, `/etc/apache2/apache2.conf`, `/etc/apache2/httpd.conf` or `/usr/local/apache2/conf/httpd.conf`. A relative path is resolved against `ServerRoot`, and `${APACHE_LOG_DIR}` and the other variables of the Debian family are resolved against `/etc/apache2/envvars`.
* Falls back to probing `/var/log/httpd/error_log`, `/var/log/apache2/error.log`, `/var/log/apache2/error_log`, `/var/log/httpd/error.log` and `/usr/local/apache2/logs/error_log` when the configuration yields nothing, which is also what happens when only an included file sets `ErrorLog`.
* Supports reading from a file path, `docker:CONTAINER`, `podman:CONTAINER`, `kubectl:CONTAINER` or `systemd:UNITNAME` via `--server-log`.
* Reads at most the last 30000 lines of the source, the most recent rotated file included, and reports how many lines it actually saw, which files they came from, whether it stopped at that cap, and which stretch of time they cover.
* Recognizes a line by the level Apache puts in it (`[core:error]`) or by the message code every Apache message carries (`AH00484`), wherever the configured `ErrorLogFormat` places them.
* Lines can be narrowed down with `--match` and filtered out with `--ignore`, both Python regular expressions.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/apache-httpd-logfile> |
| Nagios/Icinga Check Name              | `check_apache_httpd_logfile` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | Yes |
| Runs on                               | Linux |
| Compiled for Windows                  | No |
| Requirements                          | User with higher permissions |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-apache-httpd-logfile-*.db` (only with `--icinga-callback`) |


## Help

```text
usage: apache-httpd-logfile [-h] [-V] [--always-ok]
                            [--auth-failures-critical AUTH_FAILURES_CRITICAL]
                            [--auth-failures-warning AUTH_FAILURES_WARNING]
                            [--client-denials-critical CLIENT_DENIALS_CRITICAL]
                            [--client-denials-warning CLIENT_DENIALS_WARNING]
                            [--critical-level {emerg,alert,crit,error,warn,none}]
                            [--icinga-callback]
                            [--icinga-password ICINGA_PASSWORD]
                            [--icinga-service-name ICINGA_SERVICE_NAME]
                            [--icinga-url ICINGA_URL]
                            [--icinga-username ICINGA_USERNAME]
                            [--ignore IGNORE] [--insecure]
                            [--lookback LOOKBACK] [--match MATCH]
                            [--no-insecure]
                            [--no-match-severity {ok,warn,crit,unknown}]
                            [--no-per-source] [--no-perfdata] [--no-proxy]
                            [--per-source] [--proxy PROXY]
                            [--proxy-failures-critical PROXY_FAILURES_CRITICAL]
                            [--proxy-failures-warning PROXY_FAILURES_WARNING]
                            [--request-errors-critical REQUEST_ERRORS_CRITICAL]
                            [--request-errors-warning REQUEST_ERRORS_WARNING]
                            [--server-log SERVER_LOG] [--timeout TIMEOUT]
                            [--warning-level {emerg,alert,crit,error,warn,none}]

Scans the Apache HTTP Server error log for the events an administrator has to
act on: children that died on a signal, a server that ran out of workers,
processes it failed to fork, backends a reverse proxy could not reach, and
stapling switched on for a certificate it cannot work for. Startups, restarts
and shutdowns are counted alongside them, so a server that keeps restarting is
visible. What Apache logged about one request and one client - a denied
access, a password that did not match, a request line it refused to parse - is
counted within `--lookback` and judged by how many of them arrived, not by the
fact that they did: one is a bot or a bad link, hundreds within ten minutes is
somebody walking the site or guessing passwords. Those lines are counted there
and nowhere else, so the background noise every internet-facing server
produces does not keep the check permanently yellow. What is left is what
Apache said about itself, and that is counted by the level it wrote at the
head of the line: `emerg`, `alert` and `crit` return CRITICAL, `error` returns
WARNING, and `--critical-level` and `--warning-level` move that split. The
events named above raise their own state either way, because Apache logs some
of them at `notice`. A message that merely contains the word "error" never
counts, and a `LogLevel` below `warn` hides a line from this check just as it
hides it from the file. The log is read either from a file, from a systemd
unit (`systemd:`) or from a container (`docker:`/`podman:`/`kubectl:`).
Without `--server-log` the file path is taken from the `ErrorLog` directive of
the main configuration file, with the common locations of the distributions
probed when that yields nothing. The most recent rotated file is read along
with the live one, so the window does not end where logrotate last ran. Note
that a server which fails to start writes to its standard error instead of
into the error log, so a rejected configuration or an address already in use
shows up only when the unit is read (`--server-log=systemd:httpd.service`).
Requires root or sudo.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --auth-failures-critical AUTH_FAILURES_CRITICAL
                        Number of authentication failures within `--lookback`
                        that returns CRITICAL. 0 turns the threshold off.
                        Example: `--auth-failures-critical=200`. Default: 60
  --auth-failures-warning AUTH_FAILURES_WARNING
                        Number of authentication failures within `--lookback`
                        that returns WARNING. 0 turns the threshold off.
                        Example: `--auth-failures-warning=20`. Default: 6
  --client-denials-critical CLIENT_DENIALS_CRITICAL
                        Number of denied requests within `--lookback` that
                        returns CRITICAL. 0 turns the threshold off. Example:
                        `--client-denials-critical=200`. Default: 60
  --client-denials-warning CLIENT_DENIALS_WARNING
                        Number of denied requests within `--lookback` that
                        returns WARNING. 0 turns the threshold off. Example:
                        `--client-denials-warning=50`. Default: 6
  --critical-level {emerg,alert,crit,error,warn,none}
                        Least severe Apache log level that returns CRITICAL.
                        Each level includes everything more severe than
                        itself, so `error` covers `crit`, `alert` and `emerg`
                        as well. Case-sensitive. `none` lets no level return
                        CRITICAL, which leaves the events this check names as
                        the only way to reach it. Example: `--critical-
                        level=error`. Default: crit
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
                        Example: `--ignore='ah01630'`.
  --insecure            Applies to the connection to the monitoring server
                        that `--icinga-callback` makes, which is the only
                        network connection this check opens. This option
                        explicitly allows insecure SSL connections.
  --lookback LOOKBACK   Denied requests, failed passwords and failed requests
                        are counted within this window rather than reported
                        one by one. Time window in seconds to look back over,
                        ending at the moment of the run. Only what falls
                        within it is counted, so what is reported is how often
                        something happened lately rather than a total that
                        keeps growing for as long as the source is kept.
                        Example: `--lookback=3600`. Default: 600 (seconds)
  --match MATCH         Only consider a log line matching this Python regular
                        expression. The log line is lowercased before
                        matching, so write the pattern in lowercase (or use
                        the `(?i)` flag). Can be specified multiple times. If
                        both `--match` and `--ignore` are given, an item must
                        match `--match` AND not match `--ignore` to be
                        reported (include first, exclude second). Example:
                        `--match='\[ssl:'`.
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
                        that `--icinga-callback` makes, which is the only
                        network connection this check opens. Do not use a
                        proxy, not even one the environment names. Overrides
                        `--proxy`.
  --per-source          Judge a rate by the busiest single source address
                        rather than by everything that arrived. A handful of
                        failures from one address within the window is
                        somebody working on this host; the same number spread
                        over as many addresses is the background of an open
                        network going past, and only the first is worth
                        reporting. Lines that name no source are counted
                        together as one, so a burst of those still reports.
                        Default: True
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
  --proxy-failures-critical PROXY_FAILURES_CRITICAL
                        Number of unreachable backends within `--lookback`
                        that returns CRITICAL. 0 turns the threshold off.
                        Example: `--proxy-failures-critical=50`. Default: 100
  --proxy-failures-warning PROXY_FAILURES_WARNING
                        Number of unreachable backends within `--lookback`
                        that returns WARNING. One of them is a backend being
                        restarted, so this counts how many arrived rather than
                        that any did. 0 turns the threshold off. Example:
                        `--proxy-failures-warning=1`. Default: 10
  --request-errors-critical REQUEST_ERRORS_CRITICAL
                        Number of failed requests within `--lookback` that
                        returns CRITICAL. Counts what Apache logged about one
                        request and one client, denied requests and failed
                        passwords excluded, as those have counters of their
                        own. 0 turns the threshold off. Example: `--request-
                        errors-critical=200`. Default: 60
  --request-errors-warning REQUEST_ERRORS_WARNING
                        Number of failed requests within `--lookback` that
                        returns WARNING. Counts what Apache logged about one
                        request and one client, denied requests and failed
                        passwords excluded, as those have counters of their
                        own. 0 turns the threshold off. Example: `--request-
                        errors-warning=50`. Default: 6
  --server-log SERVER_LOG
                        Log source to read from. Accepts a file path,
                        `docker:CONTAINER`, `podman:CONTAINER`,
                        `kubectl:CONTAINER` or `systemd:UNITNAME`. If omitted,
                        the check reads the `ErrorLog` directive of the main
                        Apache configuration file and falls back to the common
                        locations of the distributions. Example: `--server-
                        log=systemd:httpd.service`.
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
  --warning-level {emerg,alert,crit,error,warn,none}
                        Least severe Apache log level that returns WARNING.
                        Each level includes everything more severe than
                        itself, and a level that `--critical-level` already
                        covers returns CRITICAL instead. Case-sensitive.
                        `none` lets no level return WARNING, which leaves the
                        events this check names as the only way to reach it.
                        Example: `--warning-level=warn`. Default: error

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/apache-httpd-logfile/
```


## Usage Examples

```bash
./apache-httpd-logfile
./apache-httpd-logfile --server-log=/var/log/apache2/error.log
./apache-httpd-logfile --server-log=systemd:httpd.service
./apache-httpd-logfile --server-log=podman:httpd

# Page on every `error` line as well, on a host where the configuration denies nothing
# and no application logs through Apache.
./apache-httpd-logfile --critical-level=error

# An internet-facing site behind a WAF that already answers scans. Report a walk of the
# site only once it is large enough to matter, and never at night.
./apache-httpd-logfile --client-denials-warning=1000 --client-denials-critical=0

# A login form that is being guessed at should be seen within the hour rather than
# within ten minutes.
./apache-httpd-logfile --lookback=3600 --auth-failures-warning=200

# A quiet internal server, where a single failed request is already worth a look.
./apache-httpd-logfile --request-errors-warning=1

# A reverse proxy in front of a single application, where the backend going away at all
# is worth knowing about.
./apache-httpd-logfile --proxy-failures-warning=1

# Silence the mod_ssl notice a container image produces when it was built against a
# different OpenSSL. Everything else stays visible.
./apache-httpd-logfile --ignore='ah01882'

# Watch the log of one virtual host as a service of its own.
./apache-httpd-logfile --server-log=/var/log/httpd/shop_error_log
```

Output of a healthy host:

```text
No errors or warnings found. 1 startup detected (last: [Fri Aug 28 17:12:25.860583 2026] [mpm_event:notice] [pid 1929:tid 1929] AH00489: Apache/2.4.62 (Rocky Linux) configured -- resuming normal operations). No restarts detected. 1 shutdown detected (last: [Fri Aug 28 17:12:28.865860 2026] [mpm_event:notice] [pid 1929:tid 1929] AH00491: caught SIGTERM, shutting down). Read 6 lines from `/var/log/httpd/error_log` (size: 815.0B), covering 2026-08-28 17:12..2026-08-28 17:12 (3s).
```

Output of a host that ran out of workers, lost a child to a segfault and could not reach its backend:

```text
3 error lines found [WARNING] (last: [Fri Aug 28 17:12:07.128098 2026] [cgid:error] [pid 1835:tid 1835] AH01239: cgid daemon process died, restarting). Found 1 child crash, 1 worker saturation, 2 proxy failures. 0 client denials in the last 10m (1 in the window read). 0 request errors in the last 10m (1 in the window read). 2 startups detected (last: [Fri Aug 28 17:12:08.167550 2026] [mpm_event:notice] [pid 1835:tid 1835] AH00489: Apache/2.4.62 (Rocky Linux) configured -- resuming normal operations). 1 restart detected (last: [Fri Aug 28 17:12:08.157150 2026] [mpm_event:notice] [pid 1835:tid 1835] AH00493: SIGUSR1 received.  Doing graceful restart). 1 shutdown detected (last: [Fri Aug 28 17:12:11.175839 2026] [mpm_event:notice] [pid 1835:tid 1835] AH00491: caught SIGTERM, shutting down). Read 17 lines from `/var/log/httpd/error_log` (size: 2.4KiB), covering 2026-08-28 17:11..2026-08-28 17:12 (24s).

Error lines:
* [Fri Aug 28 17:11:47.108528 2026] [mpm_event:error] [pid 1835:tid 1835] AH00484: server reached MaxRequestWorkers setting, consider raising the MaxRequestWorkers setting
* [Fri Aug 28 17:12:05.129900 2026] [proxy:error] [pid 1838:tid 1859] (111)Connection refused: AH00957: http: attempt to connect to 127.0.0.1:9999 (127.0.0.1:9999) failed
* [Fri Aug 28 17:12:07.128098 2026] [cgid:error] [pid 1835:tid 1835] AH01239: cgid daemon process died, restarting

Recommendations:
* Children died on a signal Apache did not send them; look for a core dump, a faulty module, or the OOM killer in the kernel log
* The server ran out of workers; raise `MaxRequestWorkers` (and `ServerLimit` with it) or shorten the requests, otherwise clients wait in the listen queue
* A backend behind the reverse proxy could not be reached; check that it is running and that Apache may open the connection to it
```

Output of a host somebody is walking:

```text
147 client denials in the last 10m [WARNING]. No startups detected. No restarts detected. No shutdowns detected. Read 147 lines from `/var/log/httpd/error_log` (size: 25.0KiB), covering 2026-08-28 16:55..2026-08-28 17:12 (17m).

Recommendations:
* Clients are being denied access in bulk; the paths in the log say whether somebody is walking the site, and an intrusion prevention system or the firewall is where that is answered
```

## States

* CRIT if the window holds `emerg`, `alert` or `crit` lines, and with `--critical-level` also on the levels below them.
* WARN if the window holds `error` lines, and with `--warning-level` also on `warn`.
* CRIT if the window holds a saturated server, a process Apache could not fork, or a start Apache refused to complete. Apache logs a saturated server at `error` and a refused start without any level at all, so neither of them would be reported by level alone.
* WARN if the window holds a child that died on a signal, or a server that came within `MinSpareThreads` of `MaxRequestWorkers`. Apache logs a dead child at `notice`.
* WARN or CRIT if more denied requests, failed passwords, unreachable backends or other failed requests arrived within `--lookback` than `--proxy-failures-warning` / `--proxy-failures-critical`, `--client-denials-warning` / `--client-denials-critical`, `--auth-failures-warning` / `--auth-failures-critical` and `--request-errors-warning` / `--request-errors-critical` allow. A single one of any of them never alerts, and none of them is counted by its level.
* WARN if OCSP stapling is switched on for a certificate it cannot be set up for. Apache says so once per certificate on every start and then serves TLS without stapling.
* WARN if the log file is configured but is not an existing regular file.
* UNKNOWN if not a single line in the window carries an Apache log level or message code. The source is then something else, the access log for example.
* UNKNOWN if no log file could be determined at all, or if `ErrorLog` hands the log to syslog or pipes it into a program, neither of which is a file the check can open.
* OK if the log file is empty, which is what a log looks like right after logrotate ran.
* OK with `--no-match-severity` at its default when `--match` dropped every line; set it to `warn`, `crit` or `unknown` to have a filter that matches nothing reported instead.
* The size of the log file is reported and trended but never alerted on. Apache defines no cutoff of its own, and an unrotated log is the business of `logrotate` and of the [disk-usage](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/disk-usage.md) check.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| apache_httpd_alert_lines | Number | Number of `alert` lines found in the log. |
| apache_httpd_auth_failures | Number | Number of failed passwords and unknown users within the rate window. |
| apache_httpd_child_crashes | Number | Number of children that died on a signal Apache did not send them. |
| apache_httpd_client_denials | Number | Number of requests the configuration denied within the rate window. |
| apache_httpd_crit_lines | Number | Number of `crit` lines found in the log. |
| apache_httpd_emerg_lines | Number | Number of `emerg` lines found in the log. |
| apache_httpd_error_lines | Number | Number of `error` lines about the server itself; what Apache logged about one request is counted separately. |
| apache_httpd_fork_failures | Number | Number of processes Apache failed to fork. |
| apache_httpd_logfile_size | Bytes | Log file size. |
| apache_httpd_proxy_failures | Number | Number of times a backend could not be reached or its reply broke off, within the lookback window. |
| apache_httpd_request_errors | Number | Number of requests Apache logged a problem about within the lookback window, denied requests and failed passwords excluded. |
| apache_httpd_restarts | Number | Number of restarts and graceful reloads found in the log. |
| apache_httpd_shutdowns | Number | Number of shutdowns found in the log. |
| apache_httpd_stapling_failures | Number | Number of lines about a certificate OCSP stapling could not be set up for. |
| apache_httpd_startup_failures | Number | Number of starts Apache refused to complete. |
| apache_httpd_startups | Number | Number of startups found in the log, restarts included. |
| apache_httpd_warn_lines | Number | Number of `warn` lines about the server itself; what Apache logged about one request is counted separately. |
| apache_httpd_worker_pressure | Number | Number of times the server came within `MinSpareThreads` of `MaxRequestWorkers`. |
| apache_httpd_worker_saturations | Number | Number of times the server reached `MaxRequestWorkers` or filled its scoreboard. |


## Troubleshooting

### The check is green while the site is down

The error log only holds what a running Apache wrote. A server that never came up wrote its reason to standard error and exited, and a server that is simply not running writes nothing at all.

1. `systemctl status httpd` (or `apache2`) says whether it is running, and [systemd-unit](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/systemd-unit.md) is what monitors that.
2. `--server-log=systemd:httpd.service` points this check at the journal instead of at the file, where a rejected configuration and an address already in use are visible.
3. `apachectl configtest` names the directive Apache refused, without touching the running server.

### The check keeps reporting the same lines

Every run reads a window of the log rather than only what is new, so a line keeps being reported until it leaves the window or logrotate moves it away. That is what makes the startup, restart and shutdown counts meaningful. Acknowledge the service and hand the check `--icinga-callback` together with the credentials of the monitoring server, and the lines it currently reports are remembered as handled and stop raising an alert.

### The check is permanently yellow on an internet-facing host

Look at which lines it names. Anything Apache logged about one request is already counted as a rate and cannot do this, so what is left is a line about the server itself.

1. `AH02218` / `AH02604` mean OCSP stapling is switched on for a certificate whose issuer publishes no OCSP responder, which is every certificate Let's Encrypt issues today. Turn `SSLUseStapling off` for that host; stapling is doing nothing there either way.
2. `AH01882` (mod_ssl built against a different OpenSSL) and `AH01909` (certificate name does not match the server name) come from the image or the certificate and are fixed there, or dropped from this check with `--ignore='ah01882'`.
3. For any other recurring message, a per-module `LogLevel authz_core:crit` in the Apache configuration keeps it out of the file entirely, which is better than filtering it here.
4. Where the noise comes from an application behind `mod_proxy_fcgi` (`AH01071: Got error 'PHP message: ...'`), the application's own log is the better place to watch it, with the generic [logfile](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/logfile.md) check.

### The check does not alert although the log is full of `error` lines

Read the lines. If they carry a `[client ...]` field, Apache logged them about one request and this check counts them as a rate rather than by their level, which is what keeps a scanned server green. The `... request errors in the last ...` fact says how many arrived recently and how many the whole window holds.

1. Lower `--request-errors-warning` to have a smaller number of them reported. On a server nobody but the application talks to, `--request-errors-warning=1` is reasonable.
2. Widen `--lookback` to judge over a longer stretch, for instance `--lookback=3600`.
3. A line about the server itself is never affected by this and always counts by its level.

### `proxy failures in the last ...` on a host where nothing is broken

`mod_proxy` logs one line per request it could not hand to a backend, so restarting the backend leaves one line behind and a backend that is gone leaves a stream of them. The count is what separates the two.

1. Compare the number against how often the backend was restarted. `systemctl show php-fpm --property=ExecMainStartTimestamp` says when it last came up.
2. Where a single one already matters, `--proxy-failures-warning=1` reports it.
3. Whether the site answers at all is not something a log can say. Watch that with an HTTP check against the site itself.

### `does not look like an Apache error log`

Not one line in the window carried an Apache log level or an `AHnnnnn` message code, so the source holds something else. The file that gets mixed up with it most often is the access log, which `CustomLog` writes in a completely different format. Check `--server-log` and the `ErrorLog` directive; `apachectl -S` prints the paths Apache actually uses, virtual hosts included.

### `ErrorLog` hands the log to syslog, or pipes it into a program

`ErrorLog syslog:local1` gives the messages to the syslog daemon, and `ErrorLog "|/usr/sbin/rotatelogs ..."` hands them to a program; in neither case is there a file this check can open. Point the check at the unit with `--server-log=systemd:httpd.service`, or at the file the syslog daemon or the rotator writes.

### `Refusing to read "…": resolved path is outside the allowed roots`

The check runs as root and therefore only opens a log that resolves inside `/var/log`. Bind-mount the directory holding the log under `/var/log`; a symlink that points out of it is rejected, because the confinement resolves symlinks before it decides.

### The server keeps reaching `MaxRequestWorkers`

Every request that arrives while all workers are busy waits in the listen queue, and the visible symptom is a slow site rather than an error page.

1. Look at [apache-httpd-status](https://linuxfabrik.github.io/monitoring-plugins/check-plugins/apache-httpd-status.md) for how saturated the server runs on an ordinary day.
2. Raise `MaxRequestWorkers` only as far as the memory of the host allows, and raise `ServerLimit` with it where the MPM needs more child processes to reach the new number.
3. Where the requests themselves are slow, raising the limit only buys time. A reverse proxy that waits for a backend and an application that waits for a database both show up here as saturation.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
