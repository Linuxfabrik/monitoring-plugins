Check wildfly-non-xa-datasource-stats
=====================================

Overview
--------

This check plugin returns metrics of Non-XA datasources of a WildFly server, using its HTTP-JSON based API (JBossAS REST Management API). This allows us to monitor the application server without any additional configuration and installation - no need to deploy WAR-Agents like Jolokia. The plugin supports both standalone mode and domain mode.

Tested with WildFly 11 and WildFly 23.

The check recognizes if a datasource does not support statistics.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/wildfly-non-xa-datasource-stats"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "No"
    "Available for",                        "Python 2, Python 3"
    "Requirements",                         "None"


Help
----

.. code-block:: text

    usage: wildfly-non-xa-datasource-stats [-h] [-V] [--always-ok]
                                           [--critical CRIT]
                                           [--instance INSTANCE]
                                           [--mode {standalone,domain}]
                                           [--node NODE] -p PASSWORD
                                           [--timeout TIMEOUT] [--url URL]
                                           --username USERNAME [--warning WARN]

    Returns metrics about Non-XA Datasources of a Wildfly/JBossAS over HTTP.

    optional arguments:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      --critical CRIT       Set the critical threshold.
      --instance INSTANCE   The instance (server-config) to check if running in
                            domain mode.
      --mode {standalone,domain}
                            The mode the server is running.
      --node NODE           The node (host) if running in domain mode.
      -p PASSWORD, --password PASSWORD
                            WildFly API password.
      --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
      --url URL             WildFly API URL. Default: http://localhost:9990
      --username USERNAME   WildFly API username. Default: wildfly-admin
      --warning WARN        Set the warning threshold.


Usage Examples
--------------

.. code-block:: bash

    ./wildfly-non-xa-datasource-stats --username wildfly-admin --password password --url http://wildfly:9990 --warning 80 --critical 90

Output:

.. code-block:: text

    MyFirstDS: 0.0% active used (0/20), 0.0% max used (0/20); Statistics are not enabled for data source MySecondDS


States
------

Triggers an alarm on usage in percent.

* WARN or CRIT if active or max used datapool connections are above certain thresholds (default 80/90%).


Perfdata / Metrics
------------------

* non-xa-ds-<name>-active
* non-xa-ds-<name>-active-pct: Usage in Percent
* non-xa-ds-<name>-blockingfailurecount
* non-xa-ds-<name>-createdcount
* non-xa-ds-<name>-destroyedcount
* non-xa-ds-<name>-idlecount
* non-xa-ds-<name>-inusecount
* non-xa-ds-<name>-maxused
* non-xa-ds-<name>-maxused-pct: Usage in Percent
* non-xa-ds-<name>-maxwaitcount
* non-xa-ds-<name>-waitcount
* non-xa-ds-<name>-xacommitcount
* non-xa-ds-<name>-xaendcount
* non-xa-ds-<name>-xaforgetcount
* non-xa-ds-<name>-xapreparecount
* non-xa-ds-<name>-xarecovercount
* non-xa-ds-<name>-xarollbackcount
* non-xa-ds-<name>-xastartcount


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
