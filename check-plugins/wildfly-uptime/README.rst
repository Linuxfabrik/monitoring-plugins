Check "wildfly-uptime"
======================

Overview
--------

This check plugin monitors the uptime of a WildFly server, using its HTTP-JSON based API (JBossAS REST Management API). This allows us to monitor the application server without any additional configuration and installation - no need to deploy WAR-Agents like Jolokia. The plugin supports both standalone mode and domain mode.

Tested with WildFly 11 and WildFly 23.

We recommend running this check every minute.


Installation and Usage
----------------------

.. code-block:: bash

    ./wildfly-uptime --username wildfly-admin --password password --url http://wildfly:9990 --warning 180 --critical 366

Output::

    Up 1h 11m


States
------

Triggers an alarm on uptime in days.

* WARN or CRIT when uptime (the number of days) exceeds the thresholds (default 180/366 days)


Perfdata
--------

* uptime: seconds


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see LICENSE file.
