Check nodebb-users
==================

Overview
--------

Get NodeBB users.

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

    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/nodebb-users"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "No"
    "Compiled for Windows",                 "No"
    "Requirements",                         "NodeBB v1.14.4+"


Help
----

.. code-block:: text

    usage: nodebb-users [-h] [-V] [--always-ok] [--insecure] [--no-proxy]
                        [--severity {warn,crit}] [--test TEST] [--timeout TIMEOUT]
                        -p TOKEN [--url URL]

    Get NodeBB users.

    options:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      --insecure            This option explicitly allows to perform "insecure"
                            SSL connections. Default: False
      --no-proxy            Do not use a proxy. Default: False
      --severity {warn,crit}
                            Severity for alerts that do not depend on thresholds.
                            One of "warn" or "crit". Default: warn
      --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                            stderr-file,expected-retc".
      --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
      -p, --token TOKEN     NodeBB API Bearer token.
      --url URL             NodeBB API URL. Default: http://localhost:4567/forum


Usage Examples
--------------

.. code-block:: bash

    ./nodebb-users --token edd956be-9ea5-4f2a-94ca-3948a1b9d184 --severity warn

Output:

.. code-block:: text

    402 users, latest active user: alice <alice@example.com>, online 2022-07-12 10:17:23 (22s ago)

    uid ! userslug         ! lastonline                        ! banned ! admin ! ip              
    ----+------------------+-----------------------------------+--------+-------+-----------------
    373 ! alice            ! 2022-07-12 10:17:23 (22s ago)     ! False  ! False ! 1.2.3.4         
    2   ! bob              ! 2022-07-12 10:17:17 (28s ago)     ! False  ! True  ! 2.3.4.5   
    ...


States
------

* Alerts according to the given severity (default: WARN) if a user gets banned.


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description
    users,                                      Number,             Number of users


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
