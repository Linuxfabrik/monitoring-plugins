# Check apache-httpd-status


## Overview

Monitors Apache httpd performance via the mod_status endpoint (server-status?auto). Alerts when worker usage exceeds the configured thresholds. Reports busy and idle workers, request rates, bytes served, CPU load, connection states, and system load averages. Requires "ExtendedStatus On" in the Apache configuration for full metrics. Uses a local SQLite database to calculate per-second rates from cumulative counters.

**Important Notes:**

* Works with any Apache httpd version that provides `mod_status`
* Some metrics (connection stats, load averages, processes) are only available in newer versions of `mod_status`
* `mod_status` must be loaded and `ExtendedStatus On` must be set in the Apache configuration for full metrics. Without `ExtendedStatus`, only worker counts and scoreboard data are reported.
* The check alerts on the percentage of busy workers relative to the total number of worker slots (busy + idle + free)
* Workers in the "Gracefully finishing" (G) state are counted as idle workers, not busy workers

Busy workers (workers serving requests) are:

* `C`: Closing connection
* `D`: DNS Lookup
* `G`: Gracefully finishing
* `I`: Idle cleanup of worker
* `K`: Keepalive (read)
* `L`: Logging
* `R`: Reading Request
* `S`: Starting up
* `W`: Sending Reply

Idle workers are:

* `_`: Waiting for Connection

Free workers are:

* `.`: Open slot with no current process

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
    ExtendedStatus On
    <Location /server-status>
        SetHandler server-status
        Require local
    </Location>
</IfModule>
```

If you want to configure `/server-status` in a virtual host:

```text
<IfModule status_module>
    ExtendedStatus On
</IfModule>

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

* Fetches data from the Apache `mod_status` machine-readable endpoint (`server-status?auto`)
* Parses the scoreboard to count workers in each state (reading, replying, keepalive, DNS lookup, closing, logging, starting, finishing, waiting, free slots)
* Uses a local SQLite database to store previous values and calculate per-interval deltas for accesses, bytes, and duration
* On the first run (or after a restart), returns "Waiting for more data." until at least two measurements are available


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
                           [--no-proxy] [--test TEST] [--timeout TIMEOUT]
                           [-u URL] [-w WARN]

Monitors Apache httpd performance via the mod_status endpoint (server-
status?auto). Alerts when worker usage exceeds the configured thresholds.
Reports busy and idle workers, request rates, bytes served, CPU load,
connection states, and system load averages. Requires "ExtendedStatus On" in
the Apache configuration for full metrics. Uses a local SQLite database to
calculate per-second rates from cumulative counters.

options:
  -h, --help           show this help message and exit
  -V, --version        show program's version number and exit
  --always-ok          Always returns OK.
  -c, --critical CRIT  CRIT threshold for the percentage of workers processing
                       requests. Default: >= 95
  --insecure           This option explicitly allows insecure SSL connections.
  --no-proxy           Do not use a proxy.
  --test TEST          For unit tests. Needs "path-to-stdout-file,path-to-
                       stderr-file,expected-retc".
  --timeout TIMEOUT    Network timeout in seconds. Default: 8 (seconds)
  -u, --url URL        Apache Server Status URL. Default:
                       http://localhost/server-status
  -w, --warning WARN   WARN threshold for the percentage of workers processing
                       requests. Default: >= 80
```


## Usage Examples

```bash
./apache-httpd-status --url http://apache-httpd/server-status --warning 80 --critical 90
```

Output:

```text
192.168.122.97: 2/400 workers busy (0.5%; 0 "G"), 98 idle, 300 free; 54.0 accesses, 122.0KiB traffic; Up 1W 1D

Key                            ! Value                                               
-------------------------------+-----------------------------------------------------
Current Time                   ! Wednesday, 28-Jul-2021 14:40:48 CEST                
Restart Time                   ! Monday, 19-Jul-2021 20:17:11 CEST                   
Check Interval                 ! 3m 52s                                              
Uptime                         ! 1W 1D                                               
Requests                       ! 54.0                                                
Bytes                          ! 122.0KiB                                            
Request Duration               ! 10s 28ms                                            
Load1                          ! 0.08                                                
Load5                          ! 0.06                                                
Load15                         ! 0.01                                                
Workers Total                  ! 400                                                 
  Busy                         ! 2                                                   
  Idle                         ! 98                                                  
  Usage (%)                    ! 0.5                                                 
Parent Server ConfigGeneration ! 19                                                  
Parent Server MPMGeneration    ! 18                                                  
Server Name                    ! 192.168.122.97                                      
Server MPM                     ! worker                                              
Server Version                 ! Apache/2.4.48 (Fedora) OpenSSL/1.1.1k mod_qos/11.66 
Server Built                   ! Jun  2 2021 00:00:00
```


## States

* OK if the percentage of busy workers is below the warning threshold.
* OK with "Waiting for more data." on the first run or after an Apache restart.
* WARN if the percentage of busy workers is >= `--warning` (default: 80).
* CRIT if the percentage of busy workers is >= `--critical` (default: 95).
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| Accesses | Number | Total number of accesses during the check interval. |
| BusyWorkers | Number | Number of workers currently processing requests. |
| Bytes | Bytes | Total bytes served during the check interval. |
| ConnsAsyncClosing | Number | Number of async connections in closing state. |
| ConnsAsyncKeepAlive | Number | Number of async connections in keep-alive state. |
| ConnsAsyncWriting | Number | Number of async connections in writing state. |
| ConnsTotal | Number | Total number of connections. |
| CPULoad | Number | CPU load of the Apache process. |
| IdleWorkers | Number | Number of idle workers (finishing + waiting). |
| Load1 | Number | System load average, 1 minute. |
| Load15 | Number | System load average, 15 minutes. |
| Load5 | Number | System load average, 5 minutes. |
| ParentServerConfigGeneration | Number | Apache configuration generation counter. |
| ParentServerMPMGeneration | Number | Apache MPM generation counter. |
| Processes | Number | Number of Apache processes. |
| Stopping | Number | Number of stopping processes. |
| Total Duration | Seconds | Total duration of all requests during the check interval. |
| TotalWorkers | Number | Total number of worker slots (busy + idle + free). |
| Uptime | Seconds | Time the server has been running. |
| WorkerUsagePercentage | Percentage | Percentage of workers currently processing requests. |
| workers_closing | Number | Workers closing connections ("C" in scoreboard). |
| workers_dns | Number | Workers performing DNS lookup ("D" in scoreboard). |
| workers_finishing | Number | Workers gracefully finishing ("G" in scoreboard). |
| workers_free | Number | Open slots with no current process ("." in scoreboard). |
| workers_idle | Number | Workers in idle cleanup ("I" in scoreboard). |
| workers_keepalive | Number | Workers in keepalive read ("K" in scoreboard). |
| workers_logging | Number | Workers logging ("L" in scoreboard). |
| workers_reading | Number | Workers reading request ("R" in scoreboard). |
| workers_replying | Number | Workers sending reply ("W" in scoreboard). |
| workers_starting | Number | Workers starting up ("S" in scoreboard). |
| workers_waiting | Number | Workers waiting for connection ("_" in scoreboard). |


## Troubleshooting

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
