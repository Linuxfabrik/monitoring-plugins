Check disk-io
=============

Overview
--------

Checks disk bandwidth over a period of time. The check tracks the maximum bandwidth and alerts if the bandwidth over the last n reads is above a certain percentage (by default 80/90% over the last 5 reads). This works similar to Load5, but at the disk I/O level.

On Linux, the check plugin tries to find "important" disks automatically by default, so as not to waste disk space in a time series database with unnecessary disk information. To do this, it looks for disks that are mounted to a folder.

Disk I/O always starts at 10 MiB/sec, but stores the highest measured bandwidth, so it adjusts the ``RWmax/s`` value accordingly. For this reason, this check takes some time to warm up its (cached) readings: The check will throw some warnings and criticals during the first major disk activities above 10Mib/sec until the maximum bandwidth of the disk has been determined.

Example: The result of ``./disk-io --count 5 --warning 80 --critical 90`` could look like this:

.. code-block:: text

    dm-0: 23.6MiB/s read, 17.2MiB/s write (current)

    Name ! RWmax/s ! R1/s     ! W1/s     ! R5/s     ! W5/s     ! RW5/s              
    -----+---------+----------+----------+----------+----------+--------------------
    dm-0 ! 44.9MiB ! 42.8MiB  ! 17.2MiB  ! 23.1MiB  ! 18.6MiB  ! 36.3MiB [CRITICAL] 
    dm-1 ! 10.0MiB ! 4.7KiB   ! 4.0KiB   ! 2.0KiB   ! 6.8KiB   ! 8.7KiB             
    sda  ! 10.0MiB ! 729.6KiB ! 154.2KiB ! 732.0KiB ! 152.4KiB ! 884.4KiB           

The first line always shows the disk with the currently highest bandwidth (here ``dm-0``).

The table columns mean:

* RWmax: Here, a maximum bandwidth of 44.9 MB/sec was determined.
* R1, W1: The current bandwidth is 23.6 MB/sec read and 17.2 MB/sec write.
* R5, W5: The bandwidth from now to 5 measured values in the past is 23.1 MB/sec read and 18.6 MB/sec write.
* First line in the table, RW5: Compared to the current values, there was a higher bandwidth for a while. Since a maximum of 44.9 MB/sec bandwidth has been measured for this disk so far, a mean bandwidth (RW5) value of 36.3 MB/sec results in a warning (``36.3 MB/sec >= 44.9 MB/sec * 80%``). The current value of 42.8 MB/sec doesn't matter, this is only a peak. The check alerts because there is unusual high disk I/O over a certain amount of time.

Hints:

* ``--count=5`` (the default) while checking every minute means that the check will report an alert if any of your disks have been above a threshold in the last 5 minutes.
* The check uses the SQLite databases ``$TEMP/linuxfabrik-monitoring-plugins-disk-io.db`` to store its historical data.
* If you're wondering about ``dm-0``, ``dm-1`` etc.: It's part of the "device mapper" in the Linux kernel, e.g. used by LVM. The plugin can translate this using the ``--translate-dm`` switch.


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
    "Uses SQLite DBs",                      "``$TEMP/linuxfabrik-monitoring-plugins-disk-io.db``"


Help
----

.. code-block:: text

    usage: disk-io [-h] [-V] [--all-disks] [--always-ok] [--count COUNT]
                   [--critical CRIT] [--match MATCH] [--top TOP] [--translate-dm]
                   [--warning WARN]

    Checks disk I/O. If the bandwidth usage of a disk is above the specified
    threshold (as a percentage of the maximum bandwidth measured) for a certain
    period of time, an alarm is triggered.

    options:
      -h, --help       show this help message and exit
      -V, --version    show program's version number and exit
      --all-disks      By default, the check attempts to return only mounted
                       devices (Linux only). This switch disables this behavior.
      --always-ok      Always returns OK.
      --count COUNT    Number of times the value must exceed specified thresholds
                       before alerting. Default: 5
      --critical CRIT  Threshold for disk bandwidth saturation (over the last
                       `--count` measurements) as a percentage of the maximum
                       bandwidth the disk can support. Default: >= 90
      --match MATCH    Match on disk names. Uses Python regular expressions
                       without any external flags like `re.IGNORECASE`. The
                       regular expression is applied to each line of the output.
                       Examples: `(?i)example` to match the word "example" in a
                       case-insensitive manner. `^(?!.*example).*$` to match any
                       string except "example" (negative lookahead). `(?: ... )*`
                       is a non-capturing group that matches any sequence of
                       characters that satisfy the condition inside it, zero or
                       more times. Default: ^(?:(?!sr|loop|zram).)*$
      --top TOP        List x "Top processes that generated the most I/O traffic".
                       Default: 5
      --translate-dm   Get the names of the device mapper devices from sysfs,
                       replacing `dm-0` etc. (Linux only). Just for the output,
                       ``--match`` has no effect on device mapper names.
      --warning WARN   Threshold for disk bandwidth saturation (over the last
                       `--count` measurements) as a percentage of the maximum
                       bandwidth the disk can support. Default: >= 80


Usage Examples
--------------

Just check disk ``dm-0``:

.. code-block:: bash

    ./disk-io --match=dm-0

Check all disks (mounted or not), but filter ``vda``, not ``vda1``, ``vda2`` etc.::

.. code-block:: bash

    ./disk-io --all-disks --match='vda$'

Translate device mapper names:

.. code-block:: bash

    ./disk-io --translate-dm --top 5

Output:

.. code-block:: text

    dm-0: 0.0B/s read1, 306.4KiB/s write1, 306.4KiB/s total, 632.5MiB/s max (disks matching `^(?:(?!sr!loop!zram).)*$`).

    Name      ! DevMapper                                 ! RWmax/s  ! R1/s ! W1/s     ! R5/s ! W5/s     ! RW5/s    
    ----------+-------------------------------------------+----------+------+----------+------+----------+----------
    dm-0      ! luks-a453077c-0a79-4494-96f0-6ce71303bf66 ! 632.5MiB ! 0.0B ! 306.4KiB ! 0.0B ! 197.6KiB ! 197.6KiB 
    nvme0n1p1 ! nvme0n1p1                                 ! 10.0MiB  ! 0.0B ! 0.0B     ! 0.0B ! 0.0B     ! 0.0B     
    nvme0n1p2 ! nvme0n1p2                                 ! 10.0MiB  ! 0.0B ! 0.0B     ! 0.0B ! 0.0B     ! 0.0B     

    Top 5 processes that generate the most I/O traffic:
    1. firefox: 92.1MiB/8.5GiB (r/w)
    2. gnome-shell: 830.9MiB/6.1GiB (r/w)
    3. morgen: 243.2MiB/2.5GiB (r/w)
    4. sublime_text: 10.3MiB/646.4MiB (r/w)
    5. nextcloud: 125.8MiB/426.9MiB (r/w)


States
------

* WARN or CRIT if the bandwidth over the last n measured values is above a certain percentage, compared to the all time maximum bandwidth of this drive.


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
    <disk>_read_merged_count,           Continous Counter,      Number of merged reads. See https://www.kernel.org/doc/Documentation/iostats.txt.
    <disk>_read_time,                   Continous Counter,      Time spent reading from disk (in milliseconds).
    <disk>_write_bytes,                 Continous Counter,      Number of bytes written.
    <disk>_write_bytes_per_second1,     Bytes,                  Current number of bytes written.
    <disk>_write_merged_count,          Continous Counter,      Number of merged writes. See https://www.kernel.org/doc/Documentation/iostats.txt.
    <disk>_write_time,                  Continous Counter,      Time spent writing to disk (in milliseconds).
    <disk>_bandwidth1,                  None,                   Bytes per second. read_bytes_per_second1 + write_bytes_per_second1.


Troubleshooting
---------------

``Query failed: INSERT INTO "perfdata" ...``
    Delete ``$TEMP/linuxfabrik-monitoring-plugins-disk-io.db`` and try again.

``psutil raised error "not sure how to interpret line '...'"`` or ``Nothing checked. Running Kernel >= 4.18, this check needs the Python module psutil v5.7.0+``
    Update the ``psutil`` library. On RHEL 8+, use at least ``python38`` and ``python38-psutil`` if using ``dnf``.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
