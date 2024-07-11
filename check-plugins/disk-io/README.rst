Check disk-io
=============

Overview
--------

Checks disk bandwidth over a period of time. The check tracks the maximum bandwidth and alerts if the bandwidth over the last n reads is above a certain percentage (by default 80/90% over the last 5 reads). This works similar to Load5, but at the disk I/O level.

On Linux, the check plugin by default tries to find "important" disks automatically and returns only useful perfdata information, so as not to waste disk space in a time series database with unnecessary disk information (as in earlier versions). To do this, it looks for disks that are mounted to a folder. If you want to monitor more disk than the automatic scan provides, you can use the match parameter. This will generate a list of all disks including the "important" ones and will then act on the ones matching the regex provided. This is indeed necessary on systems with e.g zfs pools, where the pools will not be automatically recognised and you will need to monitor the raw disks with the match option. As a starting point the following regex match will include most disks ``^(nvme[0-9]{1,}n[0-9]{1,}$|[sv]d[a-z][0-9]{1,}|md|dm)``

Disk I/O always starts at 10 MiB/sec, but stores the highest measured bandwidth, so it adjusts the ``RWmax/s`` value accordingly. For this reason, this check takes some time to warm up its (cached) readings: The check will throw some warnings and criticals during the first major disk activities above 10Mib/sec until the maximum bandwidth of the disk has been determined.

Example: The (shortened) result of ``./disk-io --count 5 --warning 80 --critical 90`` could look like this:

.. code-block:: text
    /dev/dm-0: 0.0B/s read1, 380.0KiB/s write1, 380.0KiB/s total, 10.0MiB/s max, 0/s readops, 89/s writeops

    Name ! MntPnts ! DvMppr      ! RWmax/s ! R1/s    ! W1/s     ! R5/s    ! W5/s    ! RW5/s              ! R1/s ! W1/s ! R5/s ! W5/s
    -----+---------+-------------+---------+---------+----------+---------+---------+--------------------+------+------+------+------
    dm-0 ! /       ! ubuntu-root ! 44.9MiB ! 42.8MiB ! 17.2MiB  ! 23.1MiB ! 18.6MiB ! 36.3MiB [CRITICAL] ! 0    ! 89   ! 0    ! 71
    md0  ! /boot   !             ! 10.0MiB ! 0.0B    ! 0.0B     ! 0.0B    ! 0.0B    ! 0.0B               ! 0    ! 0    ! 0    ! 0
    dm-2 ! /var    ! ubuntu-var  ! 10.0MiB ! 0.0B    ! 0.0B     ! 0.0B    ! 0.0B    ! 0.0B               ! 0    ! 0    ! 0    ! 0
    dm-1 ! /home   ! ubuntu-home ! 10.0MiB ! 0.0B    ! 0.0B     ! 0.0B    ! 0.0B    ! 0.0B               ! 0    ! 0    ! 0    ! 0            
    ...

The first line always shows the disk with the currently highest bandwidth (here ``dm-0``).

The table columns mean:

* RWmax: Here, a maximum bandwidth of 44.9 MB/sec was determined.
* R1, W1: The current bandwidth is 23.6 MB/sec read and 17.2 MB/sec write.
* R5, W5: The bandwidth from now to 5 measured values in the past is 23.1 MB/sec read and 18.6 MB/sec write.
* First line in the table, RW5: Compared to the current values, there was a higher bandwidth for a while. Since a maximum of 44.9 MB/sec bandwidth has been measured for this disk so far, a mean bandwidth (RW5) value of 36.3 MB/sec results in a warning (``36.3 MB/sec >= 44.9 MB/sec * 80%``). The current value of 42.8 MB/sec doesn't matter, this is only a peak. The check alerts because there is unusual high disk I/O over a certain amount of time.
* R1, W1: The current IOPs for read and write
* R5, W5: The IOPs from now to 5 measured valued in the past for read and write

Hints:

* ``--count=5`` (the default) while checking every minute means that the check will report an alert if any of your disks have been above a threshold in the last 5 minutes.
* The check uses the SQLite database ``$TEMP/linuxfabrik-monitoring-plugins-disk-io.db`` to store its historical data.


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

    usage: disk-io [-h] [-V] [--always-ok] [--count COUNT] [--critical CRIT]
                   [--match MATCH] [--top TOP] [--warning WARN]

    Checks disk I/O. If the bandwidth usage of a disk is above the specified
    threshold (as a percentage of the maximum bandwidth measured) for a certain
    period of time, an alarm is triggered.

    options:
      -h, --help       show this help message and exit
      -V, --version    show program's version number and exit
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
                       more times. Default:
      --top TOP        List x "Top processes that generated the most I/O traffic".
                       Default: 5
      --warning WARN   Threshold for disk bandwidth saturation (over the last
                       `--count` measurements) as a percentage of the maximum
                       bandwidth the disk can support. Default: >= 80


Usage Examples
--------------

Just check disk ``dm-0`` (if listed as ``/dev/dm-0``):

.. code-block:: bash

    ./disk-io --match='dm-0$'

Match all disks except ``vdc``, ``vdh`` and ``vdz``:

.. code-block:: bash

    ./disk-io --match='^(?:(?!vdc|vdh|vdz).)*$'

Match all disks starting with sd, vd, md, dm and nvme disks except the raw disk itself

.. code-block:: bash

    ./disk-io --match='^(nvme[0-9]{1,}n[0-9]{1,}$|[sv]d[a-z][0-9]{1,}|md|dm)'

Example Output:

.. code-block:: text

    /dev/dm-0: 0.0B/s read1, 380.0KiB/s write1, 380.0KiB/s total, 10.0MiB/s max, 0/s readops, 89/s writeops

    Name ! MntPnts ! DvMppr      ! RWmax/s ! R1/s ! W1/s     ! R5/s ! W5/s     ! RW5/s    ! R1/s ! W1/s ! R5/s ! W5/s
    -----+---------+-------------+---------+------+----------+------+----------+----------+------+------+------+------
    dm-0 ! /       ! ubuntu-root ! 10.0MiB ! 0.0B ! 380.0KiB ! 0.0B ! 305.0KiB ! 305.0KiB ! 0    ! 89   ! 0    ! 71
    md0  ! /boot   !             ! 10.0MiB ! 0.0B ! 0.0B     ! 0.0B ! 0.0B     ! 0.0B     ! 0    ! 0    ! 0    ! 0
    dm-2 ! /var    ! ubuntu-var  ! 10.0MiB ! 0.0B ! 0.0B     ! 0.0B ! 0.0B     ! 0.0B     ! 0    ! 0    ! 0    ! 0
    dm-1 ! /home   ! ubuntu-home ! 10.0MiB ! 0.0B ! 0.0B     ! 0.0B ! 0.0B     ! 0.0B     ! 0    ! 0    ! 0    ! 0

    Top 5 processes that generate the most I/O traffic:
    1. nfsd: 149.2GiB/5.7TiB (r/w)
    2. systemd: 695.7GiB/169.9GiB (r/w)
    3. systemd-journald: 33.9MiB/124.4GiB (r/w)
    4. icinga2: 7.9GiB/4.9GiB (r/w)
    5. rsyslogd: 114.8MiB/4.1GiB (r/w)


States
------

* WARN or CRIT if the bandwidth over the last n measured values is above a certain percentage, compared to the all time maximum bandwidth of this drive.


Perfdata / Metrics
------------------

Per (matched) disk, where <disk> is the block device name:

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                               Type,                   Description                                           
    <disk>_busy_time,                   Continous Counter,      Time spent doing actual I/Os (in milliseconds).
    <disk>_read_bytes,                  Continous Counter,      Number of bytes read.
    <disk>_read_count,                  Continous Counter,      Number of read operations.
    <disk>_read_time,                   Continous Counter,      Time spent reading from disk (in milliseconds).
    <disk>_write_bytes,                 Continous Counter,      Number of bytes written.
    <disk>_write_count,                 Continous Counter,      Number of write operations.
    <disk>_write_time,                  Continous Counter,      Time spent writing to disk (in milliseconds).


Troubleshooting
---------------

``psutil raised error "not sure how to interpret line '...'"`` or ``Nothing checked. Running Kernel >= 4.18, this check needs the Python module psutil v5.7.0+``
    Update the ``psutil`` library. On RHEL 8+, use at least ``python38`` and ``python38-psutil`` if using ``dnf``.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
