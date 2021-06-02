Check erpm-lastactivity
=======================

Overview
--------

Checks the timespan since the last rpm activity, for example due to a yum/dnf install, update or remove.

* ``./rpm-lastactivity`` checks if the last rpm-activity (for example a yum-update) is more than 90 or 365 days ago. If not, it results in "Last rpm/yum/dnf activity is below the given thresholds (90d/365d)." (OK)
* ``./rpm-lastactivity --warning 0`` checks if there was rpm-activity within the last 0 days. If not, it results in "Last rpm/yum/dnf activity is more than 0 days ago." (WARN)


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/rpm-lastactivity"
    "Check Interval Recommendation",        "Once a day"
    "Available for",                        "Python 2"
    "Requirements",                         "Python module ``psutil``, command-line tool ``rpm``"
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

    ./rpm-lastactivity
    ./rpm-lastactivity --warning 90 --critical 365
    
Output:

.. code-block:: text

    TODOVM Output


States
------

* WARN or CRIT if last activity is above a given threshold.


Perfdata / Metrics
------------------

There is no perfdata.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
