Check fortios-ha-stats
======================

Overview
--------

Returns statistics for members of HA cluster from a Forti Appliance like FortiGate running FortiOS, using the FortiOS REST API. Warns if the number of HA members is more or less than expected (default: 2). The authentication is done via a single API token (Token-based authentication), not via Session-based authentication, which is stated as "legacy".


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/fortios-ha-stats"
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

    ./fortios-ha-stats --hostname fortigate-cluster.linuxfabrik.io --password sSEaTjuNbPYW5yepUD2JtDhyykY59D --count 2
    
Output:

.. code-block:: text

    TODOVM Output


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
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
