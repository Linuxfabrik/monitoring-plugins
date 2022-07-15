Check mysql-logfile
===================

Overview
--------

Checks MySQL/MariaDB log content. The check plugin caches the location of the log in case the DB goes down. The log inspection logic is more or less taken from `MySQLTuner script <https://github.com/major/MySQLTuner-perl>`_:log_file_recommendations(), v1.9.8, and later on enhanced.

Depending on your site's policy for DB management, you could ignore lines matching the following patterns:

* "aborted connection" (happens pretty often, and might not be worth alerting)
* "access denied for user" (could be handled automatically by Fail2ban)

Hints:

* On RHEL 7+, the Python MySQL Connector can be installed with ``pip3 install mysql-connector-python``
* Must be running locally on the MySQL/MariaDB server to be able to check the log.
* Compared to MySQLTuner this check

    * is able to ignore log lines using simple lowercase string patterns or Python regular expressions
    * even checks the log if MySQL/MariaDB is down
    * supports only simple login with username/password (not via SSL/TLS)
    * does not support a connection via socket

  
Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-logfile"
    "Check Interval Recommendation",        "Every 5 minutes"
    "Can be called without parameters",     "No"
    "Available for",                        "Python 3, Windows"
    "Requirements",                         "Python module ``pymysql``; User with no privileges, locked down to ``127.0.0.1`` - for example ``monitoring@127.0.0.1``. Usernames in MySQL/MariaDB are limited to 16 chars in specific versions."
    "Uses SQLite DBs",                      "Yes"


Help
----

.. code-block:: text

    usage: mysql-logfile [-h] [-V] [--always-ok] [--cache-expire CACHE_EXPIRE]
                         [-H HOSTNAME] [--ignore-pattern IGNORE_PATTERN]
                         [--ignore-regex IGNORE_REGEX] [-p PASSWORD]
                         [--port PORT] [--server-log SERVER_LOG] [-u USERNAME]

    Checks MySQL/MariaDB log content the same way MySQLTuner does, but also in
    case the DB is down.

    options:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      --cache-expire CACHE_EXPIRE
                            The amount of time after which the cached data
                            expires, in minutes. Default: 7200
      -H HOSTNAME, --hostname HOSTNAME
                            MySQL/MariaDB hostname. Default: 127.0.0.1
      --ignore-pattern IGNORE_PATTERN
                            Any line containing this pattern will be ignored (must
                            be lowercase; repeating).
      --ignore-regex IGNORE_REGEX
                            Any line matching this python regex will be ignored.
      -p PASSWORD, --password PASSWORD
                            Use the indicated password to authenticate the
                            connection. Default:
      --port PORT           MySQL/MariaDB port. Default: 3306
      --server-log SERVER_LOG
                            One of: Path to error log file (including filename);
                            docker:CONTAINER; podman:CONTAINER; kubectl:CONTAINER;
                            systemd:UNITNAME. If ommitted, this check tries to
                            fetch the logfile location automatically.
      -u USERNAME, --username USERNAME
                            MySQL/MariaDB username. Default: root


Usage Examples
--------------

.. code-block:: bash

    ./mysql-logfile --ignore-pattern 'aborted connection' --ignore-pattern 'access denied'
    ./mysql-logfile --username mon-log --password mypassword
    ./mysql-logfile --server-log=systemd:mariadb
    ./mysql-logfile --server-log=docker:mariadb
    
Output:

.. code-block:: text

    Src: Log file /var/log/mariadb/mariadb.log (size: 5.8KiB), 2 errors [CRITICAL] (last: 220503 11:21:43 [ERROR] Aborting), 1 warning [WARNING] (last: 220502 14:59:58 [Warning] Plugin 'FEEDBACK' is disabled.), 2 starts (last: 220503 11:24:54), 4 shutdowns (last: 220503 11:21:48)
    Errors:
    * 220503 11:21:43 [ERROR] /usr/libexec/mysqld: unknown variable 'myvar2=myvalue2'
    * 220503 11:21:43 [ERROR] Aborting
    Warnings:
    * 220502 14:59:58 [Warning] Plugin 'FEEDBACK' is disabled.
    Starts:
    * 220503 11:07:38 [Note] /usr/libexec/mysqld: ready for connections.
    * 220503 11:24:54 [Note] /usr/libexec/mysqld: ready for connections.
    Shutdowns:
    * 220503 11:07:07 [Note] /usr/libexec/mysqld: Shutdown complete
    * 220503 11:07:12 [Note] /usr/libexec/mysqld: Shutdown complete
    * 220503 11:21:42 [Note] /usr/libexec/mysqld: Shutdown complete
    * 220503 11:21:48 [Note] /usr/libexec/mysqld: Shutdown complete


States
------

* CRIT if log contains "error" lines.
* WARN if log contains "warning" lines.
* WARN if a log file is configured, but it does not exist.
* WARN if a log file is configured, and it is >= 32 MiB in size.


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description                                           
    mysql_logfile_size,                         Bytes,              Logfile size
    mysql_error_lines,                          Number,             Number of error lines
    mysql_warning_lines,                        Number,             Number of warning lines
    mysql_startups,                             Number,             Number of startups
    mysql_shutdowns,                            Number,             Number of shutdowns


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
* Credits:

    * heavily inspired by MySQLTuner (https://github.com/major/MySQLTuner-perl)
