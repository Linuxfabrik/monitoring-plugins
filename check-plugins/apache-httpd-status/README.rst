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

    Workers: 1/400 busy (0%; 0 "G"), 99 idle, 300 free; 2.5K total accesses, 0.0 req/s; 62.4MiB total traffic, 9.4KiB/s, 25.3KiB/req; Up 1h 53m


States
------

* WARN or CRIT if more than 80% or 95% busy workers compared to the total possible number of workers found.


Perfdata / Metrics
------------------

* httpd_bytesperreq: Average number of bytes per request (\*)
* httpd_bytespersec: Average number of bytes served per second (\*)
* httpd_reqpersec: Average number of requests per second (\*)
* httpd_total_accesses: A total number of accesses and byte count served (\*)
* httpd_total_traffic
* workers: Maximum number of workers possible
* workers_free
* uptime: The time the server has been running for

The number of idle workers:

* workers_idle
* workers_waiting

The number of workers serving requests:

* workers_closing
* workers_dns
* workers_finishing
* workers_keepalive
* workers_logging
* workers_reading
* workers_replying
* workers_starting

The lines marked "(\*)" are only available if ``ExtendedStatus`` is ``On``.


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
