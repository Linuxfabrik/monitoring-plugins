Check axenita-stats
===================

Overview
--------

With this plugin you can track some values of the Axenita application, currently focusing on "Achilles". Axenita Praxissoftware is powered by Axonlab / Axon Lab AG.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/axenita-stats"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "Yes"
    "Available for",                        "Python 2, Python 3"
    "Requirements",                         "None"


Help
----

.. code-block:: text

    usage: axenita-stats [-h] [-V] [--always-ok] [--url URL] [--test TEST]
                          [--timeout TIMEOUT]

    With this plugin you can track some values of the Aexnita application.

    optional arguments:
      -h, --help         show this help message and exit
      -V, --version      show program's version number and exit
      --always-ok        Always returns OK.
      --url URL          Axenita API URL. Default:
                         http://localhost:10000/achilles/ar
      --test TEST        For unit tests. Needs "path-to-stdout-file,path-to-
                         stderr-file,expected-retc".
      --timeout TIMEOUT  Network timeout in seconds. Default: 3 (seconds)


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
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
