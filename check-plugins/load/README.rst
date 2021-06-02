Check load
==========

Overview
--------

On the *No Sheep* blog, Zachary Tirrell defines the `load average <http://nosheep.net/story/defining-unix-load-average/>` on GNU/Linux operating system:

> In short it is the average sum of the number of processes waiting in the run-queue plus the numbercurrently executing over 1, 5, and 15 minutes time periods.

Alerts on load average are only set on 15 minutes time period. For this, the check gets the number of CPU cores to *normalize* load values automatically. Loads are computed by dividing the 15 minutes average load per CPU(s) count. For example, if you have 3 CPUs and the 15 minutes load is 6.0, then you get a warning because of (6 / 3) >= 1.15, where 1.15 is the default warning threshold. Main advantage of this method is to make machines comparable and making the design of Grafana panels easier.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/load"
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

    ./load
    ./load --warning 1.15 --critical 5.0
    
Output:

.. code-block:: text

    TODOVM Output


States
------

* WARN if load15 >= 1.15 (default)
* CRIT if load15 >= 5.00 (default)


Perfdata / Metrics
------------------

* load1
* load5
* load15


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
