Check network-io
================

Overview
--------

Checks the network throughput over a period of time. The check tracks the maximum throughput and warns if the throughput over the last n readings is above a certain percentage (by default 80/90% over the last 5 readings). This works similar to Load5, but at the network I/O level.

Network I/O always starts with 10 MiB/sec, but stores the highest measured throughput (rx + tx), so it adjusts the ``rxtx-max/s`` value accordingly. For this reason, this check takes some time to warm up its (cached) readings: The check will throw some warnings and criticals during the first major network activity above 10Mib/sec until the maximum throughput of the network has been determined.

Example: The result of ``./network-io --count 5 --warning 80 --critical 90`` could look like this:

.. code-block:: text

    wlp0s20f3: 28.1MiB/s rx, 5.6KiB/s tx (current)

    Interface ! rxtx-max/s ! rx1/s   ! tx1/s  ! rx5/s    ! tx5/s  ! rxtx5/s  
    ----------+------------+---------+--------+----------+--------+----------
    tun0      ! 10.0MiB    ! 0.0B    ! 0.0B   ! 2.8B     ! 7.8B   ! 10.6B    
    tun2      ! 10.0MiB    ! 183.0B  ! 106.0B ! 2.9B     ! 7.9B   ! 10.8B    
    wlp0s20f3 ! 30.0MiB    ! 28.1MiB ! 5.6KiB ! 25.1 MiB ! 2.9KiB ! 25.1MiB [WARNING]

The first line always shows the interface with the currently highest throughput (here ``wlp0s20f3``).

The table columns mean:

* rxtx-max: Here, a maximum throughput of 30.0 MiB/sec was determined.
* rx1, tx1: The current throughput is 28.1 MiB/sec (receive) and 5.6 KiB/sec (transmit).
* rx5, tx5: The throughput from now to 5 measured values in the past is 25.1 MiB/sec (receive) and 2.9 KiB/sec (transmit).
* rxtx5: Compared to the current values, there was a higher throughput for a while. Since a maximum of 30.0 MB/sec throughput has been measured for this network so far, a mean throughput (rxtx5) value of 25.1 MB/sec results in a warning (``25.1 MB/sec >= 30.0 MB/sec * 80%``). The current value of 28.1 MiB/sec doesn't matter, this is only a peak. The check alerts because there is unusual high network I/O over a certain amount of time.

Hints:

* ``--count=5`` (the default) while checking every minute means that the check reports a warning if any of your interfaces were above a threshold in the last 5 minutes.
* The check uses the SQLite databases ``$TEMP/linuxfabrik-monitoring-plugins-network-io.db`` to store its historical data.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70

    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/network-io"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "Yes"
    "Compiled for Windows",                 "Yes"
    "3rd Party Python modules",             "``psutil``"
    "Handles Periods",                      "Yes"
    "Uses SQLite DBs",                      "``$TEMP/linuxfabrik-monitoring-plugins-network-io.db``"


Help
----

.. code-block:: text

    usage: network-io [-h] [-V] [--always-ok] [--count COUNT] [--critical CRIT]
                      [--ignore IGNORE] [--warning WARN]

    Checks network IO.

    options:
      -h, --help       show this help message and exit
      -V, --version    show program's version number and exit
      --always-ok      Always returns OK.
      --count COUNT    Number of times the value must exceed specified thresholds
                       before alerting. Default: 5
      --critical CRIT  Set the CRIT threshold for network I/O rx/tx rate over the
                       entire period as a percentage of the maximum network I/O
                       rate. Default: >= 90
      --ignore IGNORE  Ignore network interfaces starting with a string like "tun"
                       (repeating). Default: ['lo']
      --warning WARN   Set the CRIT threshold for network I/O rx/tx rate over the
                       entire period as a percentage of the maximum network I/O
                       rate. Default: >= 80


Usage Examples
--------------

.. code-block:: bash

    ./network-io --ignore lo --warning 80 --critical 90 --count 5

Output:

.. code-block:: text

    wlp0s20f3: 28.1MiB/s rx, 5.6KiB/s tx (current)

    Interface ! rxtx-max/s ! rx1/s   ! tx1/s  ! rx5/s    ! tx5/s  ! rxtx5/s  
    ----------+------------+---------+--------+----------+--------+----------
    tun0      ! 10.0MiB    ! 0.0B    ! 0.0B   ! 2.8B     ! 7.8B   ! 10.6B    
    tun2      ! 10.0MiB    ! 183.0B  ! 106.0B ! 2.9B     ! 7.9B   ! 10.8B    
    wlp0s20f3 ! 30.0MiB    ! 28.1MiB ! 5.6KiB ! 25.1 MiB ! 2.9KiB ! 25.1MiB [WARNING]


States
------

* WARN or CRIT if the throughput over the last n measured values is above a certain percentage, compared to the all time maximum throughput of this interface.


Perfdata / Metrics
------------------

Per network:

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                               Type,                   Description                                           
    <interface>_bytes_recv,             Continous Counter,      Number of bytes received.
    <interface>_bytes_recv_per_second1, Bytes,                  Current number of bytes received.
    <interface>_bytes_recv_per_second15,Bytes,                  Current number of bytes received.
    <interface>_bytes_sent,             Continous Counter,      Number of bytes sent.
    <interface>_bytes_sent_per_second1, Bytes,                  Current number of bytes sent.
    <interface>_bytes_sent_per_second15,Bytes,                  Current number of bytes sent.
    <interface>_dropin,                 Continous Counter,      Total number of incoming packets which were dropped.
    <interface>_dropout,                Continous Counter,      Total number of outgoing packets which were dropped (always 0 on macOS and BSD).
    <interface>_errin,                  Continous Counter,      Total number of errors while receiving.
    <interface>_errout,                 Continous Counter,      Total number of errors while sending.
    <interface>_packets_recv,           Continous Counter,      Number of packets received.
    <interface>_packets_sent,           Continous Counter,      Number of packets sent.
    <interface>_throughput1,            None,                   Bytes per second. bytes_recv_per_second1 + bytes_sent_per_second1.
    <interface>_throughput15,           None,                   Bytes per second. bytes_recv_per_second15 + bytes_sent_per_second15.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
