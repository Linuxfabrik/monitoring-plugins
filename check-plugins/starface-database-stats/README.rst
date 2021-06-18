Check example
=============

Overview
--------

This plugin processes the database statistics of the Starface PBX.

It uses the data output of the Starface Monitoring Module, which was originally written for Check_MK and listens on port 6556. Supports both IPv4 and IPv6. Fetched data is cached up to one minute, so that other Starface plugins running in parallel do not query the data again and overload the PBX.

Hints:

* The check plugin relies on the `Monitoring module for Starface PBX <https://wiki.fluxpunkt.de/display/FPW/Monitoring>`_ - technically a Check_MK agent running on your Starface PBX and listening on port 6556.

Special features of this check:

* Connects directly via Socket.
* IPv4 (default), IPv6 capable.
* Fetched data is cached up to one minute and shared between other monitoring plugins dealing with Starface PBX, so that those checks running in parallel do not query the data again and overload the PBX.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/starface-database-stats"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "Yes"
    "Available for",                        "Python 2, Python 3"
    "Requirements",                         "`Monitoring module for Starface PBX <https://wiki.fluxpunkt.de/display/FPW/Monitoring>`_"
    "Uses SQLite DBs",                      "Yes"


Help
----

.. code-block:: text

    usage: starface-database-stats [-h] [-V] [--cache-expire CACHE_EXPIRE]
                                   [-H HOSTNAME] [--port PORT] [--test TEST]
                                   [--timeout TIMEOUT] [-6]

    This plugin processes the database statistics of the Starface PBX. It uses the
    data output of the Starface Monitoring Module, which was originally written
    for Check_MK and listens on port 6556. Supports both IPv4 and IPv6. Fetched
    data is cached up to one minute, so that other Starface plugins running in
    parallel do not query the data again and overload the PBX.

    optional arguments:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --cache-expire CACHE_EXPIRE
                            The amount of time after which the cached data
                            expires, in minutes. Default: 1
      -H HOSTNAME, --hostname HOSTNAME
                            Starface PBX address, can be IP address or hostname.
                            Default: localhost
      --port PORT           Starface PBX monitoring port. Default: 6556
      --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                            stderr-file,expected-retc".
      --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
      -6, --6               Use IPv6.


Usage Examples
--------------

.. code-block:: bash

    ./starface-database-stats --cache-expire 1 --hostname mypbx --port 6556 --timeout 3

Output:

.. code-block:: text

    Connections: 25.4M opened, 25.4M closed, 20.0 active, 1.0 idle


States
------

* Always returns OK.


Perfdata / Metrics
------------------

There is no perfdata.

OR

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                               Type,                   Description                                           
    active_connections,                 "Count",                "Number of currently active database connections"
    closed_connections,                 "Continous Counter",    "Number of closed database connections"
    idle_connections,                   "Count",                "Number of currently idle database connections"
    opened_connections,                 "Continous Counter",    "Number of opened database connections"


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
