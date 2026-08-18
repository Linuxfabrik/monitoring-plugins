# Check apache-httpd-status


## Overview

Monitors Apache httpd via the mod_status endpoint (server-status?auto). Reports worker slot usage, worker and connection states, request and traffic rates, mean request duration, CPU usage and system load averages. Alerts when the percentage of occupied worker slots exceeds the warning or critical threshold. Cumulative counters are converted into per-second rates against the previous check run, so the first run after an installation and the first run after an httpd restart report no rates yet. Metrics that the queried httpd version, MPM or ExtendedStatus setting does not provide are left out instead of failing.

**Important Notes:**

* On httpd 2.4 and newer, `ExtendedStatus` is already on as soon as `mod_status` is loaded, so it does not have to be configured. Setting `ExtendedStatus Off` is an explicit opt-out and costs the request, traffic, duration and CPU metrics. Everything else, including worker slots, connections, processes, uptime and load averages, is still reported. On httpd 2.2 it is off unless configured, and without it that httpd reports nothing but the worker counts and the scoreboard.
* Rates need two measurements. The first run after an installation and the first run after an httpd restart report worker slots but no rates.
* The check alerts on the percentage of **occupied** worker slots, read from the scoreboard, not on `BusyWorkers`. During a graceful restart the two disagree by a lot: `mod_status` skips every process that is shutting down, so the slots still draining requests from the old generation count as neither busy nor graceful. On a server with 400 slots, 20 requests in flight across a `httpd -k graceful` show up as 20 occupied slots here while `BusyWorkers` reports 1. `BusyWorkers`, `GracefulWorkers` and `IdleWorkers` are still reported as metrics of their own so both readings can be compared.
* Which metrics a host delivers depends on its MPM, its httpd version and which other modules are loaded, not on one of them alone. Distributions backport freely, so a metric may be present on an older httpd than the upstream release that introduced it.
* Only the `event` MPM reports connections and processes. On `prefork` and `worker` those metrics are absent.
* The load averages are the **whole machine's**, not Apache's share: `mod_status` fills them from `getloadavg(3)`. Apache's own consumption is `apache_cpu_percent`. The raw averages are reported as httpd sent them, and a per-CPU value is added whenever the check runs on the Apache host itself, which is the case for the default loopback URL. Against a remote `--url` only the raw values are reported, because `mod_status` never says how many CPUs the machine it measured has, and the monitoring host's count would be the wrong divisor.
* The number of worker slots is `MaxRequestWorkers`. Raising that limit raises the denominator, which lowers the reported percentage at unchanged load.
* On httpd 2.2 the scoreboard covers `ServerLimit` rather than `MaxClients`, because that version does not mark the unused slots. A 2.2 server configured with `MaxClients` below `ServerLimit` therefore reports a percentage that is too low by that ratio. Set the two equal, or scale the thresholds, on those hosts. httpd 2.4 and newer are exact.

A worker slot is **occupied** unless it is one of:

* `_`: Waiting for connection
* `.`: Open slot with no current process

All other scoreboard states hold a request, are about to hold one, or are draining one:

* `C`: Closing connection
* `D`: DNS lookup
* `G`: Gracefully finishing
* `I`: Idle cleanup of worker
* `K`: Keepalive (read)
* `L`: Logging
* `R`: Reading request
* `S`: Starting up
* `W`: Sending reply

Load the Apache module:

```text
LoadModule status_module modules/mod_status.so
```

If you want to configure `/server-status` in your main Apache config file:

```text
<IfModule status_module>
    # the alias prevents the processing of .htaccess files, which could contain RewriteRules
    # that interfere with server-status
    Alias /server-status /dev/null
    <Location /server-status>
        SetHandler server-status
        Require local
    </Location>
</IfModule>
```

If you want to configure `/server-status` in a virtual host:

```text
<VirtualHost *:80>
    ServerName localhost
    <IfModule status_module>
        # the alias prevents the processing of .htaccess files, which could contain RewriteRules
        # that interfere with server-status
        Alias /server-status /dev/null
        <Location /server-status>
            SetHandler server-status
            Require local
        </Location>
    </IfModule>
</VirtualHost>
```

**Data Collection:**

* Fetches data from the Apache `mod_status` machine-readable endpoint (`server-status?auto`). The `auto` query parameter is appended by the plugin, so `--url` takes the plain location and may carry query parameters of its own.
* Parses the scoreboard to count the worker slots in each state and to derive the slot usage the check alerts on.
* Stops reading at the first block another module appended. `mod_ssl`, `mod_cache_socache`, `mod_md`, `mod_proxy` and third-party modules such as `mod_qos` add key/value blocks of their own behind the scoreboard, and their keys are not Apache worker metrics.
* Uses a local SQLite database to store the previous measurement and to convert the cumulative counters into per-second rates. The cache is keyed by URL, so several virtual hosts on one machine can be checked independently.
* Discards the averages httpd computes over its whole uptime (`BytesPerReq`, `BytesPerSec`, `CPULoad`, `DurationPerReq`, `ReqPerSec`). They converge to a constant line within minutes and say nothing about the moment of measurement. Request rate, traffic rate, mean request duration and CPU usage are recalculated for the current check interval instead.


**What your httpd version delivers:**

Every metric is emitted when the server reports its source value and left out otherwise, so an old httpd yields a smaller set rather than an error. Distributions backport freely, so treat this as the upstream origin of a field, not as a promise about a given host: Rocky 8 reports `GracefulWorkers` on httpd 2.4.37, long before upstream added it in 2.4.58.

| Since | What it adds |
|----|----|
| 2.2 | Worker slots and the scoreboard, plus the request and traffic rates with `ExtendedStatus On` |
| 2.4.0 | Connection counters (event MPM), and `ExtendedStatus` becomes the default |
| 2.4.13 | Server identity, system load averages, CPU usage |
| 2.4.35 | Process counters (event MPM), mean request duration |
| 2.4.58 | `GracefulWorkers` |
| 2.4.63 | Connections waiting for I/O |

Verified against real installations of httpd 2.2.15 (CentOS 6), 2.4.6 (CentOS 7), 2.4.10 (Debian 8), 2.4.25 (Debian 9), 2.4.37 (Rocky 8), 2.4.48 (Fedora 34), 2.4.59 (Debian 10), 2.4.62 (Rocky 9), 2.4.63 (Rocky 10), 2.4.66/2.4.68 (Debian 11 to 13, Fedora 43).


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/apache-httpd-status> |
| Nagios/Icinga Check Name              | `check_apache_httpd_status` |
| Check Interval Recommendation         | Every minute |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-apache-httpd-status.db` |


## Help

```text
usage: apache-httpd-status [-h] [-V] [--always-ok] [-c CRIT] [--insecure]
                           [--no-perfdata] [--no-proxy] [--timeout TIMEOUT]
                           [-u URL] [-w WARN]

Monitors Apache httpd via the mod_status endpoint (server-status?auto).
Reports worker slot usage, worker and connection states, request and traffic
rates, mean request duration, CPU usage and system load averages. Alerts when
the percentage of occupied worker slots exceeds the warning or critical
threshold. Cumulative counters are converted into per-second rates against the
previous check run, so the first run after an installation and the first run
after an httpd restart report no rates yet. Metrics that the queried httpd
version, MPM or ExtendedStatus setting does not provide are left out instead
of failing.

options:
  -h, --help           show this help message and exit
  -V, --version        show program's version number and exit
  --always-ok          Always returns OK.
  -c, --critical CRIT  CRIT threshold for the percentage of occupied worker
                       slots. Supports Nagios ranges. Default: 95
  --insecure           This option explicitly allows insecure SSL connections.
  --no-perfdata        Suppress the performance data section from the output.
                       The status message and the exit code are unaffected, so
                       alerting keeps working while trending data is dropped.
  --no-proxy           Do not use a proxy.
  --timeout TIMEOUT    Network timeout in seconds. Default: 8 (seconds)
  -u, --url URL        Apache Server Status URL. The plugin appends the "auto"
                       query parameter itself. Default:
                       http://localhost/server-status
  -w, --warning WARN   WARN threshold for the percentage of occupied worker
                       slots. Supports Nagios ranges. Default: 80

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/apache-httpd-status/
```


## Usage Examples

A server under load, with the default thresholds:

```bash
./apache-httpd-status --url=http://apache-httpd/server-status --warning=80 --critical=95
```

```text
192.168.122.97: 81.8% worker usage (327/400) [WARNING], 6180.0 req/s, 732.9MiB/s, up 1W 1D

Flag ! Worker State           ! Slots ! Usage
-----+------------------------+-------+------
_    ! Waiting for connection ! 73    ! 18.2%
S    ! Starting up            ! 0     ! 0.0%
R    ! Reading request        ! 0     ! 0.0%
W    ! Sending reply          ! 215   ! 53.8%
K    ! Keepalive (read)       ! 0     ! 0.0%
D    ! DNS lookup             ! 0     ! 0.0%
C    ! Closing connection     ! 112   ! 28.0%
L    ! Logging                ! 0     ! 0.0%
G    ! Gracefully finishing   ! 0     ! 0.0%
I    ! Idle cleanup of worker ! 0     ! 0.0%
.    ! Open slot              ! 0     ! 0.0%

Key                            ! Value
-------------------------------+----------------------------------------------------
Server Name                    ! 192.168.122.97
Server Version                 ! Apache/2.4.48 (Fedora) OpenSSL/1.1.1k mod_qos/11.66
Server MPM                     ! worker
Server Built                   ! Jun  2 2021 00:00:00
Current Time                   ! Wednesday, 28-Jul-2021 14:59:23 CEST
Restart Time                   ! Monday, 19-Jul-2021 20:17:11 CEST
Uptime                         ! 1W 1D
Parent Server ConfigGeneration ! 19
Parent Server MPMGeneration    ! 18
Requests                       ! 6180.0/s
Traffic                        ! 732.9MiB/s
Request Duration               ! 1399.1ms mean
CPU Usage                      ! 595.0%
  CPUUser                      ! 17.95s
  CPUSystem                    ! 20.13s
  CPUChildrenUser              ! 205.72s
  CPUChildrenSystem            ! 102.54s
Workers Total                  ! 400
  Occupied                     ! 327 (81.8%)
  Busy                         ! 327
  Idle                         ! 73
System Load                    ! whole machine, 8 CPUs
  Load1                        ! 0.10 (0.01 per CPU)
  Load5                        ! 0.03 (0.00 per CPU)
  Load15                       ! 0.01 (0.00 per CPU)
```

A quiet server with `ExtendedStatus Off`. The counters and everything derived from them are gone, the worker slots, connections, processes and load averages are not. The check runs on the Apache host here, so the load averages carry their per-CPU value:

```bash
./apache-httpd-status
```

```text
localhost: 0.2% worker usage (1/400), up 2s

Flag ! Worker State           ! Slots ! Usage
-----+------------------------+-------+------
_    ! Waiting for connection ! 74    ! 18.5%
S    ! Starting up            ! 0     ! 0.0%
R    ! Reading request        ! 0     ! 0.0%
W    ! Sending reply          ! 1     ! 0.2%
K    ! Keepalive (read)       ! 0     ! 0.0%
D    ! DNS lookup             ! 0     ! 0.0%
C    ! Closing connection     ! 0     ! 0.0%
L    ! Logging                ! 0     ! 0.0%
G    ! Gracefully finishing   ! 0     ! 0.0%
I    ! Idle cleanup of worker ! 0     ! 0.0%
.    ! Open slot              ! 325   ! 81.2%

Key                            ! Value
-------------------------------+-----------------------------------------
Server Name                    ! localhost
Server Version                 ! Apache/2.4.62 (Red Hat Enterprise Linux)
Server MPM                     ! event
Server Built                   ! Dec 12 2025 00:00:00
Current Time                   ! Monday, 13-Apr-2026 07:00:37 UTC
Restart Time                   ! Monday, 13-Apr-2026 07:00:34 UTC
Uptime                         ! 2s
Parent Server ConfigGeneration ! 1
Parent Server MPMGeneration    ! 0
Connections                    ! 0
  Async Writing                ! 0
  Async KeepAlive              ! 0
  Async Closing                ! 0
Processes                      ! 3
  Stopping                     ! 0
Workers Total                  ! 400
  Occupied                     ! 1 (0.2%)
  Busy                         ! 1
  Graceful                     ! 0
  Idle                         ! 74
System Load                    ! whole machine, 8 CPUs
  Load1                        ! 2.13 (0.27 per CPU)
  Load5                        ! 1.59 (0.20 per CPU)
  Load15                       ! 1.33 (0.17 per CPU)
```

An httpd 2.2 host, which reports nothing but the worker counts and the scoreboard unless `ExtendedStatus On` is configured. The check still works and still alerts:

```text
0.4% worker usage (1/256)

Flag ! Worker State           ! Slots ! Usage
-----+------------------------+-------+------
_    ! Waiting for connection ! 7     ! 2.7%
S    ! Starting up            ! 0     ! 0.0%
R    ! Reading request        ! 0     ! 0.0%
W    ! Sending reply          ! 1     ! 0.4%
K    ! Keepalive (read)       ! 0     ! 0.0%
D    ! DNS lookup             ! 0     ! 0.0%
C    ! Closing connection     ! 0     ! 0.0%
L    ! Logging                ! 0     ! 0.0%
G    ! Gracefully finishing   ! 0     ! 0.0%
I    ! Idle cleanup of worker ! 0     ! 0.0%
.    ! Open slot              ! 248   ! 96.9%

Key           ! Value
--------------+---------
Workers Total ! 256
  Occupied    ! 1 (0.4%)
  Busy        ! 1
  Idle        ! 7
```


## States

* OK if the percentage of occupied worker slots is within both thresholds.
* WARN if it violates `--warning` (default: 80).
* CRIT if it violates `--critical` (default: 95).
* Both thresholds accept Nagios range expressions, see [THRESHOLDS.md](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/THRESHOLDS.md), so an unusually **idle** server can be alerted on as well: `--warning=20:90` warns below 20% and above 90%.
* UNKNOWN if the URL does not answer with `mod_status` data, for example because `mod_status` is not loaded, because the location is not configured with `SetHandler server-status`, or because a catch-all served an error page instead.
* UNKNOWN if the endpoint is unreachable or does not answer within `--timeout`.
* `--always-ok` suppresses all alerts and always returns OK.

The state does not depend on the rates, only on worker slot usage. A run that reports no rates yet, because it is the first one or because httpd restarted, still alerts on slot usage.


## Perfdata / Metrics

Which metrics a host actually delivers depends on its MPM, its httpd version and its `ExtendedStatus` setting. A metric the server does not report is left out rather than reported as zero.

| Name | Type | Description |
|----|----|----|
| apache_busy_workers | Number | Workers processing a request, as counted by `mod_status`. Excludes every process that is shutting down. |
| apache_bytes_per_second | Bytes | Traffic served during the check interval. |
| apache_connections_closing | Number | Async connections in lingering close. Event MPM only. |
| apache_connections_keepalive | Number | Async connections in keepalive. Event MPM only. |
| apache_connections_total | Number | Connections held by the server. Event MPM only. |
| apache_connections_wait_io | Number | Async connections waiting for I/O. Event MPM, httpd 2.4.63 and newer. |
| apache_connections_writing | Number | Async connections in write completion. Event MPM only. |
| apache_cpu_percent | Percentage | CPU used by the httpd processes during the check interval. Exceeds 100% when several workers run on several cores. httpd 2.4.13 and newer. |
| apache_graceful_workers | Number | Workers finishing gracefully, as counted by `mod_status`. httpd 2.4.58 and newer. |
| apache_idle_workers | Number | Workers ready for a request, as counted by `mod_status`. |
| apache_system_load1 | Number | Load average of the whole machine, 1 minute, raw. Not Apache's share. httpd 2.4.13 and newer. |
| apache_system_load1_per_cpu | Number | The same average divided by the CPU count. Only when the check runs on the Apache host (loopback `--url`). |
| apache_system_load15 | Number | Load average of the whole machine, 15 minutes, raw. httpd 2.4.13 and newer. |
| apache_system_load15_per_cpu | Number | The same average divided by the CPU count. Only when the check runs on the Apache host (loopback `--url`). |
| apache_system_load5 | Number | Load average of the whole machine, 5 minutes, raw. httpd 2.4.13 and newer. |
| apache_system_load5_per_cpu | Number | The same average divided by the CPU count. Only when the check runs on the Apache host (loopback `--url`). |
| apache_processes | Number | Child processes. Event MPM, httpd 2.4.35 and newer. |
| apache_processes_stopping | Number | Child processes shutting down. Event MPM, httpd 2.4.35 and newer. |
| apache_requests_per_second | Number | Requests served during the check interval. |
| apache_seconds_per_request | Seconds | Mean request duration over the check interval. Needs httpd 2.4.35 or newer. |
| apache_workers_closing | Number | Worker slots closing a connection (`C`). |
| apache_workers_dns_lookup | Number | Worker slots performing a DNS lookup (`D`). |
| apache_workers_finishing | Number | Worker slots finishing gracefully (`G`). |
| apache_workers_free | Number | Open worker slots with no current process (`.`). |
| apache_workers_idle_cleanup | Number | Worker slots in idle cleanup (`I`). |
| apache_workers_keepalive | Number | Worker slots in keepalive read (`K`). |
| apache_workers_logging | Number | Worker slots logging (`L`). |
| apache_workers_occupied | Number | Worker slots that are neither open nor waiting. |
| apache_workers_occupied_percent | Percentage | Occupied worker slots as a percentage of all slots. This is what the check alerts on. |
| apache_workers_reading | Number | Worker slots reading a request (`R`). |
| apache_workers_sending | Number | Worker slots sending a reply (`W`). |
| apache_workers_starting | Number | Worker slots starting up (`S`). |
| apache_workers_total | Number | Worker slots in total, which is `MaxRequestWorkers`. |
| apache_workers_waiting | Number | Worker slots waiting for a connection (`_`). |


## Troubleshooting

### `did not answer with Apache mod_status data`

The URL answered, but with something other than the machine-readable status. Either `mod_status` is not loaded, or the location does not carry `SetHandler server-status` and a catch-all served an error page or an index page instead. Check `httpd -M | grep status` (`apache2ctl -M` on Debian) and fetch the URL by hand with `curl --silent 'http://localhost/server-status?auto'`. The response must begin with the server name followed by `ServerVersion:`, or, on httpd before 2.4.13, directly with a metric line.

### No request, traffic, duration or CPU metrics

Two different causes look the same in a graph.

On the first run after an installation, and on the first run after httpd restarted, there is no previous measurement to compute a rate against. This resolves itself with the next check.

If the rates never appear, `ExtendedStatus` is off. On httpd 2.4 it is on by default as soon as `mod_status` is loaded, so something switched it off explicitly. Search the configuration with `grep -rn ExtendedStatus /etc/httpd/ /etc/apache2/` and remove the `ExtendedStatus Off` line. Note that Debian ships `ExtendedStatus On` in `/etc/apache2/mods-available/status.conf`, so on Debian the directive is normally present and correct. On httpd 2.2 the directive is genuinely required and has to be added.

If only the request and traffic rates appear while CPU usage and mean request duration stay missing, the server is too old for them rather than misconfigured: CPU usage needs httpd 2.4.13, mean request duration needs 2.4.35. See the version table under Overview.

### No connection or process metrics

`ConnsTotal`, the async connection counters, `Processes` and `Stopping` come from the `event` MPM only. Check `httpd -M | grep mpm` (`apache2ctl -M` on Debian). On `prefork` and `worker` these metrics do not exist and their absence is not a defect.

On the event MPM with the connection counters present but the process counters missing, the server predates httpd 2.4.35, which is where `Processes` and `Stopping` were added.

### Worker usage disagrees with `BusyWorkers`

Expected during a graceful restart. The slots draining requests from the old generation show up as `G` in the scoreboard, but `mod_status` counts neither `BusyWorkers` nor `GracefulWorkers` for a process that is shutting down. The check reads the scoreboard, so it keeps seeing those requests. `apache_processes_stopping` above zero confirms that a restart is still draining.

### The load averages look high but Apache is idle

The load averages are the machine's, not Apache's: `mod_status` fills them from `getloadavg(3)`, which on Linux is `/proc/loadavg`, so every process on the host contributes. Apache's own share is `apache_cpu_percent`, computed from Apache's own CPU counters. If that is near zero while the load averages sit around the core count, the load comes from something else on the host.

A raw load average is also not a percentage: 1.00 means one runnable process on average, which is a quarter of a four-core machine. The check adds a per-CPU value next to each raw one whenever it runs on the Apache host, so read that column rather than dividing by hand. Against a remote `--url` the per-CPU value is absent on purpose: `mod_status` does not report the CPU count of the machine it measured, and the monitoring host's count would be the wrong divisor.

### Worker usage jumped down without the load changing

Something raised `MaxRequestWorkers`, which is the denominator of the percentage. Compare `apache_workers_total` over the same period. The absolute `apache_workers_occupied` shows whether the load itself changed.

### Identifying which requests or clients consume all resources

From <https://httpd.apache.org/docs/2.4/mod/mod_status.html#troubleshoot>:

> The check may be used as a starting place for troubleshooting a situation where your server is consuming all available resources (CPU or memory), and you wish to identify which requests or clients are causing the problem.
>
> First, ensure that you have `ExtendedStatus` set on, so that you can see the full request and client information for each child or thread.
>
> Now look in your process list (using top, or similar process viewing utility) to identify the specific processes that are the main culprits. Order the output of top by CPU usage, or memory usage, depending on what problem you're trying to address.
>
> Reload the server-status page, and look for those process ids, and you'll be able to see what request is being served by that process, for what client. Requests are transient, so you may need to try several times before you catch it in the act, so to speak.
>
> This process should give you some idea what client, or what type of requests, are primarily responsible for your load problems. Often you will identify a particular web application that is misbehaving, or a particular client that is attacking your site.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
