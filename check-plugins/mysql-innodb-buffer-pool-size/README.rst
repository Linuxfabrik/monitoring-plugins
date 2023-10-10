Check mysql-innodb-buffer-pool-size
===================================

Overview
--------

Checks the size of the InnoDB buffer pool in MySQL/MariaDB. Logic is taken from `MySQLTuner script <https://github.com/major/MySQLTuner-perl>`_:mysql_innodb().

Always take care of both ``innodb_buffer_pool_size`` and ``innodb_log_file_size`` when making adjustments.

User account requires:

* Access to INFORMATION_SCHEMA (user with no privileges is sufficient).
* SELECT privileges on all schemas and tables to provide accurate results.

Hints:

* See `additional notes for all mysql monitoring plugins <https://github.com/Linuxfabrik/monitoring-plugins/blob/main/PLUGINS-MYSQL.rst>`_
* `For most INFORMATION_SCHEMA tables, each MySQL user has the right to access them, but can see only the rows in the tables that correspond to objects for which the user has the proper access privileges. <https://dev.mysql.com/doc/refman/5.7/en/information-schema-introduction.html#information-schema-privileges>`_. `So you can't grant permission to INFORMATION_SCHEMA directly, you have to grant SELECT permission to the tables on your own schemas, and as you do, those tables will start showing up in INFORMATION_SCHEMA queries <https://stackoverflow.com/questions/60499772/cannot-grant-mysql-user-access-to-information-schema-database>`_. Then this check provide correct results.
* On MariaDB 10.2.2+, ``innodb_buffer_pool_size`` `can be set dynamically. <https://mariadb.com/kb/en/setting-innodb-buffer-pool-size-dynamically/>`_.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-innodb-buffer-pool-size"
    "Check Interval Recommendation",        "Every 5 minutes"
    "Can be called without parameters",     "Yes"
    "Compiled for",                         "Linux, Windows"
    "3rd Party Python modules",             "``pymysql``"


Help
----

.. code-block:: text

    usage: mysql-innodb-buffer-pool-size [-h] [-V] [--always-ok]
                                         [--defaults-file DEFAULTS_FILE]
                                         [--defaults-group DEFAULTS_GROUP]
                                         [--timeout TIMEOUT]

    Checks the size of the InnoDB buffer pool in MySQL/MariaDB.

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

    ./mysql-innodb-buffer-pool-size --defaults-file=/var/spool/icinga2/.my.cnf

Output:

.. code-block:: text

    Data size: 2.5GiB, innodb_buffer_pool_size: 4.0GiB
    Ratio innodb_log_file_size (1.0GiB) * innodb_log_files_in_group (1) vs. innodb_buffer_pool_size (4.0GiB): 25%


States
------

* WARN on 32 bit systems when InnoDB buffer pool size > 4 GiB.
* WARN on 64 bit systems when InnoDB buffer pool size > 16 EiB.
* WARN if size of data does not fit into the InnoDB buffer pool.
* WARN if the InnoDB log file size versus the InnoDB buffer pool size ratio is not in the range of 20 to 30%.


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description
    mysql_innodb_buffer_pool_size,              Bytes,              "InnoDB buffer pool size in bytes. The primary value to adjust on a database server with entirely/primarily InnoDB tables, can be set up to 80% of the total memory."
    mysql_innodb_log_file_size,                 Bytes,              "Size in bytes of each InnoDB redo log file in the log group. The combined size can be no more than 512GB. Larger values mean less disk I/O due to less flushing checkpoint activity, but also slower recovery from a crash."
    mysql_innodb_log_files_in_group,            Number,             "Number of physical files in the InnoDB redo log. Deprecated and ignored from MariaDB 10.5.2."
    mysql_innodb_log_size_pct,                  Percentage,         innodb_log_file_size \* innodb_log_files_in_group / innodb_buffer_pool_size \* 100


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
* Credits:

    * heavily inspired by MySQLTuner (https://github.com/major/MySQLTuner-perl)
