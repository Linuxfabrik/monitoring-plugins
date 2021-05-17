Check "disk-io"
===============

Overview
--------

Checks the disk throughput over a period of time.

For this purpose, the check logs the maximum throughput and warns if the throughput over the last n measured values is above a certain percentage (by default 80/90% over the last 5 values). So the whole thing works similarly to Load5, only on disk I/O level.

Assuming the NVMe disk offers 2.1 GB/sec throughput. The result of ``./disk-io --count 5 --warning 80 --critical 90`` could then look like this::

    dm-2: 0.0B/s read, 1.75GiB/s write (current)

    Disk RWmax/s R1/s W1/s   R5/s     W5/s   RW5/s  State     
    ---- ------- ---- ----   ----     ----   -----  -----     
    dm-2 2.1GiB  0.0B 1.6GiB 100.0MiB 1.7GiB 1.8GiB [WARNING] 

The first line always shows the disk with the currently highest throughput. For example, the table row for ``dm-2`` means:

* In practice, a maximum throughput of 2.1 GB/sec was determined (RWmax).
* The current throughput is 0.0 B/sec read and 1.75 GB/sec write (R1/W1).
* The throughput from now to 5 measured values in the past is 100 MB/sec read and 1.7 GB/sec write (R5/W5). Compared to the current values, there was a higher throughput for a while.
* Since the drive offers a maximum of 2.1 GB/sec, a RW5 value of 1.8 GB/sec results in a warning (``2.1 GB/sec * 80% = 1.68 GB/sec``). The current value of 1.75 GB/sec doesn't matter, it could be a peak.

Hints and Recommendations:

* ``--count=5`` (the default) while checking every minute means that the check reports a warning if any of your disks was above a threshold in the last 5 minutes.
* The check uses the SQLite databases ``/tmp/disk-io.db`` and ``/tmp/linuxfabrik-plugin-cache.db`` to store its historical data.
* If you are wondering about ``dm-0``, ``dm-1`` etc.: It's part of the "device mapper" in the kernel, used by LVM. Use ``dmsetup ls`` to see what is behind it.

We recommend running the check once a minute.


Installation and Usage
----------------------

Requirements:

* Python2 module ``psutil``

.. code-block:: bash

    ./disk-io
    ./disk-io --ignore sr0 --ignore dm-1 --warning 80 --critical 90 --count 5
    ./disk-io --help

Output::

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


Perfdata
--------

Per disk:

* <disk>_busy_time: Continous Counter. Time spent doing actual I/Os (in milliseconds).
* <disk>_read_bytes: Continous Counter. Number of bytes read.
* <disk>_read_bytes_per_second1: Bytes. Current number of bytes read.
* <disk>_read_bytes_per_second15: Bytes. Current number of bytes read.
* <disk>_read_merged_count: Continous Counter. Number of merged reads. See https://www.kernel.org/doc/Documentation/iostats.txt.
* <disk>_read_time: Continous Counter. Time spent reading from disk (in milliseconds).
* <disk>_write_bytes: Continous Counter. Number of bytes written.
* <disk>_write_bytes_per_second1: Bytes. Current number of bytes written.
* <disk>_write_bytes_per_second15: Bytes. Current number of bytes written.
* <disk>_write_merged_count: Continous Counter. Number of merged writes. See https://www.kernel.org/doc/Documentation/iostats.txt.
* <disk>_write_time: Continous Counter. Time spent writing to disk (in milliseconds).
* <disk>_throughput1: Bytes per second. read_bytes_per_second1 + write_bytes_per_second1.
* <disk>_throughput15: Bytes per second. read_bytes_per_second15 + write_bytes_per_second15.


Credits, License
----------------

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.