Check "apache-httpd-status"
===========================

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

We recommend to run this check every minute.


Installation and Usage
----------------------

.. code-block:: bash

    ./apache-httpd-status
    ./apache-httpd-status --url http://localhost/server-status --warning 80 --critical 90
    ./apache-httpd-status --help

Output::

    Workers: 1/256 busy (0%; 0 "G"), 5 idle, 250 free; 2010 total accesses, 0.0 req/s; 1.4M total traffic, 12.0B/s, 731.0B/req; Up 1d 9h


States
------

* WARN or CRIT if more than 80% or 95% busy workers compared to the total possible number of workers are found.


Perfdata
--------

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

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.