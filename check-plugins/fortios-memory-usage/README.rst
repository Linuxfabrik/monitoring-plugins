Check efortios-memory-usage
===========================

Overview
--------

Returns the current system-wide memory utilization as a percentage from a Forti Appliance like FortiGate running FortiOS, using the FortiOS REST API. The authentication is done via a single API token (Token-based authentication), not via Session-based authentication, which is stated as "legacy".

Hints:

* This plugin tries to check against the global configured ``memory-use-threshold-green`` and ``memory-use-threshold-red`` first; only if there is no value, the check's command line values are used.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/fortios-memory-usage"
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

    ./fortios-memory-usage --hostname fortigate-cluster.linuxfabrik.io --password sSEaTjuNbPYW5yepUD2JtDhyykY59D --warning=50 --critical=70
    
Output:

.. code-block:: text

    TODOVM Output


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
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
