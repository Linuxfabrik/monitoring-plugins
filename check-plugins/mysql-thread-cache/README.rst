Check mysql-thread-cache
========================

Overview
--------

MySQL/MariaDB tracks the number of threads it caches for re-use. This plug-in checks the cache hit rate after a minimum uptime of one hour. If the thread pool is active, ``thread_cache_size`` is ignored. Logic is taken from `MySQLTuner script <https://github.com/major/MySQLTuner-perl>`_:mysql_stats(), v1.9.8.

Hints:

* See `additional notes for all mysql monitoring plugins <https://github.com/Linuxfabrik/monitoring-plugins/blob/main/PLUGINS-MYSQL.rst>`_


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70

    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-thread-cache"
    "Check Interval Recommendation",        "Once an hour"
    "Can be called without parameters",     "Yes"
    "Compiled for",                         "Linux, Windows"
    "Requirements",                         "User with no privileges, locked down to ``127.0.0.1`` - for example ``monitoring\@127.0.0.1``. Usernames in MySQL/MariaDB are limited to 16 chars in specific versions."
    "3rd Party Python modules",             "``pymysql``"


Help
----

.. code-block:: text

    usage: mysql-thread-cache [-h] [-V] [--always-ok]
                              [--defaults-file DEFAULTS_FILE]
                              [--defaults-group DEFAULTS_GROUP]
                              [--timeout TIMEOUT]

    Checks the number of threads MySQL/MariaDB caches for re-use.

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

    ./mysql-thread-cache --defaults-file=/var/spool/icinga2/.my.cnf

Output:

.. code-block:: text

    100.0% thread cache hit rate (910.0 threads created / 8.7M connections).


States
------

* WARN if ``thread_cache_size`` is ``0``.
* WARN if thread cache hit rate is <= 50%.


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description
    mysql_connections,                          Continous Counter,  "Number of connection attempts (both successful and unsuccessful)."
    mysql_thread_cache_hit_rate,                Percentage,         "100 - Threads_created / Connections \* 100"
    mysql_thread_cache_size,                    Bytes,              "Number of threads server caches for re-use."
    mysql_threads_created,                      Continous Counter,  "Number of threads created to respond to client connections. If too large, look at increasing thread_cache_size."


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
* Credits:

    * heavily inspired by MySQLTuner (https://github.com/major/MySQLTuner-perl)
