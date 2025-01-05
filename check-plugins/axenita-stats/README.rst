Check axenita-stats
===================

Overview
--------

With this plugin you can track some values of the Axenita application, currently focusing on "Achilles". Axenita Praxissoftware is powered by Axonlab / Axon Lab AG.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70

    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/axenita-stats"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "Yes"
    "Compiled for",                         "Linux, Windows"


Help
----

.. code-block:: text

    usage: axenita-stats [-h] [-V] [--always-ok] [--insecure] [--no-proxy]
                         [--test TEST] [--timeout TIMEOUT] [--url URL]

    With this plugin you can track some values of the Axenita application.

    options:
      -h, --help         show this help message and exit
      -V, --version      show program's version number and exit
      --always-ok        Always returns OK.
      --insecure         This option explicitly allows to perform "insecure" SSL
                         connections. Default: False
      --no-proxy         Do not use a proxy. Default: False
      --test TEST        For unit tests. Needs "path-to-stdout-file,path-to-
                         stderr-file,expected-retc".
      --timeout TIMEOUT  Network timeout in seconds. Default: 3 (seconds)
      --url URL          Axenita API URL. Default:
                         http://localhost:10000/achilles/ar


Usage Examples
--------------

.. code-block:: bash

    ./axenita-stats --url http://localhost:10000/achilles/ar --timeout 3


States
------

Alerts if

* achilles_buildinfo['state'] != 'SUCCESS'
* achilles_maintenance['data'] != False
* achilles_maintenance['state'] != 'SUCCESS'
* achilles_readmodel['data']['readModelState'] != 'DONE'
* achilles_readmodel['state'] != 'SUCCESS'
* achilles_userinfo['state'] != 'SUCCESS'


Perfdata / Metrics
------------------

* axenita-version: 14.0.8 is reported as "1408"
* currentActiveSessions
* currentInitRmStep
* loggedInUsers
* maintenance: 0 = no/false, 1 = yes/true
* totalDurationInitRm
* totalInitRmSteps


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
