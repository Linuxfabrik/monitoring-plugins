Check "wildfly-server-status"
=============================

Overview
--------

This check plugin monitors a WildFly server, using its HTTP-JSON based API (JBossAS REST Management API). This allows us to monitor the application server without any additional configuration and installation - no need to deploy WAR-Agents like Jolokia. The plugin supports both standalone mode and domain mode.

Tested with WildFly 11 and WildFly 23.

We recommend running this check every minute.


Installation and Usage
----------------------

.. code-block:: bash

    ./wildfly-server-status --username wildfly-admin --password password --url http://wildfly:9990

Output::

    Server status "running", Launch Type STANDALONE, Running Mode NORMAL, v23.0.0.Final


States
------

Triggers an alarm on its own.

* OK: server-state == 'running'
* WARN: server-state in ['reload-required', 'restart-required']
* CRIT: everything else


Perfdata
--------

* server-state: 0 (STATE_OK), 1 (STATE_WARN), 2 (STATE_CRIT)


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see LICENSE file.
