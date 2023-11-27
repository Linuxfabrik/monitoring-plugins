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

    usage: disk-usage [-h] [-V] [--always-ok] [-c CRIT]
                      [--exclude-pattern EXCLUDE_PATTERN]
                      [--exclude-regex EXCLUDE_REGEX]
                      [--include-pattern INCLUDE_PATTERN]
                      [--include-regex INCLUDE_REGEX]
                      [--perfdata-regex PERFDATA_REGEX] [-w WARN]

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
      --exclude-pattern EXCLUDE_PATTERN
                            Any line matching this pattern (case-insensitive) will
                            count as a exclude. The mountpoint is excluded if it
                            contains the specified value. Example: "boot" excludes
                            "/boot" as well as "/boot/efi". Can be specified
                            multiple times. On Windows, use drive letters without
                            backslash ("Y:" or "Y"). Includes are matched before
                            excludes.
      --exclude-regex EXCLUDE_REGEX
                            Any line matching this python regex (case-insensitive)
                            will count as a exclude. Can be specified multiple
                            times. On Windows, use drive letters without backslash
                            ("Y:" or "Y"). Includes are matched before excludes.
      --include-pattern INCLUDE_PATTERN
                            Any line matching this pattern (case-insensitive) will
                            count as a include. The mountpoint is included if it
                            contains the specified value. Example: "boot" includes
                            "/boot" as well as "/boot/efi". Can be specified
                            multiple times. On Windows, use drive letters without
                            backslash ("Y:" or "Y"). Includes are matched before
                            excludes.
      --include-regex INCLUDE_REGEX
                            Any line matching this python regex (case-insensitive)
                            will count as a include. Can be specified multiple
                            times. On Windows, use drive letters without backslash
                            ("Y:" or "Y"). Includes are matched before excludes.
      --perfdata-regex PERFDATA_REGEX
                            Only print perfdata keys matching this python regex.
                            For a list of perfdata keys, have a look at the README
                            and run this plugin. Can be specified multiple times.
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

Simple usage:

.. code-block:: bash

    ./disk-usage

Output:

.. code-block:: text

    Everything is ok. (warn=90%USED crit=95%USED)

    Mountpoint     ! Type ! Size      ! Used     ! Avail    ! Use%  
    ---------------+------+-----------+----------+----------+-------
    /              ! xfs  ! 4.0GiB    ! 2.4GiB   ! 1.5GiB   ! 61.4% 
    /boot          ! xfs  ! 1014.0MiB ! 287.1MiB ! 726.9MiB ! 28.3% 
    /var           ! xfs  ! 4.0GiB    ! 1.4GiB   ! 2.6GiB   ! 34.4% 
    /tmp           ! xfs  ! 1014.0MiB ! 39.5MiB  ! 974.5MiB ! 3.9%  
    /var/log       ! xfs  ! 1014.0MiB ! 190.9MiB ! 823.1MiB ! 18.8% 
    /var/tmp       ! xfs  ! 1014.0MiB ! 39.4MiB  ! 974.6MiB ! 3.9%  
    /var/log/audit ! xfs  ! 506.7MiB  ! 63.9MiB  ! 442.7MiB ! 12.6% 
    /home          ! xfs  ! 1014.0MiB ! 130.1MiB ! 883.9MiB ! 12.8%

For each ``/var`` partition, except ``/var/tmp``, alert when any of these partitions has only 450 MiB of free space left:

.. code-block:: bash

    ./disk-usage --include-pattern=var --exclude-pattern=tmp --critical 450MFREE

Output:

.. code-block:: text

    There are critical errors. (warn=90%USED crit=450MFREE)

    Mountpoint     ! Type ! Size      ! Used     ! Avail    ! Use%             
    ---------------+------+-----------+----------+----------+------------------
    /var           ! xfs  ! 4.0GiB    ! 1.4GiB   ! 2.6GiB   ! 34.4%            
    /var/log       ! xfs  ! 1014.0MiB ! 190.9MiB ! 823.1MiB ! 18.8%            
    /var/log/audit ! xfs  ! 506.7MiB  ! 64.2MiB  ! 442.5MiB ! 12.7% [CRITICAL]|

Check exactly one partition:

.. code-block:: bash

    ./disk-usage --include-pattern=audit --warning 60MUSED

Output:

.. code-block:: text

    /var/log/audit 12.6% [WARNING] - total: 506.7MiB, free: 442.7MiB, used: 63.9MiB (warn=60MUSED crit=95%USED)

Some other examples:

.. code-block:: bash

    ./disk-usage --exclude-pattern=/var/log --exclude-pattern=/tmp --warning=80 --critical=90
    ./disk-usage --exclude-pattern=/var/log --exclude-pattern=/tmp --warning=80%USED --critical=90%USED
    ./disk-usage --exclude-pattern=/var/log --exclude-pattern=/tmp --warning=80%USED --critical=3GFREE

    ./disk-usage --perfdata-pattern='/-usage'
    ./disk-usage --perfdata-pattern='var.*-usage'

    # on Windows:
    ./disk-usage --exclude-pattern=E: --exclude-pattern=Y: --warning=80 --critical=90


States
------

* WARN or CRIT if disk usage in percent is above a given threshold.


Perfdata / Metrics
------------------

Can be limited by using ``--perfdata-regex``.

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
