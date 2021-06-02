Check swap-usage
================

Overview
--------

Displays amount of free and used swap space in the system, checks against used swap in percent.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/swap-usage"
    "Check Interval Recommendation",        "Once a minute"
    "Available for",                        "Python 2"
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

    ./swap-usage
    ./swap-usage --warning 70 --critical 90
    
Output:

.. code-block:: text

    TODOVM Output


States
------

* WARN or CRIT if swap usage is above a given threshold.


Perfdata / Metrics
------------------

* Swap Usage (%)
* Total Swap Space (Bytes)
* Used (Bytes)
* Free (Bytes)
* Swap In (Bytes)
* Swap Out (Bytes)


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
