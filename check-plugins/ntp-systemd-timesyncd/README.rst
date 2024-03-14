Check ntp-systemd-timesyncd
===========================

Overview
--------

This plugin checks the state of systemd-timesyncd. It also prints

* ``LinkNTPServers``
* ``SystemNTPServers``
* ``FallbackNTPServers``
* ``ServerName``
* ``ServerAddress``
* ``RootDistanceMaxUSec``
* ``PollIntervalMinUSec``
* ``PollIntervalMaxUSec``
* ``PollIntervalUSec``
* ``NTPMessage``
* ``Frequency``

The stratum of the NTP time source determines its quality. The stratum is equal to the number of hops to a reference clock (which is stratum 0). A NTP server connected directly to the reference clock is Stratum 1, a client connected to this NTP server is Stratum 2, etc.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/ntp-systemd-timesyncd"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "Yes"
    "Compiled for",                         "Linux"


Help
----

.. code-block:: text

    usage: ntp-systemd-timesyncd [-h] [-V] [--test TEST]

    This plugin checks the state of systemd-timesyncd.

    options:
      -h, --help     show this help message and exit
      -V, --version  show program's version number and exit
      --test TEST    For unit tests. Needs "path-to-stdout-file,path-to-stderr-
                     file,expected-retc".


Usage Examples
--------------

.. code-block:: bash

    ./ntp-systemd-timesyncd
    
Output:

.. code-block:: text

    Stratum is 2

    LinkNTPServers=
    SystemNTPServers=0.arch.pool.ntp.org 1.arch.pool.ntp.org 2.arch.pool.ntp.org 3.arch.pool.ntp.org
    FallbackNTPServers=0.pool.ntp.org 1.pool.ntp.org 0.fr.pool.ntp.org
    ServerName=0.arch.pool.ntp.org
    ServerAddress=46.22.24.205
    RootDistanceMaxUSec=5s
    PollIntervalMinUSec=32s
    PollIntervalMaxUSec=34min 8s
    PollIntervalUSec=34min 8s
    NTPMessage={ Leap=0, Version=4, Mode=4, Stratum=2, Precision=-26, RootDelay=4.364ms, RootDispersion=534us, Reference=C3B01ACD, OriginateTimestamp=Sun 2022-08-07 10:09:44 UTC, ReceiveTimestamp=Sun 2022-08-07 10:09:44 UTC, TransmitTimestamp=Sun 2022-08-07 10:09:44 UTC, DestinationTimestamp=Sun 2022-08-07 10:09:44 UTC, Ignored=no PacketCount=6, Jitter=22.804ms }
    Frequency=-1365573


States
------

* WARN if stratum is >= 9.
* WARN if no NTP server is used.


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description      
    stratum,                                    Number,             Stratum


Troubleshooting
---------------

Failed to parse bus message: No such device or address
    You don't have ``systemd-timesyncd``.

No NTP server used.
    This message occurs when systemd-timesyncd is running, and systemd-timesyncd does (currently) not use any ntp server.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
