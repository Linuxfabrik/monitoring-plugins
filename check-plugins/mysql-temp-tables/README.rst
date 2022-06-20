Check mysql-temp-tables
=======================

Overview
--------

Checks the number of on-disk versus in-memory temporary tables created in MySQL/MariaDB. Logic is taken from `MySQLTuner script <https://github.com/major/MySQLTuner-perl>`_:mysql_stats(), v1.9.8.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-temp-tables"
    "Check Interval Recommendation",        "Every 15 minutes"
    "Can be called without parameters",     "Yes"
    "Available for",                        "Python 3, Windows"
    "Requirements",                         "Python module ``pymysql``; User with no privileges, locked down to ``127.0.0.1`` - for example ``monitoring@127.0.0.1``. Usernames in MySQL/MariaDB are limited to 16 chars in specific versions."


Help
----

.. code-block:: text

    usage: mysql-temp-tables [-h] [-V] [--always-ok] [-H HOSTNAME] [-p PASSWORD]
                             [--port PORT] [-u USERNAME]

    Checks the number of on-disk versus in-memory temporary tables created in
    MySQL/MariaDB.

    options:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      -H HOSTNAME, --hostname HOSTNAME
                            MySQL/MariaDB hostname. Default: 127.0.0.1
      -p PASSWORD, --password PASSWORD
                            Use the indicated password to authenticate the
                            connection. Default:
      --port PORT           MySQL/MariaDB port. Default: 3306
      -u USERNAME, --username USERNAME
                            MySQL/MariaDB username. Default: root


Usage Examples
--------------

.. code-block:: bash

    ./mysql-temp-tables --hostname localhost --username root --password mypassword

Output:

.. code-block:: text

    17.9% temporary tables created on disk (2.4M on disk / 13.6M total).


States
------

* WARN if ``pct_temp_disk`` (number of on-disk temporary tables) > 25%


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description
    mysql_created_tmp_disk_tables,              Continous Counter,  Number of on-disk temporary tables created.
    mysql_created_tmp_tables,                   Continous Counter,  Number of in-memory temporary tables created.
    mysql_max_heap_table_size,                  Bytes,              Maximum size in bytes for user-created MEMORY tables.
    mysql_max_tmp_table_size,                   Bytes,              "max(max_heap_table_size, tmp_table_size)"
    mysql_pct_temp_disk,                        Percentage,         Created_tmp_disk_tables / Created_tmp_tables * 100
    mysql_tmp_table_size,                       Bytes,              The largest size for temporary tables in memory (not MEMORY tables) although if max_heap_table_size is smaller the lower limit will apply.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
* Credits:

    * heavily inspired by MySQLTuner (https://github.com/major/MySQLTuner-perl)
