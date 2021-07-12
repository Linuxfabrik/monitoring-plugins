Check apache-httpd-status
=========================

Overview
--------

This check "allows a server administrator to find out how well their server is performing". For the check plugin to work you have to enable ``mod_status`` and set ``ExtendedStatus`` to ``On``. Have a look at https://httpd.apache.org/docs/2.4/mod/mod_status.html.

Busy workers (workers serving requests) are:

* ``C``: Closing connection
* ``D``: DNS Lookup
* ``G``: Gracefully finishing
* ``I``: Idle cleanup of worker
* ``K``: Keepalive (read)
* ``L``: Logging
* ``R``: Reading Request
* ``S``: Starting up
* ``W``: Sending Reply

Idle workers are:

* ``_``: Waiting for Connection

Free workers are:

* ``.``: Open slot with no current process

Apache httpd config example:

.. code-block:: text

    # the alias prevents the processing of .htaccess files, which could contain RewriteRules that interfere with server-status
    Alias /server-status /dev/null
    <IfModule status_module>
        ExtendedStatus On
        <Location /server-status>
            SetHandler server-status
            Require local
        </Location>
    </IfModule>


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/apache-httpd-status"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "Yes"
    "Available for",                        "Python 2"
    "Requirements",                         "Enable ``mod_status`` and set ``ExtendedStatus`` to ``On``"


Help
----

.. code-block:: text

    usage: apache-httpd-status [-h] [-V] [--always-ok] [-c CRIT] [-u URL]
                                [-w WARN]

    Checks how well an Apache httpd server is performing.

    optional arguments:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      -c CRIT, --critical CRIT
                            Set the CRIT threshold for the number of workers
                            processing requests in percent. Default: >= 95
      -u URL, --url URL     Apache Server Status URL. Default: http://localhost
                            /server-status
      -w WARN, --warning WARN
                            Set the WARN threshold for the number of workers
                            processing requests in percent. Default: >= 80


Usage Examples
--------------

.. code-block:: bash

    ./apache-httpd-status --url http://apache-httpd/server-status --warning 80 --critical 90

Output:

.. code-block:: text

    192.168.122.97: 256/400 workers busy (64.0%; 0 "G"), 144 idle, 0 free; 78.7K accesses, 8.4GiB traffic, 2537.5 req/s, 0.04s/req, 278.6MiB/s, 112.4KiB/req in the last 31s; Up 2m 3s

    Key                            ! Value                                               
    ------------------------------ ! --------------------------------------------------- 
    Current Time                   ! Friday, 09-Jul-2021 16:11:17 CEST                   
    Restart Time                   ! Friday, 09-Jul-2021 16:09:14 CEST                   
    Interval                       ! 31s                                                 
    Uptime                         ! 2m 3s                                               
    Connections                    ! 314                                                 
      Async Writing                ! 0                                                   
      Async KeepAlive              ! 0                                                   
      Async Closing                ! 140                                                 
    Requests per Second            ! 2537.5                                              
    Bytes per Second               ! 278.6MiB                                            
    Bytes per Request              ! 112.4KiB                                            
    Seconds per Request            ! 0.04                                                
    Requests                       ! 78.7K                                               
    Bytes                          ! 8.4GiB                                              
    Request Duration               ! 58m 39s                                             
    Load1                          ! 2.32                                                
    Load5                          ! 0.56                                                
    Load15                         ! 0.19                                                
    Processes                      ! 16                                                  
      Stopping                     ! 0                                                   
    Workers Total                  ! 400                                                 
      Busy                         ! 256                                                 
      Idle                         ! 144                                                 
      Usage (%)                    ! 64.0                                                
    Parent Server ConfigGeneration ! 1                                                   
    Parent Server MPMGeneration    ! 0                                                   
    Server Name                    ! 192.168.122.97                                      
    Server MPM                     ! event                                               
    Server Version                 ! Apache/2.4.48 (Fedora) OpenSSL/1.1.1k mod_qos/11.66 
    Server Built                   ! Jun  2 2021 00:00:00


States
------

* WARN or CRIT if more than 80% or 95% busy workers compared to the total possible number of workers found.


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description                                           
    Accesses,                                   Number,             "A total number of accesses and byte count served"
    BusyWorkers,                                Number,             workers_closing + workers_dns + workers_idle + workers_keepalive + workers_logging + workers_reading + workers_replying + workers_starting
    Bytes,                                      Bytes,              
    BytesPerReq,                                Bytes,              "Average number of bytes per request"
    BytesPerSec,                                Bytes,              "Average number of bytes served per second"
    ConnsAsyncClosing,                          Number,             
    ConnsAsyncKeepAlive,                        Number,             
    ConnsAsyncWriting,                          Number,             
    ConnsTotal,                                 Number,             
    CPULoad,                                    Number,             
    DurationPerReq,                             Number,             
    IdleWorkers,                                Number,             workers_finishing + workers_waiting
    Load1,                                      Number,             
    Load15,                                     Number,             
    Load5,                                      Number,             
    ParentServerConfigGeneration,               Number,             
    ParentServerMPMGeneration,                  Number,             
    Processes,                                  Number,             
    ReqPerSec,                                  Number,             "Average number of requests per second"
    Stopping,                                   Number,             
    Total Duration,                             Seconds,            
    TotalWorkers,                               Number,             
    Uptime,                                     Seconds,            "The time the server has been running for"
    WorkerUsagePercentage,                      Percentage,         
    workers_closing,                            Number,             "BusyWorkers; Closing connection, 'C' in Apache Scoreboard (SERVER_CLOSING)"
    workers_dns,                                Number,             "BusyWorkers; DNS Lookup,'D' in Apache Scoreboard (SERVER_BUSY_DNS)"
    workers_finishing,                          Number,             "IdleWorkers; Gracefully finishing, 'G' in Apache Scoreboard (SERVER_GRACEFUL)"
    workers_free,                               Number,             "Open slot with no current process, '.' in Apache Scoreboard (SERVER_DEAD)"
    workers_idle,                               Number,             "BusyWorkers; Idle cleanup of worker, 'I' in Apache Scoreboard (SERVER_IDLE_KILL)"
    workers_keepalive,                          Number,             "BusyWorkers; Keepalive (read), 'K' in Apache Scoreboard (SERVER_BUSY_KEEPALIVE)"
    workers_logging,                            Number,             "BusyWorkers; Logging, 'L' in Apache Scoreboard (SERVER_BUSY_LOG)"
    workers_reading,                            Number,             "BusyWorkers; Reading Request, 'R' in Apache Scoreboard (SERVER_BUSY_READ)"
    workers_replying,                           Number,             "BusyWorkers; Sending Reply, 'W' in Apache Scoreboard (SERVER_BUSY_WRITE)"
    workers_starting,                           Number,             "BusyWorkers; Starting up, 'S' in Apache Scoreboard (SERVER_STARTING)"
    workers_waiting,                            Number,             "IdleWorkers; Waiting for Connection, '_' in Apache Scoreboard (SERVER_READY)"


Troubleshooting
---------------

From https://httpd.apache.org/docs/2.4/mod/mod_status.html#troubleshoot:

    The check may be used as a starting place for troubleshooting a situation where your server is consuming all available resources (CPU or memory), and you wish to identify which requests or clients are causing the problem.

    First, ensure that you have ``ExtendedStatus`` set on, so that you can see the full request and client information for each child or thread.

    Now look in your process list (using top, or similar process viewing utility) to identify the specific processes that are the main culprits. Order the output of top by CPU usage, or memory usage, depending on what problem you're trying to address.

    Reload the server-status page, and look for those process ids, and you'll be able to see what request is being served by that process, for what client. Requests are transient, so you may need to try several times before you catch it in the act, so to speak.

    This process should give you some idea what client, or what type of requests, are primarily responsible for your load problems. Often you will identify a particular web application that is misbehaving, or a particular client that is attacking your site.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
