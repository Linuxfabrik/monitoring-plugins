Check keycloak-version
======================

Overview
--------

This plugin lets you track if Keycloak is End-of-Life (EOL). To compare against the current/installed version of Keycloak, the check has to run on the Keycloak server itself and needs access to the Keycloak installation directory.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/keycloak-version"
    "Check Interval Recommendation",        "Once a day"
    "Can be called without parameters",     "Yes"
    "Compiled for",                         "Linux"


Help
----

.. code-block:: text

    usage: keycloak-version [-h] [-V] [--always-ok] [--path PATH]

    Tracks if Keycloak is EOL.

    options:
      -h, --help     show this help message and exit
      -V, --version  show program's version number and exit
      --always-ok    Always returns OK.
      --path PATH    Local path to your Keycloak installation. Default:
                     /opt/keycloak


Usage Examples
--------------

.. code-block:: bash

    ./keycloak-version --path /opt/keycloak

Output:

.. code-block:: text

    Keycloak v18.0.0 (EOL 2022-07-27) [WARNING]


States
------

* If wanted, always returns OK,
* else returns WARN if Software is EOL


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description                                           
    keycloak-version,                           Number,             Installed Keycloak version as float. "18.0.3" becomes "18.03".


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
