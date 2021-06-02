Check sensors-temperatures
==========================

Overview
--------

Return certain hardware temperature sensors (it may be a CPU, an hard disk or something else, depending on the OS and its configuration). All temperatures are expressed in celsius. Check is done automatically against hardware thresholds. If sensors are not supported by the OS OK is returned.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/sensors-temperatures"
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

    ./sensors-temperatures
    
Output:

.. code-block:: text

    TODOVM Output


States
------

* WARN or CRIT if temperature for a sensor is above a given hardware threshold (automatically).


Perfdata / Metrics
------------------

* temperature for each sensor found (°C)


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
* Credits: https://github.com/giampaolo/psutil/blob/master/scripts/temperatures.py
