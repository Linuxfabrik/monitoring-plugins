Check fortios-firewall-stats
============================

Overview
--------

Summarizes traffic statistics for all IPv4 and IPv6 firewall policies from Forti Appliances like a Forti Appliance like FortiGate running FortiOS, using the FortiOS REST API. The authentication is done via a single API token (Token-based authentication), not via Session-based authentication, which is stated as "legacy".


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/fortios-firewall-stats"
    "Check Interval Recommendation",        "Once a minute"
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

    ./fortios-firewall-stats --hostname fortigate-cluster.linuxfabrik.io --password sSEaTjuNbPYW5yepUD2JtDhyykY59D
    
Output:

.. code-block:: text

    TODOVM Output


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
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
