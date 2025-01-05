Check fortios-firewall-stats
============================

Overview
--------

Summarizes traffic statistics for all IPv4 and IPv6 firewall policies from Forti Appliances like FortiGate running FortiOS, using the FortiOS REST API. The authentication is done via a single API token (Token-based authentication), not via Session-based authentication, which is stated as "legacy".


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70

    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/fortios-firewall-stats"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "No"
    "Compiled for",                         "Linux, Windows"


Help
----

.. code-block:: text

    usage: fortios-firewall-stats [-h] [-V] [--always-ok] -H HOSTNAME [--insecure]
                                  [--no-proxy] --password PASSWORD
                                  [--timeout TIMEOUT]

    Summarizes traffic statistics for all IPv4 and IPv6 firewall policies from
    Forti Appliances like FortiGate running FortiOS via FortiOS REST API. The
    authentication is done via a single API token (Token-based authentication),
    not via Session-based authentication, which is stated as "legacy".

    options:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      -H, --hostname HOSTNAME
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

    ./fortios-firewall-stats --hostname fortigate-cluster.linuxfabrik.io --password mypass

Output:

.. code-block:: text

    2 policies, 0 sessions (0 active), 21 hits, 1.8KiB bytes (1.8KiB software, 0.0B asic, 0.0B nturbo)


States
------

* Always returns OK.


Perfdata / Metrics
------------------

For example:

* ``total_active_sessions``
* ``total_asic_bytes``
* ``total_bytes``
* ``total_hit_count``
* ``total_nturbo_bytes``
* ``total_session_count``
* ``total_software_bytes``


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
