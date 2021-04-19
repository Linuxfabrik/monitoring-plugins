Check "wildfly-non-xa-datasource-stats"
=======================================

Overview
--------

This check plugin returns metrics of Non-XA datasources of a WildFly server, using its HTTP-JSON based API (JBossAS REST Management API). This allows us to monitor the application server without any additional configuration and installation - no need to deploy WAR-Agents like Jolokia. The plugin supports both standalone mode and domain mode.

Tested with WildFly 11 and WildFly 23.


Installation and Usage
----------------------

.. code-block:: bash

    ./wildfly-non-xa-datasource-stats --username wildfly-admin --password password --url http://wildfly:9990

Output::

    Non-XA Datasources Statistics. H2DS - no interesting data, H2DSAA - no interesting data, H2DSxxx - no interesting data


States
------

Never triggers an alarm.

* Always returns OK


Perfdata
--------

* non-xa-datasource-<name>-ActiveCount
* non-xa-datasource-<name>-AvailableCount
* non-xa-datasource-<name>-AverageBlockingTime
* non-xa-datasource-<name>-AverageCreationTime
* non-xa-datasource-<name>-AverageGetTime
* non-xa-datasource-<name>-AveragePoolTime
* non-xa-datasource-<name>-AverageUsageTime
* non-xa-datasource-<name>-BlockingFailureCount
* non-xa-datasource-<name>-CreatedCount
* non-xa-datasource-<name>-DestroyedCount
* non-xa-datasource-<name>-IdleCount
* non-xa-datasource-<name>-InUseCount
* non-xa-datasource-<name>-MaxUsedCount
* non-xa-datasource-<name>-MaxWaitTime
* non-xa-datasource-<name>-TimedOut
* non-xa-datasource-<name>-WaitCount


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see LICENSE file.
