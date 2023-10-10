Check gitlab-health
===================

Overview
--------

Checks whether the GitLab application server is running. It does not hit the database or verifies other services are running. Its purpose is to notify that the application server is handling requests, but a STATE_OK response does not signify that the database or other services are ready.

Hints:

* Requires GitLab 9.1.0+
* To access monitoring resources, the requesting client IP needs to be included in the allowlist. For details, see `how to add IPs to the allowlist for the monitoring endpoints <https://docs.gitlab.com/ee/administration/monitoring/ip_allowlist.html>`.
* GitLab Health Checks: https://docs.gitlab.com/ee/administration/monitoring/health_check.html


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/gitlab-health"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "Yes"
    "Compiled for",                         "Linux"


Help
----

.. code-block:: text

    usage: gitlab-health [-h] [-V] [--always-ok] [--severity {warn,crit}]
                         [--test TEST] [--timeout TIMEOUT] [--url URL]

    Checks whether the GitLab application server is running. It does not hit the
    database or verifies other services are running.

    options:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      --severity {warn,crit}
                            Severity for alerting. Default: warn
      --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                            stderr-file,expected-retc".
      --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
      --url URL             GitLab health URL endpoint. Default:
                            http://localhost/-/health


Usage Examples
--------------

.. code-block:: bash

    ./gitlab-health --severity warn --timeout 3 --url http://localhost/-/health

Output:

.. code-block:: text

    The GitLab application server is processing requests, but this does not mean that the database or other services are ready.


States
------

* Depending on the given ``--severity``, returns WARN (default) or CRIT if liveness and readiness probes to indicate service health and reachability to required services fail.


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1

    Name,                                       Type,               Description                                           
    gitlab-health-state,                        Number,             "The current state (0 = OK, 1 = WARN, 2 = CRIT, 3 = UNKNOWN)."


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
