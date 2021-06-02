Check edisk-usage
=================

Overview
--------

Measures the usage of all mounted disk _partitions_ on physical disks only (e.g. hard disks, CD-ROM drives, USB keys) found. It does not check the usage on the raw disks, because for example in LVM more than one disk can be a member of a logical volume, and some of the disks might be full - which is ok as long as the LVM has some space available. The check also ignores all other partition types (e.g. memory partitions such as /dev/shm).

*Note*: UNIX usually reserves 5% of the total disk space for the root user. total and used fields on UNIX refer to the overall total and used space, whereas free represents the space available for the user and percent represents the user utilization. That is why percent value may look 5% bigger than what you would expect it to be (starting with psutil v4.3.0; quote from the `psutil documentation <https://psutil.readthedocs.io/en/latest/>`_).


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/disk-usage"
    "Check Interval Recommendation",        "Every 5 minutes"
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

    ./disk-usage
    ./disk-usage --warning=80 --critical=90
    
Output:

.. code-block:: text

    TODOVM Output


States
------

* WARN or CRIT if disk usage is above a given threshold.


Perfdata / Metrics
------------------

* Usage (%)
* Usage (Bytes)
* Total Disksize (Bytes)


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
