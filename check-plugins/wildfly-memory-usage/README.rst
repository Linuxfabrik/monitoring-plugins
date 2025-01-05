Check wildfly-memory-usage
==========================

Overview
--------

This check plugin monitors the heap and non-heap memory usage of a WildFly server, using its HTTP-JSON based API (JBossAS REST Management API). This allows us to monitor the application server without any additional configuration and installation - no need to deploy WAR-Agents like Jolokia. The plugin supports both standalone mode and domain mode.

Tested with WildFly 11 and WildFly 23+.

Hints:

* See `additional notes for all wildfly monitoring plugins <https://github.com/Linuxfabrik/monitoring-plugins/blob/main/PLUGINS-WILDFLY.rst>`_


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70

    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/wildfly-memory-usage"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "No"
    "Compiled for",                         "Linux, Windows"


Help
----

.. code-block:: text

    usage: wildfly-memory-usage [-h] [-V] [--always-ok] [--critical CRIT]
                                [--insecure] [--instance INSTANCE]
                                [--mode {standalone,domain}] [--no-proxy]
                                [--node NODE] -p PASSWORD [--timeout TIMEOUT]
                                [--url URL] --username USERNAME [--warning WARN]

    Checks the memory usage of a Wildfly/JBossAS over HTTP.

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
      -p, --password PASSWORD
                            WildFly API password.
      --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
      --url URL             WildFly API URL. Default: http://localhost:9990
      --username USERNAME   WildFly API username. Default: wildfly-monitoring
      --warning WARN        Set the warning threshold.


Usage Examples
--------------

.. code-block:: bash

    ./wildfly-memory-usage --username wildfly-monitoring --password password --url http://wildfly:9990 --warning 80 --critical 90

Output:

.. code-block:: text

    Heap used: 18.04% (82.2MiB of 455.5MiB), Heap committed: 44.35% (202.0MiB of 455.5MiB), Non-Heap used: 14.56% (108.3MiB of 744.0MiB), Non-Heap committed: 16.25% (120.9MiB of 744.0MiB)


States
------

Triggers an alarm on usage in percent.

* WARN or CRIT if memory usage (used or committed, heap or non-heap) is above certain thresholds (default 80/90%)


Perfdata / Metrics
------------------

* heap-committed: in bytes
* heap-committed-percent: in percent
* heap-max: in bytes
* heap-usage-percent: in percent
* heap-used: in bytes
* non-heap-committed: in bytes
* non-heap-committed-percent: in percent
* non-heap-max: in bytes
* non-heap-usage-percent: in percent
* non-heap-used: in bytes


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
