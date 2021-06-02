Check mysql-stats
=================

Overview
--------

This check is more or less a port of the MySQLTuner script. The check *allows you to review a MySQL installation quickly and make adjustments to increase performance and stability. The current configuration variables and status data is retrieved and presented in a brief format along with some basic performance suggestions.*

If you compare the output from MySQLTuner with this check keep in mind that this check uses less connections then MySQLTuner does (in fact this check uses one connection per call only).

If you just want to check if MySQL or MariaDB is listening on its port, use the ``network-port-tcp`` check.

* Compared to MySQLTuner only performance checks are ported.
* Compared to check_mysql / MySQLTuner:
  - connections via sockets are not supported
  - only login with username / password (not via SSL/TLS) implemented
  - no option file support
  - currently no slave check via "show slave status"

  
Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/mysql-stats"
    "Check Interval Recommendation",        "Every 5 minutes"
    "Available for",                        "Python 2"
    "Requirements",                         "Python2 module ``mysql.connector``, a user with at least "PROCESS" (Role "MonitorAdmin") privileges, locked down to "127.0.0.1" - for example a user `mariadb-stats@127.0.0.1`. Usernames in MySQL/MariaDB are limited to 16 chars.
    "Handles Periods",                      "Yes"
    "Uses SQLite DBs",                      "Yes"
    "Perfdata compatible with Prometheus",  "Yes"



Help
----

.. code-block:: text

    usage: example [-h] [-V]

    Example Check.

    optional arguments:
      -h, --help       show this help message and exit
      -V, --version    show program's version number and exit


Usage Examples
--------------

.. code-block:: bash

    ./mysql-stats --username mariadb-monitor --password mypassword
    
Output:

.. code-block:: text

    TODOVM Output


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
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
* Credits:
  - heavily inspired by MySQLTuner (https://github.com/major/MySQLTuner-perl)
  - check_mysql from monitoring-plugins.org
