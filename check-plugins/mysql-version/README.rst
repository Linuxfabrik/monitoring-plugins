Check mysql-version
===================

Overview
--------

This plugin lets you track if MySQL/MariaDB is End-of-Life (EOL). To compare against the current/installed version of MySQL/MariaDB, the check has to run on the MySQL/MariaDB server itself.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-version"
    "Check Interval Recommendation",        "Once a day"
    "Can be called without parameters",     "Yes"
    "Compiled for",                         "Linux"


Help
----

.. code-block:: text

    usage: mysql-version [-h] [-V] [--always-ok]

    Tracks if mysql is EOL.

    options:
      -h, --help     show this help message and exit
      -V, --version  show program's version number and exit
      --always-ok    Always returns OK.


Usage Examples
--------------

.. code-block:: bash

    ./mysql-version

Output:

.. code-block:: text

    MariaDB v10.6.12 (EOL 2026-07-06)


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
    mysql-version,                              Number,             Installed MySQL/MariaDB version as float. "10.6.12" becomes "10.612".


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
