Check mysql-open-files
======================

Overview
--------

Checks the open file usage in MySQL/MariaDB. Logic is taken from `MySQLTuner script <https://github.com/major/MySQLTuner-perl>`_:mysql_stats(), v1.9.8.

Hints:

* See `additional notes for all mysql monitoring plugins <https://github.com/Linuxfabrik/monitoring-plugins/blob/main/PLUGINS-MYSQL.rst>`_


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-open-files"
    "Check Interval Recommendation",        "Every 5 minutes"
    "Can be called without parameters",     "Yes"
    "Available for",                        "Python 3, Windows"
    "Requirements",                         "Python module ``pymysql``; User with no privileges, locked down to ``127.0.0.1`` - for example ``monitoring@127.0.0.1``. Usernames in MySQL/MariaDB are limited to 16 chars in specific versions."


Help
----

.. code-block:: text

    usage: mysql-open-files [-h] [-V] [--always-ok]
                            [--defaults-file DEFAULTS_FILE]
                            [--defaults-group DEFAULTS_GROUP] [--timeout TIMEOUT]

    Checks the open file usage in MySQL/MariaDB.

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

    ./mysql-open-files --defaults-file=/var/spool/icinga2/.my.cnf

Output:

.. code-block:: text

    0.2% of open_files_limit used (80.0/32.8K).


States
------

* WARN if amount of open files is > 85%.


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description
    mysql_open_files,                           Number,             "Number of regular files currently opened by the server. Does not include sockets or pipes, or storage engines using internal functions."
    mysql_open_files_limit,                     Number,             "The number of file descriptors available to MariaDB. If you are getting the ``Too many open files`` error, then you should increase this limit."
    mysql_pct_files_open,                       Percentage,         Open_files / open_files_limit * 100


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
* Credits:

    * heavily inspired by MySQLTuner (https://github.com/major/MySQLTuner-perl)
