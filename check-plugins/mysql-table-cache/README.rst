Check mysql-table-cache
=======================

Overview
--------

Checks the hit rate for open tables cache lookups in MySQL/MariaDB. Logic is taken from `MySQLTuner script <https://github.com/major/MySQLTuner-perl>`_:mysql_stats(), v1.9.8.

Hints:

* See `additional notes for all mysql monitoring plugins <https://github.com/Linuxfabrik/monitoring-plugins/blob/main/PLUGINS-MYSQL.rst>`_
* Requires MySQL/MariaDB v5.1+.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-table-cache"
    "Check Interval Recommendation",        "Every 5 minutes"
    "Can be called without parameters",     "Yes"
    "Compiled for",                         "Linux, Windows"
    "Requirements",                         "User with no privileges, locked down to ``127.0.0.1`` - for example ``monitoring\@127.0.0.1``. Usernames in MySQL/MariaDB are limited to 16 chars in specific versions."
    "3rd Party Python modules",             "``pymysql``"


Help
----

.. code-block:: text

    usage: mysql-table-cache [-h] [-V] [--always-ok]
                             [--defaults-file DEFAULTS_FILE]
                             [--defaults-group DEFAULTS_GROUP] [--timeout TIMEOUT]

    Checks the hit rate for open tables cache lookups in MySQL/MariaDB.

    options:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      --defaults-file DEFAULTS_FILE
                            Specifies a cnf file to read parameters like user,
                            host and password from (instead of specifying them on
                            the command line), for example
                            `/var/spool/icinga2/.my.cnf`. Default:
                            /var/spool/icinga2/.my.cnf
      --defaults-group DEFAULTS_GROUP
                            Group/section to read from in the cnf file. Default:
                            client
      --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)


Usage Examples
--------------

.. code-block:: bash

    ./mysql-table-cache --defaults-file=/var/spool/icinga2/.my.cnf

Output:

.. code-block:: text

    100.0% table cache hit rate (2.3M hits / 2.3M requests)


States
------

* WARN if ``table_cache_hit_rate`` < 20%


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description
    mysql_open_files_limit,                     Number,             The number of file descriptors available to MariaDB.
    mysql_open_tables,                          Number,             "Number of currently opened tables, excluding temporary tables."
    mysql_opened_tables,                        Continous Counter,  Number of tables the server has opened.
    mysql_table_cache_hit_rate,                 Percentage,         Table_open_cache_hits / (Table_open_cache_hits + Table_open_cache_misses) * 100. If Table_open_cache_hits is not available: Open_tables / Opened_tables * 100
    mysql_table_open_cache,                     Number,             Maximum number of open tables cached in one table cache instance.
    mysql_table_open_cache_hits,                Continous Counter,  Number of hits for open tables cache lookups.
    mysql_table_open_cache_misses,              Continous Counter,  Number of misses for open tables cache lookups.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
* Credits:

    * heavily inspired by MySQLTuner (https://github.com/major/MySQLTuner-perl)
