Check memory-usage
==================

Overview
--------

Displays amount of free and used memory in the system, checks against used memory in percent.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/memory-usage"
    "Check Interval Recommendation",        "Once a minute"
    "Available for",                        "Python 2, Python 3, Windows"
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

    ./memory-usage
    ./memory-usage --warning 90 --critical 95
    
Output:

.. code-block:: text

    TODOVM Output


States
------

* WARN or CRIT if total memory usage is above a given threshold.


Perfdata / Metrics
------------------


* total: total physical memory (exclusive swap).
* used: memory used, calculated differently depending on the platform and designed for informational purposes only. total - free does not necessarily match used.
* free: memory not being used at all (zeroed) that is readily available; note that this doesn’t reflect the actual memory available (use available instead). total - used does not necessarily match free.
* shared (Linux, BSD): memory that may be simultaneously accessed by multiple processes.
* buffers (Linux, BSD): cache for things like file system metadata.
* cached (Linux, BSD): cache for various things.
* available: the memory that can be given instantly to processes without the system going into swap. This is calculated by summing different memory values depending on the platform and it is supposed to be used to monitor actual memory usage in a cross platform fashion.

The sum of used and available memory is not necessarily equal to total.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
* Credits:  https://github.com/giampaolo/psutil/blob/master/scripts/free.py
