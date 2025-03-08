Check hin-status
================

Overview
--------

Retrieves the HIN status page from https://support.hin.ch/de/ and searches for out-of-service messages. Unfortunately there is no machine-readable version yet, so the plugin has to rely on the WordPress-generated HTML content.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70

    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/hin-status"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "Yes"
    "Compiled for",                         "Linux, Windows"
    "3rd Party Python modules",             "``beautifulsoup``"


Help
----

.. code-block:: text

    usage: hin-status [-h] [-V] [--always-ok] [--insecure] [--no-proxy]
                      [--test TEST] [--timeout TIMEOUT] [--url URL]

    Retrieves the HIN status page from https://support.hin.ch/de/ and searches for
    out-of-service messages. Unfortunately there is no machine-readable version
    yet, so the plugin has to rely on the WordPress-generated HTML content.

    options:
      -h, --help         show this help message and exit
      -V, --version      show program's version number and exit
      --always-ok        Always returns OK.
      --insecure         This option explicitly allows to perform "insecure" SSL
                         connections. Default: False
      --no-proxy         Do not use a proxy. Default: False
      --test TEST        For unit tests. Needs "path-to-stdout-file,path-to-
                         stderr-file,expected-retc".
      --timeout TIMEOUT  Network timeout in seconds. Default: 8 (seconds)
      --url URL          HIN Status Page URL. Default: https://support.hin.ch/de/


Usage Examples
--------------

.. code-block:: bash

    ./hin-status

Output:

.. code-block:: text

    Incidents: Störung beim Einlesen von Krankenkassenkarten. See https://support.hin.ch/de/ for details.


States
------

* WARN if out-of-service messages are found


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1

    Name,                                       Type,               Description                                           
    cnt_incidents,                              Number,             "``1`` if out-of-service messages are found, ``0`` otherwise"


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
