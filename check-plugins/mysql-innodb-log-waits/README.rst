Check mysql-innodb-log-waits
============================

Overview
--------

Checks the number of times InnoDB was forced to wait for log writes to be flushed due to the log buffer being too small in MySQL/MariaDB. Logic is taken from `MySQLTuner script <https://github.com/major/MySQLTuner-perl>`_:mysql_innodb(), v1.8.3.

Hints:

* See `additional notes for all mysql monitoring plugins <https://github.com/Linuxfabrik/monitoring-plugins/blob/main/PLUGINS-MYSQL.rst>`_


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-innodb-log-waits"
    "Check Interval Recommendation",        "Once an hour"
    "Can be called without parameters",     "Yes"
    "Available for",                        "Python 3, Windows"
    "Requirements",                         "Python module ``pymysql``; User with no privileges, locked down to ``127.0.0.1`` - for example ``monitoring@127.0.0.1``. Usernames in MySQL/MariaDB are limited to 16 chars in specific versions."


Help
----

.. code-block:: text

    usage: mysql-innodb-log-waits [-h] [-V] [--always-ok]
                                  [--defaults-file DEFAULTS_FILE]
                                  [--defaults-group DEFAULTS_GROUP]
                                  [--timeout TIMEOUT]

    Checks the number of times InnoDB was forced to wait for log writes to be
    flushed due to the log buffer being too small in MySQL/MariaDB.

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

    ./mysql-innodb-log-waits --defaults-file=/var/spool/icinga2/.my.cnf

Output:

.. code-block:: text

    0.0 InnoDB log buffer waits / 867.6K writes.


States
------

* WARN if the number of times InnoDB was forced to wait for log writes to be flushed is > 0.


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description
    mysql_innodb_log_buffer_size,               Bytes,              "Size in bytes of the buffer for writing InnoDB redo log files to disk. Increasing this means larger transactions can run without needing to perform disk I/O before committing."
    mysql_innodb_log_waits,                     Continous Counter,  "Number of times InnoDB was forced to wait for log writes to be flushed due to the log buffer being too small."
    mysql_innodb_log_writes,                    Continous Counter,  "Number of writes to the InnoDB redo log."


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
* Credits:

    * heavily inspired by MySQLTuner (https://github.com/major/MySQLTuner-perl)
