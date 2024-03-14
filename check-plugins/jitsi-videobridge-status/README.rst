Check jitsi-videobridge-status
==============================

Overview
--------

Checks the Jitsi Videobridge health state.

The REST API allows querying Videobridge whether it deems itself in a healthy state (i.e. the application is operational and the functionality it provides should perform as expected) at the time of the query or not. Videobridge performs periodic internal tests, and returns the latest result in response to requests to the ``/about/health`` endpoint. For details have a look `here <https://github.com/jitsi/jitsi-videobridge/blob/master/doc/health-checks.md>`_.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/jitsi-videobridge-status"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "Yes"
    "Compiled for",                         "Linux, Windows"


Help
----

.. code-block:: text

    usage: jitsi-videobridge-status [-h] [-V] [--always-ok] [--insecure]
                                    [--no-proxy] [-p PASSWORD]
                                    [--severity {warn,crit}] [--test TEST]
                                    [--timeout TIMEOUT] [--url URL]
                                    [--username USERNAME]

    Checks the Jitsi Videobridge health state.

    options:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      --insecure            This option explicitly allows to perform "insecure"
                            SSL connections. Default: False
      --no-proxy            Do not use a proxy. Default: False
      -p PASSWORD, --password PASSWORD
                            Jitsi API password.
      --severity {warn,crit}
                            Severity for alerting. Default: warn
      --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                            stderr-file,expected-retc".
      --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
      --url URL             Jitsi API URL. Default: http://localhost:8080
      --username USERNAME   Jitsi API username. Default: None


Usage Examples
--------------

.. code-block:: bash

    ./jitsi-videobridge-status --severity warn

Output:

.. code-block:: text

    Problems with jitsi-videobridge.


States
------

* Depending on the given ``--severity``, returns WARN (default) or CRIT if Videobridge determined that it is in an unhealthy state.


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description                                           
    jitsi-videobridge-state,                    Number,             "The current state (0 = OK, 1 = WARN, 2 = CRIT, 3 = UNKNOWN)."


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
