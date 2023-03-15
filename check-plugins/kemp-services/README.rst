Check kemp-services
===================

Overview
--------

Kemp is a virtual load balancer (https://kemptechnologies.com). This check warns on any virtual service which is marked as down, using the REST API.

Hints:

* Use ``--filter`` to only check services that contain a certain string in their NickName.
* Use ``--severity`` to choose which state should be returned.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/kemp-services"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "No"
    "Available for",                        "Python 2, Python 3, Windows"
    "Requirements",                         "None"


Help
----

.. code-block:: text

    usage: kemp-services [-h] [-V] [--always-ok] [--filter FILTER] -H HOSTNAME
                         [--insecure] [--no-proxy] --password PASSWORD
                         [--port PORT] [--severity {warn,crit}] [--test TEST]
                         [--timeout TIMEOUT] -u USERNAME

    Warns if virtual services provided by a kemp loadbalancer appliance are down.

    optional arguments:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
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
      --severity {warn,crit}
                            Severity for alerting. Default: warn
      --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                            stderr-file,expected-retc".
      --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
      -u USERNAME, --username USERNAME
                            API Username.


Usage Examples
--------------

.. code-block:: bash

    ./kemp-services --hostname localhost --username user --password password
    ./kemp-services --hostname localhost --username user --password password --filter PROD
    ./kemp-services --hostname localhost --username user --password password --filter PROD --severity crit

Output:

.. code-block:: text

    4 services checked. 

    NickName               ! State 
    -----------------------+-------
    KEMP LoadBalancer PROD ! [OK]  
    website1 PROD          ! [OK]  
    website2 PROD          ! [OK]  
    website01 DEV          ! [OK]


States
------

* WARN (default) if any virtual service is marked as down.


Perfdata / Metrics
------------------

There is no perfdata.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
