Check "wildfly-xa-datasource-stats"
===================================

Overview
--------

This check plugin returns metrics of XA datasources of a WildFly server, using its HTTP-JSON based API (JBossAS REST Management API). This allows us to monitor the application server without any additional configuration and installation - no need to deploy WAR-Agents like Jolokia. The plugin supports both standalone mode and domain mode.

Tested with WildFly 11 and WildFly 23.


Installation and Usage
----------------------

.. code-block:: bash

    ./wildfly-xa-datasource-stats --username wildfly-admin --password password --url http://wildfly:9990

Output::

    XA Datasources Statistics. H2DS - no interesting data, H2DSAA - no interesting data, H2DSxxx - no interesting data


States
------

Never triggers an alarm.

* Always returns OK


Perfdata
--------

* xa-datasource-<name>-ActiveCount
* xa-datasource-<name>-AvailableCount
* xa-datasource-<name>-AverageBlockingTime
* xa-datasource-<name>-AverageCreationTime
* xa-datasource-<name>-AverageGetTime
* xa-datasource-<name>-AveragePoolTime
* xa-datasource-<name>-AverageUsageTime
* xa-datasource-<name>-BlockingFailureCount
* xa-datasource-<name>-CreatedCount
* xa-datasource-<name>-DestroyedCount
* xa-datasource-<name>-IdleCount
* xa-datasource-<name>-InUseCount
* xa-datasource-<name>-MaxUsedCount
* xa-datasource-<name>-MaxWaitTime
* xa-datasource-<name>-TimedOut
* xa-datasource-<name>-WaitCount


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see LICENSE file.
