Check starface-channel-status
=============================

Overview
--------

Counts the number of current active DAHDI, SIP or other channels of the Starface PBX, and warns on possibly overusage (in percentage).

It uses the data output of the `Starface Monitoring Module <https://wiki.fluxpunkt.de/display/FPW/Monitoring>`_, which was originally written for Check_MK and listens on port 6556. Supports both IPv4 and IPv6. Fetched data is cached up to one minute, so that other Starface plugins running in parallel do not query the data again and overload the PBX.

Special features of this check:

* Connects directly via Socket.
* IPv4 (default), IPv6 capable.
* Fetched data is cached up to one minute and shared between other monitoring plugins dealing with Starface PBX, so that those checks running in parallel do not query the data again and overload the PBX.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/starface-channel-status"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "Yes"
    "Compiled for",                         "Linux, Windows"
    "Requirements",                         "`Monitoring module for Starface PBX <https://wiki.fluxpunkt.de/display/FPW/Monitoring>`_"
    "Uses SQLite DBs",                      "Yes"


Help
----

.. code-block:: text

    usage: starface-channel-status [-h] [-V] [--always-ok]
                                   [--cache-expire CACHE_EXPIRE]
                                   [--critical CRIT] [-H HOSTNAME] [--port PORT]
                                   [--test TEST] [--timeout TIMEOUT]
                                   [--warning WARN] [-6]

    Counts the number of current active DAHDI, SIP or other channels of the
    Starface PBX, and warns on possibly overusage (in percentage). It uses the
    data output of the Starface Monitoring Module, which was originally written
    for Check_MK and listens on port 6556. Supports both IPv4 and IPv6. Fetched
    data is cached up to one minute, so that other Starface plugins running in
    parallel do not query the data again and overload the PBX.

    optional arguments:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      --cache-expire CACHE_EXPIRE
                            The amount of time after which the cached data
                            expires, in minutes. Default: 1
      --critical CRIT       Set the critical threshold (percentage). Default: 90
      -H HOSTNAME, --hostname HOSTNAME
                            Starface PBX address, can be IP address or hostname.
                            Default: localhost
      --port PORT           Starface PBX monitoring port. Default: 6556
      --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                            stderr-file,expected-retc".
      --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
      --warning WARN        Set the warning threshold (percentage). Default: 80
      -6, --6               Use IPv6.


Usage Examples
--------------

.. code-block:: bash

    ./starface-channel-status --cache-expire 1 --hostname mypbx --port 6556 --timeout 3

Output:

.. code-block:: text

    Current channels: 4x DAHDI, 7x SIP


States
------

Triggers an alarm on usage in percent.

* WARN or CRIT if channel usage is above 80/90% (defaults)


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                               Type,                   Description                                           
    channel_dahdi,                      "Counter",              "Number of currently active DHADI connections"
    channel_other,                      "Counter",              "Number of all other currently active connections"
    channel_sip,                        "Counter",              "Number of currently active SIP connections"



Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
