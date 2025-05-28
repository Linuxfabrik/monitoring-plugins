Check atlassian-statuspage
==========================

Overview
--------

Receive alerts on incidents on a specific `Atlassian Statuspage <https://www.atlassian.com/software/statuspage>`__. The plugin requires access to the `/api/v2/status.json` endpoint.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70

    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/atlassian-statuspage"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "Yes"
    "Compiled for",                         "Linux"


Help
----

.. code-block:: text

    usage: atlassian-statuspage [-h] [-V] [--always-ok] [--insecure] [--no-proxy]
                                [--test TEST] [--timeout TIMEOUT] [--url URL]

    Receive alerts on incidents on a specific Atlassian Statuspage.

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
      --url URL          UptimeRobot Status Page URL. Default:
                         https://status.atlassian.com


Usage Examples
--------------

.. code-block:: bash

    ./atlassian-statuspage --url=https://www.githubstatus.com

Output:

.. code-block:: text

    Minor Service Outage @ https://www.githubstatus.com, last update at 2025-05-28T12:41:26 Etc/UTC (23m 11s ago)


States
------

See https://support.atlassian.com/statuspage/docs/top-level-status-and-incident-impact-calculations/:

* WARN if statuspage reports ['minor', 'maintenance']
* CRIT if statuspage reports ['major', 'critical']


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1

    Name,                                       Type,               Description                                           
    impact,                                     Number,             "The current state (0 = OK, 1 = WARN, 2 = CRIT, 3 = UNKNOWN)."


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
