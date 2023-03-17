Check nextcloud-security-scan
=============================

Overview
--------

Checks the security of your private cloud server using Nextcloud Security Scan from https://scan.nextcloud.com/, so the check itself does not need to run on the same host that serves Nextcloud. Triggers a rescan on https://scan.nextcloud.com/ if result is older than 14 days (default). Have a look at https://scan.nextcloud.com/ for further explanation. Works with ownCloud, too.

Hints:

* Run it once a day max. There is an API limit at the scan.nextcloud.com server at the /api/queue endpoint with less than 100 POST requests a day (you will then run into a "403 Forbidden").
* ``--noproxy`` not implemented
* ``--insecure`` not implemented


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/nextcloud-security-scan"
    "Check Interval Recommendation",        "Once a day or week"
    "Can be called without parameters",     "No"
    "Compiled for",                         "Linux, Windows"


Help
----

.. code-block:: text

    usage: nextcloud-security-scan [-h] [-V] [--timeout TIMEOUT]
                                   [--trigger TRIGGER] -u URL

    Checks the security of your private Nextcloud server.

    optional arguments:
      -h, --help         show this help message and exit
      -V, --version      show program's version number and exit
      --timeout TIMEOUT  Network timeout in seconds. Default: 7 (seconds)
      --trigger TRIGGER  Trigger re-scan of the Nextcloud server if result on
                         scan.nextcloud.com is older than n days. Default: 14
                         (days)
      -u URL, --url URL  Nextcloud API URL, for example "cloud.linuxfabrik.io".


Usage Examples
--------------

.. code-block:: bash

    ./nextcloud-security-scan --url cloud.linuxfabrik.io --timeout 1 --trigger 10
    
Output:

.. code-block:: text

    "A+" rating for cloud.linuxfabrik.io, checked at 2021-06-04, on Nextcloud v21.0.2.1.


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
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
