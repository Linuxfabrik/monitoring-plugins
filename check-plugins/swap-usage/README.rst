Check swap-usage
================

Overview
--------

Displays amount of free and used swap space in the system, checks against used swap in percent.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/swap-usage"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "Yes"
    "Available for",                        "Python 2, Python 3, Windows"
    "Requirements",                         "Python module ``psutil``"


Help
----

.. code-block:: text

    usage: swap-usage [-h] [-V] [--always-ok] [-c CRIT] [-w WARN]

    Displays amount of free and used swap space in the system, checks against used
    swap in percent.

    optional arguments:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      -c CRIT, --critical CRIT
                            Set the critical threshold for swap usage (in
                            percent). Default: 90
      -w WARN, --warning WARN
                            Set the warning threshold for swap usage (in percent).
                            Default: 70


Usage Examples
--------------

.. code-block:: bash

    ./swap-usage --warning 70 --critical 90
    
Output:

.. code-block:: text

    38.6% - total: 11.7GiB, used: 4.5GiB, free: 7.2GiB
    swapped in: 1.6GiB, swapped out: 11.9GiB


States
------

* WARN or CRIT if swap usage is above a given threshold.


Perfdata / Metrics
------------------

* Swap Usage (%)
* Total Swap Space (Bytes)
* Used (Bytes)
* Free (Bytes)
* Swap In (Bytes)
* Swap Out (Bytes)


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
