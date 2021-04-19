Check "wildfly-memory-usage"
============================

Overview
--------

This check plugin monitors the heap and non-heap memory usage of a WildFly server, using its HTTP-JSON based API (JBossAS REST Management API). This allows us to monitor the application server without any additional configuration and installation - no need to deploy WAR-Agents like Jolokia. The plugin supports both standalone mode and domain mode.

Tested with WildFly 11 and WildFly 23.

We recommend running this check every minute.


Installation and Usage
----------------------

.. code-block:: bash

    ./wildfly-memory-usage --username wildfly-admin --password password --url http://wildfly:9990 --warning 80 --critical 90

Output::

    Heap used: 18.04% (82.2MiB of 455.5MiB), Heap committed: 44.35% (202.0MiB of 455.5MiB), Non-Heap used: 14.56% (108.3MiB of 744.0MiB), Non-Heap committed: 16.25% (120.9MiB of 744.0MiB)


States
------

Triggers an alarm on usage in percent.

* WARN or CRIT if memory usage (used or committed, heap or non-heap) is above certain thresholds (default 80/90%)


Perfdata
--------

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
* License: The Unlicense, see LICENSE file.
