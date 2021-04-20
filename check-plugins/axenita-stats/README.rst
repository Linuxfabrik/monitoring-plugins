Check "axenita-stats"
=====================

Overview
--------

With this plugin you can track some values of the Axenita application, currently focusing on "Achilles". Axenita Praxissoftware is powered by Axonlab / Axon Lab AG.


Installation and Usage
----------------------

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


Perfdata
--------

* axenita-version: 14.0.8 is reported as "1408"
* currentActiveSessions
* currentInitRmStep
* loggedInUsers
* maintenance: 0 = no/false, 1 = yes/true
* totalDurationInitRm
* totalInitRmSteps


Hints and Recommendations
-------------------------

* Currently not evaluating:

    * startTimeInitRm
    * startTimeCurrentInitRmStep
    * startTimeInitRmSteps


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see LICENSE file.
