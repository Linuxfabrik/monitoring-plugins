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
    "Compiled for",                         "Linux, Windows"
    "3rd Party Python modules",             "``psutil``"


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

    # on Windows:
    ./disk-usage --ignore=E: --ignore=Y: --warning=80 --critical=90

Output:

.. code-block:: text

    /var/log/audit 10.7% - total: 506.7MiB, used: 54.4MiB, free: 452.3MiB

    mountpoint     ! type ! used     ! total     ! percent 
    ---------------+------+----------+-----------+------------------
    /              ! xfs  ! 4.0GiB   ! 4.0GiB    ! 100.0% [CRITICAL]
    /var           ! xfs  ! 2.2GiB   ! 4.0GiB    ! 53.9%   
    /var/log       ! xfs  ! 172.3MiB ! 1014.0MiB ! 17.0%   
    /home          ! xfs  ! 40.1MiB  ! 1014.0MiB ! 4.0%    
    /boot          ! xfs  ! 163.8MiB ! 1014.0MiB ! 16.2%   
    /tmp           ! xfs  ! 136.2MiB ! 5.0GiB    ! 2.6%    
    /var/tmp       ! xfs  ! 39.4MiB  ! 1014.0MiB ! 3.9%    
    /var/log/audit ! xfs  ! 54.4MiB  ! 506.7MiB  ! 10.7%


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
