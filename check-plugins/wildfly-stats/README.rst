Check "wildfly-stats"
=====================

Overview
--------

This check plugin monitors a WildFly server, using its HTTP-JSON based API (JBossAS REST Management API) to collect server statistics. This allows us to monitor the application server without any additional configuration and installation - no need to deploy WAR-Agents like Jolokia. The plugin supports both standalone mode and domain mode.

Tested with WildFly 11 and WildFly 23.


Meaningful Thresholds for Actions
---------------------------------

==================  ===============================================
--action            Meaningful values for --warning and --critical
==================  ===============================================
deployment-status   not supported
garbage-collector   --warning 500 --critical 1000
heap-usage          --warning 80 --critical 90
memory-pool-usage   --warning 80 --critical 90
non-heap-usage      --warning 80 --critical 90
non-xa-datasource   not supported
server-status       not supported
threading           --warning 100 --critical 200
uptime              --warning 180 --critical 366
xa-datasource       not supported
==================  ===============================================


Deployment Status
-----------------

Triggers an alarm on its own.

.. code-block:: bash

    ./wildfly-stats --username wildfly-admin --password password --url http://wildfly:9990 --action deployment-status

Output::

    2 Deployments checked, everything is ok.

    * myapp1.war is OK
    * myapp2.war is RUNNING

States:

* OK: app state in ['OK', 'RUNNING']
* WARN: app state in ['STOPPED']
* CRIT: everything else

Perfdata:

* deployment-state-<name>: 0 (STATE_OK), 1 (STATE_WARN), 2 (STATE_CRIT)


Garbage Collector Status
------------------------

Triggers an alarm on absolute values.

.. code-block:: bash

    ./wildfly-stats --username wildfly-admin --password password --url http://wildfly:9990 --warning 500 --critical 1000 --action garbage-collector

Output::

    GC Statistics (time/count/avg). PS_MarkSweep: 143/1/143.0, PS_Scavenge: 105/8/13.0

States:

* WARN or CRIT if any Garbage Collector "Average Time" is above certain thresholds (default 80/90)

Perfdata:

* garbage-collector-<name>-collection-avgtime
* garbage-collector-<name>-collection-count
* garbage-collector-<name>-collection-time


Heap Usage
----------

Triggers an alarm on usage in percent.

.. code-block:: bash

    ./wildfly-stats --username wildfly-admin --password password --url http://wildfly:9990 --warning 80 --critical 90 --action heap-usage

Output::

    Heap used: 33.58% (152.9MiB of 455.5MiB), Heap committed: 47.86% (218.0MiB of 455.5MiB)

States:

* WARN or CRIT if memory usage (used or committed) is above certain thresholds (default 80/90 %)

Perfdata:

* heap-committed: in bytes
* heap-committed-percent: in percent
* heap-max: in bytes
* heap-usage-percent: in percent
* heap-used: in bytes


Memory Pool Usage
-----------------

Triggers an alarm on usage in percent.

.. code-block:: bash

    ./wildfly-stats --username wildfly-admin --password password --url http://wildfly:9990 --warning 80 --critical 90 --action memory-pool-usage

Output::

    6 Memory Pools checked, there are errors.

    * PS_Old_Gen - Memory used: 12.48% (42.6MiB of 341.5MiB), Memory committed: 21.08% (72.0MiB of 341.5MiB)
    * PS_Survivor_Space - Memory used: 30.54% (7.8MiB of 25.5MiB), Memory committed: 100.0% (25.5MiB of 25.5MiB)
    * Compressed_Class_Space - Memory used: 2.99% (7.4MiB of 248.0MiB), Memory committed: 3.83% (9.5MiB of 248.0MiB)
    * Code_Cache - Memory used: 6.69% (16.1MiB of 240.0MiB), Memory committed: 6.82% (16.4MiB of 240.0MiB)
    * PS_Eden_Space - Memory used: 91.91% (110.8MiB of 120.5MiB) [CRITICAL], Memory committed: 100.0% (120.5MiB of 120.5MiB)
    * Metaspace - Memory used: 23.43% (60.0MiB of 256.0MiB), Memory committed: 26.27% (67.2MiB of 256.0MiB)

States:

* WARN or CRIT if memory usage (used) is above certain thresholds (default 80/90 %)
* WARN if WildFly reports 'collection-usage-threshold-exceeded' == TRUE

Perfdata:

* memory-pool-<name>-committed: in bytes
* memory-pool-<name>-committed-percent: in percent
* memory-pool-<name>-max: in bytes
* memory-pool-<name>-used: in bytes
* memory-pool-<name>-used-percent: in percent


Non-Heap Usage
--------------

Triggers an alarm on usage in percent.

.. code-block:: bash

    ./wildfly-stats --username wildfly-admin --password password --url http://wildfly:9990 --warning 80 --critical 90 --action non-heap-usage

Output::

    Non-Heap used: 11.23% (83.5MiB of 744.0MiB), Non-Heap committed: 12.52% (93.1MiB of 744.0MiB)

States:

* WARN or CRIT if memory usage (used or committed) is above certain thresholds (default 80/90 %)

Perfdata:

* non-heap-committed: in bytes
* non-heap-committed-percent: in percent
* non-heap-max: in bytes
* non-heap-usage-percent: in percent
* non-heap-used: in bytes


Non-XA Datasource Stats
-----------------------

Never triggers an alarm.

.. code-block:: bash

    ./wildfly-stats --username wildfly-admin --password password --url http://wildfly:9990 --action non-xa-datasource

Output::

    Non-XA Datasources Statistics. H2DS - no interesting data, H2DSAA - no interesting data, H2DSxxx - no interesting data

States:

* Always returns OK

Perfdata:

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


Server Status
-------------

Triggers an alarm on its own.

.. code-block:: bash

    ./wildfly-stats --username wildfly-admin --password password --url http://wildfly:9990 --action server-status

Output::

    Server status "running", Launch Type STANDALONE, Running Mode NORMAL, v23.0.0.Final

States:

* OK: server-state == 'running'
* WARN: server-state in ['reload-required', 'restart-required']
* CRIT: everything else

Perfdata:

* server-state: 0 (STATE_OK), 1 (STATE_WARN), 2 (STATE_CRIT)


Threading Statistics
--------------------

Triggers an alarm on absolute values.

.. code-block:: bash

    ./wildfly-stats --username wildfly-admin --password password --url http://wildfly:9990 --warning 100 --critical 200  --action threading

Output::

    Threading Statistics - daemon-thread-count: 10, thread-count: 62

States:

* WARN or CRIT if thread counts are above certain thresholds (default 80/90).


Uptime
------

Triggers an alarm on uptime in days.

.. code-block:: bash

    ./wildfly-stats --username wildfly-admin --password password --url http://wildfly:9990 --warning 180 --critical 366 --action uptime

Output::

    Up 1h 11m

States:

* WARN or CRIT when uptime (the number of days) exceeds the thresholds (default 180/366 days)

Perfdata:

* uptime: seconds


XA Datasource Stats
-------------------

Never triggers an alarm.

.. code-block:: bash

    ./wildfly-stats --username wildfly-admin --password password --url http://wildfly:9990 --action xa-datasource

Output::

    XA Datasources Statistics. H2DS - no interesting data, H2DSAA - no interesting data, H2DSxxx - no interesting data

States:

* Always returns OK

Perfdata:

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

