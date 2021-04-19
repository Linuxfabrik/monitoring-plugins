Check "wildfly-gc-status"
=========================

Overview
--------

This check plugin monitors the garbage collector of a WildFly server, using its HTTP-JSON based API (JBossAS REST Management API). This allows us to monitor the application server without any additional configuration and installation - no need to deploy WAR-Agents like Jolokia. The plugin supports both standalone mode and domain mode.

Tested with WildFly 11 and WildFly 23.

We recommend running this check every minute.


Installation and Usage
----------------------

.. code-block:: bash

    ./wildfly-gc-status --username wildfly-admin --password password --url http://wildfly:9990 --warning 500 --critical 1000

Output::

    GC Statistics (time/count/avg). PS_MarkSweep: 143/1/143.0, PS_Scavenge: 105/8/13.0


States
------

Triggers an alarm on absolute values.

* WARN or CRIT if any Garbage Collector "Average Time" is above certain thresholds (default 500/1000)


Perfdata
--------

* garbage-collector-<name>-collection-count
* garbage-collector-<name>-collection-time
* garbage-collector-<name>-collection-avgtime: gc_time / gc_count


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see LICENSE file.
