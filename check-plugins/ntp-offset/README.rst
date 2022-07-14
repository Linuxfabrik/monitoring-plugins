Check ntp-offset
================

Overview
--------

This plugin checks the clock offset in milliseconds compared to ntp servers.

If ``chronyd`` is used, it prints

* frequency
* last offset
* leap status
* ref time (utc)
* reference id
* residual freq
* rms offset
* root delay
* root dispersion
* skew
* stratum
* system time
* update interval

If ``systemd-timesyncd`` is used and ``systemd`` v239 or higher is available, it prints

* delay
* frequency
* jitter
* leap
* offset
* packet count
* poll interval
* precision
* reference
* root distance
* server
* stratum
* version

If ``ntpd`` is used, it prints

* address of the remote peer
* reference ID (0.0.0.0 if this is unknown)
* stratum of the remote peer
* type of the peer (local, unicast, multicast or broadcast)
* when the last packet was received
* polling interval in seconds
* reachability register in octal
* and the current estimated delay, offset and dispersion of the peer

``ntpd`` is deprecated on RHEL 8+.

The stratum of the NTP time source determines its quality. The stratum is equal to the number of hops to a reference clock (which is stratum 0). A NTP server connected directly to the reference clock is Stratum 1, a client connected to this NTP server is Stratum 2, etc.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/ntp-offset"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "Yes"
    "Available for",                        "Python 2, Python 3"
    "Requirements",                         "None"


Help
----

.. code-block:: text

    usage: ntp-offset2 [-h] [-V] [-c CRIT] [-w WARN]

    This plugin checks the clock offset in milliseconds compared to ntp servers.

    optional arguments:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      -c CRIT, --critical CRIT
                            Set the critical threshold for the ntp time offset, in
                            ms. Default: 1001ms
      -w WARN, --warning WARN
                            Set the warning threshold for the ntp time offset, in
                            ms. Default: 800ms


Usage Examples
--------------

.. code-block:: bash

    ./ntp-offset --warning 500 --critical 1000
    
Output:

.. code-block:: text

    chronyd: NTP offset is 50us 926ns, Stratum is 2

    Reference ID    : 54104921 (tick.ntp.infomaniak.ch)
    Stratum         : 2
    Ref time (UTC)  : Thu Jul 14 11:58:14 2022
    System time     : 0.000107969 seconds slow of NTP time
    Last offset     : +0.000050926 seconds
    RMS offset      : 0.000800193 seconds
    Frequency       : 24.956 ppm fast
    Residual freq   : +0.078 ppm
    Skew            : 1.753 ppm
    Root delay      : 0.008431715 seconds
    Root dispersion : 0.000363616 seconds
    Update interval : 257.2 seconds
    Leap status     : Normal


States
------

* WARN or CRIT if ntp offset is above a given threshold.
* WARN if stratum is >= 9.


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description                                           
    offset,                                     Milliseconds,       Time offset in ms


Troubleshooting
---------------

No NTP server used.
    This message occurs when

    * ntpd is running, and ntpd does not returns any ntp server
    * any of chrony, ntpd or systemd-timesyncd uses the LOCAL clock

    In both cases UNKNOWN is returned.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
