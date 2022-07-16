Check mysql-thread-cache
========================

Overview
--------

MySQL/MariaDB tracks the number of threads it caches for re-use. This plugin checks the cache hit rate. If the thread pool is active, ``thread_cache_size`` is ignored. Logic is taken from `MySQLTuner script <https://github.com/major/MySQLTuner-perl>`_:mysql_stats(), v1.9.8.

Hints:

* On RHEL 7+, one way to install the Python MySQL Connector is via ``pip install pymysql``
* Compared to check_mysql / MySQLTuner this check currently:

    * supports only simple login with username/password (not via SSL/TLS)
    * does not support a connection via socket


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-thread-cache"
    "Check Interval Recommendation",        "Once an hour"
    "Can be called without parameters",     "Yes"
    "Available for",                        "Python 3, Windows"
    "Requirements",                         "Python module ``pymysql``; User with no privileges, locked down to ``127.0.0.1`` - for example ``monitoring@127.0.0.1``. Usernames in MySQL/MariaDB are limited to 16 chars in specific versions."


Help
----

.. code-block:: text

    usage: mysql-thread-cache [-h] [-V] [--always-ok] [-H HOSTNAME] [-p PASSWORD]
                              [--port PORT] [-u USERNAME]

    Checks the number of threads MySQL/MariaDB caches for re-use.

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

    ./mysql-thread-cache --hostname localhost --username root --password mypassword

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
    mysql_connections,                          Continous Counter,  Number of connection attempts (both successful and unsuccessful).
    mysql_thread_cache_hit_rate,                Percentage,         100 - Threads_created / Connections \* 100
    mysql_thread_cache_size,                    Bytes,              Number of threads server caches for re-use.
    mysql_threads_created,                      Continous Counter,  "Number of threads created to respond to client connections. If too large, look at increasing thread_cache_size.""


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
* Credits:

    * heavily inspired by MySQLTuner (https://github.com/major/MySQLTuner-perl)
