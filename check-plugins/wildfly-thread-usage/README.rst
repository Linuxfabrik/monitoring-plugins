Check "wildfly-thread-usage"
============================

Overview
--------

This check plugin monitors the thread statistics of a WildFly server, using its HTTP-JSON based API (JBossAS REST Management API). This allows us to monitor the application server without any additional configuration and installation - no need to deploy WAR-Agents like Jolokia. The plugin supports both standalone mode and domain mode.

Tested with WildFly 11 and WildFly 23.

We recommend running this check every minute.


Installation and Usage
----------------------

.. code-block:: bash

    ./wildfly-thread-usage --username wildfly-admin --password password --url http://wildfly:9990 --warning 80 --critical 90

Output::

    32.1% used (18/56 threads)


States
------

Triggers an alarm on usage in percent.

* WARN or CRIT if thread counts are above certain thresholds (default 80/90%).


Perfdata
--------

* thread-pct
* thread-count


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see LICENSE file.
