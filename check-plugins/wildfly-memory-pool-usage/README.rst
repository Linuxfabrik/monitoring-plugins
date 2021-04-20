Check "wildfly-memory-pool-usage"
=================================

Overview
--------

This check plugin monitors the memory pool usage of a WildFly server, using its HTTP-JSON based API (JBossAS REST Management API). This allows us to monitor the application server without any additional configuration and installation - no need to deploy WAR-Agents like Jolokia. The plugin supports both standalone mode and domain mode.

Tested with WildFly 11 and WildFly 23.

We recommend running this check every minute.


Installation and Usage
----------------------

.. code-block:: bash

    ./wildfly-memory-pool-usage --username wildfly-admin --password password --url http://wildfly:9990 --warning 80 --critical 90

Output::

    8 Memory Pools checked, everything is ok.

    Heap:
    * G1_Eden_Space - Memory used: 0.0% (39.0MiB of unlimited), 45.0MiB committed
    * G1_Old_Gen - Memory used: 4.01% (20.5MiB of 512.0MiB max.), 29.0MiB committed
    * G1_Survivor_Space - Memory used: 0.0% (2.7MiB of unlimited), 3.0MiB committed

    Non-Heap:
    * CodeHeap_non-nmethods - Memory used: 23.53% (1.3MiB of 5.6MiB max.), 2.4MiB committed
    * Compressed_Class_Space - Memory used: 2.45% (5.1MiB of 208.0MiB max.), 5.6MiB committed
    * CodeHeap_profiled_nmethods - Memory used: 9.45% (11.1MiB of 117.2MiB max.), 12.2MiB committed
    * CodeHeap_non-profiled_nmethods - Memory used: 3.54% (4.2MiB of 117.2MiB max.), 4.2MiB committed
    * Metaspace - Memory used: 16.95% (43.4MiB of 256.0MiB max.), 44.6MiB committed


States
------

Triggers an alarm on usage in percent.

* WARN or CRIT if memory usage (used) is above certain thresholds (default 80/90 %)
* WARN if WildFly reports 'usage-threshold-exceeded' == TRUE


Perfdata
--------

* memory-pool-<name>-committed: Returns the amount of memory in bytes that is committed for the Java virtual machine to use. This amount of memory is guaranteed for the Java virtual machine to use.
* memory-pool-<name>-max: Returns the maximum amount of memory in bytes that can be used for memory management. This method returns -1 if the maximum memory size is undefined. This amount of memory is not guaranteed to be available for memory management if it is greater than the amount of committed memory. The Java virtual machine may fail to allocate memory even if the amount of used memory does not exceed this maximum size.
* memory-pool-<name>-used: The amount of used memory in bytes.
* memory-pool-<name>-used-percent: in percent


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see LICENSE file.
