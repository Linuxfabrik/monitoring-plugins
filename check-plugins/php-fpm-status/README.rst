Check php-fpm-status
====================

Overview
--------

This check collects information from the PHP-FPM pool status page and alerts on certain overuse. In addition, a table is printed which contains each pool process in the status "Running" (which information relates to the current request that is being served).

PHP-FPM config example:

.. code-block:: text
    
    ; PHP-FPM Config
    pm.status_path = /fpm-status

.. code-block:: text
    
    # Apache Config
    Alias /fpm-status /dev/null
    <LocationMatch "/fpm-status">
        Require local
        ProxyPass unix:/run/php-fpm/www.sock|fcgi://localhost/fpm-status
    </LocationMatch>


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/php-fpm-status"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "Yes"
    "Compiled for",                         "Linux, Windows"
    "Requirements",                         "Configure a status page like ``/fpm-status``, ``/<poolname>-fpm-status`` or similar in ``/etc/php-fpm.d/<poolname>.conf``"


Help
----

.. code-block:: text

    usage: php-fpm-status [-h] [-V] [--always-ok] [-c CRIT]
                          [--critical-maxchildren CRIT_MAX_CHILDREN]
                          [--critical-slowreq CRIT_SLOW_REQUESTS] [--insecure]
                          [--no-proxy] [--test TEST] [--timeout TIMEOUT] [-u URL]
                          [-w WARN] [--warning-maxchildren WARN_MAX_CHILDREN]
                          [--warning-slowreq WARN_SLOW_REQUESTS]

    This check collects information from the PHP-FPM status page and alerts on
    certain overuse. In addition, a table is printed which contains each pool
    process in the status "Running" (information relates to the current request
    that is being served).

    options:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      -c CRIT, --critical CRIT
                            Set the CRIT threshold for queue usage as a
                            percentage. Default: >= 90
      --critical-maxchildren CRIT_MAX_CHILDREN
                            Set the CRIT threshold for the number of times the
                            process limit has been reached. Default: >= 100
      --critical-slowreq CRIT_SLOW_REQUESTS
                            Set the CRIT threshold for slow requests. Default: >=
                            100
      --insecure            This option explicitly allows to perform "insecure"
                            SSL connections. Default: False
      --no-proxy            Do not use a proxy. Default: False
      --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                            stderr-file,expected-retc".
      --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
      -u URL, --url URL     PHP-FPM Status URL. Default: http://localhost/fpm-
                            status
      -w WARN, --warning WARN
                            Set the WARN threshold for queue usage as a
                            percentage. Default: >= 80
      --warning-maxchildren WARN_MAX_CHILDREN
                            Set the WARN threshold for the number of times the
                            process limit has been reached. Default: >= 1
      --warning-slowreq WARN_SLOW_REQUESTS
                            Set the WARN threshold for slow requests. Default: >=
                            1


Usage Examples
--------------

.. code-block:: bash

    ./php-fpm-status --url http://localhost/fpm-status --warning 80 --warning-maxchildren 10 --critical-slowreq 3

Output:

.. code-block:: text

    Pool www (dynamic): 47/55 reqs in queue (85.5%) [WARNING], 3x max children reached [WARNING], 42 slow requests [WARNING], 129k connections, 23 processes (3 active, 20 idle), Up 3h 28m (since 2021-05-08 09:18:11)

    PID     Reqs ReqDur Request URI           POST    AuthUser
    ---     ---- ------ -----------           ----    --------
    1818627 5785 6h 23m /nextcloud/remote.php -       user@example.org 
    1821973 5062 5h 14m /nextcloud/remote.php -       user@example.org 
    1823283 5092 3m 40s /nextcloud/index.php  252.0B  -

The columns mean:

* PID: the PID of the process
* Requests: the number of requests the process has served
* ReqDur: the duration of the requests
* Request URI: the request URI with the query string
* POST: the content length of the POST request (or '-' if not a POST)
* AuthUser: the user (PHP_AUTH_USER) (or '-' if not set);


States
------

* WARN or CRIT on queue usage over certain thresholds (default 80/90%)
* WARN or CRIT if number of max children is over certain thresholds (default 1/100)
* WARN or CRIT if number of slow queries is over certain thresholds (default 1/100)


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description                                           
    accepted conn,                              Continous Counter,  "Number of requests accepted by the pool"
    active processes,                           Number,             "Number of active processes"
    idle processes,                             Number,             "Number of idle processes"
    listen queue len,                           Number,             "Size of the socket queue of pending connections"
    listen queue,                               Number,             "Number of requests in the queue of pending connections"
    max children reached,                       Number,             "Number of times, the process limit has been reached, when pm tries to start more children (works only for pm 'dynamic' and 'ondemand')"
    queue usage,                                Percentage,         "Number of requests in the queue of pending connections, in %"
    slow requests,                              Number,             "Number of slow requests"
    start since,                                Seconds,            "Number of seconds since FPM has started"


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
