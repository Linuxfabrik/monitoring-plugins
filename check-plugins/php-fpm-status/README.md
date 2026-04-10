# Check php-fpm-status

## Overview

Monitors PHP-FPM pool performance via the status page. Reports active processes, listen queue depth, idle workers, request rates, and uptime per pool. Also lists currently running processes with their request details.

Requires a configured PHP-FPM status page (e.g. `pm.status_path = /fpm-status` in `/etc/php-fpm.d/<poolname>.conf`)

PHP-FPM config example:

```text
; PHP-FPM Config
pm.status_path = /fpm-status
```

```text
# Apache Config
Alias /fpm-status /dev/null
<LocationMatch "/fpm-status">
    Require local
    ProxyPass unix:/run/php-fpm/www.sock|fcgi://localhost/fpm-status
</LocationMatch>
```

**Data Collection:**

* Fetches JSON data from the PHP-FPM status page (`?json&full`)
* Per-process details (PID, request duration, URI, script, etc.) are shown for processes in "Running" state
* The monitoring request itself is excluded from the process list
* Supports extended reporting via `--lengthy`, which adds columns for process state, start time, and content length

**Compatibility:**

* Cross-platform


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/php-fpm-status> |
| Nagios/Icinga Check Name              | `check_php_fpm_status` |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |


## Help

```text
usage: php-fpm-status [-h] [-V] [--always-ok] [-c CRIT]
                      [--critical-slowreq CRIT_SLOW_REQUESTS] [--insecure]
                      [--lengthy] [--no-proxy] [--test TEST]
                      [--timeout TIMEOUT] [-u URL] [-w WARN]
                      [--warning-slowreq WARN_SLOW_REQUESTS]

Monitors PHP-FPM pool performance via the status page. Reports active
processes, listen queue depth, idle workers, request rates, and memory usage
per pool. Alerts when the pool approaches capacity. Also lists currently
running processes with their request details. Supports extended reporting via
--lengthy.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  -c, --critical CRIT   CRIT threshold for queue usage, in percent. Default:
                        >= 90
  --critical-slowreq CRIT_SLOW_REQUESTS
                        CRIT threshold for the number of slow requests.
                        Default: >= 100
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --lengthy             Extended reporting.
  --no-proxy            Do not use a proxy.
  --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                        stderr-file,expected-retc".
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
  -u, --url URL         PHP-FPM status page URL. Default:
                        http://localhost/fpm-status
  -w, --warning WARN    WARN threshold for queue usage, in percent. Default:
                        >= 80
  --warning-slowreq WARN_SLOW_REQUESTS
                        WARN threshold for the number of slow requests.
                        Default: >= 1
```


## Usage Examples

```bash
./php-fpm-status --url http://localhost/fpm-status --warning 80 --critical-slowreq 3 --lengthy
```

Output:

```text
Pool www (dynamic): 71.0 connections, 14 processes (4 active, 10 idle), Up 23s (since 2024-04-12 13:24:23)

PID   ! State   ! Process Start                 ! Reqs ! LastReqDur  ! LastMthd ! LastContLen ! Last Request URI ! Script                                    ! AuthUser 
------+---------+-------------------------------+------+-------------+----------+-------------+------------------+-------------------------------------------+----------
55238 ! Running ! 2024-04-12 13:24:23 (23s ago) ! 6    ! 530ms 807us ! GET      ! -           ! /index.php       ! /var/www/html/www.example.com/index.php ! -     
```

The columns mean:

* AuthUser: The HTTP user (`PHP_AUTH_USER`) of the last request.
* LastContLen: The length of the request body of the last request.
* LastMthd: The HTTP method of the last served request.
* LastReqDur: The total time in microseconds spent serving last request.
* Last Request URI: The URI of the last served request (after webserver processing, it may always be /index.php if you use a front controller pattern redirect).
* PID: The system PID of the process.
* Reqs: The total number of requests served.
* Script: The full path of the script executed by the last request. This will be '-' if not applicable (eg. status page requests).

For more details see <https://www.php.net/manual/en/fpm.status.php>.


## States

* OK if queue usage and slow request count are below the thresholds.
* WARN if queue usage is >= `--warning` (default: 80%).
* WARN if slow request count is >= `--warning-slowreq` (default: 1).
* WARN if `max_children` has been reached at least once.
* CRIT if queue usage is >= `--critical` (default: 90%).
* CRIT if slow request count is >= `--critical-slowreq` (default: 100).
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| accepted conn | Continous Counter | Number of requests accepted by the pool. |
| active processes | Number | Number of active processes. |
| idle processes | Number | Number of idle processes. |
| listen queue | Number | Number of requests in the queue of pending connections. |
| listen queue len | Number | Size of the socket queue of pending connections. |
| max children reached | Number | Number of times the process limit has been reached when pm tries to start more children (works only for pm "dynamic" and "ondemand"). |
| queue usage | Percentage | Queue usage, in percent. |
| slow requests | Number | Number of slow requests. |
| start since | Seconds | Number of seconds since FPM has started. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
