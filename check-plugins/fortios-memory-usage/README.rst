Check fortios-memory-usage
==========================

Overview
--------

Returns the current system-wide memory utilization as a percentage from a Forti Appliance like FortiGate running FortiOS, using the FortiOS REST API. The authentication is done via a single API token (Token-based authentication), not via Session-based authentication, which is stated as "legacy".

Hints:

* This plugin tries to check against the global configured ``memory-use-threshold-green`` and ``memory-use-threshold-red`` first; only if there is no value, the check's command line values are used.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70

    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/fortios-memory-usage"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "No"
    "Compiled for",                         "Linux, Windows"


Help
----

.. code-block:: text

    usage: fortios-memory-usage [-h] [-V] [--always-ok] [-c CRIT] -H HOSTNAME
                                [--insecure] [--no-proxy] --password PASSWORD
                                [--timeout TIMEOUT] [-w WARN]

    Displays amount of used memory in percent, and checks against configured or
    given thresholds.

    options:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      -c CRIT, --critical CRIT
                            Set the critical threshold for memory usage (in
                            percent). Hint: This plugin tries to check against the
                            global configured `memory-use-threshold-green` and
                            `memory-use-threshold-red` first; only if there is no
                            value, the check's command line values are used.
                            Default: 88
      -H HOSTNAME, --hostname HOSTNAME
                            FortiOS-based Appliance address, optional including
                            port ("192.168.1.1:443").
      --insecure            This option explicitly allows to perform "insecure"
                            SSL connections. Default: False
      --no-proxy            Do not use a proxy. Default: False
      --password PASSWORD   FortiOS REST API Single Access Token.
      --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
      -w WARN, --warning WARN
                            Set the warning threshold for memory usage (in
                            percent). Hint: This plugin tries to check against the
                            global configured `memory-use-threshold-green` and
                            `memory-use-threshold-red` first; only if there is no
                            value, the check's command line values are used.
                            Default: 82


Usage Examples
--------------

.. code-block:: bash

    ./fortios-memory-usage --hostname fortigate-cluster.linuxfabrik.io --password mypass --warning=50 --critical=70

Output:

.. code-block:: text

    1%


States
------

* OK if overall `memory-usage` is below the thresholds.
* Otherwise CRIT or WARN.


Perfdata / Metrics
------------------

* ``usage_percent``: The overall memory usage.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
