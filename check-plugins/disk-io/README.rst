Check disk-io
=============

Overview
--------

Checks the disk throughput over a period of time. For this purpose, the check logs the maximum throughput and warns if the throughput over the last n measured values is above a certain percentage (by default 80/90% over the last 5 values). So the whole thing works similarly to Load5, only on disk I/O level.

Disk I/O is always starting with 10Mib/sec but saves the highest mesured throughput, so it adjusts the ``RWmax/s`` value accordingly. For this reason, this check needs some time to warm up its (cached) measured values: The check will throw a few warnings and criticals during the first major disk activities above 10Mib/sec until the maximum throughput of the disk has been determined.

Assuming the NVMe disk offers 2.1 GB/sec throughput. The result of ``./disk-io --count 5 --warning 80 --critical 90`` could then look like this::

    dm-2: 0.0B/s read, 1.75GiB/s write (current)

    Disk RWmax/s R1/s W1/s   R5/s     W5/s   RW5/s
    ---- ------- ---- ----   ----     ----   ----------------
    dm-2 2.1GiB  0.0B 1.6GiB 100.0MiB 1.7GiB 1.8GiB [WARNING]

The first line always shows the disk with the currently highest throughput. The table columns shown above mean:

* RWmax: Here, a maximum throughput of 2.1 GB/sec was determined.
* R1, W1: The current throughput is 0.0 B/sec read and 1.75 GB/sec write.
* R5, W5: The throughput from now to 5 measured values in the past is 100 MB/sec read and 1.7 GB/sec write. Compared to the current values, there was a higher throughput for a while.

State: Since the drive offers a maximum of 2.1 GB/sec, a total throughput (RW5) value of 1.8 GB/sec results in a warning (``2.1 GB/sec * 80% = 1.68 GB/sec``). The current value of 1.75 GB/sec doesn't matter, it could be a peak.

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
    "Available for ",                       "Python 2, Python 3, Windows"
    "Requirements",                         "Python module ``psutil``"
    "Handles Periods",                      "Yes"
    "Uses SQLite DBs",                      "Yes"


Help
----

.. code-block:: text

    usage: disk-io [-h] [-V] [--always-ok] [--count COUNT] [--critical CRIT]
                   [--ignore IGNORE] [--warning WARN]

    Checks disk IO.

    optional arguments:
      -h, --help       show this help message and exit
      -V, --version    show program's version number and exit
      --always-ok      Always returns OK.
      --count COUNT    Number of times the value has to be above the given
                       thresholds. Default: 5
      --critical CRIT  Set the CRIT threshold for disk I/O read/write rate over
                       the entire period as a percentage of the maximum disk I/O
                       rate. Default: >= 90
      --ignore IGNORE  Ignore some disks like "sr0" or "zram0" (repeating).
                       Default: ['sr0', 'loop0', 'loop1', 'loop2', 'loop3',
                       'loop4', 'loop5', 'loop6', 'loop7', 'loop8', 'loop9',
                       'zram0']
      --warning WARN   Set the CRIT threshold for disk I/O read/write rate over
                       the entire period as a percentage of the maximum disk I/O
                       rate. Default: >= 80


Usage Examples
--------------

.. code-block:: bash

    ./disk-io --ignore sr0 --ignore dm-1 --warning 80 --critical 90 --count 5

Output:

.. code-block:: text

    dm-2: 516.0B/s read, 540.1KiB/s write (current)

    Disk      RWmax/s R1/s   W1/s     R5/s   W5/s    RW5/s   State 
    ----      ------- ----   ----     ----   ----    -----   ----- 
    dm-0      2.2GiB  516.0B 533.3KiB 5.2KiB 10.2MiB 10.2MiB [OK]  
    dm-2      2.1GiB  516.0B 540.1KiB 5.2KiB 9.9MiB  9.9MiB  [OK]  
    nvme0n1   2.1GiB  516.0B 533.3KiB 5.2KiB 10.2MiB 10.2MiB [OK]  
    nvme0n1p3 2.1GiB  516.0B 533.3KiB 5.2KiB 10.2MiB 10.2MiB [OK]  


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

psutil raised error "not sure how to interpret line '...'"
    Update the ``psutil`` library. On Rocky 8, use at least ``python38`` and ``python38-psutil``.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
