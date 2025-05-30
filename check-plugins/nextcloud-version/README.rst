Check nextcloud-version
=======================

Overview
--------

This plugin lets you track if Nextcloud is End-of-Life (EOL). To compare against the current/installed version of Nextcloud, the check has to run on the nextcloud server itself and needs access to the Nextcloud installation directory.

This check plugin alerts n days before or after the EOL date is reached. Optionally, it can also alert on available major, minor or patch releases (each independently).


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70

    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/nextcloud-version"
    "Check Interval Recommendation",        "Once a day"
    "Can be called without parameters",     "Yes"
    "Compiled for Windows",                 "No"
    "Uses SQLite DBs",                      "``$TEMP/linuxfabrik-lib-version.db``"


Help
----

.. code-block:: text

    usage: nextcloud-version [-h] [-V] [--always-ok] [--check-major]
                             [--check-minor] [--check-patch] [--insecure]
                             [--no-proxy] [--offset-eol OFFSET_EOL] [--path PATH]
                             [--timeout TIMEOUT]

    Tracks if Nextcloud is EOL.

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
      --insecure            This option explicitly allows to perform "insecure"
                            SSL connections. Default: False
      --no-proxy            Do not use a proxy. Default: False
      --offset-eol OFFSET_EOL
                            Alert me n days before ("-30") or after an EOL date
                            ("30" or "+30"). Default: -30 days
      --path PATH           Local path to your Nextcloud installation, typically
                            within your Webserver's Document Root. Default:
                            /var/www/html/nextcloud
      --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)


Usage Examples
--------------

.. code-block:: bash

    ./nextcloud-version --path /var/www/html/nextcloud

Output:

.. code-block:: text

    Nextcloud v22.1.7 (EOL 2022-07-01 -30d [WARNING], major 27.1.2 available, minor 22.2.10 available)


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
    nextcloud-version,                          Number,             Installed Nextcloud version as float. "23.0.12" becomes "23.012".


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
