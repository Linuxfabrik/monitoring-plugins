Check grassfish-players
=======================

Overview
--------

The Grassfish Platform offers a unified way to manage Digital Signage touchpoints. This monitoring plugin shows you a list of Grassfish players whose data transfer status is overdue, whose last access date is more than ``--warning`` hours ago or who are unlicensed. The list of players can be filtered. You must provide both the Grassfish hostname and a Grassfish token for this check to work.

Tested with Grassfish v1.12.

Hints:

* May take more than 10 seconds to execute.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70

    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/grassfish-players"
    "Check Interval Recommendation",        "Once an hour"
    "Can be called without parameters",     "No"
    "Compiled for Windows",                 "No"


Help
----

.. code-block:: text

    usage: grassfish-players [-h] [-V] [--always-ok] [--api-version API_VERSION]
                             [--box-id BOX_ID]
                             [--box-state {activated,deleted,new,reserved,undefined}]
                             [--custom-id CUSTOM_ID] -H HOSTNAME [--insecure]
                             [--is-installed {yes,no}] [--is-licensed {yes,no}]
                             [--lengthy] [--no-proxy] [--port PORT] [--test TEST]
                             [--timeout TIMEOUT] --token TOKEN
                             [--transfer-status {complete,overdue,pending}]
                             [-w WARN] [-u URL]

    This monitoring plugin shows you a list of Grassfish players whose data
    transfer status is overdue, whose last access date is more than `--warning`
    hours ago or who are unlicensed. The list of players can be filtered. You must
    provide both the Grassfish hostname and a Grassfish token for this check to
    work.

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
      --custom-id CUSTOM_ID
                            Filter by specific custom IDs. Supports Python Regular
                            Expressions (regex).
      -H, --hostname HOSTNAME
                            Grassfish hostname. Default: None
      --insecure            This option explicitly allows to perform "insecure"
                            SSL connections. Default: False
      --is-installed {yes,no}
                            Filter by boxes that are installed (= "yes") or not (=
                            "no"). Repeating.
      --is-licensed {yes,no}
                            Filter by boxes that are licensed (= "yes") or not (=
                            "no"). Repeating.
      --lengthy             Extended reporting.
      --no-proxy            Do not use a proxy. Default: False
      --port PORT           Grassfish port. Default: 443
      --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                            stderr-file,expected-retc".
      --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
      --token TOKEN         Grassfish API token
      --transfer-status {complete,overdue,pending}
                            Filter by specific data transfer status. Repeating.
      -w, --warning WARN    Set the WARN threshold for Last Access in hours
                            (considers player is offline). Default: > 8 h
      -u, --url URL         Grassfish API URL. Default: /gv2/webservices/API


Usage Examples
--------------

.. code-block:: bash

    ./grassfish-players --hostname=ds.example.com --token=TOKEN --box-id=gp11

Output:

.. code-block:: text

    There are 6 players with warnings: 2 unlicensed, 2 transfer overdue, 6 accessed > 10 hours ago. 6 players checked. Filter: --box-state=['activated']

    Box ID    ! License Type            ! Name                 ! Box State ! Lic             ! Transfer          ! Last Access                                
    ----------+-------------------------+----------------------+-----------+-----------------+-------------------+--------------------------------------------
    GP111-111 ! Player                  ! Grassfish Player 111 ! Activated ! True            ! Complete          ! 2020-03-09 14:07:53 (2Y 12M ago) [WARNING] 
    GP112-112 ! DsPlayerAdvancedSaas    ! Grassfish Player 112 ! Activated ! True            ! Pending           ! 2020-03-09 14:07:53 (2Y 12M ago) [WARNING] 
    GP113-113 ! ColorDoorSignPlayerSaas ! Grassfish Player 113 ! Activated ! True            ! Overdue [WARNING] ! 2020-03-09 14:07:53 (2Y 12M ago) [WARNING] 
    GP114-114 ! ColorDoorSignPlayerSaas ! Grassfish Player 114 ! Activated ! True            ! Complete          ! 2020-03-09 14:07:53 (2Y 12M ago) [WARNING] 
    GP115-115 ! ColorDoorSignPlayerSaas ! Grassfish Player 115 ! Activated ! False [WARNING] ! Complete          ! 2020-03-09 14:07:53 (2Y 12M ago) [WARNING] 
    GP117-117 ! ColorDoorSignPlayerSaas ! Grassfish Player 117 ! Activated ! False [WARNING] ! Overdue [WARNING] ! 2020-03-09 14:07:53 (2Y 12M ago) [WARNING]


States
------

* WARN if player is not licensed
* WARN if player's transfer status is "Overdue"
* WARN if player's last access timestamp is > ``--warning`` hours (which considers player is offline)


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description
    grassfish_play_players,                     Number,             Number of matching players found
    grassfish_play_unlicensed,                  Number,             Number of unlicensed players
    grassfish_play_transfer_overdue,            Number,             Number of player with transfer status "Overdue"
    grassfish_play_access_overdue,              Number,             Number of players with last access timestamp > ``--warning`` hours
    grassfish_play_warnings,                    Number,             grassfish_play_unlicensed + grassfish_play_transfer_overdue + grassfish_play_access_overdue


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
