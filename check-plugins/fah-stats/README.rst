Check fah-stats
===============

Overview
--------

Returns information about a specific team or donor at Folding@Home.

No need to run this every minute (depends on your number of team members and/or active CPUs).


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/fah-stats"
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

    ./fah-stats --team 260774
    ./fah-stats --donor 105577492
    
Output:

.. code-block:: text

    TODOVM Output


States
------

* Always returns OK.


Perfdata / Metrics
------------------

* active_50: Active CPUs within 50 days
* credit: Grand Score
* donors: Number of Team Members (only when querying for a team)
* rank: Team Ranking
* wus: Work Unit Count


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
