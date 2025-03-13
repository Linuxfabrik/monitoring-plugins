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

    usage: swap-usage [-h] [-V] [--always-ok] [-c CRIT] [--top TOP] [-w WARN]

    Displays amount of free and used swap space in the system, checks against used
    swap in percent.

    options:
      -h, --help           show this help message and exit
      -V, --version        show program's version number and exit
      --always-ok          Always returns OK.
      -c, --critical CRIT  Set the critical threshold for swap usage (in percent).
                           Default: 90
      --top TOP            List x "Top processes that use the most swap space"
                           (except on Windows). Default: 5
      -w, --warning WARN   Set the warning threshold for swap usage (in percent).
                           Default: 70


Usage Examples
--------------

.. code-block:: bash

    ./swap-usage --warning 70 --critical 90 --top 3

Output:

.. code-block:: text

    77.7% - total: 2.0GiB, used: 1.6GiB, free: 456.1MiB
    swapped in: 997.6MiB, swapped out: 2.6GiB (both cumulative)

    Top 3 processes that use the most swap space:
    1. php-fpm: 1.6GiB
    2. icinga2: 7.7MiB
    3. tuned: 3.9MiB


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
