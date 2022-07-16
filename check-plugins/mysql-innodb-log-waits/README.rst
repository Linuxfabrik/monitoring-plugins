Check mysql-innodb-log-waits
============================

Overview
--------

Checks the number of times InnoDB was forced to wait for log writes to be flushed due to the log buffer being too small in MySQL/MariaDB. Logic is taken from `MySQLTuner script <https://github.com/major/MySQLTuner-perl>`_:mysql_innodb(), v1.8.3.

Hints:

* On RHEL 7+, one way to install the Python MySQL Connector is via ``pip install pymysql``
* Compared to check_mysql / MySQLTuner this check currently:

    * supports only simple login with username/password (not via SSL/TLS)
    * does not support a connection via socket


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

    usage: mysql-innodb-log-waits [-h] [-V] [--always-ok] [-H HOSTNAME]
                                  [-p PASSWORD] [--port PORT] [-u USERNAME]

    Checks the number of times InnoDB was forced to wait for log writes to be
    flushed due to the log buffer being too small in MySQL/MariaDB.

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

    ./mysql-innodb-log-waits --hostname localhost --username root --password mypassword

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
