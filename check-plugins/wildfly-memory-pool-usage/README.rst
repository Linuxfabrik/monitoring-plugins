Check "wildfly-memory-pool-usage"
=================================

Overview
--------

This check plugin monitors the memory pool usage of a WildFly server, using its HTTP-JSON based API (JBossAS REST Management API). This allows us to monitor the application server without any additional configuration and installation - no need to deploy WAR-Agents like Jolokia. The plugin supports both standalone mode and domain mode.

Tested with WildFly 11 and WildFly 23.


Installation and Usage
----------------------

.. code-block:: bash

    ./wildfly-memory-pool-usage --username wildfly-admin --password password --url http://wildfly:9990 --warning 80 --critical 90

Output::

    6 Memory Pools checked, there are errors.

    * PS_Old_Gen - Memory used: 12.48% (42.6MiB of 341.5MiB), Memory committed: 21.08% (72.0MiB of 341.5MiB)
    * PS_Survivor_Space - Memory used: 30.54% (7.8MiB of 25.5MiB), Memory committed: 100.0% (25.5MiB of 25.5MiB)
    * Compressed_Class_Space - Memory used: 2.99% (7.4MiB of 248.0MiB), Memory committed: 3.83% (9.5MiB of 248.0MiB)
    * Code_Cache - Memory used: 6.69% (16.1MiB of 240.0MiB), Memory committed: 6.82% (16.4MiB of 240.0MiB)
    * PS_Eden_Space - Memory used: 91.91% (110.8MiB of 120.5MiB) [CRITICAL], Memory committed: 100.0% (120.5MiB of 120.5MiB)
    * Metaspace - Memory used: 23.43% (60.0MiB of 256.0MiB), Memory committed: 26.27% (67.2MiB of 256.0MiB)


States
------

Triggers an alarm on usage in percent.

* WARN or CRIT if memory usage (used) is above certain thresholds (default 80/90 %)
* WARN if WildFly reports 'collection-usage-threshold-exceeded' == TRUE


Perfdata
--------

* memory-pool-<name>-committed: in bytes
* memory-pool-<name>-committed-percent: in percent
* memory-pool-<name>-max: in bytes
* memory-pool-<name>-used: in bytes
* memory-pool-<name>-used-percent: in percent


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see LICENSE file.
