Check qts-memory-usage
======================

Overview
--------

Returns the current system-wide memory utilization as a percentage from a QNAP Appliance running QTS, using the HTTP API.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/qts-memory-usage"
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

    ./qts-memory-usage --url http://192.168.1.100:8080 --username admin --password my-password
    
Output:

.. code-block:: text

    TODOVM Output


States
------

* OK if overall ``memory-usage`` is below the thresholds.
* Otherwise CRIT or WARN.


Perfdata / Metrics
------------------

* ``memory-usage``: The overall memory usage.
* ``free``: The free memory.
* ``total``: The total memory.
* ``used``: The used memory.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
