Check "wildfly-xa-datasource-stats"
===================================

Overview
--------

This check plugin returns metrics of XA datasources of a WildFly server, using its HTTP-JSON based API (JBossAS REST Management API). This allows us to monitor the application server without any additional configuration and installation - no need to deploy WAR-Agents like Jolokia. The plugin supports both standalone mode and domain mode.

Tested with WildFly 11 and WildFly 23.

We recommend running this check every minute.


Installation and Usage
----------------------

.. code-block:: bash

    ./wildfly-xa-datasource-stats --username wildfly-admin --password password --url http://wildfly:9990 --warning 80 --critical 90

Output::

    MyFirstDS: 0.0% active used (0/20), 0.0% max used (0/20); Statistics are not enabled for data source MySecondDS


States
------

Triggers an alarm on usage in percent.

* WARN or CRIT if active or max used datapool connections are above certain thresholds (default 80/90%).


Perfdata
--------

* xa-ds-<name>-active
* xa-ds-<name>-active-pct: Usage in Percent
* xa-ds-<name>-blockingfailurecount
* xa-ds-<name>-createdcount
* xa-ds-<name>-destroyedcount
* xa-ds-<name>-idlecount
* xa-ds-<name>-inusecount
* xa-ds-<name>-maxused
* xa-ds-<name>-maxused-pct: Usage in Percent
* xa-ds-<name>-maxwaitcount
* xa-ds-<name>-waitcount
* xa-ds-<name>-xacommitcount
* xa-ds-<name>-xaendcount
* xa-ds-<name>-xaforgetcount
* xa-ds-<name>-xapreparecount
* xa-ds-<name>-xarecovercount
* xa-ds-<name>-xarollbackcount
* xa-ds-<name>-xastartcount


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see LICENSE file.
