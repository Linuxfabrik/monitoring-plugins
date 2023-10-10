Check ntp-w32tm
===============

Overview
--------

This monitoring plugin runs ``w32tm /query /status /verbose`` (Windows) to help diagnose problems with the time settings.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/ntp-w32tm"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "Yes"
    "Compiled for",                         "Windows"


Help
----

.. code-block:: text

    usage: ntp-w32tm [-h] [-V] [-c CRIT] [--test TEST] [-w WARN]

    This monitoring plugin runs `w32tm /query /status /verbose` (Windows) to help
    diagnose problems with the time settings.

    options:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      -c CRIT, --critical CRIT
                            Set the critical threshold for the time since "Last
                            Good Sync", in s. Default: 129600s
      --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                            stderr-file,expected-retc".
      -w WARN, --warning WARN
                            Set the warning threshold for the time since "Last
                            Good Sync", in s. Default: 28800s


Usage Examples
--------------

.. code-block:: bash

    ./ntp-w32tm --warning 28800 --critical 129600
    
Output:

.. code-block:: text

    Leap Indicator: 3 (not synchronized), No NTP server used [WARNING], Last Sync Error: 1 (The computer did not resync because no time data was available.)

    Leap Indicator: 3(not synchronized)
    Stratum: 0 (unspecified)
    Precision: -23 (119.209ns per tick)
    Root Delay: 0.0267908s
    Root Dispersion: 0.0402331s
    ReferenceId: 0x00000000 (unspecified)
    Last Successful Sync Time: 9/16/2023 12:52:13 PM
    Source: time.windows.com,0x8
    Poll Interval: 6 (64s)

    Phase Offset: 0.7679486s
    ClockRate: 0.0156250s
    State Machine: 0 (Unset)
    Time Source Flags: 0 (None)
    Server Role: 0 (None)
    Last Sync Error: 1 (The computer did not resync because no time data was available.)
    Time since Last Good Sync Time: 19.2218793s


States
------

* WARN if no NTP server is used.
* WARN if stratum is >= 5.
* WARN if "Leap Indicator" is not "0(no warning)"
* WARN if "Last Sync Error" is not "0"
* WARN or CRIT if "Time since Last Good Sync Time" is above a given threshold.


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description      
    clock_rate,                                 Milliseconds,
    leap_indicator,                             Number,             "Indicates whether an impending leap second is to be inserted or deleted in the last minute of the current day."
    phase_offset,                               Milliseconds,
    precision,                                  Number,
    root_delay,                                 Milliseconds,       "This is the total of the network path delays to the stratum-1 computer from which the computer is ultimately synchronized. In certain extreme situations, this value can be negative. (This can arise in a symmetric peer arrangement where the computers’ frequencies are not tracking each other and the network delay is very short relative to the turn-around time at each computer.)"
    root_dispersion,                            Milliseconds,       "This is the total dispersion accumulated through all the computers back to the stratum-1 computer from which the computer is ultimately synchronized. Dispersion is due to system clock resolution, statistical measurement variations etc."
    stratum,                                    Number,             "The stratum indicates how many hops away from a computer with an attached reference clock we are. Such a computer is a stratum-1 computer, so the computer in the example is two hops away (that is to say, a.b.c is a stratum-2 and is synchronized from a stratum-1)."
    time_since_last_good_sync_time,             Seconds


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
