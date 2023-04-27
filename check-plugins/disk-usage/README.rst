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

    usage: disk-usage [-h] [-V] [--always-ok] [-c CRIT] [--ignore IGNORE]
                      [-w WARN]

    Checks the used disk space, for each partition.

    options:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      -c CRIT, --critical CRIT
                            Critical threshold, of the form
                            "<number>[unit][method]", where unit is one of
                            `%|K|M|G|T|P` and method is one of `USED|FREE`. If
                            "unit" is omitted, `%` is assumed. `K` means
                            `kibibyte` etc. If "method" is omitted, `USED` is
                            assumed. `USED` means "number ore more", `FREE` means
                            "number or less". Examples: `95` = alert at 95% usage
                            or more. `9.5M` = alert when 9.5 MiB or more is used.
                            Other self-explanatory examples are `95%USED`,
                            `5%FREE`, `9.5GFREE`, `1400GUSED`. Default: 95%USED
      --ignore IGNORE       Mountpoint to be ignored (repeating). The mountpoint
                            is ignored if it starts with the specified value.
                            Example: "/boot" ignores "/boot" as well as
                            "/boot/efi". On Windows, use drive letters without
                            backslash ("Y:" or "Y"). Default: []
      -w WARN, --warning WARN
                            Warning threshold, of the form
                            "<number>[unit][method]", where unit is one of
                            `%|K|M|G|T|P` and method is one of `USED|FREE`. If
                            "unit" is omitted, `%` is assumed. `K` means
                            `kibibyte` etc. If "method" is omitted, `USED` is
                            assumed. `USED` means "number ore more", `FREE` means
                            "number or less". Examples: `95` = alert at 95% usage.
                            `9.5M` = alert when 9.5 MiB is used. Other self-
                            explanatory examples are `95%USED`, `5%FREE`,
                            `9.5GFREE`, `1400GUSED`. Default: 90%USED


Usage Examples
--------------

.. code-block:: bash

    ./disk-usage

Output:

.. code-block:: text

    / 61.4% - total: 4.0GiB, used: 2.4GiB, avail: 1.5GiB (warn=90%USED crit=95%USED)

    Mountpoint     ! Type ! Size      ! Used     ! Avail    ! Use%  
    ---------------+------+-----------+----------+----------+-------
    /              ! xfs  ! 4.0GiB    ! 2.4GiB   ! 1.5GiB   ! 61.4% 
    /boot          ! xfs  ! 1014.0MiB ! 287.1MiB ! 726.9MiB ! 28.3% 
    /var           ! xfs  ! 4.0GiB    ! 1.4GiB   ! 2.6GiB   ! 34.4% 
    /tmp           ! xfs  ! 1014.0MiB ! 39.5MiB  ! 974.5MiB ! 3.9%  
    /var/log       ! xfs  ! 1014.0MiB ! 180.1MiB ! 833.9MiB ! 17.8% 
    /var/tmp       ! xfs  ! 1014.0MiB ! 39.4MiB  ! 974.6MiB ! 3.9%  
    /var/log/audit ! xfs  ! 506.7MiB  ! 61.9MiB  ! 444.8MiB ! 12.2% 
    /home          ! xfs  ! 1014.0MiB ! 130.1MiB ! 883.9MiB ! 12.8%

Other examples:

.. code-block:: bash

    ./disk-usage --ignore=/var/log --ignore=/tmp --warning=80 --critical=90
    ./disk-usage --ignore=/var/log --ignore=/tmp --warning=80%USED --critical=90%USED
    ./disk-usage --ignore=/var/log --ignore=/tmp --warning=80%USED --critical=3GFREE

    # on Windows:
    ./disk-usage --ignore=E: --ignore=Y: --warning=80 --critical=90


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
