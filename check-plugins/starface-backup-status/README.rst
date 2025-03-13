Check starface-backup-status
============================

Overview
--------

Checks the status of the newest backups of the Starface PBX.

It uses the data output of the `Starface Monitoring Module <https://wiki.fluxpunkt.de/display/FPW/Monitoring>`_, which was originally written for Check_MK and listens on port 6556. Supports both IPv4 and IPv6. Fetched data is cached up to one minute, so that other Starface plugins running in parallel do not query the data again and overload the PBX.

Special features of this check:

* Connects directly via Socket.
* IPv4 (default), IPv6 capable.
* Fetched data is cached up to one minute and shared between other monitoring plugins dealing with Starface PBX, so that those checks running in parallel do not query the data again and overload the PBX.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70

    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/starface-backup-status"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "Yes"
    "Compiled for",                         "Linux, Windows"
    "Requirements",                         "`Monitoring module for Starface PBX <https://wiki.fluxpunkt.de/display/FPW/Monitoring>`_"
    "Uses SQLite DBs",                      "``$TEMP/linuxfabrik-monitoring-plugins-starface.db``"


Help
----

.. code-block:: text

    usage: starface-backup-status [-h] [-V] [--always-ok]
                                  [--cache-expire CACHE_EXPIRE] [-c CRIT]
                                  [-H HOSTNAME] [--port PORT] [--test TEST]
                                  [--timeout TIMEOUT] [-w WARN] [--ipv6]

    Checks the status of the newest backups of the Starface PBX. It uses the data
    output of the Starface Monitoring Module, which was originally written for
    Check_MK and listens on port 6556. Supports both IPv4 and IPv6. Fetched data
    is cached up to one minute, so that other Starface plugins running in parallel
    do not query the data again and overload the PBX.

    options:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      --cache-expire CACHE_EXPIRE
                            The amount of time after which the cached data
                            expires, in minutes. Default: 1
      -c, --critical CRIT   Set the critical threshold for the time difference to
                            the start of the last backup (in hours). Default: None
      -H, --hostname HOSTNAME
                            Starface PBX address, can be IP address or hostname.
                            Default: localhost
      --port PORT           Starface PBX monitoring port. Default: 6556
      --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                            stderr-file,expected-retc".
      --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
      -w, --warning WARN    Set the warning threshold for the time difference to
                            the start of the last backup (in hours). Default: 24
      --ipv6                Use IPv6.


Usage Examples
--------------

.. code-block:: bash

    ./starface-backup-status --cache-expire 1 --hostname mypbx --port 6556 --timeout 3

Output:

.. code-block:: text

    Last Backup to [HDD] at 2021-06-21 01:14:07 (13h 45m ago) was successful.


States
------

Triggers an alarm if the last backup is too long ago.

* Returns WARN or CRIT for the time difference to the start of the last backup


Perfdata / Metrics
------------------

There is no perfdata.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
