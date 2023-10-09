Check mysql-joins
=================

Overview
--------

Checks if many joins per day without indexes were executed on MySQL/MariaDB. Logic is taken from `MySQLTuner script <https://github.com/major/MySQLTuner-perl>`_:mysql_stats(), v1.9.8.

Hints:

* See `additional notes for all mysql monitoring plugins <https://github.com/Linuxfabrik/monitoring-plugins/blob/main/PLUGINS-MYSQL.rst>`_


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-joins"
    "Check Interval Recommendation",        "Once an hour"
    "Can be called without parameters",     "Yes"
    "Compiled for",                         "Linux, Windows"
    "Requirements",                         "User with no privileges, locked down to ``127.0.0.1`` - for example ``monitoring\@127.0.0.1``. Usernames in MySQL/MariaDB are limited to 16 chars in specific versions."
    "3rd Party Python modules",             "``pymysql``"


Help
----

.. code-block:: text

    usage: mysql-joins [-h] [-V] [--always-ok] [--defaults-file DEFAULTS_FILE]
                       [--defaults-group DEFAULTS_GROUP] [--timeout TIMEOUT]

    Checks if many joins per day without indexes were executed on MySQL/MariaDB.

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

    ./mysql-joins --defaults-file=/var/spool/icinga2/.my.cnf

Output:

.. code-block:: text

    222.0 joins without indexes while MySQL/MariaDB is 20m 13s up (approx. 15.8K joins without indexes per day)

    Recommendations:
    * Set join_buffer_size > 256.0KiB, or always use indexes with JOINs
    * Raise the join_buffer_size until JOINs not using indexes are found


States
------

* WARN if there are more than 250 joins without indexes per day.


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description
    mysql_join_buffer_size,                     Bytes,              "Minimum size in bytes of the buffer used for queries that cannot use an index, and instead perform a full table scan. Increase to get faster full joins when adding indexes is not possible, although be aware of memory issues, since joins will always allocate the minimum size."
    mysql_select_full_join,                     Continous Counter,  "Number of joins which did not use an index. If not zero, you may need to check table indexes."
    mysql_select_range_check,                   Continous Counter,  "Number of joins without keys that check for key usage after each row. If not zero, you may need to check table indexes."
    mysql_uptime,                               Seconds,            "Number of seconds the server has been running."
    mysql_joins_without_indexes,                Continous Counter,  Select_range_check + Select_full_join
    mysql_joins_without_indexes_per_day,        Number,             joins_without_indexes / Uptime in days


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
* Credits:

    * heavily inspired by MySQLTuner (https://github.com/major/MySQLTuner-perl)
