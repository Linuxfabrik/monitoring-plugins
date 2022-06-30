Check disk-usage
================

Overview
--------

Measures the usage of all mounted disk *partitions* on physical disks only (e.g. hard disks, CD-ROM drives, USB keys) found. It does not check the usage on the raw disks, because for example in LVM more than one disk can be a member of a logical volume, and some of the disks might be full - which is ok as long as the LVM has some space available. The check also ignores all other partition types (e.g. memory partitions such as ``/dev/shm``).

.. note::

    UNIX usually reserves 5% of the total disk space for the root user. ``total`` and ``used`` fields on UNIX refer to the overall total and used space, whereas ``free`` represents the space available for the user and ``percent`` represents the user utilization. That is why percent value may look 5% bigger than what you would expect it to be (starting with psutil v4.3.0; quote from the `psutil documentation <https://psutil.readthedocs.io/en/latest/>`_).


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/disk-usage"
    "Check Interval Recommendation",        "Every 5 minutes"
    "Can be called without parameters",     "Yes"
    "Available for",                        "Python 2, Python 3, Windows"
    "Requirements",                         "Python module ``psutil``"


Help
----

.. code-block:: text

    usage: disk-usage [-h] [-V] [--always-ok] [-c CRIT] [--ignore IGNORE] [-w WARN]

    Checks the used disk space, for each partition.

    optional arguments:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      -c CRIT, --critical CRIT
                            Set the critical threshold partition usage percentage.
                            Default: 95
      --ignore IGNORE       Mountpoint to be ignored (repeating). The mountpoint is
                            ignored if it starts with the specified value. Example:
                            "/boot" ignores "/boot" as well as "/boot/efi". On Windows,
                            use drive letters without backslash ("Y:" or "Y"). Default: []
      -w WARN, --warning WARN
                            Set the warning threshold partition usage percentage. Default:
                            90


Usage Examples
--------------

.. code-block:: bash

    ./disk-usage
    ./disk-usage --ignore=/var/log --ignore=/tmp --warning=80 --critical=90
    ./disk-usage --ignore=E: --ignore=Y: --warning=80 --critical=90
    
Output:

.. code-block:: text

    / 43.3% - total: 928.8GiB, used: 381.7GiB, free: 499.8GiB

    mountpoint type used     total    percent 
    ---------- ---- ----     -----    ------- 
    /          ext4 381.7GiB 928.8GiB 43.3%
    /boot/efi  vfat 60.0MiB  598.8MiB 10.0%   
    /boot      ext4 389.4MiB 975.9MiB 42.8%   


States
------

* WARN or CRIT if disk usage in percent is above a given threshold.


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description
    <mountpoint>-percent,                       Percentage,         Usage in percent
    <mountpoint>-total,                         Bytes,              Total Disksize
    <mountpoint>-usage,                         Bytes,              Usage in Bytes


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
