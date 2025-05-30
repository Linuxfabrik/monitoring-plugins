Check nodebb-version
====================

Overview
--------

This plugin lets you track if a NodeBB update is available.

The Plugin uses the Read API and Bearer Authentication. You need to issue a bearer token of type "user" in the NodeBB admin panel in order to grant access to the API. In NodeBB, a user token is associated with a specific uid, and all calls are made in the name of that user.

* Settings > API Access > Create Token > Specify your User ID and Description (for example "Linuxfabrik API Token").

Hints:

* NodeBB Read API: https://docs.nodebb.org/api/read/
* Requires NodeBB v1.14.4+.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70

    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/nodebb-version"
    "Check Interval Recommendation",        "Once a day"
    "Can be called without parameters",     "No"
    "Compiled for Windows",                 "No"
    "Requirements",                         "NodeBB v1.14.4+"


Help
----

.. code-block:: text

    usage: nodebb-version [-h] [-V] [--always-ok] [--insecure] [--no-proxy]
                          [--test TEST] [--timeout TIMEOUT] [-p TOKEN] [--url URL]

    This plugin lets you track if a NodeBB update is available.

    options:
      -h, --help         show this help message and exit
      -V, --version      show program's version number and exit
      --always-ok        Always returns OK.
      --insecure         This option explicitly allows to perform "insecure" SSL
                         connections. Default: False
      --no-proxy         Do not use a proxy. Default: False
      --test TEST        For unit tests. Needs "path-to-stdout-file,path-to-
                         stderr-file,expected-retc".
      --timeout TIMEOUT  Network timeout in seconds. Default: 3 (seconds)
      -p, --token TOKEN  NodeBB API Bearer token.
      --url URL          NodeBB API URL. Default: http://localhost:4567/forum


Usage Examples
--------------

.. code-block:: bash

    ./nodebb-version --url http://localhost:4567/forum --token bc68eed3-4cff-4a6e-8372-3b41dfa67635

Output:

.. code-block:: text

    NodeBB v1.18.1 is available (installed: v1.17.1), Last restart: 2021-08-09 16:03:29 by Linuxfabrik <info at linuxfabrik dot ch> (4W 22h ago)


States
------

* If wanted, always returns OK,
* else returns WARN if update is available.


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description
    nodebb-version,                             Number,             "Currently installed version. Example: '1.171' for v1.17.1"


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
