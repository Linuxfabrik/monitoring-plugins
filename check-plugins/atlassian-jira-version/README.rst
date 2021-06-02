Check eatlassian-jira-version
=============================

Overview
--------

This plugin lets you track if a Atlassian Jira server update is available. To check for updates, this plugin uses the Atlassian RSS release feed. To compare against the current/installed version of Atlassian Jira, the check has to run on the Atlassian Jira server itself and needs access to the Atlassian Jira installation directory.

The check uses a sqlite database to cache its query result.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/atlassian-jira-version"
    "Check Interval Recommendation",        "Once a day"
    "Available for",                        "Python 2"
    "Requirements",                         "Python module ``psutil``, command-line tool ``foo``"
    "Handles Periods",                      "Yes"
    "Uses SQLite DBs",                      "Yes"
    "Perfdata compatible with Prometheus",  "Yes"


Help
----

.. code-block:: text

    usage: example [-h] [-V]

    Example Check.

    optional arguments:
      -h, --help       show this help message and exit
      -V, --version    show program's version number and exit


Usage Examples
--------------

.. code-block:: bash

    ./atlassian-jira-version --path /opt/atlassian/jira
    ./atlassian-jira-version --path /opt/atlassian/jira --cache-expire 8 --always-ok
    
Output:

.. code-block:: text

    TODOVM Output


States
------

* If wanted, always returns OK,
* else returns WARN if update is available.


Perfdata / Metrics
------------------

There is no perfdata.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
