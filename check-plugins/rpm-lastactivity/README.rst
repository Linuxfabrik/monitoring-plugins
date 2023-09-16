Check rpm-lastactivity
======================

Overview
--------

Checks the timespan since the last package manager activity, for example due to a yum/dnf install/update.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/rpm-lastactivity"
    "Check Interval Recommendation",        "Once a day"
    "Can be called without parameters",     "Yes"
    "Compiled for",                         "Linux"


Help
----

.. code-block:: text

    usage: rpm-lastactivity [-h] [-V] [-c CRIT] [-w WARN]

    Checks the timespan since the last package manager activity, for example due
    to a yum/dnf install/update.

    options:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      -c CRIT, --critical CRIT
                            Set the critical threshold (in days). Default: 365
      -w WARN, --warning WARN
                            Set the warning threshold (in days). Default: 90


Usage Examples
--------------

.. code-block:: bash

    ./rpm-lastactivity --warning 90 --critical 365
    
Output:

.. code-block:: text

    Last package manager activity is 5M 2W ago [WARNING] (thresholds 90D/365D).


States
------

* WARN or CRIT if last activity is above a given threshold.


Perfdata / Metrics
------------------

There is no perfdata.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
