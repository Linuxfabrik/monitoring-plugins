Check scheduled-task
====================

Overview
--------

Checks the status of a Windows scheduled task.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/scheduled-task"
    "Check Interval Recommendation",        "Once a minute"
    "Available for",                        "Python 3, Windows"
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

    ./scheduled-task3 --task Schedule
    ./scheduled-task3 --task Schedule --severity crit
    ./scheduled-task3 --task Schedule --status Disabled
    
Output:

.. code-block:: text

    TODOVM Output


States
------

* WARN if result does not match the expected status.
* CRIT only if configured as such.


Perfdata / Metrics
------------------

There is no perfdata.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
