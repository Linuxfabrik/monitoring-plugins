Check mysql-binlog-cache
========================

Overview
--------

Checks if a certain amount of transactions used a temporary disk cache because they could not fit in the regular binary log cache in MySQL/MariaDB. Logic is taken from `MySQLTuner script <https://github.com/major/MySQLTuner-perl>`_:mysql_stats(), v1.9.8.

Hints:

* See `additional notes for all mysql monitoring plugins <https://github.com/Linuxfabrik/monitoring-plugins/blob/main/PLUGINS-MYSQL.rst>`_
* If ``log_bin`` is set to ``OFF``, this check makes no sense.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-binlog-cache"
    "Check Interval Recommendation",        "Every 5 minutes"
    "Can be called without parameters",     "Yes"
    "Compiled for",                         "Linux, Windows"
    "Requirements",                         "User with no privileges, locked down to ``127.0.0.1`` - for example ``monitoring\@127.0.0.1``. Usernames in MySQL/MariaDB are limited to 16 chars in specific versions."
    "3rd Party Python modules",             "``pymysql``"


Help
----

.. code-block:: text

    usage: mysql-binlog-cache [-h] [-V] [--always-ok]
                              [--defaults-file DEFAULTS_FILE]
                              [--defaults-group DEFAULTS_GROUP]
                              [--timeout TIMEOUT]

    Checks if a certain amount of transactions used a temporary disk cache because
    they could not fit in the regular binary log cache in MySQL/MariaDB.

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

    ./mysql-binlog-cache --defaults-file=/var/spool/icinga2/.my.cnf

Output:

.. code-block:: text

    0% binlog cache memory access (0 memory / 0 total).


States
------

* WARN if more than 10% of all transactions using the binary log cache are read from disk.


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description
    mysql_binlog_cache_disk_use,                Continous Counter,  "Number of transactions which used a temporary disk cache because they could not fit in the regular binary log cache, being larger than binlog_cache_size."
    mysql_binlog_cache_size,                    Bytes,              "If the binary log is active, this variable determines the size in bytes, per-connection, of the cache holding a record of binary log changes during a transaction."
    mysql_binlog_cache_use,                     Continous Counter,  "Number of transaction which used the regular binary log cache, being smaller than binlog_cache_size."
    mysql_pct_binlog_cache,                     Percentage,         (Binlog_cache_use - Binlog_cache_disk_use) / Binlog_cache_use \* 100


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
* Credits:

    * heavily inspired by MySQLTuner (https://github.com/major/MySQLTuner-perl)
