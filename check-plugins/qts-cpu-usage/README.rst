Check eqts-cpu-usage
====================

Overview
--------

Returns the current system-wide CPU utilization as a percentage from a QNAP Appliance running QTS, using the HTTP API. Warns only if the overall CPU usage is above a certain threshold within the last n checks (default: 5).

Hints and Recommendations:
* ``--count=5`` (the default) while checking every minute means that the check reports a warning if the overall CPU usage is above a threshold in the last 5 minutes.
* Check uses a SQLite database in ``/tmp`` to store its historical data.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/qts-cpu-usage"
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

    ./qts-cpu-usage --url http://192.168.1.100:8080 --username admin --password my-password
    
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
