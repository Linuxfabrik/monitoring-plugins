Check fortios-cpu-usage
=======================

Overview
--------

Returns the current system-wide CPU utilization as a percentage from a Forti Appliance like FortiGate running FortiOS, using the FortiOS REST API. Warns only if the overall CPU usage is above a certain threshold within the last n checks (default: 5). The authentication is done via a single API token (Token-based authentication), not via Session-based authentication, which is stated as "legacy".

Hints:

* This plugin tries to check against the global configured ``cpu-use-threshold`` first; only if there is no value, the check's command line values (or their defaults) are used.
* ``--count=5`` (the default) while checking every minute means that the check reports a warning if the overall CPU usage is above a threshold in the last 5 minutes.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70

    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/fortios-cpu-usage"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "No"
    "Available for",                        "Python 2, Python 3, Windows"
    "Requirements",                         "None"
    "Handles Periods",                      "Yes"
    "Uses SQLite DBs",                      "Yes"


Help
----

.. code-block:: text

    usage: fortios-cpu-usage [-h] [-V] [--always-ok] [--count COUNT] [-c CRIT] -H
                             HOSTNAME [--insecure] [--no-proxy] --password
                             PASSWORD [--timeout TIMEOUT] [-w WARN]

    Returns the current system-wide CPU utilization as a percentage from Forti
    Appliances like FortiGate running FortiOS via FortiOS REST API. Warns only if
    the overall CPU usage is above a certain threshold within the last n checks
    (default: 5). The authentication is done via a single API token (Token-based
    authentication), not via Session-based authentication, which is stated as
    "legacy". Hint: This plugin tries to check against the global configured `cpu-
    use-threshold` first; only if there is no value, the check's command line
    values (or their defaults) are used.

    optional arguments:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      --count COUNT         Number of times the value has to be above the given
                            thresholds. Default: 5
      -c CRIT, --critical CRIT
                            Set the critical threshold CPU Usage Percentage.
                            Default: 90
      -H HOSTNAME, --hostname HOSTNAME
                            FortiOS-based Appliance address, optional including
                            port ("192.168.1.1:443").
      --insecure            This option explicitly allows to perform "insecure"
                            SSL connections. Default: False
      --no-proxy            Do not use a proxy. Default: False
      --password PASSWORD   FortiOS REST API Single Access Token.
      --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
      -w WARN, --warning WARN
                            Set the warning threshold CPU Usage Percentage.
                            Default: 80


Usage Examples
--------------

.. code-block:: bash

    ./fortios-cpu-usage --hostname fortigate-cluster.linuxfabrik.io --password mypass --count=15 --warning=50 --critical=70

Output:

.. code-block:: text

    0%


States
------

* OK if overall ``cpu-usage`` is below the thresholds within the last ``--count`` checks.
* Otherwise CRIT or WARN.


Perfdata / Metrics
------------------

* ``cpu-usage``: The overall cpu usage.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
