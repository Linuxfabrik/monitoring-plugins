Check qts-disk-smart
====================

Overview
--------

Checks the disk SMART values returned by QTS. This check does not run SMART itself. In order to get the latest values, schedule the in-built SMART check in the QTS webinterface.

Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/qts-disk-smart"
    "Check Interval Recommendation",        "Every day"
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

    ./qts-disk-smart --url http://192.168.1.100:8080 --username admin --password my-password
    
Output:

.. code-block:: text

    TODOVM Output


States
------

* OK if all disks ``disk-smart`` are ok.
* Otherwise WARN.


Perfdata / Metrics
------------------

* Temperatures


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
