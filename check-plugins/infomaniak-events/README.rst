Check infomaniak-events
=======================

Overview
--------

Informs you about open events at Infomaniak via the Infomaniak API. To use this check, you have to create a Bearer Token with scope "event" at Infomaniak first.

"Services" (service categories) that we know about and that can be filtered:

* certificate
* cloud
* email_hosting
* hosting
* housing
* jelastic
* public_cloud
* radio
* swiss_backup
* web_hosting
* webmail

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
    "Compiled for",                         "Linux, Windows"


Help
----

.. code-block:: text

    usage: infomaniak-events [-h] [-V] [--always-ok] [--service SERVICE] --token
                             TOKEN [--test TEST]

    Informs you about open events at Infomaniak.

    options:
      -h, --help         show this help message and exit
      -V, --version      show program's version number and exit
      --always-ok        Always returns OK.
      --service SERVICE  Only report this service category (repeating). Example:
                         `--service=swiss_backup --service=public_cloud`. Default:
                         none (so report all)
      --token TOKEN      Infomaniak API token
      --test TEST        For unit tests. Needs "path-to-stdout-file,path-to-
                         stderr-file,expected-retc".


Usage Examples
--------------

.. code-block:: bash

    ./infomaniak-events --token=TOKEN --service=public_cloud --service=swiss_backup

Output:

.. code-block:: text

    information: Wave of fraudulent e-mails () - see https://infomaniakstatus.com/en/

    Type        ! Title                                ! Services      ! Start               ! End                             ! Duration 
    ------------+--------------------------------------+---------------+---------------------+---------------------------------+----------
    impacting   ! Swiss Backup: planned Acronis update ! swiss_backup  ! 2023-05-22 20:30:55 ! 2023-05-23 00:31:10 (1M 2W ago) ! 4h 15s   
    impacting   ! Public Cloud: service disruption     ! public_cloud  ! 2023-05-10 19:30:15 ! 2023-05-10 20:12:02 (1M 3W ago) ! 41m 47s  


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
