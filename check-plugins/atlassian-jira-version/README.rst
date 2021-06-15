Check atlassian-jira-version
=============================

Overview
--------

This plugin lets you track if an Atlassian Jira server update is available. To check for updates, this plugin uses the Atlassian RSS release feed. To compare against the current/installed version of Atlassian Jira, the check has to run on the Atlassian Jira server itself and needs access to the Atlassian Jira installation directory.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/atlassian-jira-version"
    "Check Interval Recommendation",        "Once a day"
    "Can be called without parameters",     "Yes"
    "Available for",                        "Python 2"
    "Requirements",                         "None"
    "Uses SQLite DBs",                      "Yes"


Help
----

.. code-block:: text

    usage: atlassian-jira-version [-h] [-V] [--always-ok]
                                   [--cache-expire CACHE_EXPIRE] [--path PATH]

    This plugin lets you track if server updates are available.

    optional arguments:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      --cache-expire CACHE_EXPIRE
                            The amount of time after which the update check cache
                            expires, in hours. Default: 24
      --path PATH           Local path to your Atlassian Jira installation.
                            Default: /opt/atlassian/jira


Usage Examples
--------------

.. code-block:: bash

    ./atlassian-jira-version --path /opt/atlassian/jira --cache-expire 8 --always-ok
    
Output:

.. code-block:: text

    Atlassian Jira v8.17.0 is up to date


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
