# Check php-fpm-status


## Overview

Monitors PHP-FPM pool performance via the pool status page. Reports pool saturation (percentage of busy workers), new slow requests since the previous check, the request rate, process counts, and per-process request details for every pool. Multiple pools on the same host can be checked in one run by passing `--url` several times; each URL is treated as an independent pool, and the overall plugin state is the worst of all pools. Basic authentication can be embedded in the URL as `http://user:password@host/pool-status`. Alerts when pool saturation exceeds the warning/critical thresholds or when new slow requests appear since the last check. Alerts with a configurable severity if a pool is unreachable. Supports extended reporting via `--lengthy`.

**Important Notes:**

* The first check run (and the first run after an FPM restart) captures a baseline for slow-request and request-rate deltas. During that run the delta metrics are shown as `-`; the saturation metric is already alerted on immediately.
* The plugin keeps per-URL state between runs in a small local SQLite database (`linuxfabrik-monitoring-plugins-php-fpm-status.db` in the system temp directory). Removing the file forces a fresh baseline.

Requires a configured PHP-FPM status page per pool. Example pool snippet:

```text
; /etc/php-fpm.d/nextcloud.conf (RHEL) or
; /etc/php/8.2/fpm/pool.d/nextcloud.conf (Debian)
pm.status_path = /nextcloud-fpm-status
ping.path = /nextcloud-fpm-ping
```

The web server has to route that URL to the pool's FastCGI socket. Apache example (httpd):

```text
<LocationMatch "/nextcloud-fpm-status">
    Require local
    ProxyPass unix:/run/php-fpm/nextcloud.sock|fcgi://localhost/nextcloud-fpm-status
</LocationMatch>
```

Nginx example:

```text
location = /nextcloud-fpm-status {
    access_log off;
    allow 127.0.0.1;
    allow ::1;
    deny all;
    fastcgi_pass unix:/run/php-fpm/nextcloud.sock;
    include fastcgi_params;
    fastcgi_param SCRIPT_NAME /nextcloud-fpm-status;
    fastcgi_param SCRIPT_FILENAME /nextcloud-fpm-status;
}
```

**Data Collection:**

* Fetches JSON data from every PHP-FPM pool status page (`?json&full` is appended automatically even if the URL already carries query parameters).
* Saturation is computed as `active_processes / total_processes * 100`. The old `queue_usage` metric (which measured socket-backlog fill rate, not pool saturation) has been replaced.
* Accepted connections and slow requests are stored between runs and reported as rate-per-second and as a delta-since-last-check; continuous counters are never exposed as perfdata.
* Per-process details (PID, request duration, URI, script, etc.) are shown for processes currently in "Running" state. The monitoring request itself is excluded from the process list.
* Supports extended reporting via `--lengthy`, which adds columns for process manager, idle/peak processes, listen queue, socket backlog size, pool uptime, process state, process start time, content length, and full script path.


## Multi-Pool Setup

On a host that runs two or more PHP applications (for example Nextcloud **and** WordPress), give each application its own PHP-FPM pool, its own status URL, and its own Icinga/Nagios service. Example:

```text
# /etc/php-fpm.d/nextcloud.conf
[nextcloud]
user = nextcloud
group = nextcloud
listen = /run/php-fpm/nextcloud.sock
listen.acl_users = nginx
listen.mode = 0660
pm = dynamic
pm.max_children = 80
pm.status_path = /nextcloud-fpm-status

# /etc/php-fpm.d/wordpress.conf
[wordpress]
user = wordpress
group = wordpress
listen = /run/php-fpm/wordpress.sock
listen.acl_users = nginx
listen.mode = 0660
pm = dynamic
pm.max_children = 40
pm.status_path = /wordpress-fpm-status
```

The plugin can then check both pools in one run with:

```bash
./php-fpm-status \
    --url http://localhost/nextcloud-fpm-status \
    --url http://localhost/wordpress-fpm-status
```

The overall state is the worst of all pools. Perfdata labels are prefixed with the pool name, so Grafana panels can distinguish them (`nextcloud saturation`, `wordpress saturation`, etc.), and the admin sees which pool is in trouble directly on the first line of the output:

```text
2 pools checked, 1 OK, 1 CRIT (nextcloud)
```


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/php-fpm-status> |
| Nagios/Icinga Check Name              | `check_php_fpm_status` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |


## Help

```text
usage: php-fpm-status [-h] [-V] [--always-ok] [-c CRIT]
                      [--critical-slowreq CRIT_SLOW_REQUESTS] [--insecure]
                      [--lengthy] [--no-proxy] [--severity {warn,crit}]
                      [--test TEST] [--timeout TIMEOUT] [-u URL] [-w WARN]
                      [--warning-slowreq WARN_SLOW_REQUESTS]

Monitors PHP-FPM pool performance via the pool status page. Reports pool
saturation (percentage of busy workers), new slow requests since the previous
check, the request rate, process counts, and per-process request details for
every pool. Multiple pools on the same host can be checked in one run by
passing `--url` several times; each URL is treated as an independent pool, and
the overall plugin state is the worst of all pools. Basic authentication can
be embedded in the URL as `http://user:pass@host/path`. Alerts when pool
saturation exceeds the warning/critical thresholds or when new slow requests
appear since the last check. Alerts with a configurable severity if a pool is
unreachable. Supports extended reporting via --lengthy.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  -c, --critical CRIT   CRIT threshold for pool saturation (active processes /
                        total processes), in percent. Default: >= 90
  --critical-slowreq CRIT_SLOW_REQUESTS
                        CRIT threshold for the number of NEW slow requests
                        seen since the previous check run. Default: >= 100
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --lengthy             Extended reporting.
  --no-proxy            Do not use a proxy.
  --severity {warn,crit}
                        Severity for alerting. Applied to pools that are
                        unreachable or whose status JSON cannot be parsed.
                        Saturation and slow-request thresholds are unaffected.
                        Default: warn
  --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                        stderr-file,expected-retc". Can be specified multiple
                        times; each entry maps to the URL at the same
                        position.
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
  -u, --url URL         PHP-FPM status page URL. Can be specified multiple
                        times to check several pools on the same host; each
                        URL is treated as an independent pool. Basic
                        authentication may be embedded in the URL as
                        `http://user:password@host/pool-status`; the
                        credentials are stripped from the request URL and sent
                        via the `Authorization` header. Default:
                        http://localhost/fpm-status
  -w, --warning WARN    WARN threshold for pool saturation (active processes /
                        total processes), in percent. Default: >= 80
  --warning-slowreq WARN_SLOW_REQUESTS
                        WARN threshold for the number of NEW slow requests
                        seen since the previous check run. Default: >= 1
```


## Usage Examples

Single pool, default thresholds:

```bash
./php-fpm-status --url http://localhost/fpm-status
```

Two pools on the same host:

```bash
./php-fpm-status \
    --url http://localhost/nextcloud-fpm-status \
    --url http://localhost/wordpress-fpm-status
```

Basic auth on a protected status page:

```bash
./php-fpm-status --url 'http://monitor:s3cret@localhost/fpm-status'
```

Extended output (all columns, both tables):

```bash
./php-fpm-status --url http://localhost/fpm-status --lengthy
```

### Single-pool output (default)

```text
Pool www (dynamic): Up 2h 47m (since 2026-04-14 10:12:31)

Pool ! Req/s ! Act ! Tot ! Sat   ! Slow+
-----+-------+-----+-----+-------+------
www  ! 71.0  ! 4   ! 14  ! 28.6% ! 0

PID   ! Reqs ! LastDur ! Mthd ! URI         ! User
------+------+---------+------+-------------+-----
55238 ! 6    ! 531ms   ! GET  ! /index.php? ! -
```

### Multi-pool output (default)

```text
2 pools checked, 2 OK

Pool      ! Req/s ! Act ! Tot ! Sat   ! Slow+
----------+-------+-----+-----+-------+------
nextcloud ! 71.0  ! 4   ! 14  ! 28.6% ! 0
wordpress ! 2.1   ! 1   ! 5   ! 20.0% ! 0
```

### Pool-table columns

| Column | Default | `--lengthy` | Description |
|----|----|----|----|
| `Pool`   | yes | yes | Pool name (`pool` field from the FPM JSON). |
| `Req/s`  | yes | yes | Accepted connections per second since the previous check. Shown as `-` on the first run (baseline). |
| `Act`    | yes | yes | Active processes (currently serving a request). |
| `Idle`   | -   | yes | Idle processes (alive, waiting for a request). |
| `Tot`    | yes | yes | Total processes = Active + Idle. |
| `Peak`   | -   | yes | Max active processes seen by this FPM instance since it started. |
| `Mgr`    | -   | yes | Process manager: `dynamic`, `static`, or `ondemand`. |
| `LQ`     | -   | yes | Current length of the OS socket listen queue (requests waiting for a free worker). |
| `LQmax`  | -   | yes | Max listen queue length seen since FPM start. |
| `Sat`    | yes | yes | Saturation: `active / total * 100`. Alerted against `--warning` / `--critical`. |
| `Slow+`  | yes | yes | New slow requests since the previous check. Alerted against `--warning-slowreq` / `--critical-slowreq`. Shown as `-` on the first run (baseline). |
| `Up`     | -   | yes | Pool uptime since FPM started. Shown in the header line for single-pool runs. |

### Process-table columns

| Column | Default | `--lengthy` | Description |
|----|----|----|----|
| `PID`      | yes | yes | Worker process PID. |
| `State`    | -   | yes | Process state: `Running` (currently serving a request) or `Idle` (alive, waiting for a request). The default view shows only `Running` workers for a compact output; `--lengthy` also includes `Idle` workers so the table is always populated, even on quiet pools. |
| `Start`    | -   | yes | When the worker was forked by the FPM master, plus how long ago in parentheses. Shortened to minute precision (e.g. `2026-04-13 04:20 (1D 15h)`). |
| `Reqs`     | yes | yes | Total number of requests this worker has served since it was forked. |
| `LastDur`  | yes | yes | Wall-clock time the worker spent on its last request, at millisecond precision (e.g. `926ms`, `3s`, `2s 998ms`, `1m 1s`). |
| `Mthd`     | yes | yes | HTTP method of the last served request (`GET`, `POST`, `PROPFIND`, ...). |
| `CLen`     | -   | yes | Request body content length of the last served request (POST only). |
| `URI`      | yes | yes | Request URI of the last served request, with the query string stripped for brevity and privacy (a trailing `?` is kept as a visual cue that the original URI had parameters). Truncated from the right to 50 characters if still too long. |
| `Script`   | -   | yes | Filesystem path of the script executed by the last request. Directory components are abbreviated to their first character, keeping the basename in full (e.g. `/usr/share/icingaweb2/public/index.php` → `/u/s/i/p/index.php`), and the result is left-truncated to 30 characters if still too long. `-` for internal endpoints such as the status page. |
| `User`     | yes | yes | HTTP basic-auth user (`PHP_AUTH_USER`) of the last request. `-` if no basic auth was used. |

For details, see <https://www.php.net/manual/en/fpm.status.php>.


## States

* OK if every pool is reachable, saturation is below `--warning` and the slow-request delta is below `--warning-slowreq`.
* WARN if at least one pool's saturation is `>= --warning` (default: 80%).
* WARN if at least one pool's slow-request delta is `>= --warning-slowreq` (default: 1 new slow request since the previous check).
* WARN (default) or CRIT (with `--severity crit`) if at least one pool is unreachable or its status JSON cannot be parsed.
* CRIT if at least one pool's saturation is `>= --critical` (default: 90%).
* CRIT if at least one pool's slow-request delta is `>= --critical-slowreq` (default: 100).
* In multi-pool mode the overall state is the worst state of all pools.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

All labels are prefixed with the pool name in `<pool>_snake_case` form (for example `nextcloud_saturation` on a pool called `nextcloud`), matching the convention used by `procs`, `disk-io`, and other per-instance plugins. In a single-pool setup the prefix is the pool name from the FPM JSON (typically `www` unless the pool was renamed). Non-word characters in a pool name are collapsed to underscores so exotic names like `my-app` become `my_app_saturation`.

| Name | Type | Description |
|----|----|----|
| `<pool>_accepted_conn_rate` | Number (req/s) | New accepted connections per second since the previous check. Only emitted from the second run on. |
| `<pool>_active_processes` | Number | Worker processes currently serving a request. |
| `<pool>_idle_processes` | Number | Worker processes alive and waiting for a request. |
| `<pool>_listen_queue` | Number | Current length of the OS socket listen queue. |
| `<pool>_listen_queue_len` | Number | Configured size of the OS socket listen queue (socket backlog). |
| `<pool>_max_active_processes` | Number | Peak active processes since FPM started. |
| `<pool>_max_listen_queue` | Number | Peak listen queue length since FPM started. |
| `<pool>_saturation` | Percentage | Pool saturation (`active / total * 100`). Alerted against `--warning` / `--critical`. |
| `<pool>_slow_requests_delta` | Number | New slow requests since the previous check. Alerted against `--warning-slowreq` / `--critical-slowreq`. Only emitted from the second run on. |
| `<pool>_start_since` | Seconds | Seconds since the FPM master was started (effectively the pool uptime). |
| `<pool>_total_processes` | Number | Total worker processes (active + idle). |


## Troubleshooting

### Saturation >= 80%

The plugin reports saturation as the percentage of the pool's **currently allocated** worker processes that are actively serving a request. A sustained saturation above 80% means the pool is under real pressure, and if it reaches 100% requests will start to queue on the OS socket and eventually time out or get "502 Bad Gateway" from the web server. Runbook for an operator paged by this alert:

1. **Confirm the workload is legitimate.** Check the webserver access log for a traffic spike, crawler, or attack. If the spike is unwanted, mitigate at the web layer (rate limiting, WAF, geoblock) before scaling FPM.
2. **Look at `LastDur` and `URI` in the process table** (run the plugin with `--lengthy` on the command line). If the same URI dominates the list with a high `LastDur`, you have a slow endpoint. Typical causes: expensive database query, missing index, remote API call without timeout, blocking filesystem operation on a slow mount. Fix the endpoint or add a timeout.
3. **Check the slow-requests delta** (`Slow+` column, `<pool> slow requests delta` perfdata). If it is non-zero, a subset of requests is hitting the `request_slowlog_timeout` configured in the pool. Read `slowlog = …` from the pool config and inspect `/var/log/php-fpm/<pool>-slow.log` to see the backtrace of the stuck request. Focus on the deepest non-framework stack frame.
4. **Check memory before scaling workers up.** On the host, `free -h` and `ps -o rss,cmd --sort -rss -C php-fpm | head`. If the resident set of one FPM worker is already `memory_limit` or close to it, increasing `pm.max_children` will push the host into swap. Fix the memory leak, tune `memory_limit`, or tune `pm.max_requests` so workers recycle sooner.
5. **Scale the pool.** If the workload is legitimate, memory headroom is available, and the slow endpoints are already optimised, raise `pm.max_children` in the pool config (`/etc/php-fpm.d/<pool>.conf` on RHEL, `/etc/php/<ver>/fpm/pool.d/<pool>.conf` on Debian) and reload FPM (`systemctl reload php-fpm` on RHEL, `systemctl reload php<ver>-fpm` on Debian). Rule of thumb for a rough starting point: `pm.max_children = available_RAM_for_php / average_worker_rss`.
6. **Consider ondemand vs dynamic.** If the pool is idle most of the time and bursts occasionally, `pm = ondemand` with a higher `pm.max_children` uses less steady-state RAM than `pm = dynamic`. If the pool is constantly under load, `pm = static` with a pinned worker count avoids the dynamic-pm overhead.
7. **If the saturation is across all pools on the host,** look beyond PHP-FPM. CPU-bound database, saturated network link, swapping, or a bad upstream (memcached, Redis, MariaDB). Check `top`, `iotop`, and the slow query log.

### New slow requests

An alert on `<pool> slow requests delta` means the pool served at least one request that exceeded its configured `request_slowlog_timeout`, **since the previous plugin run**. Read the pool's slowlog file (`slowlog = /var/log/php-fpm/<pool>-slow.log` by default) to see the backtrace at the moment the request crossed the threshold. The deepest non-framework frame is usually the culprit (slow query, remote API call, filesystem stall).

### Pool unreachable

If a `--url` cannot be reached, the plugin reports that single pool with the state configured via `--severity` (default: WARN). The other pools are still checked normally. Common causes:

1. **Web server misroute.** The web server location for the status URL points to the wrong FPM socket. Confirm `fastcgi_pass` / `ProxyPass` maps `/<pool>-fpm-status` to `/run/php-fpm/<pool>.sock`, not to the default `www.sock`.
2. **Pool not running.** The pool config exists but the FPM master never started it (typo in the pool header, permission error on the socket directory, PHP extension error). Check `journalctl -u php-fpm` (RHEL) / `journalctl -u php<ver>-fpm` (Debian) and the pool's `error_log`.
3. **ACL on the status URL.** Many deployments restrict the status URL to `127.0.0.1`/`::1`. The monitoring plugin must run on the same host, or the ACL must be extended to allow the monitoring host.
4. **Basic auth.** If the status URL is behind HTTP basic auth, embed the credentials in the URL: `--url 'http://monitor:pw@localhost/fpm-status'`.

### First run reports "baseline captured"

The plugin needs two consecutive runs to report the request rate and the slow-requests delta. On the very first run, and on the first run after an FPM restart (detected by a changed `start time`), the delta metrics are shown as `-` and are not alerted on. This is intentional; the saturation metric is computed and alerted on normally even during a baseline run.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
