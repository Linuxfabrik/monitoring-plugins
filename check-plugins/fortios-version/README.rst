Check fortios-version
=====================

Overview
--------

This plugin lets you track if FortiOS is End-of-Life (EOL). To compare against the current/installed version of FortiOS, the check has to fetch the REST API of the FortiOS appliance.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/fortios-version"
    "Check Interval Recommendation",        "Once a day"
    "Can be called without parameters",     "Yes"
    "Compiled for",                         "Linux, Windows"


Help
----

.. code-block:: text

    usage: fortios-version [-h] [-V] [--always-ok] -H HOSTNAME [--insecure]
                           [--no-proxy] --password PASSWORD [--timeout TIMEOUT]

    Tracks if FortiOS is EOL.

    options:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      -H HOSTNAME, --hostname HOSTNAME
                            FortiOS-based Appliance address, optional including
                            port ("192.0.2.1:443").
      --insecure            This option explicitly allows to perform "insecure"
                            SSL connections. Default: False
      --no-proxy            Do not use a proxy. Default: False
      --password PASSWORD   FortiOS REST API Single Access Token.
      --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)


Usage Examples
--------------

.. code-block:: bash

    ./fortios-version --hostname fortigate-cluster.example.com --password mypass

Output:

.. code-block:: text

    FortiOS v6.0.1 (EOL 2022-09-29) [WARNING]


States
------

* If wanted, always returns OK,
* else returns WARN if Software is EOL


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description                                           
    fortios-version,                            Number,             Installed FortiOS version as float. "6.0.1" becomes "6.01".


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
