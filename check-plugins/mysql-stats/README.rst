Check mysql-stats
=================

Overview
--------

This check is more or less a port of the `MySQLTuner script <https://github.com/major/MySQLTuner-perl>`_. The check *allows you to review a MySQL installation quickly and make adjustments to increase performance and stability. The current configuration variables and status data is retrieved and presented in a brief format along with some basic performance suggestions.*

If you compare the output from MySQLTuner with this check keep in mind that this check uses less connections then MySQLTuner does (in fact this check uses one connection per call only).

Hints:

* If you just want to check if MySQL or MariaDB is listening on its port, use the ``network-port-tcp`` check.
* Compared to MySQLTuner only performance checks are ported.
* Compared to check_mysql / MySQLTuner:

    * connections via sockets are not supported
    * only login with username / password (not via SSL/TLS) implemented
    * no option file support
    * currently no slave check via "show slave status"

  
Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-stats"
    "Check Interval Recommendation",        "Every 5 minutes"
    "Can be called without parameters",     "No"
    "Available for",                        "Python 2, Python 3, Windows"
    "Requirements",                         "Python module ``psutil``, Python module ``mysql.connector``; User with at least 'PROCESS' (Role 'MonitorAdmin') privileges, locked down to '127.0.0.1' - for example a user ``mariadb-stats@127.0.0.1``. Usernames in MySQL/MariaDB are limited to 16 chars."


Help
----

.. code-block:: text

    usage: mysql-stats [-h] [-V] [--always-ok] [-H HOSTNAME] -p PASSWORD
                       [--port PORT] -u USERNAME

    This check tests connections to a mysql server and gets some statistics.

    optional arguments:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      -H HOSTNAME, --hostname HOSTNAME
                            MySQL/MariaDB hostname. Default: 127.0.0.1
      -p PASSWORD, --password PASSWORD
                            Use the indicated password to authenticate the
                            connection. IMPORTANT: THIS FORM OF AUTHENTICATION IS
                            NOT SECURE.
      --port PORT           MySQL/MariaDB port. Default: 3306
      -u USERNAME, --username USERNAME
                            MySQL/MariaDB username.


Usage Examples
--------------

.. code-block:: bash

    ./mysql-stats --username mariadb-monitor --password mypassword
    
Output:

.. code-block:: text

    There are warnings.
    * More than 250 JOINs without indexes per day (increase join_buffer_size until JOINs not using indexes are found, or always use indexes with JOINs)
    * Table cache hit rate < 20% (increase table_open_cache gradually to avoid file descriptor limits, read https://mariadb.com/kb/en/library/optimizing-table_open_cache/ before increasing for MariaDB)
    ---
    MariaDB v10.5, 94%/6% r/w, up 4W 5h, 25.2M Questions, 10.3 QPS, 311.3K Connections, 8.3GiB/104.0GiB (Rx/Tx)
    * No log file set (set log_error)
    * Maximum possible memory usage: 2.0GiB (72% of installed RAM)
    * Maximum reached memory usage: 1.6GiB (57% of installed RAM)
    * Slow queries: 0% (1.0/25.2M)
    * Highest connection usage: 25% (38.0/151.0)
    * Aborted connections: 0% (559.0/311292.0)
    * Sorts requiring temporary tables: 0% (2395.0 temp sorts / 6.8M sorts)
    * Joins performed without indexes: 89885.0
    * Temporary tables created on disk: 18% (464.5K on disk / 2.5M total)
    * Thread cache hit rate: 99% (119.0 created / 311292.0 connections)
    * Table cache hit rate: 1% (779.0 open / 63955.0 opened)
    * Open file limit used: 0% (56.0/32184.0)
    * Table locks acquired immediately: 99% (1235750.0 immediate / 1235791.0 locks)


States
------

* CRIT if MySQL's / MariaDB's maximum memory usage is dangerously high.
* WARN if any recommendation regarding system ressources is found.


Perfdata / Metrics
------------------

* bytes_received
* bytes_sent
* connections
* joins_without_indexes
* pct_connections_aborted
* pct_connections_used
* pct_files_open
* pct_max_physical_memory
* pct_max_used_memory
* pct_slow_queries
* pct_table_locks_immediate
* pct_temp_disk
* pct_temp_sort_table
* qps: Queries per second
* questions: Number of queries
* table_cache_hit_rate
* thread_cache_hit_rate
* uptime: MySQL/MariaDB's uptime


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
* Credits:

    * heavily inspired by MySQLTuner (https://github.com/major/MySQLTuner-perl)
    * check_mysql from monitoring-plugins.org
