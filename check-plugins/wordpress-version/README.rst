Check wordpress-version
=======================

Overview
--------

This plugin lets you track if WordPress is End-of-Life (EOL). To compare against the current/installed version of WordPress, the check has to run on the WordPress server itself and needs access to the WordPress installation directory.

This check plugin alerts n days before or after the EOL date is reached. Optionally, it can also alert on available major, minor or patch releases (each independently).


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/wordpress-version"
    "Check Interval Recommendation",        "Once a day"
    "Can be called without parameters",     "Yes"
    "Compiled for",                         "Linux, Windows"
    "Uses SQLite DBs",                      "``$TEMP/linuxfabrik-lib-version.db``"


Help
----

.. code-block:: text

    usage: wordpress-version [-h] [-V] [--always-ok] [--path PATH]

    Tracks if WordPress is EOL.

    options:
      -h, --help     show this help message and exit
      -V, --version  show program's version number and exit
      --always-ok    Always returns OK.
      --path PATH    Local path to your WordPress installation, typically within
                     your Webserver's Document Root. Default:
                     /var/www/html/wordpress


Usage Examples
--------------

.. code-block:: bash

    ./wordpress-version --path /var/www/html/wordpress

Output:

.. code-block:: text

    WordPress v4.0.37 (EOL 2022-12-01 -30d [WARNING], major 6.3.1 available, minor 4.9.23 available, patch 4.0.38 available)


States
------

* WARN if software is EOL
* Optional: WARN when new major version is available
* Optional: WARN when new minor version is available
* Optional: WARN when new patch version is available


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description                                           
    wordpress-version,                          Number,             Installed WordPress version as float. "4.0.38" becomes "4.038".


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
