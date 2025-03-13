Check ntp-chronyd
=================

Overview
--------

This plugin checks the clock offset of chronyd in milliseconds compared to ntp servers. It also prints

* ``Reference ID``
* ``Stratum``
* ``Ref time (UTC)``
* ``System time``
* ``Last offset``
* ``RMS offset``
* ``Frequency``
* ``Residual freq``
* ``Skew``
* ``Root delay``
* ``Root dispersion``
* ``Update interval``
* ``Leap status``

The stratum of the NTP time source determines its quality. The stratum is equal to the number of hops to a reference clock (which is stratum 0). A NTP server connected directly to the reference clock is Stratum 1, a client connected to this NTP server is Stratum 2, etc.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70

    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/ntp-chronyd"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "Yes"
    "Compiled for",                         "Linux"


Help
----

.. code-block:: text

    usage: ntp-chronyd [-h] [-V] [-c CRIT] [--test TEST] [-w WARN]

    This plugin checks the clock offset of chronyd in milliseconds compared to ntp
    servers.

    options:
      -h, --help           show this help message and exit
      -V, --version        show program's version number and exit
      -c, --critical CRIT  Set the critical threshold for the ntp time offset, in
                           ms. Default: 86400000ms
      --test TEST          For unit tests. Needs "path-to-stdout-file,path-to-
                           stderr-file,expected-retc".
      -w, --warning WARN   Set the warning threshold for the ntp time offset, in
                           ms. Default: 800ms


Usage Examples
--------------

.. code-block:: bash

    ./ntp-chronyd --warning 500 --critical 10000
    
Output:

.. code-block:: text

    NTP offset is 0.698234ms, Stratum is 3, Leap status is Normal

    Reference ID    : C3BA0165 (bwntp1pool.bluewin.ch)
    Stratum         : 3
    Ref time (UTC)  : Sun Aug 07 10:02:47 2022
    System time     : 0.000254363 seconds slow of NTP time
    Last offset     : +0.000698234 seconds
    RMS offset      : 0.028022379 seconds
    Frequency       : 23.159 ppm fast
    Residual freq   : -0.032 ppm
    Skew            : 6.203 ppm
    Root delay      : 0.068764083 seconds
    Root dispersion : 0.016749078 seconds
    Update interval : 518.9 seconds
    Leap status     : Normal

Example of an alert:

.. code-block:: text

    NTP server not reachable. No NTP server is used.

    MS Name/IP address         Stratum Poll Reach LastRx Last sample               
    ===============================================================================
    ^? ntp1.hetzner.de               0   6     0     -     +0ns[   +0ns] +/-    0ns


States
------

* WARN or CRIT if ntp offset is below or above a given threshold.
* WARN if stratum is >= 9.
* WARN if no NTP server is used.
* WARN if no NTP server is found.


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description      
    frequency,                                  ppm,                "The 'frequency' is the rate by which the system’s clock would be wrong if chronyd was not correcting it. It is expressed in ppm (parts per million). For example, a value of 1 ppm would mean that when the system’s clock thinks it has advanced 1 second, it has actually advanced by 1.000001 seconds relative to true time."
    last_offset,                                Milliseconds,       "This is the estimated local offset on the last clock update."
    residual_freq,                              ppm,                "This shows the 'residual frequency' for the currently selected reference source. This reflects any difference between what the measurements from the reference source indicate the frequency should be and the frequency currently being used. The reason this is not always zero is that a smoothing procedure is applied to the frequency. Each time a measurement from the reference source is obtained and a new residual frequency computed, the estimated accuracy of this residual is compared with the estimated accuracy (see skew next) of the existing frequency value. A weighted average is computed for the new frequency, with weights depending on these accuracies. If the measurements from the reference source follow a consistent trend, the residual will be driven to zero over time."
    rms_offset,                                 Milliseconds,       "This is a long-term average of the offset value."
    root_delay,                                 Milliseconds,       "This is the total of the network path delays to the stratum-1 computer from which the computer is ultimately synchronized. In certain extreme situations, this value can be negative. (This can arise in a symmetric peer arrangement where the computers’ frequencies are not tracking each other and the network delay is very short relative to the turn-around time at each computer.)"
    root_dispersion,                            Milliseconds,       "This is the total dispersion accumulated through all the computers back to the stratum-1 computer from which the computer is ultimately synchronized. Dispersion is due to system clock resolution, statistical measurement variations etc."
    skew,                                       ppm,                "This is the estimated error bound on the frequency."
    stratum,                                    Number,             "The stratum indicates how many hops away from a computer with an attached reference clock we are. Such a computer is a stratum-1 computer, so the computer in the example is two hops away (that is to say, a.b.c is a stratum-2 and is synchronized from a stratum-1)."

Source of description: https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/system_administrators_guide/ch-configuring_ntp_using_the_chrony_suite


Troubleshooting
---------------

OS Error "2 No such file or directory" calling command "chronyc tracking"
    You don't have ``chronyd``.

No NTP server used.
    This message occurs when chronyd is running, and chronyd does (currently) not use any ntp server.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
