# Check php-fpm-status

## Overview

This check collects information from the PHP-FPM pool status page and alerts on certain overuse. In addition, a table is printed which contains each pool process in the status "Running" (which information relates to the current request that is being served).

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


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/php-fpm-status> |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |
| Requirements                          | Configure a status page like `/fpm-status`, `/<poolname>-fpm-status` or similar in `/etc/php-fpm.d/<poolname>.conf` |


## Help

```text
usage: php-fpm-status [-h] [-V] [--always-ok] [-c CRIT]
                      [--critical-slowreq CRIT_SLOW_REQUESTS] [--insecure]
                      [--lengthy] [--no-proxy] [--test TEST]
                      [--timeout TIMEOUT] [-u URL] [-w WARN]
                      [--warning-slowreq WARN_SLOW_REQUESTS]

This check collects information from the PHP-FPM status page and alerts on
certain overuse. In addition, a table is printed which contains each pool
process in the status "Running" (information relates to the current request
that is being served).

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  -c, --critical CRIT   Set the CRIT threshold for queue usage as a
                        percentage. Default: >= 90
  --critical-slowreq CRIT_SLOW_REQUESTS
                        Set the CRIT threshold for slow requests. Default: >=
                        100
  --insecure            This option explicitly allows to perform "insecure"
                        SSL connections. Default: False
  --lengthy             Extended reporting.
  --no-proxy            Do not use a proxy. Default: False
  --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                        stderr-file,expected-retc".
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
  -u, --url URL         PHP-FPM Status URL. Default: http://localhost/fpm-
                        status
  -w, --warning WARN    Set the WARN threshold for queue usage as a
                        percentage. Default: >= 80
  --warning-slowreq WARN_SLOW_REQUESTS
                        Set the WARN threshold for slow requests. Default: >=
                        1
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

* PID: The system PID of the process.
* Reqs: The total number of requests served.
* LastReqDur: The total time in microseconds spent serving last request.
* LastMthd: The HTTP method of the last served request.
* LastContLen: The length of the request body of the last request.
* Last Request URI: The URI of the last served request (after webserver processing, it may always be /index.php if you use a front controller pattern redirect).
* Script: The full path of the script executed by the last request. This will be '-' if not applicable (eg. status page requests).
* AuthUser: The HTTP user (`PHP_AUTH_USER`) of the last request.

For more details see <https://www.php.net/manual/en/fpm.status.php>.


## States

* WARN or CRIT on queue usage over certain thresholds (default 80/90%)
* WARN or CRIT if number of slow queries is over certain thresholds (default 1/100)


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| accepted conn | Continous Counter | Number of requests accepted by the pool |
| active processes | Number | Number of active processes |
| idle processes | Number | Number of idle processes |
| listen queue len | Number | Size of the socket queue of pending connections |
| listen queue | Number | Number of requests in the queue of pending connections |
| max children reached | Number | Number of times, the process limit has been reached, when pm tries to start more children (works only for pm 'dynamic' and 'ondemand') |
| queue usage | Percentage | Number of requests in the queue of pending connections, in % |
| slow requests | Number | Number of slow requests |
| start since | Seconds | Number of seconds since FPM has started |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
