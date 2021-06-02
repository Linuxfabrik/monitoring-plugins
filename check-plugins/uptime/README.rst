Check uptime
============

Overview
--------

Checks and tells how long the system has been running (in days).


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/uptime"
    "Check Interval Recommendation",        "Every 5 minutes"
    "Available for",                        "Python 2, Python 3, Windows"
    "Requirements",                         "Python2 module ``psutil``, command-line tool ``foo``"
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

    ./uptime
    ./uptime --always-ok
    ./uptime --warning 180 --critical 366
    
Output:

.. code-block:: text

    TODOVM Output


States
------

* WARN or CRIT if system uptime is above a given threshold.


Perfdata / Metrics
------------------

* Uptime (seconds)


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
