Check wildfly-deployment-status
===============================

Overview
--------

This check plugin monitors the deployment status of a WildFly server, using its HTTP-JSON based API (JBossAS REST Management API). This allows us to monitor the application server without any additional configuration and installation - no need to deploy WAR-Agents like Jolokia. The plugin supports both standalone mode and domain mode.

Tested with WildFly 11 and WildFly 23+.

Hints:

* See `additional notes for all wildfly monitoring plugins <https://github.com/Linuxfabrik/monitoring-plugins/blob/main/PLUGINS-WILDFLY.rst>`_


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/wildfly-deployment-status"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "No"
    "Compiled for",                         "Linux, Windows"


Help
----

.. code-block:: text

    usage: wildfly-deployment-status [-h] [-V] [--always-ok]
                                     [--deployment DEPLOYMENT]
                                     [--instance INSTANCE]
                                     [--mode {standalone,domain}] [--node NODE]
                                     -p PASSWORD [--timeout TIMEOUT] [--url URL]
                                     --username USERNAME

    Checks the deployment status of a Wildfly/JBossAS over HTTP.

    options:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      --deployment DEPLOYMENT
                            The name of an application whose deployment status is
                            to be checked (repeating). Default: None
      --instance INSTANCE   The instance (server-config) to check if running in
                            domain mode.
      --mode {standalone,domain}
                            The mode the server is running.
      --node NODE           The node (host) if running in domain mode.
      -p PASSWORD, --password PASSWORD
                            WildFly API password.
      --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
      --url URL             WildFly API URL. Default: http://localhost:9990
      --username USERNAME   WildFly API username. Default: wildfly-monitoring


Usage Examples
--------------

.. code-block:: bash

    # check all deployments
    ./wildfly-deployment-status --username wildfly-monitoring --password password --url http://wildfly:9990

    # just check specific deployments
    ./wildfly-deployment-status --username wildfly-monitoring --password password --url http://wildfly:9990 --deployment MyFirstApp --deployment MySecondApp

Output:

.. code-block:: text

    2 Deployments checked, everything is ok.

    * MyFirstApp is OK
    * MySecondApp is RUNNING


States
------

Triggers an alarm on its own.

* OK: app state in ['OK', 'RUNNING']
* WARN: app state in ['STOPPED']
* CRIT: everything else


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description                                           
    deployment-state-<name>,                    Number,             "0 (STATE_OK), 1 (STATE_WARN), 2 (STATE_CRIT)"


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
