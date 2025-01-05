Check starface-status
=====================

Overview
--------

This plugin checks the overall health of the Starface PBX.

It uses the data output of the `Starface Monitoring Module <https://wiki.fluxpunkt.de/display/FPW/Monitoring>`_, which was originally written for Check_MK and listens on port 6556. Supports both IPv4 and IPv6. Fetched data is cached up to one minute, so that other Starface plugins running in parallel do not query the data again and overload the PBX.

Special features of this check:

* Connects directly via Socket.
* IPv4 (default), IPv6 capable.
* Fetched data is cached up to one minute and shared between other monitoring plugins dealing with Starface PBX, so that those checks running in parallel do not query the data again and overload the PBX.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70

    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/starface-status"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "Yes"
    "Compiled for",                         "Linux, Windows"
    "Requirements",                         "`Monitoring module for Starface PBX <https://wiki.fluxpunkt.de/display/FPW/Monitoring>`_"
    "Uses SQLite DBs",                      "``$TEMP/linuxfabrik-monitoring-plugins-starface.db``"


Help
----

.. code-block:: text

    usage: starface-status [-h] [-V] [--always-ok] [--cache-expire CACHE_EXPIRE]
                           [--critical CRIT] [-H HOSTNAME] [--port PORT]
                           [--test TEST] [--timeout TIMEOUT] [--warning WARN]
                           [--ipv6]

    Checks the overall health of the Starface PBX. It uses the data output of the
    Starface Monitoring Module, which was originally written for Check_MK and
    listens on port 6556. Supports both IPv4 and IPv6. Fetched data is cached up
    to one minute, so that other Starface plugins running in parallel do not query
    the data again and overload the PBX.

    options:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      --cache-expire CACHE_EXPIRE
                            The amount of time after which the cached data
                            expires, in minutes. Default: 1
      --critical CRIT       Set the critical threshold (percentage). Default: 90
      -H, --hostname HOSTNAME
                            Starface PBX address, can be IP address or hostname.
                            Default: localhost
      --port PORT           Starface PBX monitoring port. Default: 6556
      --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                            stderr-file,expected-retc".
      --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
      --warning WARN        Set the warning threshold (percentage). Default: 80
      --ipv6                Use IPv6.


Usage Examples
--------------

.. code-block:: bash

    ./starface-status --cache-expire 1 --hostname mypbx --port 6556 --timeout 3

Output:

.. code-block:: text

    STARFACE Free, v6.7.3.20, RAID Status: HEALTHY, 7 blacklisted hosts, SIP Status: OK, 97 phones online
    Owner: Linuxfabrik, 99 licensed users, 138 whitelisted hosts, 167 phones known, 3 phones changed IP, Up 2 weeks, 6 days, 21 hours, 21 minutes, 42 seconds


States
------

* WARN if RAID status != HEALTHY
* WARN if SIP status != OK


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                               Type,                   Description                                           
    starface_version,                   "Float",                "Version number as float"
    blacklisted_hosts,                  "Counter",              "Number of blacklisted hosts"
    whitelisted_hosts,                  "Counter",              "Number of whitelisted hosts"
    known_phones,                       "Counter",              "Number of known phones"
    online_phones,                      "Counter",              "Number of online phones"
    ip_changed_phones,                  "Counter",              "Number of phones which changed their IP addresses"


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
