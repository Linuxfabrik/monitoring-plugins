# Check haproxy-status


## Overview

Monitors HAProxy performance and health via the stats endpoint. Reports frontend and backend session usage, request rates, response times, error rates, and server states. Alerts when session usage exceeds the configured thresholds or when backends/servers are in an unhealthy state. Supports extended reporting via `--lengthy`.

**Important Notes:**

* HAProxy with `stats enable` directive or Unix socket configured
* To use Unix socket access (the default), HAProxy must be configured with a `stats socket` directive in its `global` section:

    ```text
    global
        stats socket /run/haproxy.sock mode 600 level admin
    ```

* To use TCP/HTTP access, configure HAProxy with a `listen stats` section:

    ```text
    listen stats
        bind :9000
        mode http
        stats auth haproxy-stats:password
        stats enable
        stats hide-version
        stats realm HAProxy\ Statistics
        stats uri /server-status
    ```

* No authentication is needed for Unix socket access.

**Data Collection:**

* Connects to the HAProxy stats interface via a Unix domain socket (`unix:///run/haproxy.sock` by default) or HTTP(S) endpoint
* Parses the HAProxy CSV stats output for all frontends, backends, and servers
* Checks session usage against `--warning`/`--critical` thresholds (percentage of session limit)
* Checks queue usage and session rate against the same thresholds
* For HTTP access, supports Basic authentication (`--username` / `--password`)


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/haproxy-status> |
| Nagios/Icinga Check Name              | `check_haproxy_status` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| Requirements                          | HAProxy stats directive enabled (socket or HTTP) |


## Help

```text
usage: haproxy-status [-h] [-V] [--always-ok] [-c CRIT] [--insecure]
                      [--lengthy] [--no-proxy] [-p PASSWORD] [--test TEST]
                      [--timeout TIMEOUT] [-u URL] [--username USERNAME]
                      [-w WARN]

Monitors HAProxy performance and health via the stats endpoint. Reports
frontend and backend session usage, request rates, response times, error
rates, and server states. Alerts when session usage exceeds the configured
thresholds. Supports extended reporting via --lengthy.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  -c, --critical CRIT   CRIT threshold in percent. Default: >= 95
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --lengthy             Extended reporting.
  --no-proxy            Do not use a proxy.
  -p, --password PASSWORD
                        HAProxy stats auth password. Not needed for socket
                        access.
  --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                        stderr-file,expected-retc".
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
  -u, --url URL         HAProxy stats URI. Accepts
                        `unix:///path/to/haproxy.sock` or an HTTP(S) URL.
                        Example: `--url https://webserver:8443/server-status`.
                        Default: unix:///run/haproxy.sock
  --username USERNAME   HAProxy stats auth username. Not needed for socket
                        access. Default: haproxy-stats
  -w, --warning WARN    WARN threshold in percent. Default: >= 80
```


## Usage Examples

```bash
./haproxy-status --username haproxy-stats --password password --url http://webserver/server-status
```

Output:

```text
static static: DOWN, static BACKEND: DOWN, app app1: DOWN, app app2: DOWN, app app3: DOWN, app app4: DOWN, app BACKEND: DOWN

Proxy name ! Server name ! Sessions ! RqBytes  ! RspBytes ! Rsp5xx ! Rq/s ! Status        
-----------+-------------+----------+----------+----------+--------+------+---------------
main       ! FRONTEND    ! 0/3000   ! 0.0B     ! 0.0B     ! 0      ! 0    ! OPEN          
static     ! static      ! 0        ! 0.0B     ! 0.0B     ! 0      !      ! DOWN [WARNING]
static     ! BACKEND     ! 0/300    ! 0.0B     ! 0.0B     ! 0      !      ! DOWN [WARNING]
app        ! app1        ! 0        ! 0.0B     ! 0.0B     ! 0      !      ! DOWN [WARNING]
app        ! app2        ! 0        ! 0.0B     ! 0.0B     ! 0      !      ! DOWN [WARNING]
app        ! app3        ! 0        ! 0.0B     ! 0.0B     ! 0      !      ! DOWN [WARNING]
app        ! app4        ! 0        ! 0.0B     ! 0.0B     ! 0      !      ! DOWN [WARNING]
app        ! BACKEND     ! 0/300    ! 0.0B     ! 0.0B     ! 0      !      ! DOWN [WARNING]
stats      ! FRONTEND    ! 0/3000   ! 443.2KiB ! 8.6MiB   ! 733    ! 0    ! OPEN          
stats      ! BACKEND     ! 0/300    ! 443.2KiB ! 8.6MiB   ! 733    !      ! UP
```

With `--lengthy`:

```text
static static: DOWN, static BACKEND: DOWN, app app1: DOWN, app app2: DOWN, app app3: DOWN, app app4: DOWN, app BACKEND: DOWN

Proxy name ! Server name ! Queued ! Sessions ! RqBytes  ! RspBytes ! RqLB ! Rate ! Rsp2xx ! Rsp4xx ! Rsp5xx ! Rq/s ! LastReq ! RqRspTime ! Status        
-----------+-------------+--------+----------+----------+----------+------+------+--------+--------+--------+------+---------+-----------+---------------
main       ! FRONTEND    !        ! 0/3000   ! 0.0B     ! 0.0B     !      ! 0/0  ! 0      ! 0      ! 0      ! 0    !         !           ! OPEN          
static     ! static      ! 0      ! 0        ! 0.0B     ! 0.0B     ! 0    ! 0    ! 0      ! 0      ! 0      !      !         ! 0         ! DOWN [WARNING]
static     ! BACKEND     ! 0      ! 0/300    ! 0.0B     ! 0.0B     ! 0    ! 0    ! 0      ! 0      ! 0      !      !         ! 0         ! DOWN [WARNING]
app        ! app1        ! 0      ! 0        ! 0.0B     ! 0.0B     ! 0    ! 0    ! 0      ! 0      ! 0      !      !         ! 0         ! DOWN [WARNING]
app        ! app2        ! 0      ! 0        ! 0.0B     ! 0.0B     ! 0    ! 0    ! 0      ! 0      ! 0      !      !         ! 0         ! DOWN [WARNING]
app        ! app3        ! 0      ! 0        ! 0.0B     ! 0.0B     ! 0    ! 0    ! 0      ! 0      ! 0      !      !         ! 0         ! DOWN [WARNING]
app        ! app4        ! 0      ! 0        ! 0.0B     ! 0.0B     ! 0    ! 0    ! 0      ! 0      ! 0      !      !         ! 0         ! DOWN [WARNING]
app        ! BACKEND     ! 0      ! 0/300    ! 0.0B     ! 0.0B     ! 0    ! 0    ! 0      ! 0      ! 0      !      !         ! 0         ! DOWN [WARNING]
stats      ! FRONTEND    !        ! 0/3000   ! 443.2KiB ! 8.6MiB   !      ! 0/0  ! 2397   ! 0      ! 733    ! 0    !         !           ! OPEN          
stats      ! BACKEND     ! 0      ! 0/300    ! 443.2KiB ! 8.6MiB   ! 0    ! 0    ! 0      ! 0      ! 733    !      ! 3m 22s  ! 0         ! UP
```


## States

* OK if all backends/servers are UP or OPEN and all utilization metrics are below thresholds.
* WARN if any backend or server status is not in "OPEN", "UP", or "no check".
* WARN if queue, session, or rate utilization is >= `--warning` (default: 80%).
* CRIT if queue, session, or rate utilization is >= `--critical` (default: 95%).
* UNKNOWN if `--url` does not start with `http://`, `https://`, or `unix://`, or on malformed HAProxy stats output.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

For each proxy+server combination, the following metrics are emitted (where applicable). See also the [HAProxy Management Guide](https://cbonte.github.io/haproxy-dconv/1.7/management.html) for details.

| Name | Type | Description |
|----|----|----|
| proxyname_servername_act | Number | Total number of active UP servers with a non-zero weight. |
| proxyname_servername_bck | Number | Total number of backup UP servers with a non-zero weight. |
| proxyname_servername_bin | Bytes | Total number of request bytes since process started. |
| proxyname_servername_bout | Bytes | Total number of response bytes since process started. |
| proxyname_servername_chkdown | Number | Total number of failed checks causing UP to DOWN transitions. |
| proxyname_servername_chkfail | Number | Total number of failed individual health checks. |
| proxyname_servername_cli_abrt | Number | Total number of requests/connections aborted by the client. |
| proxyname_servername_comp_byp | Bytes | Total bytes that bypassed HTTP compression. |
| proxyname_servername_comp_in | Bytes | Total bytes submitted to the HTTP compressor. |
| proxyname_servername_comp_out | Bytes | Total bytes emitted by the HTTP compressor. |
| proxyname_servername_comp_rsp | Number | Total HTTP responses that were compressed. |
| proxyname_servername_ctime | Number | Connection time in ms, averaged over 1024 last requests. |
| proxyname_servername_downtime | Seconds | Total time spent in DOWN state. |
| proxyname_servername_dreq | Number | Total number of denied requests. |
| proxyname_servername_dresp | Number | Total number of denied responses. |
| proxyname_servername_econ | Number | Total number of failed connections to server. |
| proxyname_servername_ereq | Number | Total number of invalid requests. |
| proxyname_servername_eresp | Number | Total number of invalid responses. |
| proxyname_servername_hanafail | Number | Total failed checks caused by an "on-error" directive. |
| proxyname_servername_hrsp_1xx | Number | Total HTTP responses with status 100-199. |
| proxyname_servername_hrsp_2xx | Number | Total HTTP responses with status 200-299. |
| proxyname_servername_hrsp_3xx | Number | Total HTTP responses with status 300-399. |
| proxyname_servername_hrsp_4xx | Number | Total HTTP responses with status 400-499. |
| proxyname_servername_hrsp_5xx | Number | Total HTTP responses with status 500-599. |
| proxyname_servername_hrsp_other | Number | Total HTTP responses with status <100 or >599. |
| proxyname_servername_last_chk | Seconds | Last health check contents or textual error. |
| proxyname_servername_lastchg | Seconds | Seconds since the last UP/DOWN transition. |
| proxyname_servername_lastsess | Seconds | How long ago traffic was last seen on this object. |
| proxyname_servername_lbtot | Number | Total requests routed by load balancing. |
| proxyname_servername_qcur | Number | Number of current queued connections. |
| proxyname_servername_qlimit | Number | Limit on the number of connections in queue. |
| proxyname_servername_qtime | Number | Queue time in ms, averaged over 1024 last requests. |
| proxyname_servername_rate | Number | Sessions processed over the last second. |
| proxyname_servername_rate_lim | Number | Session rate limit (frontend only). |
| proxyname_servername_req_rate | Number | HTTP requests processed over the last second. |
| proxyname_servername_req_tot | Number | Total HTTP requests processed. |
| proxyname_servername_rtime | Number | Server response time in ms, averaged over 1024 last requests. |
| proxyname_servername_scur | Number | Number of current sessions. |
| proxyname_servername_slim | Number | Session limit (maxconn/fullconn). |
| proxyname_servername_srv_abrt | Number | Total requests/connections aborted by the server. |
| proxyname_servername_stot | Number | Total number of sessions since process started. |
| proxyname_servername_tracked | Number | ID of the tracked server (for tracking). |
| proxyname_servername_ttime | Number | Total request+response time in ms, averaged over 1024 last requests. |
| proxyname_servername_weight | Number | Server's effective weight. |
| proxyname_servername_wredis | Number | Total server redispatches due to connection failures. |
| proxyname_servername_wretr | Number | Total server connection retries. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
