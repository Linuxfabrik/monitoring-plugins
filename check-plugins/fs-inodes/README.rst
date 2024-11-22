Check fs-inodes
===============

Overview
--------

Checks the percentage of inode space used. To do this, this plugin fetches a list of local devices that are in use and have a filesystem on them. Filesystems that do not report inode usage are skipped.

If you get an alert, use `find $MOUNT -xdev -printf '%h\n\' | sort | uniq -c | sort -k 1 -n | tail -n 10` to find where inodes are being used. This prints a top 10 list of directories prefixed with the number of files (and subdirectories).


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/fs-inodes"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "Yes"
    "Compiled for",                         "Linux"


Help
----

.. code-block:: text

    usage: fs-inodes [-h] [-V] [--always-ok] [-c CRIT] [-w WARN]

    Checks the percentage of inode space used. To do this, this plugin fetches a
    list of local devices that are in use and have a filesystem on them.
    Filesystems that do not report inode usage are skipped.

    options:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      -c CRIT, --critical CRIT
                            Set the critical threshold inode usage percentage.
                            Default: 95
      -w WARN, --warning WARN
                            Set the warning threshold inode usage percentage.
                            Default: 90


Usage Examples
--------------

.. code-block:: bash

    ./fs-inodes --warning 90 --critical 95
    
Output:

.. code-block:: text

    / 1.7%, /tmp 3.2%, /boot 0.2%


States
------

* WARN or CRIT if inode usage is above a given threshold.


Perfdata / Metrics
------------------

For each mount:

* inode usage (%)


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
