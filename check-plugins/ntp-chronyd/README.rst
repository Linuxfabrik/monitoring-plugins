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
    "Available for",                        "Python 3"
    "Requirements",                         "None"


Help
----

.. code-block:: text

    usage: ntp-chronyd [-h] [-V] [-c CRIT] [--test TEST] [-w WARN]

    This plugin checks the clock offset of chronyd in milliseconds compared to ntp
    servers.

    options:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      -c CRIT, --critical CRIT
                            Set the critical threshold for the ntp time offset, in
                            ms. Default: 86400000ms
      --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                            stderr-file,expected-retc".
      -w WARN, --warning WARN
                            Set the warning threshold for the ntp time offset, in
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
    frequency,                                  Number,             
    last_offset,                                Milliseconds,       Time offset in ms
    residual_freq,                              Number,             
    rms_offset,                                 Milliseconds,       
    root_delay,                                 Milliseconds,       
    root_dispersion,                            Milliseconds,       
    skew,                                       Number,             
    stratum,                                    Number,             Stratum


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
