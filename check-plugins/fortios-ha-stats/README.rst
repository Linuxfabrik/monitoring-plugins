Check fortios-ha-stats
======================

Overview
--------

Returns statistics for members of HA cluster from a Forti Appliance like FortiGate running FortiOS, using the FortiOS REST API. Warns if the number of HA members is more or less than expected (default: 2). The authentication is done via a single API token (Token-based authentication), not via Session-based authentication, which is stated as "legacy".


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70

    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/fortios-ha-stats"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "No"
    "Compiled for",                         "Linux, Windows"
    "Handles Periods",                      "Yes"


Help
----

.. code-block:: text

    usage: fortios-ha-stats [-h] [-V] [--always-ok] [--count COUNT] -H HOSTNAME
                            [--insecure] [--no-proxy] --password PASSWORD
                            [--timeout TIMEOUT]

    Returns statistics for members of HA cluster from Forti Appliances like
    FortiGate running FortiOS via FortiOS REST API. Warns if the number of HA
    members is more or less than expected (default: 2). The authentication is done
    via a single API token (Token-based authentication), not via Session-based
    authentication, which is stated as "legacy".

    optional arguments:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      --count COUNT         Number of expected cluster members. Default: 2
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

    ./fortios-ha-stats --hostname fortigate-cluster.linuxfabrik.io --password mypass --count 2

Output:

.. code-block:: text

    Found 2 HA cluster members, which handled 87458 sessions and 187.0TiB traffic so far.


States
------

* If wanted, always returns OK,
* else returns WARN if there are more or less cluster members than expected.


Perfdata / Metrics
------------------

For example:

* ``node1_sessions``
* ``node1_net_usage``
* ``node1_tbyte``
* ``node1_cpu_usage``
* ``node1_mem_usage``
* ``node2_sessions``
* ``node2_net_usage``
* ``node2_tbyte``
* ``node2_cpu_usage``
* ``node2_mem_usage``


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
