Check keycloak-version
======================

Overview
--------

This plugin lets you track if a Keycloak update is available. To check for updates, this plugin uses the Git Repo at https://github.com/keycloak/keycloak/releases. To compare against the current/installed version of Keycloak, the check has to run on the Keycloak server itself and needs access to the Keycloak installation directory.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/keycloak-version"
    "Check Interval Recommendation",        "Once a day"
    "Can be called without parameters",     "Yes"
    "Available for",                        "Python 2"
    "Requirements",                         "None"
    "Uses SQLite DBs",                      "Yes"


Help
----

.. code-block:: text

    usage: keycloak-version [-h] [-V] [--always-ok] [--cache-expire CACHE_EXPIRE]
                            [--path PATH]

    This plugin lets you track if server updates are available.

    optional arguments:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      --cache-expire CACHE_EXPIRE
                            The amount of time after which the update check cache
                            expires, in hours. Default: 24
      --path PATH           Local path to your Keycloak installation. Default:
                            /opt/keycloak


Usage Examples
--------------

.. code-block:: bash

    ./keycloak-version --path /opt/keycloak --cache-expire 8 --always-ok
    
Output:

.. code-block:: text

    Keycloak v13.0.1 is up to date


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
