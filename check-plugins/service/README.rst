Check service
=============

Overview
--------

Verifies that a set of Windows services, specified by name and specific startup types, are in specific states (such as "running") - in other words, this plugin checks the number of services in specific service states against thresholds.

You have to provide the case-insensitive Windows "Service Name", not the "Display Name". Supports Python regular expressions, so you are able to check multiple Windows services on a host with almost the same name, for example.

Example:

* Display Name: "Diagnostic Policy Service"
* Service Name: ``DPS`` (provide this)

Hints:

* For use in Icinga Director: If the service name contains a ``$``, this dollar sign must be escaped with another dollar sign. Since the plugin is capable of regular expressions, this character must also be escaped with a backslash. So if you want to check ``my$service``, you have to specify ``my\$$service``.
* On the Windows command line: If you want to check ``my$service``, you have to specify ``my\$service``.
* On the Windows command line: Only use double quotes to provide regexes to ``--service``; if running unit tests on Linux, use single quotes instead.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70

    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/service"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "No"
    "Compiled for",                         "Windows"
    "3rd Party Python modules",             "``psutil``"


Help
----

.. code-block:: text

    usage: service [-h] [-V] [--always-ok] [-c CRIT] --service SERVICE
                   [--starttype {automatic,disabled,manual}]
                   [--status {continue_pending,pause_pending,paused,running,start_pending,stop_pending,stopped}]
                   [--test TEST] [-w WARN]

    Checks the state of one or more Windows services. You have to provide the
    case-insensitive "Service Name", not the "Display Name". Supports Python
    regular expressions, so you are able to check multiple Windows services on a
    host with almost the same name, for example.

    options:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      -c, --critical CRIT   Set the CRIT threshold. Accepts ranges. Default:
                            "None"
      --service SERVICE     Name of the service(s). Supports Python Regular
                            Expressions (regex).
      --starttype {automatic,disabled,manual}
                            Filter for service start type. Default: automatic
      --status {continue_pending,pause_pending,paused,running,start_pending,stop_pending,stopped}
                            At least one expected service status (repeating).
                            Default: running
      --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                            stderr-file,expected-retc".
      -w, --warning WARN    Set the WARN threshold. Accepts ranges. Default: "1:"


Usage Examples
--------------

Check that exactly one service named "BFE" (exact match) is running, otherwise WARN:

.. code-block:: bash

    service --service="^bfe$" --status=running --warning=1:1

Output:

.. code-block:: text

    Everything is ok. 1 service named r`^bfe$` and start type ['automatic'] found, 1 in status ['running'] (thresholds 1:1/None).

    Display Name          ! Service Name ! Status  ! Startup
    ----------------------+--------------+---------+-----------
    Base Filtering Engine ! BFE          ! running ! automatic

Check that there are at least 10 but not more than 20 Windows Services named "myapp followed by a 4-digit serial number" meet the status "running":

.. code-block:: bash

    service --service="^myapp[0-9]{4}$" --starttype=automatic --status=running --warning=10:19

Output:

.. code-block:: text

    2 services named r`^myapp[0-9]{4}$` and start type ['automatic'] found, 2 in status ['running'] (thresholds 10:19/None) [WARNING].

    Display Name      ! Service Name ! Status  ! Startup
    ------------------+--------------+---------+-----------
    myapp0815         ! myapp0815    ! running ! automatic
    myapp4711         ! myapp4711    ! running ! automatic

Check that ALL services with startup type "automatic" are running, except for a few that are known for a delayed or triggered start (we'll filter these by name). In other words: First get all the services, filter out a few with a negative lookahead, and set the alert threshold to alert if at least one of the remaining services is NOT running:

.. code-block:: bash

    service --service="^(?!DPS|MSDTC|MapsBroker|UsoSvc|Dnscache|gpsvc$).*$" --starttype=automatic --status=continue_pending --status=pause_pending --status=paused --status=start_pending --status=stop_pending --status=stopped --warning 0

Output (shortened):

.. code-block:: text

    45 services named r`^(?!DPS!MSDTC!MapsBroker!UsoSvc!Dnscache!gpsvc$).*$` and start type ['automatic'] found, 2 in status ['continue_pending', 'pause_pending', 'paused', 'start_pending', 'stop_pending', 'stopped'] (thresholds 0/None) [WARNING].

    Display Name                                   ! Service Name           ! Status  ! Startup
    -----------------------------------------------+------------------------+---------+-----------
    DCOM Server Process Launcher                   ! DcomLaunch             ! running ! automatic
    User Profile Service                           ! ProfSvc                ! running ! automatic
    Remote Registry                                ! RemoteRegistry         ! stopped ! automatic
    RPC Endpoint Mapper                            ! RpcEptMapper           ! running ! automatic
    Remote Procedure Call (RPC)                    ! RpcSs                  ! running ! automatic
    Print Spooler                                  ! Spooler                ! running ! automatic
    Software Protection                            ! sppsvc                 ! stopped ! automatic
    OpenSSH SSH Server                             ! sshd                   ! running ! automatic
    SysMain                                        ! SysMain                ! running ! automatic


States
------

* WARN or CRIT if the number of services found does not match the specified ranges.


Perfdata / Metrics
------------------

There is no perfdata.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
