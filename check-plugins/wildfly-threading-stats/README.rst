Check "wildfly-threading-stats"
===============================

Overview
--------

This check plugin monitors the thread statistics of a WildFly server, using its HTTP-JSON based API (JBossAS REST Management API). This allows us to monitor the application server without any additional configuration and installation - no need to deploy WAR-Agents like Jolokia. The plugin supports both standalone mode and domain mode.

Tested with WildFly 11 and WildFly 23.


Installation and Usage
----------------------

.. code-block:: bash

    ./wildfly-threading-stats --username wildfly-admin --password password --url http://wildfly:9990 --warning 100 --critical 200

Output::

    Threading Statistics. daemon-thread-count: 18, thread-count: 56


States
------

Triggers an alarm on absolute values.

* WARN or CRIT if thread counts are above certain thresholds (default 100/200).


Perfdata
--------

* threading-daemon-thread-count
* threading-thread-count


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see LICENSE file.
