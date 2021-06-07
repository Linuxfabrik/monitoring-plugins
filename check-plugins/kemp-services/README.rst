Check kemp-services
===================

Overview
--------

Kemp is a virtual load balancer (https://kemptechnologies.com). This check warns on any virtual service which is marked as down, using the REST API.

Hints:

* Use ``--filter`` to only check services that contain a certain string in their NickName.
* Use ``--state`` to choose which state should be returned.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/kemp-services"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "No"
    "Available for",                        "Python 2"
    "Requirements",                         "None"


Help
----

.. code-block:: text

    usage: kemp-services [-h] [--always-ok] [--filter FILTER] -H HOSTNAME
                         [--insecure] [--no-proxy] --password PASSWORD
                         [--port PORT] [--state {warn,crit}] [--test TEST]
                         [--timeout TIMEOUT] -u USERNAME [-V]

    Warns if virtual services provided by a kemp loadbalancer appliance are down.

    optional arguments:
      -h, --help            show this help message and exit
      --always-ok           Always returns OK.
      --filter FILTER       Only check services that contain this string in their
                            NickName.
      -H HOSTNAME, --hostname HOSTNAME
                            KEMP Appliance address.
      --insecure            This option explicitly allows to perform "insecure"
                            SSL connections. Default: False
      --no-proxy            Do not use a proxy. Default: False
      --password PASSWORD   API Password.
      --port PORT           KEMP Appliance port.
      --state {warn,crit}   The state that has to be returned. Default: warn
      --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                            stderr-file,expected-retc".
      --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
      -u USERNAME, --username USERNAME
                            API Username.
      -V, --version         show program's version number and exit


Usage Examples
--------------

.. code-block:: bash

    ./kemp-services --hostname localhost --username user --password password
    ./kemp-services --hostname localhost --username user --password password --filter PROD
    ./kemp-services --hostname localhost --username user --password password --filter PROD --state crirt

Output:

.. code-block:: text

    TODO


States
------

* WARN (default) if any virtual service is marked as down.


Perfdata / Metrics
------------------

There is no perfdata.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
