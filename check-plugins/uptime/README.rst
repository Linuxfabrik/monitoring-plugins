Check uptime
============

Overview
--------

Checks and tells how long the system has been running (in days).


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/uptime"
    "Check Interval Recommendation",        "Every 5 minutes"
    "Can be called without parameters",     "Yes"
    "Available for",                        "Python 2, Python 3, Windows"
    "Requirements",                         "Python module ``psutil``"


Help
----

.. code-block:: text

    usage: uptime [-h] [-V] [--always-ok] [-c CRIT] [-w WARN]

    Tell how long the system has been running.

    optional arguments:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      -c CRIT, --critical CRIT
                            Set the critical threshold for uptime in days. Default: 366
      -w WARN, --warning WARN
                            Set the warning threshold for uptime in days. Default: 180


Usage Examples
--------------

.. code-block:: bash

    ./uptime --warning 180 --critical 366
    
Output:

.. code-block:: text

    Up 1W 9h


States
------

* WARN or CRIT if system uptime is above a given threshold.


Perfdata / Metrics
------------------

* Uptime (seconds)


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
