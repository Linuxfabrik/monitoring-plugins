Check nodebb-info
=================

Overview
--------

Get NodeBB process/system information.

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
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/nodebb-info"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "No"
    "Compiled for",                         "Linux, Windows"
    "Requirements",                         "NodeBB v1.14.4+"


Help
----

.. code-block:: text

    usage: nodebb-info [-h] [-V] [--always-ok] [-c CRIT] [--insecure]
                       [--test TEST] [--timeout TIMEOUT] -p TOKEN [--url URL]
                       [-w WARN]

    Get NodeBB process/system information.

    options:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      -c CRIT, --critical CRIT
                            Set the CRIT threshold as a percentage. Default: >=
                            95
      --insecure            This option explicitly allows to perform "insecure"
                            SSL connections. Default: False
      --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                            stderr-file,expected-retc".
      --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
      -p TOKEN, --token TOKEN
                            NodeBB API Bearer token.
      --url URL             NodeBB API URL. Default: http://localhost:4567/forum
      -w WARN, --warning WARN
                            Set the WARN threshold as a percentage. Default: >=
                            90


Usage Examples
--------------

.. code-block:: bash

    ./nodebb-info --token edd956be-9ea5-4f2a-94ca-3948a1b9d184 --severity warn

Output:

.. code-block:: text

    NodeBB unalone-live1:4567, /usr/bin/node v14.19.3, Heap 93.2% used (97.9MiB of 105.1MiB) [WARNING], RSS 141.9MiB, Up 4D 10h


States
------

* Alerts if heap usage is above the percentage thresholds (default: 90/95%)


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description
    nodebb_heap_used,                           Bytes,              
    nodebb_heap_used_percent,                   Percentage,         
    nodebb_rss,                                 Bytes,              "rss = 'Resident Set Size'. This is the non-swapped physical memory a process has used."
    nodebb_uptime,                              Seconds,            Uptime in seconds.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
