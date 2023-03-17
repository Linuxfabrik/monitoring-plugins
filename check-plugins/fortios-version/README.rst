Check fortios-version
=====================

Overview
--------

This plugin lets you track if an FortiOS update for a Forti Appliance like FortiGate is available, using the FortiOS REST API.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70

    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/fortios-version"
    "Check Interval Recommendation",        "Once a day"
    "Can be called without parameters",     "No"
    "Compiled for",                         "Linux, Windows"


Help
----

.. code-block:: text

    usage: fortios-version [-h] [-V] [--always-ok] -H HOSTNAME [--insecure]
                           [--no-proxy] --password PASSWORD [--timeout TIMEOUT]

    optional arguments:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      -H HOSTNAME, --hostname HOSTNAME
                            FortiOS-based Appliance address, optional including
                            port ("192.168.1.1:443").
      --insecure            This option explicitly allows to perform "insecure"
                            SSL connections. Default: False
      --no-proxy            Do not use a proxy. Default: False
      --password PASSWORD   FortiOS REST API Single Access Token.
      --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)


Usage Examples
--------------

.. code-block:: bash

    ./fortios-version --hostname fortigate-cluster.linuxfabrik.io --password mypass

Output:

.. code-block:: text

    FortiOS v6.2.7 is up to date


States
------

* If wanted, always returns OK,
* else returns WARN if update is available.


Perfdata / Metrics
------------------

There is no perfdata.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
