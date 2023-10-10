Check gitlab-liveness
=====================

Overview
--------

Checks whether the application server is running. This probe is used to know if Rails Controllers are not deadlocked due to a multi-threading.

Hints:

* Requires GitLab 12.4+
* To access monitoring resources, the requesting client IP needs to be included in the allowlist. For details, see `how to add IPs to the allowlist for the monitoring endpoints <https://docs.gitlab.com/ee/administration/monitoring/ip_allowlist.html>`.
* This check is being exempt from Rack Attack.
* GitLab Health Checks: https://docs.gitlab.com/ee/administration/monitoring/health_check.html


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/gitlab-liveness"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "Yes"
    "Compiled for",                         "Linux"


Help
----

.. code-block:: text

    usage: gitlab-liveness [-h] [-V] [--always-ok] [--severity {warn,crit}]
                           [--test TEST] [--timeout TIMEOUT] [--url URL]

    Checks whether the application server is running. This probe is used to know
    if Rails Controllers are not deadlocked due to a multi-threading. Requires
    GitLab 12.4+.

    options:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      --severity {warn,crit}
                            Severity for alerting. Default: warn
      --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                            stderr-file,expected-retc".
      --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
      --url URL             GitLab liveness URL endpoint. Default:
                            http://localhost/-/liveness


Usage Examples
--------------

.. code-block:: bash

    ./gitlab-liveness --severity warn --timeout 3 --url http://localhost/-/liveness

Output:

.. code-block:: text

    The GitLab application server is running. No Rails Controllers are deadlocked.


States
------

* Depending on the given ``--severity``, returns WARN (default) or CRIT if liveness and readiness probes to indicate service health and reachability to required services fail.


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1

    Name,                                       Type,               Description                                           
    gitlab-liveness-state,                      Number,             "The current state (0 = OK, 1 = WARN, 2 = CRIT, 3 = UNKNOWN)."


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
