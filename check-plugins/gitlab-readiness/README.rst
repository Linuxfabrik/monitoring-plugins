Check gitlab-readiness
======================

Overview
--------

The readiness probe checks whether the GitLab instance is ready to accept traffic via Rails Controllers. The check also validates the dependent services (Database, Redis, Gitaly etc.) and gives a status for each.

Hints:

* Requires GitLab 9.1.0+
* To access monitoring resources, the requesting client IP needs to be included in the allowlist. For details, see `how to add IPs to the allowlist for the monitoring endpoints <https://docs.gitlab.com/ee/administration/monitoring/ip_allowlist.html>`.
* This check is being exempt from Rack Attack.
* GitLab Health Checks: https://docs.gitlab.com/ee/administration/monitoring/health_check.html


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/gitlab-readiness"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "Yes"
    "Compiled for",                         "Linux"


Help
----

.. code-block:: text

    usage: gitlab-readiness [-h] [-V] [--always-ok] [--severity {warn,crit}]
                            [--test TEST] [--timeout TIMEOUT] [--url URL]

    The readiness probe checks whether the GitLab instance is ready to accept
    traffic via Rails Controllers. The check also validates the dependent services (Database,
    Redis, Gitaly etc.) and gives a status for each.

    options:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      --severity {warn,crit}
                            Severity for alerting. Default: warn
      --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                            stderr-file,expected-retc".
      --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
      --url URL             GitLab readiness URL endpoint. Default:
                            http://localhost/-/readiness?all=1


Usage Examples
--------------

.. code-block:: bash

    ./gitlab-readiness --severity warn --timeout 3 --url http://localhost/-/readiness

Output:

.. code-block:: text

    There are issues with gitaly_check. Run `curl http://localhost/-/readiness?all=1` for full results.

    Service           ! Message                                                     
    ------------------+-------------------------------------------------------------
    cache             ! Running                                                     
    chat              ! Running                                                     
    cluster_cache     ! Running                                                     
    db                ! Running                                                     
    db_load_balancing ! Running                                                     
    feature_flag      ! Running                                                     
    gitaly            ! [WARNING] 14:connections to all backends failing; last e... 
    master            ! Running                                                     
    queues            ! Running                                                     
    rate_limiting     ! Running                                                     
    repository_cache  ! Running                                                     
    sessions          ! Running                                                     
    shared_state      ! Running                                                     
    trace_chunks      ! Running


States
------

* Depending on the given ``--severity``, returns WARN (default) or CRIT if readiness and readiness probes to indicate service health and reachability to required services fail.


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1

    Name,                                       Type,               Description                                           
    gitlab-readiness-state,                     Number,             "The current state (0 = OK, 1 = WARN, 2 = CRIT, 3 = UNKNOWN)."


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
