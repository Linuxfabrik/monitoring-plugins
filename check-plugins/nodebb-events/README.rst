Check nodebb-events
===================

Overview
--------

Get NodeBB event log.

The Plugin uses the Read API and Bearer Authentication. You need to issue a bearer token of type "user" in the NodeBB admin panel in order to grant access to the API. In NodeBB, a user token is associated with a specific uid, and all calls are made in the name of that user.

To create a Bearer Token, do this:

* Settings > API Access > Create Token > Specify your User ID and Description (for example "Linuxfabrik API Token").

Hints:

* NodeBB Read API: https://docs.nodebb.org/api/read/
* Requires NodeBB v1.14.4+.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/nodebb-events"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "No"
    "Compiled for",                         "Linux, Windows"
    "Requirements",                         "NodeBB v1.14.4+"


Help
----

.. code-block:: text

    usage: nodebb-events [-h] [-V] [--insecure] [--test TEST]
                         [--timeout TIMEOUT] -p TOKEN [--url URL]

    Get NodeBB event log.

    options:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --insecure            This option explicitly allows to perform "insecure"
                            SSL connections. Default: False
      --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                            stderr-file,expected-retc".
      --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
      -p TOKEN, --token TOKEN
                            NodeBB API Bearer token.
      --url URL             NodeBB API URL. Default: http://localhost:4567/forum


Usage Examples
--------------

.. code-block:: bash

    ./nodebb-events --token edd956be-9ea5-4f2a-94ca-3948a1b9d184 --severity warn

Output:

.. code-block:: text

    Latest event: #770 uid=2 username settings-change 1.2.3.4 (10M 1W ago)

    eid ! uid ! displayname ! type            ! timestamp                        ! ip      
    ----+-----+-------------+-----------------+----------------------------------+---------
    770 ! 2   ! alice       ! settings-change ! 2021-09-03 14:59:48 (10M 1W ago) ! 1.2.3.4 
    769 ! 2   ! bob         ! password-reset  ! 2021-09-03 14:30:01 (10M 1W ago) ! 1.2.3.4


States
------

* Always returns OK.


Perfdata / Metrics
------------------

There is no perfdata.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
