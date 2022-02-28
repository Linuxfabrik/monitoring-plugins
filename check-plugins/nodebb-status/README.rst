Check nodebb-status
===================

Overview
--------

Checks the overall health of a NodeBB instance using various API endpoints.

The Plugin uses the Read API and Bearer Authentication. You need to issue a bearer token of type "user" in the NodeBB admin panel in order to grant access to the API. In NodeBB, a user token is associated with a specific uid, and all calls are made in the name of that user.

* Settings > API Access > Create Token > Specify your User ID and Description (for example "Linuxfabrik API Token").

Hints:

* NodeBB Read API: https://docs.nodebb.org/api/read/
* Requires NodeBB v1.14.4+.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/nodebb-status"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "No"
    "Available for",                        "Python 2, Python 3, Windows"
    "Requirements",                         "NodeBB v1.14.4+"


Help
----

.. code-block:: text

    usage: nodebb-status [-h] [-V] [--always-ok] [-c CRIT] [--insecure]
                         [--severity {warn,crit}] [--test TEST]
                         [--timeout TIMEOUT] [-p TOKEN] [--url URL] [-w WARN]

    Checks the overall health of a NodeBB instance using various API endpoints.

    optional arguments:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      -c CRIT, --critical CRIT
                            Set the CRIT threshold as a percentage. Default: >= 90
      --insecure            This option explicitly allows to perform "insecure"
                            SSL connections. Default: False
      --severity {warn,crit}
                            Severity for alerting. One of "warn" or "crit".
                            Default: warn
      --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                            stderr-file,expected-retc".
      --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
      -p TOKEN, --token TOKEN
                            NodeBB API Bearer token.
      --url URL             NodeBB API URL. Default: http://localhost:4567/forum
      -w WARN, --warning WARN
                            Set the WARN threshold as a percentage. Default: >= 80


Usage Examples
--------------

.. code-block:: bash

    ./nodebb-status --token bc68eed3-4cff-4a6e-8372-3b41dfa67635 --severity warn

Output:

.. code-block:: text

    There are errors.

    * NodeBB nodebb:4567, /usr/bin/node v14.17.5
      Heap 86.1% used (93.1MiB of 108.1MiB) [WARNING], RSS 264.8MiB
    * postCache: 197 items, 0.68% used (71.4K/10.5M), Hit Rate 96.89% (6.7K hits, 214.0 misses)
    * groupCache: 7034 items, 17.59% used (7.0K/40.0K), Hit Rate 99.08% (770.3K hits, 7.2K misses)
    * localCache: 696 items, 1.74% used (696.0/40.0K), Hit Rate 99.85% (525.8K hits, 790.0 misses)
    * objectCache: 1427 items, 3.57% used (1.4K/40.0K), Hit Rate 98.45% (1.1M hits, 17.1K misses)
    * HTTP Status today: 0x 503 too busy, 0x 404 not found
    * MongoDB "nodebb": 5 collections, 11 indexes, 175.8K objects, 11.2% Disk Usage (22.2GiB/197.4GiB)
    * Last log: #770 settings-change uid=2 1.2.3.4 Linuxfabrik (3D 23h ago)


States
------

Alerts according to the given severity (default: WARN):

* if any cache is disabled
* if any HTTP status 503 occured today
* if connection to database is not ok
    
Alerts if any of these values is above the percentage thresholds (default: 80/90%)

* heap usage
* cache usage
* filesystem usage (from database's point of view)

If using ``--always-ok``, always returns OK.


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description
    cache_<cachename>_hitRatio,                 Percentage,         
    cache_<cachename>_hits,                     Continous Counter,  
    cache_<cachename>_itemCount,                Number,             
    cache_<cachename>_length,                   Continous Counter,  
    cache_<cachename>_misses,                   Continous Counter,  
    cache_<cachename>_percentFull,              Percentage,         
    db_collections,                             Number,             MongoDB
    db_fs_total,                                Bytes,              MongoDB
    db_fs_used,                                 Bytes,              MongoDB
    db_fs_used_percent,                         Percentage,         MongoDB
    db_indexes,                                 Number,             MongoDB
    db_objects,                                 Number,             MongoDB
    err404,                                     Continous Counter,  404 responses from today
    err503,                                     Continous Counter,  503 responses from today
    nodebb_heap_used,                           Bytes,              
    nodebb_heap_used_percent,                   Percentage,         
    nodebb_rss,                                 Bytes,              "rss = 'Resident Set Size'. This is the non-swapped physical memory a process has used."


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
