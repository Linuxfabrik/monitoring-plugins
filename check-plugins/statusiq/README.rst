Check statusiq
===============

Overview
--------

StatusIQ is a hosted status page provided by Site24x7. This check plugin retrieves the StatusIQ status page (must be rss-enabled) and returns a specific status - OK for "Operational" or "Informational" messages, WARN for "Under Maintenance", "Degraded Performance" and "Partial Outage", and CRIT for "Major Outage" messages. You only need to provide the URL to the StatusIQ page, for example "https://status.trustid.ch".


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70

    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/statusiq"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "Yes"
    "Compiled for",                         "Linux, Windows"
    "3rd Party Python modules",             "``beautifulsoup``"


Help
----

.. code-block:: text

    usage: statusiq [-h] [-V] [--always-ok] [--insecure] [--no-proxy]
                    [--test TEST] [--timeout TIMEOUT] [--url URL]

    StatusIQ is a hosted status page provided by Site24x7. This check plugin
    retrieves the StatusIQ status page (must be rss-enabled) and returns a
    specific status - OK for "Operational" or "Informational" messages, WARN for
    "Under Maintenance", "Degraded Performance" and "Partial Outage", and CRIT for
    "Major Outage" messages. You only need to provide the URL to the StatusIQ
    page, for example "https://status.trustid.ch".

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
      --url URL          StatusIQ URL. Default: https://status.trustid.ch


Usage Examples
--------------

.. code-block:: bash

    ./statusiq --url=https://status.trustid.ch

Output:

.. code-block:: text

    Everything is ok @ https://status.trustid.ch

    Component Name                    ! Published                 ! State 
    ----------------------------------+---------------------------+-------
    AutoIdent - Operational           ! 2025-03-05 08:00:00+01:00 ! [OK]  
    TrustID API Service - Operational ! 2025-02-24 23:12:10+01:00 ! [OK]  
    TrustID BO Service - Operational  ! 2025-02-10 13:15:00+01:00 ! [OK]  
    TrustID IDP Service - Operational ! 2025-02-10 13:15:00+01:00 ! [OK]  
    TrustID SSE Service - Operational ! 2025-02-10 13:15:00+01:00 ! [OK]  
    VideoIdent - Operational          ! 2025-03-05 08:00:00+01:00 ! [OK]

.. code-block:: bash

    ./statusiq --url=https://status.kobv.de

Output:

.. code-block:: text

    Major incidents @ https://status.kobv.de

    Component Name                  ! Pub Date                        ! State      
    --------------------------------+---------------------------------+------------
    GVI via SRU - Major Outage      ! Thu, 06 Mar 2025 14:44:59 +0100 ! [CRITICAL] 
    ALBERT - Operational            ! Wed, 05 Mar 2025 20:54:24 +0100 ! [OK]       
    B-TU Laubert - Operational      ! Thu, 27 Feb 2025 14:48:15 +0100 ! [OK]       
    FHP FHPKat+ - Operational       ! Thu, 20 Feb 2025 18:43:16 +0100 ! [OK]       
    Fernleihe - Operational         ! Thu, 06 Mar 2025 15:46:05 +0100 ! [OK]       
    K2 Portal - Operational         ! Tue, 04 Mar 2025 11:15:00 +0100 ! [OK]       
    OPUS Uni Würzburg - Operational ! Tue, 18 Feb 2025 02:49:47 +0100 ! [OK]       
    Opus Uni Potsdam - Operational  ! Fri, 14 Feb 2025 13:45:45 +0100 ! [OK]       
    THW WILBERT - Operational       ! Wed, 26 Feb 2025 14:15:32 +0100 ! [OK]


States
------

* WARN for "Under Maintenance", "Degraded Performance" and "Partial Outage" messages
* CRIT for "Major Outage" messages


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1

    Name,                                       Type,               Description                                           
    cnt_crit,                                   Number,             Number of critical events
    cnt_warn,                                   Number,             Number of warning events


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
