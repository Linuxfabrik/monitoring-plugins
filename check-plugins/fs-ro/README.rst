Check fs-ro
===========

Overview
--------

The fs-ro plugin checks for read only mount points, for example like ``/`` mounted read only due to filesystem errors, mounted CD-ROMs or ISO files etc.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/fs-ro"
    "Check Interval Recommendation",        "Every 15 minutes"
    "Available for",                        "Python 2, Python 3"
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

    ./fs-ro
    ./fs-ro --ignore /proc,/sys/fs
    
Output:

.. code-block:: text

    TODOVM Output


States
------

* WARN if a read only mount point is found (which is not on the ignore list).


Perfdata / Metrics
------------------

There is no perfdata.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
