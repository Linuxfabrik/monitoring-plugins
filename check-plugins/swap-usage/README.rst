Check swap-usage
================

Overview
--------

Displays amount of free and used swap space in the system, checks against used swap in percent.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/swap-usage"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "Yes"
    "Compiled for",                         "Linux, Windows"
    "3rd Party Python modules",             "``psutil``"


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

    22.4% - total: 8.0GiB, used: 1.8GiB, free: 6.2GiB
    swapped in: 1.1GiB, swapped out: 3.6GiB (both cumulative)


States
------

* WARN or CRIT if swap usage is above a given threshold.


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1

    Name,                                       Type,               Description                                           
    free,                                       Bytes,              Free swap memory in bytes
    sin,                                        Bytes,              The number of bytes the system has swapped in to disk (cumulative)
    sout,                                       Bytes,              The number of bytes the system has swapped out to disk (cumulative)
    total,                                      Bytes,              Total swap memory in bytes
    usage_percent,                              Percentage,         The percentage usage calculated as (total - available) / total \* 100
    used,                                       Bytes,              Used swap memory in bytes


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
