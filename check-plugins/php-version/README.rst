Check php-version
=================

Overview
--------

This plugin lets you track if PHP is End-of-Life (EOL). To compare against the current/installed version of PHP, the check has to run on the PHP server itself.

This check plugin alerts n days before or after the EOL date is reached. Optionally, it can also alert on available major, minor or patch releases (each independently).


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70

    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/php-version"
    "Check Interval Recommendation",        "Once a day"
    "Can be called without parameters",     "Yes"
    "Compiled for",                         "Linux"
    "Uses SQLite DBs",                      "``$TEMP/linuxfabrik-lib-version.db``"


Help
----

.. code-block:: text

    usage: php-version [-h] [-V] [--always-ok] [--check-major] [--check-minor]
                       [--check-patch] [--insecure] [--no-proxy]
                       [--offset-eol OFFSET_EOL] [--path PATH] [--timeout TIMEOUT]

    Tracks if PHP is EOL.

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
      --path PATH           Local path to your PHP binary. Default: /usr/bin/php
      --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)


Usage Examples
--------------

.. code-block:: bash

    ./php-version --offset-eol=-30

Output:

.. code-block:: text

    PHP v7.3.1 (EOL 2021-12-06 -30d [WARNING], major 8.2.11 available, minor 7.4.33 available, patch 7.3.33 available)


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
    php-version,                                Number,             Installed PHP version as float. "7.4.33" becomes "7.433".


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
