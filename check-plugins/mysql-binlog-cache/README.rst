Check mysql-binlog-cache
========================

Overview
--------

Checks if a certain amount of transactions used a temporary disk cache because they could not fit in the regular binary log cache in MySQL/MariaDB. Logic is taken from `MySQLTuner script <https://github.com/major/MySQLTuner-perl>`_:mysql_stats(), v1.9.8.

Hints:

* If ``log_bin`` is set to ``OFF``, this check makes no sense.
* On RHEL 7+, one way to install the Python MySQL Connector is via ``pip install pymysql``
* Compared to check_mysql / MySQLTuner this check currently:

    * supports only simple login with username/password (not via SSL/TLS)
    * does not support a connection via socket


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-binlog-cache"
    "Check Interval Recommendation",        "Every 5 minutes"
    "Can be called without parameters",     "Yes"
    "Available for",                        "Python 3, Windows"
    "Requirements",                         "Python module ``pymysql``; User with no privileges, locked down to ``127.0.0.1`` - for example ``monitoring@127.0.0.1``. Usernames in MySQL/MariaDB are limited to 16 chars in specific versions."


Help
----

.. code-block:: text

    usage: mysql-binlog-cache [-h] [-V] [--always-ok] [-H HOSTNAME] [-p PASSWORD]
                              [--port PORT] [-u USERNAME]

    Checks if a certain amount of transactions used a temporary disk cache because
    they could not fit in the regular binary log cache in MySQL/MariaDB.

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

    ./mysql-binlog-cache --hostname localhost --username root --password mypassword

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
