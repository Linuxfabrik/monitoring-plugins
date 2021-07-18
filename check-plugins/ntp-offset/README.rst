Check ntp-offset
================

Overview
--------

This plugin checks the clock offset in milliseconds compared to ntp servers.

If ``chronyd`` is used, prints

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

If ``systemd-timesyncd`` is used and ``systemd`` v239 or higher is available, prints

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

If ``ntpd`` is used, prints

* address of the remote peer
* reference ID (0.0.0.0 if this is unknown)
* stratum of the remote peer
* type of the peer (local, unicast, multicast or broadcast)
* when the last packet was received
* polling interval in seconds
* reachability register in octal
* and the current estimated delay, offset and dispersion of the peer

``ntpd`` is deprecated on RHEL/CentOS 8+.

The stratum of the NTP time source determines its quality. The stratum is equal to the number of hops to a reference clock (which is stratum 0). A NTP server connected directly to the reference clock is Stratum 1, a client connected to this NTP server is Stratum 2, etc.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/ntp-offset"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "Yes"
    "Available for",                        "Python 2"
    "Requirements",                         "None"


Help
----

.. code-block:: text

    usage: ntp-offset [-h] [-V] [-c CRIT] [-w WARN]

    This plugin checks the clock offset with the ntp server.

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

    NTP offset is 0.515704ms (Stratum 3).
    Reference ID    : 9C6AD630 (delcatty.itu.ch)
    Stratum         : 3
    Ref time (UTC)  : Mon Jun 07 09:29:41 2021
    System time     : 0.000000042 seconds slow of NTP time
    Last offset     : +0.000515704 seconds
    RMS offset      : 0.069175042 seconds
    Frequency       : 1.998 ppm slow
    Residual freq   : +0.009 ppm
    Skew            : 0.221 ppm
    Root delay      : 0.012637243 seconds
    Root dispersion : 0.026016071 seconds
    Update interval : 3106.2 seconds
    Leap status     : Normal


States
------

* WARN or CRIT if ntp offset is above a given threshold.


Perfdata / Metrics
------------------

* Time Offset (Milliseconds)


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
