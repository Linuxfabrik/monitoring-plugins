Check "wildfly-deployment-status"
=================================

Overview
--------

This check plugin monitors the deployment status of a WildFly server, using its HTTP-JSON based API (JBossAS REST Management API). This allows us to monitor the application server without any additional configuration and installation - no need to deploy WAR-Agents like Jolokia. The plugin supports both standalone mode and domain mode.

Tested with WildFly 11 and WildFly 23.


Installation and Usage
----------------------

.. code-block:: bash

    ./wildfly-deployment-status --username wildfly-admin --password password --url http://wildfly:9990

Output::

    2 Deployments checked, everything is ok.

    * myapp1.war is OK
    * myapp2.war is RUNNING


States
------

Triggers an alarm on its own.

* OK: app state in ['OK', 'RUNNING']
* WARN: app state in ['STOPPED']
* CRIT: everything else


Perfdata
--------

* deployment-state-<name>: 0 (STATE_OK), 1 (STATE_WARN), 2 (STATE_CRIT)


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see LICENSE file.
