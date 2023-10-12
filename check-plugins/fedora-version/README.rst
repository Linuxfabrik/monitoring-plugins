Check fedora-version
====================

Overview
--------

This plugin lets you track if Fedora is End-of-Life (EOL). To compare against the current/installed version of Fedora, the check has to run on the Fedora server itself.

This check plugin alerts n days before or after the EOL date is reached. Optionally, it can also alert on available major, minor or patch releases (each independently).


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/fedora-version"
    "Check Interval Recommendation",        "Once a day"
    "Can be called without parameters",     "Yes"
    "Compiled for",                         "Linux"
    "Uses SQLite DBs",                      "``$TEMP/linuxfabrik-lib-version.db``"


Help
----

.. code-block:: text

    usage: fedora-version [-h] [-V] [--notify-new-major] [--notify-new-minor]
                          [--notify-new-patch] [--offset-eol OFFSET_EOL]
                          [--always-ok]

    Tracks if Fedora is EOL.

    options:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --notify-new-major    Alert me when there is a new major release available,
                            even if the current version of my product is not EOL.
                            Example: Notify when I run v26 (not yet EOL) and v27
                            is available. Default: False
      --notify-new-minor    Alert me when there is a new major.minor release
                            available, even if the current version of my product
                            is not EOL. Example: Notify when I run v26.2 (not yet
                            EOL) and v26.3 is available. Default: False
      --notify-new-patch    Alert me when there is a new major.minor.patch release
                            available, even if the current version of my product
                            is not EOL. Example: Notify when I run v26.2.7 (not
                            yet EOL) and v26.2.8 is available. Default: False
      --offset-eol OFFSET_EOL
                            Alert me n days before ("-30") or after an EOL date
                            ("30" or "+30"). Default: -30 days
      --always-ok           Always returns OK.


Usage Examples
--------------

.. code-block:: bash

    ./fedora-version --offset-eol=-30

Output:

.. code-block:: text

    Fedora Linux 37 (Workstation Edition) (EOL 2023-12-15 -30d, major 38 available)


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
    fedora-version,                             Number,             Installed Fedora version.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
