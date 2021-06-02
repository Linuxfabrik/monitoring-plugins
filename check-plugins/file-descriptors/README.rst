Check file-descriptors
======================

Overview
--------

Checks the number of allocated file handles in percent. Depending on the file and user (e.g. running as 'icinga') sudo (sudoers) is needed.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/file-descriptors"
    "Check Interval Recommendation",        "Once a minute"
    "Available for",                        "Python 2, Python 3"
    "Requirements",                         "Python module ``psutil``, command-line tool ``sysctl``"
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

    ./file-descriptors --warning 90 --critical 95
    
Output:

.. code-block:: text

    TODOVM Output


States
------

* WARN or CRIT if usage of file descriptors in % is above a given threshold.


Perfdata / Metrics
------------------

* File descriptors (%)


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
