Check infomaniak-events
=======================

Overview
--------

Informs you about open events at Infomaniak via the Infomaniak API. To use this check, you have to create a Bearer Token with scope "event" at Infomaniak first.

Links:

* API Documentation: https://developer.infomaniak.com/docs/api/get/2/events
* API Tokens: https://manager.infomaniak.com/v3/$ACCOUNT_ID/ng/accounts/token
* Infomaniak Status Page: https://infomaniakstatus.com/


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/infomaniak-events"
    "Check Interval Recommendation",        "Every minute"
    "Can be called without parameters",     "No"
    "Available for",                        "Python 3, Windows"
    "Requirements",                         "None"


Help
----

.. code-block:: text

    usage: infomaniak-events [-h] [-V] [--always-ok] --token TOKEN [--test TEST]

    Informs you about open events at Infomaniak.

    options:
      -h, --help     show this help message and exit
      -V, --version  show program's version number and exit
      --always-ok    Always returns OK.
      --token TOKEN  Infomaniak API token
      --test TEST    For unit tests. Needs "path-to-stdout-file,path-to-stderr-
                     file,expected-retc".


Usage Examples
--------------

.. code-block:: bash

    ./infomaniak-events --token=TOKEN

Output:

.. code-block:: text

    Everything is ok.

    Type        ! Title                                ! Start               ! End                             ! Duration 
    ------------+--------------------------------------+---------------------+---------------------------------+----------
    impacting   ! Mail Service                         ! 2022-12-21 12:50:36 ! 2022-12-21 13:18:53 (1W 5D ago) ! 28m 17s  
    impacting   ! Slowness on the Mail service         ! 2022-12-05 09:02:36 ! 2022-12-05 15:25:44 (4W 3h ago) ! 6h 23m   
    impacting   ! Saving templates and importing media ! 2022-12-02 11:13:26 ! 2022-12-02 13:56:46 (1M 1D ago) ! 2h 43m   
    impacting   ! The newsletter tool is not reachable ! 2022-11-15 10:00:40 ! 2022-11-15 12:27:47 (1M 2W ago) ! 2h 27m   
    maintenance ! Afnic maintenance                    ! 2022-11-03 14:00:36 ! 2022-11-03 17:46:16 (2M 1h ago) ! 3h 45m

States
------

* WARN if an event is not in state "terminated"


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description                                           
    event,                                      Number,             "0 = no event, 1 = event in progress"


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
