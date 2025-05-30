Check php-fpm-ping
==================

Overview
--------

This check fetches the ping monitoring page of PHP-FPM. This could be used to test from outside that FPM is alive and responding, to create a graph of FPM availability, or to trigger alerts for the operating team (24/7).

PHP-FPM config example:

.. code-block:: text
    
    ; PHP-FPM Config
    ping.path = /fpm-ping
    ping.response = pong

.. code-block:: text
    
    # Apache Config
    Alias /fpm-ping /dev/null
    <Location "/fpm-ping">
        Require local
        ProxyPass unix:/run/php-fpm/www.sock|fcgi://localhost/fpm-ping
    </Location>


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70

    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/php-fpm-ping"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "Yes"
    "Compiled for Windows",                 "No"
    "Requirements",                         "Configure a ping page like ``/fpm-ping``, ``/<poolname>-fpm-ping`` or similar in ``/etc/php-fpm.d/<poolname>.conf``"


Help
----

.. code-block:: text

    usage: php-fpm-ping [-h] [-V] [--always-ok] [--insecure] [--no-proxy]
                        [--response RESPONSE] [--severity {warn,crit}]
                        [--test TEST] [--timeout TIMEOUT] [-u URL]

    Fetches the ping monitoring page of PHP-FPM.

    options:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      --insecure            This option explicitly allows to perform "insecure"
                            SSL connections. Default: False
      --no-proxy            Do not use a proxy. Default: False
      --response RESPONSE   Expected PHP-FPM Ping response. Default: pong
      --severity {warn,crit}
                            Severity for alerting. Default: warn
      --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                            stderr-file,expected-retc".
      --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
      -u, --url URL         PHP-FPM Ping URL. Default: http://localhost/fpm-ping


Usage Examples
--------------

.. code-block:: bash

    ./php-fpm-ping --url http://localhost/fpm-ping --response pong --severity crit

Output:

.. code-block:: text

    pong


States
------

* WARN or CRIT if output is not identical to ``--response`` (default: "pong"), depending on the given severity (default: WARN)


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description                                           
    ping,                                       Number,             "0 (= STATE_OK) if response is as expected, 1 (STATE_WARN) or 2 (STATE_CRIT)otherwise"


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
