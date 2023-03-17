Check mysql-table-locks
=======================

Overview
--------

Checks whether a certain percentage of table locks had to wait in MySQL/MariaDB. Logic is taken from `MySQLTuner script <https://github.com/major/MySQLTuner-perl>`_:mysql_stats(), v1.9.8.

Hints:

* See `additional notes for all mysql monitoring plugins <https://github.com/Linuxfabrik/monitoring-plugins/blob/main/PLUGINS-MYSQL.rst>`_


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-table-locks"
    "Check Interval Recommendation",        "Once an hour"
    "Can be called without parameters",     "Yes"
    "Compiled for",                         "Linux, Windows"
    "Requirements",                         "User with no privileges, locked down to ``127.0.0.1`` - for example ``monitoring\@127.0.0.1``. Usernames in MySQL/MariaDB are limited to 16 chars in specific versions."
    "3rd Party Python modules",             "``pymysql``"


Help
----

.. code-block:: text

    usage: mysql-table-locks [-h] [-V] [--always-ok]
                             [--defaults-file DEFAULTS_FILE]
                             [--defaults-group DEFAULTS_GROUP]
                             [--timeout TIMEOUT]

    Checks whether a certain percentage of table locks had to wait in
    MySQL/MariaDB.

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

    ./mysql-table-locks --defaults-file=/var/spool/icinga2/.my.cnf

Output:

.. code-block:: text

    100% table locks acquired immediately (2.6K immediate / 2.6K locks).


States
------

* WARN if less than 95% table locks were completed immediately.


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description
    mysql_pct_table_locks_immediate,            Percentage,         Table_locks_immediate / (Table_locks_waited + Table_locks_immediate) \* 100
    mysql_table_locks_immediate,                Continous Counter,  Number of table locks which were completed immediately.
    mysql_table_locks_waited,                   Continous Counter,  Number of table locks which had to wait. Indicates table lock contention.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
* Credits:

    * heavily inspired by MySQLTuner (https://github.com/major/MySQLTuner-perl)
