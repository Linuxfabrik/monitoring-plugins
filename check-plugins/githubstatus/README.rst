Check githubstatus
==================

Overview
--------

Checks the `GitHub status page <https://www.githubstatus.com>`_, including a status indicator, component statuses and unresolved incidents.

Links:

* API Documentation: https://www.githubstatus.com/api
* GitHub Status Page: https://www.githubstatus.com


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70

    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/githubstatus"
    "Check Interval Recommendation",        "Every 5 minutes"
    "Can be called without parameters",     "Yes"
    "Compiled for Windows",                 "No"


Help
----

.. code-block:: text

    usage: githubstatus [-h] [-V] [--always-ok] [--insecure] [--no-proxy]
                        [--test TEST] [--timeout TIMEOUT]

    Checks the GitHub status page, including a status indicator, component
    statuses and unresolved incidents.

    options:
      -h, --help         show this help message and exit
      -V, --version      show program's version number and exit
      --always-ok        Always returns OK.
      --insecure         This option explicitly allows to perform "insecure" SSL
                         connections. Default: False
      --no-proxy         Do not use a proxy. Default: False
      --test TEST        For unit tests. Needs "path-to-stdout-file,path-to-
                         stderr-file,expected-retc".
      --timeout TIMEOUT  Network timeout in seconds. Default: 8 (seconds)


Usage Examples
--------------

.. code-block:: bash

    ./githubstatus

Output:

.. code-block:: text

    1 incindent, 1 component affected. 2023-05-11 17:53:35, minor impact, investigating: Incident with Actions, API Requests, Codespaces, Git Operations, Issues, Pages, Pull Requests and Webhooks. We have reindexed about 20% of the pull requests missing from the /pulls and /search pages. 

    Component      ! Status         ! Updated (Etc/UTC)   
    ---------------+----------------+---------------------
    Git Operations ! operational    ! 2023-05-11 14:40:16 
    API Requests   ! operational    ! 2023-05-11 14:40:15 
    Webhooks       ! operational    ! 2023-05-11 14:40:18 
    Issues         ! operational    ! 2023-05-11 14:40:17 
    Pull Requests  ! partial_outage ! 2023-05-11 13:33:31 
    Actions        ! operational    ! 2023-05-11 14:40:14 
    Packages       ! operational    ! 2023-04-27 09:56:19 
    Pages          ! operational    ! 2023-05-11 14:46:14 
    Codespaces     ! operational    ! 2023-05-11 14:40:16 
    Copilot        ! operational    ! 2023-05-04 16:18:39


States
------

* WARN if incidents are found
* WARN if any component is not "operational"


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description                                           
    components,                                 Number,             Number of GitHub components affected.
    incidents,                                  Number,             Number of incidents.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
