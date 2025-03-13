Check grassfish-licenses
========================

Overview
--------

The Grassfish Platform offers a unified way to manage Digital Signage touchpoints. This check plugin warns if no more Grassfish licenses are available, using the Grassfish API. You must provide both the Grassfish hostname and a Grassfish token for this check to work.

Hints:

* May take more than 10 seconds to execute.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70

    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/grassfish-licenses"
    "Check Interval Recommendation",        "Once an hour"
    "Can be called without parameters",     "No"
    "Compiled for",                         "Linux, Windows"


Help
----

.. code-block:: text

    usage: grassfish-licenses [-h] [-V] [--always-ok] [--api-version API_VERSION]
                              -H HOSTNAME [--insecure] [--no-proxy] [--port PORT]
                              [--test TEST] [--timeout TIMEOUT] --token TOKEN
                              [-u URL]

    Alerts if no more Grassfish licenses are available, using the Grassfish API.
    You must provide both the Grassfish hostname and a Grassfish token for this
    check to work.

    options:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      --api-version API_VERSION
                            Grassfish API Version. Default: 1.12
      -H, --hostname HOSTNAME
                            Grassfish hostname. Default: None
      --insecure            This option explicitly allows to perform "insecure"
                            SSL connections. Default: False
      --no-proxy            Do not use a proxy. Default: False
      --port PORT           Grassfish port. Default: 443
      --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                            stderr-file,expected-retc".
      --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
      --token TOKEN         Grassfish API token
      -u, --url URL         Grassfish API URL. Default: /gv2/webservices/API


Usage Examples
--------------

.. code-block:: bash

    ./grassfish-licenses --hostname=ds.example.com --token=TOKEN

Output:

.. code-block:: text

    Everything is ok.

    License Type     ! Usage                     
    -----------------+---------------------------
    Player           ! 9/10 (1 available)        
    DsPlayerEntry    ! 1156/1400 (244 available) 
    DsPlayerAdvanced ! 283/400 (117 available)   
    DsPlayerPro      ! 820/843 (23 available)    
    EntryPlayer      ! 51/100 (49 available)     
    AdvancedPlayer   ! 25/150 (125 available)


States
------

* WARN, if no further license of any type is available


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description
    grassfish_lic_player_used,                  Number,             Player licenses used
    grassfish_lic_dsplayerentry_used,           Number,             DsPlayerEntry licenses used
    grassfish_lic_dsplayeradvanced_used,        Number,             DsPlayerAdvanced licenses used
    grassfish_lic_dsplayerpro_used,             Number,             DsPlayerPro licenses used
    grassfish_lic_entryplayer_used,             Number,             EntryPlayer licenses used
    grassfish_lic_advancedplayer_used,          Number,             AdvancedPlayer licenses used


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
