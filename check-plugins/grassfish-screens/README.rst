Check grassfish-screens
=======================

Overview
--------

The Grassfish Platform offers a unified way to manage Digital Signage touchpoints. This monitoring plugin checks if the screens attached to a Grassfish player are on or off. You must provide both the Grassfish hostname and a Grassfish token for this check to work.

Tested with Grassfish v1.12.

Hints:

* Takes round about 5 minutes for 1'000 screens.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/grassfish-screens"
    "Check Interval Recommendation",        "Every 8 hours"
    "Can be called without parameters",     "No"
    "Compiled for",                         "Linux, Windows"
    "Uses SQLite DBs",                      "``$TEMP/linuxfabrik-monitoring-plugins-grassfish-screens.db``"


Help
----

.. code-block:: text

    usage: grassfish-screens [-h] [-V] [--always-ok] [--api-version API_VERSION]
                             [--box-id BOX_ID]
                             [--box-state {activated,deleted,new,reserved,undefined}]
                             [--cache-expire CACHE_EXPIRE]
                             [--custom-id CUSTOM_ID] -H HOSTNAME
                             [--is-installed {yes,no}] [--is-licensed {yes,no}]
                             [--lengthy] [--port PORT] [--test TEST] --token
                             TOKEN [--transfer-status {complete,overdue,pending}]
                             [-w WARN] [-u URL]

    This monitoring plugin checks if the screens attached to a Grassfish player
    are on or off. The list of players can be filtered. You must provide both the
    Grassfish hostname and a Grassfish token for this check to work.

    options:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      --api-version API_VERSION
                            Grassfish API Version. Default: 1.12
      --box-id BOX_ID       Filter by specific box IDs. Supports Python Regular
                            Expressions (regex).
      --box-state {activated,deleted,new,reserved,undefined}
                            Filter by specific box state. Repeating.
      --cache-expire CACHE_EXPIRE
                            The amount of time after which the cached data
                            expires, in hours. Default: 8
      --custom-id CUSTOM_ID
                            Filter by specific custom IDs. Supports Python Regular
                            Expressions (regex).
      -H HOSTNAME, --hostname HOSTNAME
                            Grassfish hostname. Default: None
      --is-installed {yes,no}
                            Filter by boxes that are installed (= "yes") or not (=
                            "no"). Repeating.
      --is-licensed {yes,no}
                            Filter by boxes that are licensed (= "yes") or not (=
                            "no"). Repeating.
      --lengthy             Extended reporting.
      --port PORT           Grassfish port. Default: 443
      --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                            stderr-file,expected-retc".
      --token TOKEN         Grassfish API token
      --transfer-status {complete,overdue,pending}
                            Filter by specific data transfer status. Repeating.
      -w WARN, --warning WARN
                            Set the WARN threshold for Last Access in hours
                            (considers screen is off). Default: > 8 h
      -u URL, --url URL     Grassfish API URL. Default: /gv2/webservices/API


Usage Examples
--------------

.. code-block:: bash

    ./grassfish-screens --hostname=ds.example.com --token=TOKEN --box-id=gp11

Output:

.. code-block:: text

    1 screen is off (accessed > 10 hours ago). 1 screen checked. Filter: --box-state=['activated']

    Box ID    ! Name                 ! Screen1 On      ! Screen2 On 
    ----------+----------------------+-----------------+------------
    GP111-111 ! Grassfish Player 111 ! False [WARNING] ! None


States
------

* WARN if screen's last access timestamp is > ``--warning`` hours (which considers screen is switched off)


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description
    grassfish_scr_screens,                      Number,             Number of screens attached to matching players found
    grassfish_scr_screens_off,                  Number,             Number of powered off screens


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
