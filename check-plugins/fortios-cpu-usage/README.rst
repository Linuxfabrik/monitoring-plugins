Check fortios-cpu-usage
=======================

Overview
--------

Returns the current system-wide CPU utilization as a percentage from a Forti Appliance like FortiGate running FortiOS, using the FortiOS REST API. Warns only if the overall CPU usage is above a certain threshold within the last n checks (default: 5). The authentication is done via a single API token (Token-based authentication), not via Session-based authentication, which is stated as "legacy".

Hints:

* This plugin tries to check against the global configured ``cpu-use-threshold`` first; only if there is no value, the check's command line values (or their defaults) are used.
* ``--count=5`` (the default) while checking every minute means that the check reports a warning if the overall CPU usage is above a threshold in the last 5 minutes.
* Check uses a SQLite database in ``/tmp`` to store its historical data.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/fortios-cpu-usage"
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

    ./fortios-cpu-usage --hostname fortigate-cluster.linuxfabrik.io --password sSEaTjuNbPYW5yepUD2JtDhyykY59D --count=15 --warning=50 --critical=70
    
Output:

.. code-block:: text

    TODOVM Output


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
