Check starface-java-memory-usage
================================

Overview
--------

This check plugin monitors the heap and non-heap memory usage of the Java VM of the Starface PBX.

It uses the data output of the `Starface Monitoring Module <https://wiki.fluxpunkt.de/display/FPW/Monitoring>`_, which was originally written for Check_MK and listens on port 6556. Supports both IPv4 and IPv6. Fetched data is cached up to one minute, so that other Starface plugins running in parallel do not query the data again and overload the PBX.

Special features of this check:

* Connects directly via Socket.
* IPv4 (default), IPv6 capable.
* Fetched data is cached up to one minute and shared between other monitoring plugins dealing with Starface PBX, so that those checks running in parallel do not query the data again and overload the PBX.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/starface-java-memory-usage"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "Yes"
    "Available for",                        "Python 2, Python 3, Windows"
    "Requirements",                         "`Monitoring module for Starface PBX <https://wiki.fluxpunkt.de/display/FPW/Monitoring>`_"
    "Uses SQLite DBs",                      "Yes"


Help
----

.. code-block:: text

    usage: starface-java-memory-usage [-h] [-V] [--always-ok]
                                      [--cache-expire CACHE_EXPIRE]
                                      [--critical CRIT] [-H HOSTNAME]
                                      [--port PORT] [--test TEST]
                                      [--timeout TIMEOUT] [--warning WARN] [-6]

    Monitors the heap and non-heap memory usage of the Java VM of the Starface
    PBX. It uses the data output of the Starface Monitoring Module, which was
    originally written for Check_MK and listens on port 6556. Supports both IPv4
    and IPv6. Fetched data is cached up to one minute, so that other Starface
    plugins running in parallel do not query the data again and overload the PBX.

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

    ./starface-java-memory-usage --cache-expire 1 --hostname mypbx --port 6556 --timeout 3

Output:

.. code-block:: text

    Heap used: 5.2% (277.7MiB of 5.2GiB), Non-Heap used: 303.2MiB (unlimited memory usage allowed)


States
------

Triggers an alarm on usage in percent.

* WARN or CRIT if memory usage (used heap or non-heap) is above certain thresholds (default 80/90%)


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                               Type,                   Description                                           
    heap-max,                           "Bytes",                "Max available Java heap space"
    heap-used,                          "Bytes",                "Current used Java heap space"
    heap-used-percent,                  "Percentage",           "heap-used / heap-max \* 100"
    non-heap-max,                       "Bytes",                "Max available Java non-heap space"
    non-heap-used,                      "Bytes",                "Current used Java non-heap space"
    non-heap-used-percent,              "Percentage",           "non-heap-used / non-heap-max \* 100"


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
