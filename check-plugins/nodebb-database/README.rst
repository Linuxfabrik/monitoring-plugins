Check nodebb-database
=====================

Overview
--------

Get NodeBB database information.

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

    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/nodebb-database"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "No"
    "Compiled for",                         "Linux, Windows"
    "Requirements",                         "NodeBB v1.14.4+"


Help
----

.. code-block:: text

    usage: nodebb-database [-h] [-V] [--always-ok] [-c CRIT] [--insecure]
                           [--no-proxy] [--severity {warn,crit}] [--test TEST]
                           [--timeout TIMEOUT] -p TOKEN [--url URL] [-w WARN]

    Get NodeBB database information.

    options:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      -c, --critical CRIT   Set the CRIT threshold as a percentage. Default: >= 95
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
      -w, --warning WARN    Set the WARN threshold as a percentage. Default: >= 90


Usage Examples
--------------

.. code-block:: bash

    ./nodebb-database --token edd956be-9ea5-4f2a-94ca-3948a1b9d184 --severity warn

Output:

.. code-block:: text

    MongoDB "myforum": 20.9% Disk Usage (41.3GiB/197.4GiB), 5 collections, 11 indexes, 330.1K objects


States
------

* Alerts according to the given severity (default: WARN) if connection to database is not ok
* Alerts if filesystem usage (from database's point of view) is above the percentage thresholds (default: 90/95%)


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description
    db_collections,                             Number,             MongoDB
    db_fs_total,                                Bytes,              MongoDB
    db_fs_used,                                 Bytes,              MongoDB
    db_fs_used_percent,                         Percentage,         MongoDB
    db_indexes,                                 Number,             MongoDB
    db_objects,                                 Number,             MongoDB


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
