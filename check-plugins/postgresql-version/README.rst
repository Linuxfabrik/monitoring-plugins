Check postgresql-version
========================

Overview
--------

This plugin lets you track if PostgreSQL is End-of-Life (EOL). To compare against the current/installed version of PostgreSQL, the check has to run on the PostgreSQL server itself.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/postgresql-version"
    "Check Interval Recommendation",        "Once a day"
    "Can be called without parameters",     "Yes"
    "Compiled for",                         "Linux"


Help
----

.. code-block:: text

    usage: postgresql-version [-h] [-V] [--always-ok] [--username USERNAME]

    Tracks if PostgreSQL is EOL.

    optional arguments:
      -h, --help           show this help message and exit
      -V, --version        show program's version number and exit
      --always-ok          Always returns OK.
      --username USERNAME  PostgreSQL username. Default: postgres


Usage Examples
--------------

.. code-block:: bash

    ./postgresql-version

Output:

.. code-block:: text

    PostgreSQL v10.23 (EOL 2022-11-10 [WARNING])


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
    postgresql-version,                         Number,             Installed PostgreSQL version as float. "10.23" becomes 10.23.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
