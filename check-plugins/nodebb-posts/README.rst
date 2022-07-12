Check nodebb-posts
==================

Overview
--------

Get NodeBB post settings.

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
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/nodebb-posts"
    "Check Interval Recommendation",        "Once a day"
    "Can be called without parameters",     "No"
    "Available for",                        "Python 3, Windows"
    "Requirements",                         "NodeBB v1.14.4+"


Help
----

.. code-block:: text

    usage: nodebb-posts [-h] [-V] [--always-ok] [-c CRIT] [--insecure]
                        [--test TEST] [--timeout TIMEOUT] -p TOKEN [--url URL]
                        [-w WARN]

    Get NodeBB post settings.

    options:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      -c CRIT, --critical CRIT
                            CRIT if the latest post is older than x days. Default:
                            >= 365
      --insecure            This option explicitly allows to perform "insecure"
                            SSL connections. Default: False
      --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                            stderr-file,expected-retc".
      --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
      -p TOKEN, --token TOKEN
                            NodeBB API Bearer token.
      --url URL             NodeBB API URL. Default: http://localhost:4567/forum
      -w WARN, --warning WARN
                            WARN if the latest post is older than x days. Default:
                            >= 180


Usage Examples
--------------

.. code-block:: bash

    ./nodebb-posts --token edd956be-9ea5-4f2a-94ca-3948a1b9d184 --warning 120 --critical 365

Output:

.. code-block:: text

    457 posts, latest post: "Lorem ipsum", 2022-03-06 16:21:16 (4M 1W ago) [WARNING]

    createtime                      ! slug        ! memberCount 
    --------------------------------+-------------+-------------
    2022-03-06 16:21:16 (4M 1W ago) ! lorem-ipsum ! 2
    ...


States
------

* Alerts if the newest post is older than the given thresholds (default: 180/365 days).


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description
    posts,                                      Number,             Number of posts


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
