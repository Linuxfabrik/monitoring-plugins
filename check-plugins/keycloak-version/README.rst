Check keycloak-version
======================

Overview
--------

This plugin lets you track if Keycloak is End-of-Life (EOL). To compare against the current/installed version of Keycloak, the check has to run on the Keycloak server itself and needs access to the Keycloak installation directory.

This check plugin alerts n days before or after the EOL date is reached. Optionally, it can also alert on available major, minor or patch releases (each independently).


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/keycloak-version"
    "Check Interval Recommendation",        "Once a day"
    "Can be called without parameters",     "Yes"
    "Compiled for",                         "Linux"
    "Uses SQLite DBs",                      "``$TEMP/linuxfabrik-lib-version.db``"


Help
----

.. code-block:: text

    usage: keycloak-version [-h] [-V] [--always-ok] [--check-major]
                            [--check-minor] [--check-patch]
                            [--offset-eol OFFSET_EOL] [--path PATH]

    Tracks if Keycloak is EOL.

    options:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      --check-major         Alert me when there is a new major release available,
                            even if the current version of my product is not EOL.
                            Example: Notify when I run v26 (not yet EOL) and v27
                            is available. Default: False
      --check-minor         Alert me when there is a new major.minor release
                            available, even if the current version of my product
                            is not EOL. Example: Notify when I run v26.2 (not yet
                            EOL) and v26.3 is available. Default: False
      --check-patch         Alert me when there is a new major.minor.patch release
                            available, even if the current version of my product
                            is not EOL. Example: Notify when I run v26.2.7 (not
                            yet EOL) and v26.2.8 is available. Default: False
      --offset-eol OFFSET_EOL
                            Alert me n days before ("-30") or after an EOL date
                            ("30" or "+30"). Default: -30 days
      --path PATH           Local path to your Keycloak installation. Default:
                            /opt/keycloak


Usage Examples
--------------

.. code-block:: bash

    ./keycloak-version --path /opt/keycloak

Output:

.. code-block:: text

    Keycloak v21.0.1 (EOL 2023-04-19 -30d [WARNING], major 22.0.4 available, minor 21.1.2 available, patch 21.0.2 available)


States
------

* WARN if Software is EOL
* Optional: WARN when new major version is available
* Optional: WARN when new minor version is available
* Optional: WARN when new patch version is available


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
