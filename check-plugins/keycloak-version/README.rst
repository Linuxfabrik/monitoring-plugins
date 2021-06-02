Check keycloak-version
======================

Overview
--------

This plugin lets you track if a Keycloak update is available. To check for updates, this plugin uses the Git Repo at https://github.com/keycloak/keycloak/releases. To compare against the current/installed version of Keycloak, the check has to run on the Keycloak server itself and needs access to the Keycloak installation directory.

The check uses a sqlite database to cache its query result.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/keycloak-version"
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

    ./keycloak-version --path /opt/keycloak
    ./keycloak-version --path /opt/keycloak --cache-expire 8 --always-ok
    
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
