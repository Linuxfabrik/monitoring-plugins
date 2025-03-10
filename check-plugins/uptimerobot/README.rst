Check uptimerobot
=================

Overview
--------

Alerts on all monitors in down or unknown status on a given UptimeRobot status page.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70

    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/uptimerobot"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "Yes"
    "Compiled for",                         "Linux, Windows"


Help
----

.. code-block:: text

    usage: uptimerobot [-h] [-V] [--always-ok] [--insecure] [--no-proxy]
                       [--test TEST] [--timeout TIMEOUT] [--url URL]

    Alerts on all monitors in down or unknown status on a given UptimeRobot status
    page.

    options:
      -h, --help         show this help message and exit
      -V, --version      show program's version number and exit
      --always-ok        Always returns OK.
      --insecure         This option explicitly allows to perform "insecure" SSL
                         connections. Default: False
      --no-proxy         Do not use a proxy. Default: False
      --test TEST        For unit tests. Needs "path-to-stdout-file,path-to-
                         stderr-file,expected-retc".
      --timeout TIMEOUT  Network timeout in seconds. Default: 8 (seconds)
      --url URL          UptimeRobot Status Page URL. Default:
                         https://status.linuxfabrik.io


Usage Examples
--------------

.. code-block:: bash

    ./uptimerobot --url=https://status.linuxfabrik.io

Output:

.. code-block:: text

    0/0/3 of 3 monitors are down/paused/up, 24h uptime: 99.976%

    Name                      ! Type    ! State 
    --------------------------+---------+-------
    001 cloud.linuxfabrik.io  ! HTTP(s) ! [OK]  
    001 office.linuxfabrik.io ! HTTP(s) ! [OK]  
    001 ws.linuxfabrik.io     ! HTTP(s) ! [OK]


States
------

* WARN if any monitor is in "danger" state.
* OK if all monitors are in "success" state, else UNKNOWN.


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1

    Name,                                       Type,               Description                                           
    cnt_down,                                   Number,             Number of monitors in "down" state
    cnt_paused,                                 Number,             Number of monitors in "paused" state
    cnt_up,                                     Number,             Number of monitors in "up" state


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
