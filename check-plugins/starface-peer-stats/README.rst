Check starface-peer-stats
=========================

Overview
--------

This check plugin returns the peer statistics of the Starface PBX.

It uses the data output of the `Starface Monitoring Module <https://wiki.fluxpunkt.de/display/FPW/Monitoring>`_, which was originally written for Check_MK and listens on port 6556. Supports both IPv4 and IPv6. Fetched data is cached up to one minute, so that other Starface plugins running in parallel do not query the data again and overload the PBX.

Special features of this check:

* Connects directly via Socket.
* IPv4 (default), IPv6 capable.
* Fetched data is cached up to one minute and shared between other monitoring plugins dealing with Starface PBX, so that those checks running in parallel do not query the data again and overload the PBX.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70

    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/starface-peer-status"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "Yes"
    "Compiled for Windows",                 "No"
    "Requirements",                         "`Monitoring module for Starface PBX <https://wiki.fluxpunkt.de/display/FPW/Monitoring>`_"
    "Uses SQLite DBs",                      "``$TEMP/linuxfabrik-monitoring-plugins-starface.db``"


Help
----

.. code-block:: text

    usage: starface-peer-stats [-h] [-V] [--cache-expire CACHE_EXPIRE]
                               [-H HOSTNAME] [--port PORT] [--test TEST]
                               [--timeout TIMEOUT] [--ipv6]

    Returns the peer statistics of the Starface PBX. It uses the data output of
    the Starface Monitoring Module, which was originally written for Check_MK and
    listens on port 6556. Supports both IPv4 and IPv6. Fetched data is cached up
    to one minute, so that other Starface plugins running in parallel do not query
    the data again and overload the PBX.

    options:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --cache-expire CACHE_EXPIRE
                            The amount of time after which the cached data
                            expires, in minutes. Default: 1
      -H, --hostname HOSTNAME
                            Starface PBX address, can be IP address or hostname.
                            Default: localhost
      --port PORT           Starface PBX monitoring port. Default: 6556
      --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                            stderr-file,expected-retc".
      --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
      --ipv6                Use IPv6.


Usage Examples
--------------

.. code-block:: bash

    ./starface-peer-status --cache-expire 1 --hostname mypbx --port 6556 --timeout 3

Output:

.. code-block:: text

    169 SIP Peers: 98 online / 70 offline (monitored), 1 online / 0 offline (unmonitored)


States
------

* Always returns OK.


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                               Type,                   Description                                           
    mon_offline,                        "Counter",              "Number of monitored offline peers"
    mon_online,                         "Counter",              "Number of monitored online peers"
    sip_peers,                          "Counter",              "Number of SIP peers"
    unmon_offline,                      "Counter",              "Number of unmonitored offline peers"
    unmon_online,                       "Counter",              "Number of unmonitored online peers"


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
