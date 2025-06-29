# Check haproxy-status

## Overview

This check shows you an *abundance of metrics that cover the health of your HAProxy server, current request rates, response times, and more. These metrics give you granular data on a per-frontend, backend, and server basis. You need to add a stats enable directive, which is typically put into its own frontend section.* (from <https://www.haproxy.com/blog/exploring-the-haproxy-stats-page/>).

HAProxy provides the ability to use Unix sockets for statistics. In monitoring setups where checks can be run locally on the system running HAProxy, this provides an easy and secure way to monitor without exposing the stats frontend to the network.

To make **HAProxy listen on a Unix domain socket**, you need to configure the stats socket option, typically within the global section of your `haproxy.cfg` file:

```text
global
    # Other global settings ...
    stats socket /run/haproxy.sock mode 600 level admin
```

To make **HAProxy listen on a TCP port instead**, configure HAProxy as follows:

```text
listen stats # Define a listen section called "stats"
    bind :9000                          # Listen on localhost:9000
    mode http
    stats auth haproxy-stats:password   # Authentication credentials
    stats enable                        # Enable stats page
    stats hide-version                  # Hide HAProxy version
    stats realm HAProxy\ Statistics     # Title text for popup window
    stats uri /server-status            # Stats URI
```


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/haproxy-status> |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |
| Requirements                          | Stats directive enabled |


## Help

```text
usage: haproxy-status [-h] [-V] [--always-ok] [-c CRIT] [--insecure]
                      [--lengthy] [--no-proxy] [-p PASSWORD] [--test TEST]
                      [--timeout TIMEOUT] [-u URL] [--username USERNAME]
                      [-w WARN]

This check shows you an abundance of metrics that cover the health of your
HAProxy server, current request rates, response times, and more.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  -c, --critical CRIT   Set the CRIT threshold as a percentage. Default: >= 95
  --insecure            This option explicitly allows to perform "insecure"
                        SSL connections. Default: False
  --lengthy             Extended reporting.
  --no-proxy            Do not use a proxy. Default: False
  -p, --password PASSWORD
                        HAProxy Stats Auth password (not needed for socket
                        access).
  --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                        stderr-file,expected-retc".
  --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
  -u, --url URL         HAProxy Stats URI. Can be either
                        `unix:///path/to/haproxy.sock` or an URL like
                        `https://webserver:8443/server-status`. Default:
                        unix:///run/haproxy.sock
  --username USERNAME   HAProxy Stats Auth username (not needed for socket
                        access). Default: haproxy-stats
  -w, --warning WARN    Set the WARN threshold as a percentage. Default: >= 80
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

```bash
./haproxy-status --username haproxy-stats --password password --url http://webserver/server-status --lengthy
```

Output:

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

* WARN if "Status" is not in \['OPEN', 'UP', 'no check'\]
* WARN or CRIT if queue utilization is above certain thresholds (80/90%)
* WARN or CRIT if session utilization is above certain thresholds (80/90%)
* WARN or CRIT if rate utilization (sessions per second) is above certain thresholds (80/90%)


## Perfdata / Metrics

See also <https://cbonte.github.io/haproxy-dconv/1.7/management.html>.

For each Proxy+Server:

* proxyname_servername_act: Total number of active UP servers with a non-zero weight
* proxyname_servername_bck: Total number of backup UP servers with a non-zero weight
* proxyname_servername_bin: Total number of request bytes since process started
* proxyname_servername_bout: Total number of response bytes since process started
* proxyname_servername_chkdown: Total number of failed checks causing UP to DOWN server transitions, per server/backend, since the worker process started
* proxyname_servername_chkfail: Total number of failed individual health checks per server/backend, since the worker process started
* proxyname_servername_cli_abrt: Total number of requests or connections aborted by the client since the worker process started
* proxyname_servername_comp_byp: Total number of bytes that bypassed HTTP compression for this object since the worker process started (CPU/memory/bandwidth limitation)
* proxyname_servername_comp_in: Total number of bytes submitted to the HTTP compressor for this object since the worker process started
* proxyname_servername_comp_out: Total number of bytes emitted by the HTTP compressor for this object since the worker process started
* proxyname_servername_comp_rsp: Total number of HTTP responses that were compressed for this object since the worker process started
* proxyname_servername_ctime: Time spent waiting for a connection to complete, in milliseconds, averaged over the 1024 last requests (backend/server)
* proxyname_servername_downtime: Total time spent in DOWN state, for server or backend
* proxyname_servername_dreq: Total number of denied requests since process started
* proxyname_servername_dresp: Total number of denied responses since process started
* proxyname_servername_econ: Total number of failed connections to server since the worker process started
* proxyname_servername_ereq: Total number of invalid requests since process started
* proxyname_servername_eresp: Total number of invalid responses since the worker process started
* proxyname_servername_hanafail: Total number of failed checks caused by an 'on-error' directive after an 'observe' condition matched
* proxyname_servername_hrsp_1xx: Total number of HTTP responses with status 100-199 returned by this object since the worker process started
* proxyname_servername_hrsp_2xx: Total number of HTTP responses with status 200-299 returned by this object since the worker process started
* proxyname_servername_hrsp_3xx: Total number of HTTP responses with status 300-399 returned by this object since the worker process started
* proxyname_servername_hrsp_4xx: Total number of HTTP responses with status 400-499 returned by this object since the worker process started
* proxyname_servername_hrsp_5xx: Total number of HTTP responses with status 500-599 returned by this object since the worker process started
* proxyname_servername_hrsp_other: Total number of HTTP responses with status \<100, \>599 returned by this object since the worker process started (error -1 included)
* proxyname_servername_last_chk: Last health check contents or textual error
* proxyname_servername_lastchg: Number of seconds since the last UP\<-\>DOWN transition
* proxyname_servername_lastsess: How long ago some traffic was seen on this object on this worker process, in seconds
* proxyname_servername_lbtot: Total number of requests routed by load balancing since the worker process started (ignores queue pop and stickiness)
* proxyname_servername_qcur: Number of current queued connections
* proxyname_servername_qlimit: Limit on the number of connections in queue, for servers only (maxqueue argument)
* proxyname_servername_qtime: Time spent in the queue, in milliseconds, averaged over the 1024 last requests (backend/server)
* proxyname_servername_rate: Total number of sessions processed by this object over the last second (sessions for listeners/frontends, requests for backends/servers)
* proxyname_servername_rate_lim: Limit on the number of sessions accepted in a second (frontend only, 'rate-limit sessions' setting)
* proxyname_servername_req_rate: Number of HTTP requests processed over the last second on this object
* proxyname_servername_req_tot: Total number of HTTP requests processed by this object since the worker process started
* proxyname_servername_rtime: Time spent waiting for a server response, in milliseconds, averaged over the 1024 last requests (backend/server)
* proxyname_servername_scur: Number of current sessions on the frontend, backend or server
* proxyname_servername_slim: Frontend/listener/server's maxconn, backend's fullconn
* proxyname_servername_srv_abrt: Total number of requests or connections aborted by the server since the worker process started
* proxyname_servername_stot: Total number of sessions since process started
* proxyname_servername_ttime: Total request+response time (request+queue+connect+response+processing), in milliseconds, averaged over the 1024 last requests (backend/server)
* proxyname_servername_weight: Server's effective weight, or sum of active servers' effective weights for a backend
* proxyname_servername_wredis: Total number of server redispatches due to connection failures since the worker process started
* proxyname_servername_wretr: Total number of server connection retries since the worker process started


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
