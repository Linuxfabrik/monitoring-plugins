Check mediawiki-version
=======================

Overview
--------

This plugin lets you track if MediaWiki is End-of-Life (EOL). To compare against the current/installed version of MediaWiki, the check has to run on the MediaWiki server itself.

This check plugin alerts n days before or after the EOL date is reached. Optionally, it can also alert on available major, minor or patch releases (each independently).


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mediawiki-version"
    "Check Interval Recommendation",        "Once a day"
    "Can be called without parameters",     "Yes"
    "Compiled for",                         "Linux, Windows"
    "Uses SQLite DBs",                      "``$TEMP/linuxfabrik-lib-version.db``"


Help
----

.. code-block:: text

    usage: mediawiki-version [-h] [-V] [--always-ok] [--check-major]
                             [--check-minor] [--check-patch]
                             [--offset-eol OFFSET_EOL] [--path PATH]

    Tracks if MediaWiki is EOL.

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
      --path PATH           Local path to your MediaWiki `Defines.php`. Default:
                            /var/www/html/wiki/includes/Defines.php


Usage Examples
--------------

.. code-block:: bash

    ./mediawiki-version --offset-eol=-30

Output:

.. code-block:: text

    MediaWiki v1.39.3 (EOL 2025-11-30 -30d, minor 1.41.0 available, patch 1.39.6 available)


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
    mediawiki-version,                          Number,             Installed MediaWiki version as float. "1.39.3" becomes "1.393".


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
