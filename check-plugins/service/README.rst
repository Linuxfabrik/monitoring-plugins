Check service
=============

Overview
--------

Checks the state of one or more Windows services. You have to provide the case-insensitive "Service Name", not the "Display Name". Supports Python regular expressions, so you are able to check multiple Windows services on a host with almost the same name, for example.

Example:

* Display Name: "Diagnostic Policy Service"
* Service Name: ``DPS`` (provide this)


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70

    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/service"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "No"
    "Available for",                        "Python 3, Windows"
    "Requirements",                         "Python module ``psutil``"


Help
----

.. code-block:: text

    usage: service [-h] [-V] [--always-ok] [-c CRIT] --service SERVICE
                   [--starttype {automatic,disabled,manual}]
                   [--status {continue_pending,pause_pending,paused,running,start_pending,stop_pending,stopped}]
                   [-w WARN]

    Checks the state of one or more Windows services. You have to provide the
    case-insensitive "Service Name", not the "Display Name". Supports Python
    regular expressions, so you are able to check multiple Windows services on a
    host with almost the same name, for example.

    options:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      -c CRIT, --critical CRIT
                            Set the CRIT threshold. Accepts ranges. Default:
                            "None"
      --service SERVICE     Name of the service. Supports Python Regular
                            Expressions (regex).
      --starttype {automatic,disabled,manual}
                            Expected service start type. Default: automatic
      --status {continue_pending,pause_pending,paused,running,start_pending,stop_pending,stopped}
                            At least one expected service status (repeating).
                            Default: running
      -w WARN, --warning WARN
                            Set the WARN threshold. Accepts ranges. Default: "1:"


Usage Examples
--------------

Check if exactly one service named "AppIDSvc" (exact match) is running, otherwise WARN:

.. code-block:: bash

    service --service="^appidsvc$" --status=running --warning=1:1

Output:

.. code-block:: text

    0 services named "^appidsvc$" with status "running" found, but expected "1:1" [WARNING].

    Service Name ! Display Name         ! Status  ! Startup
    -------------+----------------------+---------+---------
    AppIDSvc     ! Application Identity ! stopped ! manual

Check if at least 10 but not more than 20 Windows Services named "myapp followed by a 4-digit serial number" meet the status "running":

.. code-block:: bash

    service --service="^myapp[0-9]{4}$" --status=running --warning=10:19

    Everything is ok.

Output:

.. code-block:: text

    Service Name ! Display Name         ! Status  ! Startup
    -------------+----------------------+---------+---------
    myapp2606    ! ...                  ! ...
    ...


States
------

* WARN or CRIT if number of services found does not fit into the given ranges.


Perfdata / Metrics
------------------

There is no perfdata.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
