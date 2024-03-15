Check wildfly-uptime
====================

Overview
--------

This check plugin monitors the uptime of a WildFly server, using its HTTP-JSON based API (JBossAS REST Management API). This allows us to monitor the application server without any additional configuration and installation - no need to deploy WAR-Agents like Jolokia. The plugin supports both standalone mode and domain mode.

Tested with WildFly 11 and WildFly 23+.

Hints:

* See `additional notes for all wildfly monitoring plugins <https://github.com/Linuxfabrik/monitoring-plugins/blob/main/PLUGINS-WILDFLY.rst>`_


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/wildfly-uptime"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "No"
    "Compiled for",                         "Linux, Windows"


Help
----

.. code-block:: text

    usage: wildfly-uptime [-h] [-V] [--always-ok] [--critical CRIT] [--insecure]
                          [--instance INSTANCE] [--mode {standalone,domain}]
                          [--no-proxy] [--node NODE] -p PASSWORD
                          [--timeout TIMEOUT] [--url URL] --username USERNAME
                          [--warning WARN]

    Checks the uptime of a Wildfly/JBossAS over HTTP.

    options:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      --critical CRIT       Set the critical threshold.
      --insecure            This option explicitly allows to perform "insecure"
                            SSL connections. Default: False
      --instance INSTANCE   The instance (server-config) to check if running in
                            domain mode.
      --mode {standalone,domain}
                            The mode the server is running.
      --no-proxy            Do not use a proxy. Default: False
      --node NODE           The node (host) if running in domain mode.
      -p PASSWORD, --password PASSWORD
                            WildFly API password.
      --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
      --url URL             WildFly API URL. Default: http://localhost:9990
      --username USERNAME   WildFly API username. Default: wildfly-monitoring
      --warning WARN        Set the warning threshold.


Usage Examples
--------------

.. code-block:: bash

    ./wildfly-uptime --username wildfly-monitoring --password password --url http://wildfly:9990 --warning 180 --critical 366

Output:

.. code-block:: text

    Up 1h 11m


States
------

Triggers an alarm on uptime in days.

* WARN or CRIT when uptime (the number of days) exceeds the thresholds (default 180/366 days)


Perfdata / Metrics
------------------

* uptime: seconds


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
