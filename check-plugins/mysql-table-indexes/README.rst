Check mysql-table-indexes
=========================

Overview
--------

Checks for missing indexes in MySQL/MariaDB tables. Logic is taken from `MySQLTuner script <https://github.com/major/MySQLTuner-perl>`_, v1.9.8.

Hints:

 * See `additional notes for all mysql monitoring plugins <https://github.com/Linuxfabrik/monitoring-plugins/blob/main/PLUGINS-MYSQL.rst>`_
* Requires a user account with high privileges to access schemas like INFORMATION_SCHEMA. `For most INFORMATION_SCHEMA tables, each MySQL user has the right to access them, but can see only the rows in the tables that correspond to objects for which the user has the proper access privileges. <https://dev.mysql.com/doc/refman/5.7/en/information-schema-introduction.html#information-schema-privileges>`_. `So you can't grant permission to INFORMATION_SCHEMA directly, you have to grant permission to the tables on your own schemas, and as you do, those tables will start showing up in INFORMATION_SCHEMA queries <https://stackoverflow.com/questions/60499772/cannot-grant-mysql-user-access-to-information-schema-database>`_. Then this check provide correct results.
* Requires MySQL/MariaDB v5.5+.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-table-indexes"
    "Check Interval Recommendation",        "Once a day"
    "Can be called without parameters",     "Yes"
    "Available for",                        "Python 3, Windows"
    "Requirements",                         "Python module ``pymysql``; User with no privileges, locked down to ``127.0.0.1`` - for example ``monitoring@127.0.0.1``. Usernames in MySQL/MariaDB are limited to 16 chars in specific versions."


Help
----

.. code-block:: text

    usage: mysql-table-indexes [-h] [-V] [--always-ok]
                               [--defaults-file DEFAULTS_FILE]
                               [--defaults-group DEFAULTS_GROUP]
                               [--timeout TIMEOUT]

    Checks for missing indexes in MySQL/MariaDB tables.

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

    ./mysql-table-indexes --defaults-file=/var/spool/icinga2/.my.cnf

Output:

.. code-block:: text

    Tables without indexes: employees.current_dept_emp, employees.dept_emp_latest_date [WARNING]


States
------

* WARN if tables without indexes are found.


Perfdata / Metrics
------------------

There is no perfdata.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
* Credits:

    * heavily inspired by MySQLTuner (https://github.com/major/MySQLTuner-perl)
