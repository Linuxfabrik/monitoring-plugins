Check memory-usage
==================

Overview
--------

Displays the amount of free and used memory in the system and checks how much physical memory is left across platforms by using the ``available`` field.

Hints:

* Be aware of the differences in memory counting between different tools like top, htop, glances, GNOME System Monitor etc.
* Memory counting also changed between different Linux Kernel versions.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70

    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/memory-usage"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "Yes"
    "Compiled for Windows",                 "Yes"
    "3rd Party Python modules",             "``psutil``"


Help
----

.. code-block:: text

    usage: memory-usage [-h] [-V] [--always-ok] [-c CRIT] [--top TOP] [-w WARN]

    Displays amount of free and used memory in the system, checks against used
    memory in percent.

    options:
      -h, --help           show this help message and exit
      -V, --version        show program's version number and exit
      --always-ok          Always returns OK.
      -c, --critical CRIT  Set the critical threshold for memory usage (in
                           percent). Default: 95
      --top TOP            List x "Top most memory consuming processes". Default:
                           5
      -w, --warning WARN   Set the warning threshold for memory usage (in
                           percent). Default: 90


Usage Examples
--------------

.. code-block:: bash

    ./memory-usage
    ./memory-usage --warning 90 --critical 95
    
Output:

.. code-block:: text

    36.2% - total: 3.8GiB, used: 1.1GiB, available: 2.4GiB, free: 989.4MiB
    shared: 41.6MiB, buffers: 3.6MiB, cached: 1.8GiB

    Top5 most memory consuming processes:
    1. php-fpm: 810.7MiB (20.7%)
    2. forkit: 418.3MiB (10.7%)
    3. kit_spare_001: 335.5MiB (8.6%)
    4. mariadbd: 306.2MiB (7.8%)
    5. icinga2: 63.8MiB (1.6%)


States
------

* WARN or CRIT if total memory usage is above a given threshold.


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description                                           
    available,                                  Bytes,              "The memory that can be given instantly to processes without the system going into swap. This is calculated by summing different memory values depending on the platform and it is supposed to be used to monitor actual memory usage in a cross platform fashion."
    "buffers",                                  Bytes,              "Cache for things like file system metadata  (Linux, BSD)."
    "cached",                                   Bytes,              "Cache for various things  (Linux, BSD)."
    free,                                       Bytes,              "Memory not being used at all (zeroed) that is readily available; note that this doesn't reflect the actual memory available (use ``available`` instead). ``total - used`` does not necessarily match ``free``."
    "shared",                                   Bytes,              "Memory that may be simultaneously accessed by multiple processes  (Linux, BSD)."
    total,                                      Bytes,              "Total physical memory (exclusive swap)."
    usage_percent,                              Percentage,         
    used,                                       Bytes,              "Memory used, calculated differently depending on the platform and designed for informational purposes only. ``total - free`` does not necessarily match ``used``."


Troubleshooting
---------------

This checks sometimes reports > 100% memory usage
    That's fine, the RES column in ``top`` says the same if you sum up all values for a process (attention: the values in top's RES column are KB by default), and compare process memory to total physical system memory. The machine does not swap, so this is kind of Linux memory management mystery.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
* Credits:  https://github.com/giampaolo/psutil/blob/master/scripts/free.py
