Check sensors-fans
===================

Overview
--------

Return hardware fans speed. Fan speed is expressed in RPM (rounds per minute). OK if no fans are found.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/sensors-fans"
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

    ./sensors-fans --warning 10000 --critical 20000
    
Output:

.. code-block:: text

    TODOVM Output


States
------

* WARN or CRIT if fan speed (RPM) is above a given threshold.


Perfdata / Metrics
------------------

* for each fan: its speed (RPM)


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
* Credits: https://github.com/giampaolo/psutil/blob/master/scripts/fans.py
