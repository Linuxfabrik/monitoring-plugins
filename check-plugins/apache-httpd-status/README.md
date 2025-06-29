# Check apache-httpd-status

## Overview

This check "allows a server administrator to find out how well their server is performing". For the check plugin to work you have to enable `mod_status` and set `ExtendedStatus` to `On`. Have a look at <https://httpd.apache.org/docs/2.4/mod/mod_status.html>.

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


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/apache-httpd-status> |
| Check Interval Recommendation         | Once a minute |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |
| Requirements                          | Enable `mod_status` and set `ExtendedStatus` to `On` |
| Uses SQLite DBs                       | `$TEMP/linuxfabrik-monitoring-plugins-apache-httpd-status.db` |


## Help

```text
usage: apache-httpd-status [-h] [-V] [--always-ok] [-c CRIT] [--insecure]
                           [--no-proxy] [--test TEST] [--timeout TIMEOUT]
                           [-u URL] [-w WARN]

Checks how well an Apache httpd server is performing.

options:
  -h, --help           show this help message and exit
  -V, --version        show program's version number and exit
  --always-ok          Always returns OK.
  -c, --critical CRIT  Set the CRIT threshold for the number of workers
                       processing requests in percent. Default: >= 95
  --insecure           This option explicitly allows to perform "insecure" SSL
                       connections. Default: False
  --no-proxy           Do not use a proxy. Default: False
  --test TEST          For unit tests. Needs "path-to-stdout-file,path-to-
                       stderr-file,expected-retc".
  --timeout TIMEOUT    Network timeout in seconds. Default: 8 (seconds)
  -u, --url URL        Apache Server Status URL. Default:
                       http://localhost/server-status
  -w, --warning WARN   Set the WARN threshold for the number of workers
                       processing requests in percent. Default: >= 80
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

* WARN or CRIT if more than 80% or 95% busy workers compared to the total possible number of workers found.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| Accesses | Number | A total number of accesses and byte count served |
| BusyWorkers | Number | workers_closing + workers_dns + workers_idle + workers_keepalive + workers_logging + workers_reading + workers_replying + workers_starting |
| Bytes | Number | Bytes sent |
| ConnsAsyncClosing | Number |  |
| ConnsAsyncKeepAlive | Number |  |
| ConnsAsyncWriting | Number |  |
| ConnsTotal | Number |  |
| CPULoad | Number |  |
| IdleWorkers | Number | workers_finishing + workers_waiting |
| Load1 | Number |  |
| Load15 | Number |  |
| Load5 | Number |  |
| ParentServerConfigGeneration | Number |  |
| ParentServerMPMGeneration | Number |  |
| Processes | Number |  |
| Stopping | Number |  |
| Total Duration | Seconds |  |
| TotalWorkers | Number |  |
| Uptime | Seconds | The time the server has been running for |
| WorkerUsagePercentage | Percentage |  |
| workers_closing | Number | BusyWorkers; Closing connection, 'C' in Apache Scoreboard (SERVER_CLOSING) |
| workers_dns | Number | BusyWorkers; DNS Lookup,'D' in Apache Scoreboard (SERVER_BUSY_DNS) |
| workers_finishing | Number | IdleWorkers; Gracefully finishing, 'G' in Apache Scoreboard (SERVER_GRACEFUL) |
| workers_free | Number | Open slot with no current process, '.' in Apache Scoreboard (SERVER_DEAD) |
| workers_idle | Number | BusyWorkers; Idle cleanup of worker, 'I' in Apache Scoreboard (SERVER_IDLE_KILL) |
| workers_keepalive | Number | BusyWorkers; Keepalive (read), 'K' in Apache Scoreboard (SERVER_BUSY_KEEPALIVE) |
| workers_logging | Number | BusyWorkers; Logging, 'L' in Apache Scoreboard (SERVER_BUSY_LOG) |
| workers_reading | Number | BusyWorkers; Reading Request, 'R' in Apache Scoreboard (SERVER_BUSY_READ) |
| workers_replying | Number | BusyWorkers; Sending Reply, 'W' in Apache Scoreboard (SERVER_BUSY_WRITE) |
| workers_starting | Number | BusyWorkers; Starting up, 'S' in Apache Scoreboard (SERVER_STARTING) |
| workers_waiting | Number | IdleWorkers; Waiting for Connection, '\_' in Apache Scoreboard (SERVER_READY) |


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
