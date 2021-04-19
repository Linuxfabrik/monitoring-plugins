Check "wildfly-non-xa-datasource-stats"
=======================================

Overview
--------

This check plugin returns metrics of Non-XA datasources of a WildFly server, using its HTTP-JSON based API (JBossAS REST Management API). This allows us to monitor the application server without any additional configuration and installation - no need to deploy WAR-Agents like Jolokia. The plugin supports both standalone mode and domain mode.

Tested with WildFly 11 and WildFly 23.

We recommend running this check every minute.


Installation and Usage
----------------------

.. code-block:: bash

    ./wildfly-non-xa-datasource-stats --username wildfly-admin --password password --url http://wildfly:9990 --warning 80 --critical 90

Output::

    MyFirstDS: 0.0% active used (0/20), 0.0% max used (0/20); Statistics are not enabled for data source MySecondDS


States
------

Triggers an alarm on usage in percent.

* WARN or CRIT if active or max used datapool connections are above certain thresholds (default 80/90%).


Perfdata
--------

* non-xa-ds-<name>-active
* non-xa-ds-<name>-active-pct: Usage in Percent
* non-xa-ds-<name>-blockingfailurecount
* non-xa-ds-<name>-createdcount
* non-xa-ds-<name>-destroyedcount
* non-xa-ds-<name>-idlecount
* non-xa-ds-<name>-inusecount
* non-xa-ds-<name>-maxused
* non-xa-ds-<name>-maxused-pct: Usage in Percent
* non-xa-ds-<name>-maxwaitcount
* non-xa-ds-<name>-waitcount
* non-xa-ds-<name>-xacommitcount
* non-xa-ds-<name>-xaendcount
* non-xa-ds-<name>-xaforgetcount
* non-xa-ds-<name>-xapreparecount
* non-xa-ds-<name>-xarecovercount
* non-xa-ds-<name>-xarollbackcount
* non-xa-ds-<name>-xastartcount


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see LICENSE file.
