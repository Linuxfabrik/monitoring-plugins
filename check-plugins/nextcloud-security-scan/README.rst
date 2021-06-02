Check nextcloud-security-scan
=============================

Overview
--------

Checks the security of your private cloud server using Nextcloud Security Scan from https://scan.nextcloud.com/, so the check itself does not need to run on the same host that serves Nextcloud. Triggers a rescan on https://scan.nextcloud.com/ if result is older than 14 days (default). Have a look at https://scan.nextcloud.com/ for further explanation. 

Works with ownCloud, too.

Known Issues and Limitations:
* Run it once a day max. There is an API limit at the scan.nextcloud.com server at the /api/queue endpoint with less than 100 POST requests a day (you will then run into a "403 Forbidden").
* ``--noproxy`` not implemented
* ``--insecure`` not implemented

Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/nextcloud-security-scan"
    "Check Interval Recommendation",        "Once a day or week"
    "Available for",                        "Python 2"
    "Requirements",                         "Python module ``psutil``, command-line tool ``foo``"
    "Handles Periods",                      "Yes"
    "Uses SQLite DBs",                      "Yes"
    "Perfdata compatible with Prometheus",  "Yes"


Help
----

.. code-block:: text

    usage: example [-h] [-V]

    Example Check.

    optional arguments:
      -h, --help       show this help message and exit
      -V, --version    show program's version number and exit


Usage Examples
--------------

.. code-block:: bash

    ./nextcloud-security-scan --url cloud.linuxfabrik.io
    ./nextcloud-security-scan --url cloud.linuxfabrik.io --timeout 1 --trigger 10
    
Output:

.. code-block:: text

    TODOVM Output


States
------

* CRIT if Nextcloud Rating is F, E.
* WARN if Nextcloud Rating is D, C.
* Otherwise OK.


Perfdata / Metrics
------------------

There is no perfdata.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
