Check mysql-slow-queries
========================

Overview
--------

Checks the slow query log, which is a record of SQL queries that took a long time to perform on MySQL/MariaDB. Logic is taken from `MySQLTuner script <https://github.com/major/MySQLTuner-perl>`_:mysql_stats(), v1.9.8.

Hints:

* See `additional notes for all mysql monitoring plugins <https://github.com/Linuxfabrik/monitoring-plugins/blob/main/PLUGINS-MYSQL.rst>`_


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-slow-queries"
    "Check Interval Recommendation",        "Every 5 minutes"
    "Can be called without parameters",     "Yes"
    "Compiled for",                         "Linux, Windows"
    "Requirements",                         "User with no privileges, locked down to ``127.0.0.1`` - for example ``monitoring\@127.0.0.1``. Usernames in MySQL/MariaDB are limited to 16 chars in specific versions."
    "3rd Party Python modules",             "``pymysql``"


Help
----

.. code-block:: text

    usage: mysql-slow-queries [-h] [-V] [--always-ok]
                              [--defaults-file DEFAULTS_FILE]
                              [--defaults-group DEFAULTS_GROUP]
                              [--timeout TIMEOUT]

    Checks the slow query log, which is a record of SQL queries that took a long
    time to perform on MySQL/MariaDB.

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

    ./mysql-slow-queries --defaults-file=/var/spool/icinga2/.my.cnf

Output:

.. code-block:: text

    Slow queries: 7.0% (7.0 slow queries/100.0 questions) [WARNING]. Set long_query_time <= 10. Enable the slow_query_log to troubleshoot bad queries.


States
------

* WARN if the number of slow queries is more than 5% of all queries.


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description
    mysql_long_query_time,                      Seconds,            "If a query takes longer than this many seconds to execute, the Slow_queries status variable is incremented and, if enabled, the query is logged to the slow query log."
    mysql_questions,                            Continous Counter,  "Number of statements executed by the server, excluding COM_PING, COM_STATISTICS, COM_STMT_PREPARE, COM_STMT_CLOSE, and COM_STMT_RESET statements. Doesn't count statements executed within stored programs."
    mysql_slow_queries,                         Continous Counter,  "Number of queries which took longer than long_query_time to run. The slow query log does not need to be active for this to be recorded."
    mysql_pct_slow_queries,                     Percentage,         Slow_queries / Questions \* 100


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
* Credits:

    * heavily inspired by MySQLTuner (https://github.com/major/MySQLTuner-perl)
