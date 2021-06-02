Check ecountdown
================

Overview
--------

The check warns before an expiration date of events that are scheduled to occur. Useful to warn before a hardware or contract expiration date. For example, ``./countdown --input='Supermicro X11 (SerNo ABCD), 2025-12-23, 60, 30'`` returns WARN/CRIT 60/30 days before 2025-12-23, otherwise OK.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/countdown"
    "Check Interval Recommendation",        "Twice a day"
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

    Use `./countdown --input='<Event Name>, <yyyy-mm-dd>, <WARN days before>, <CRIT days before>'` (repeating).

    ./countdown --input='Supermicro X11 (SerNo ABCD), 2025-12-23, 60, 30'
    ./countdown --input='Contract A, 2023-12-31, 60, None' --input 'Contract B, 2024-12-31, 30, 14'
    
Output:

.. code-block:: text

    TODOVM Output


States
------

For each event:
* CRIT: if event is <= days away; 'None' means that CRIT is never returned
* WARN: if event is <= days away; 'None' is not possible


Perfdata / Metrics
------------------

There is no perfdata.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
