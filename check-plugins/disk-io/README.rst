Check disk-io
=============

Overview
--------

Checks the disk throughput over a period of time. For this purpose, the check logs the maximum throughput and warns if the throughput over the last n measured values is above a certain percentage (by default 80/90% over the last 5 values). So the whole thing works similarly to Load5, only on disk I/O level.

Disk I/O is always starting with 10Mib/sec but saves the highest mesured throughput, so it adjusts the ``RWmax/s`` value accordingly. For this reason, this check needs some time to warm up its (cached) measured values: The check will throw a few warnings and criticals during the first major disk activities above 10Mib/sec until the maximum throughput of the disk has been determined.

Example: The result of ``./disk-io --count 5 --warning 80 --critical 90`` could look like this:

.. code-block:: text

    dm-0: 23.6MiB/s read, 17.2MiB/s write (current)

    Disk ! RWmax/s ! R1/s     ! W1/s     ! R5/s     ! W5/s     ! RW5/s              
    -----+---------+----------+----------+----------+----------+--------------------
    dm-0 ! 44.9MiB ! 23.6MiB  ! 17.2MiB  ! 23.1MiB  ! 18.6MiB  ! 41.7MiB [CRITICAL] 
    dm-1 ! 10.0MiB ! 4.7KiB   ! 4.0KiB   ! 2.0KiB   ! 6.8KiB   ! 8.7KiB             
    sda  ! 10.0MiB ! 729.6KiB ! 154.2KiB ! 732.0KiB ! 152.4KiB ! 884.4KiB           
    sda1 ! 10.0MiB ! 729.6KiB ! 154.2KiB ! 732.0KiB ! 152.4KiB ! 884.4KiB           
    sdb  ! 46.0MiB ! 22.9MiB  ! 17.0MiB  ! 22.4MiB  ! 18.4MiB  ! 40.8MiB [WARNING]  
    sdb2 ! 46.0MiB ! 22.9MiB  ! 17.0MiB  ! 22.4MiB  ! 18.4MiB  ! 40.8MiB [WARNING]

The first line always shows the disk with the currently highest throughput (here ``dm-0``).

The table columns mean:

* RWmax: Here, a maximum throughput of 44.9 MB/sec was determined.
* R1, W1: The current throughput is 23.6 MB/sec read and 17.2 MB/sec write.
* R5, W5: The throughput from now to 5 measured values in the past is 23.1 MB/sec read and 18.6 MB/sec write.
* RW5: Compared to the current values, there was a higher throughput for a while. Since a maximum of 44.9 MB/sec throughput has been measured for this disk so far, a mean throughput (RW5) value of 41.7 MB/sec results in a warning (``41.7 MB/sec >= 44.9 MB/sec * 80%``). The current value of 23.6 MB/sec doesn't matter, this is only a snapshot. The check alerts because there is unusual high disk I/O over a certain amount of time.

Hints:

* ``--count=5`` (the default) while checking every minute means that the check reports a warning if any of your disks was above a threshold in the last 5 minutes.
* The check uses the SQLite databases ``$TEMP/linuxfabrik-monitoring-plugins-disk-io.db`` and ``$TEMP/linuxfabrik-monitoring-plugins-sqlite.db`` to store its historical data.
* If you are wondering about ``dm-0``, ``dm-1`` etc.: It's part of the "device mapper" in the kernel, used by LVM. Use ``dmsetup ls`` to see what is behind it.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70

    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/disk-io"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "Yes"
    "Compiled for",                         "Linux, Windows"
    "3rd Party Python modules",             "``psutil``"
    "Handles Periods",                      "Yes"
    "Uses SQLite DBs",                      "Yes"


Help
----

.. code-block:: text

    usage: disk-io [-h] [-V] [--always-ok] [--count COUNT] [--critical CRIT]
                   [--ignore IGNORE] [--warning WARN]

    Checks disk IO.

    options:
      -h, --help       show this help message and exit
      -V, --version    show program's version number and exit
      --always-ok      Always returns OK.
      --count COUNT    Number of times the value has to be above the given
                       thresholds. Default: 5
      --critical CRIT  Set the CRIT threshold for disk I/O read/write rate over
                       the entire period as a percentage of the maximum disk I/O
                       rate. Default: >= 90
      --ignore IGNORE  Ignore disk names starting with a string like "sr"
                       (repeating). Default: ['sr', 'loop', 'zram']
      --warning WARN   Set the CRIT threshold for disk I/O read/write rate over
                       the entire period as a percentage of the maximum disk I/O
                       rate. Default: >= 80


Usage Examples
--------------

.. code-block:: bash

    ./disk-io --ignore sr0 --ignore dm-1 --warning 80 --critical 90 --count 5

Output:

.. code-block:: text

    dm-0: 26.0MiB/s read, 21.1MiB/s write (current)

    Disk ! RWmax/s ! R1/s    ! W1/s     ! R5/s    ! W5/s     ! RW5/s             
    -----+---------+---------+----------+---------+----------+-------------------
    dm-0 ! 47.1MiB ! 26.0MiB ! 21.1MiB  ! 21.9MiB ! 18.4MiB  ! 40.3MiB [WARNING] 
    sda  ! 15.6MiB ! 3.4MiB  ! 167.7KiB ! 5.7MiB  ! 148.5KiB ! 5.8MiB            
    sda1 ! 15.6MiB ! 3.4MiB  ! 167.7KiB ! 5.7MiB  ! 148.5KiB ! 5.8MiB            
    sdb  ! 46.0MiB ! 22.6MiB ! 20.9MiB  ! 16.3MiB ! 18.2MiB  ! 34.5MiB           
    sdb2 ! 46.0MiB ! 22.6MiB ! 20.9MiB  ! 16.3MiB ! 18.2MiB  ! 34.5MiB


States
------

* WARN or CRIT if the throughput over the last n measured values is above a certain percentage, compared to the all time maximum throughput of this drive.


Perfdata / Metrics
------------------

Per disk:

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                               Type,                   Description                                           
    <disk>_busy_time,                   Continous Counter,      Time spent doing actual I/Os (in milliseconds).
    <disk>_read_bytes,                  Continous Counter,      Number of bytes read.
    <disk>_read_bytes_per_second1,      Bytes,                  Current number of bytes read.
    <disk>_read_bytes_per_second15,     Bytes,                  Current number of bytes read.
    <disk>_read_merged_count,           Continous Counter,      Number of merged reads. See https://www.kernel.org/doc/Documentation/iostats.txt.
    <disk>_read_time,                   Continous Counter,      Time spent reading from disk (in milliseconds).
    <disk>_write_bytes,                 Continous Counter,      Number of bytes written.
    <disk>_write_bytes_per_second1,     Bytes,                  Current number of bytes written.
    <disk>_write_bytes_per_second15,    Bytes,                  Current number of bytes written.
    <disk>_write_merged_count,          Continous Counter,      Number of merged writes. See https://www.kernel.org/doc/Documentation/iostats.txt.
    <disk>_write_time,                  Continous Counter,      Time spent writing to disk (in milliseconds).
    <disk>_throughput1,                 None,                   Bytes per second. read_bytes_per_second1 + write_bytes_per_second1.
    <disk>_throughput15,                None,                   Bytes per second. read_bytes_per_second15 + write_bytes_per_second15.


Troubleshooting
---------------

``psutil raised error "not sure how to interpret line '...'"`` or ``Nothing checked. Running Kernel >= 4.18, this check needs the Python module psutil v5.7.0+``
    Update the ``psutil`` library. On RHEL 8+, use at least ``python38`` and ``python38-psutil``.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
