Check mysql-memory
==================

Overview
--------

Checks current and maximum possible memory usage specifically for MySQL/MariaDB. Logic is taken from `MySQLTuner script <https://github.com/major/MySQLTuner-perl>`_:mysql_stats(), v1.9.8.

Hints:

* Requires MySQL/MariaDB v4+.
* On RHEL 7+, one way to install the Python MySQL Connector is via ``pip install pymysql``
* Must be running locally on the MySQL/MariaDB server to be able to check the system requirements.
* Compared to check_mysql / MySQLTuner this check currently:

    * supports only simple login with username/password (not via SSL/TLS)
    * does not support a connection via socket


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-memory"
    "Check Interval Recommendation",        "Every 5 minutes"
    "Can be called without parameters",     "Yes"
    "Available for",                        "Python 3, Windows"
    "Requirements",                         "Python module ``psutil``; Python module ``pymysql``; User with PROCESS privileges, locked down to ``127.0.0.1`` - for example ``monitoring@127.0.0.1``. Usernames in MySQL/MariaDB are limited to 16 chars in specific versions."


Help
----

.. code-block:: text

    usage: mysql-memory [-h] [-V] [--always-ok] [-H HOSTNAME] [-p PASSWORD]
                        [--port PORT] [-u USERNAME]

    Checks memory metrics for MySQL/MariaDB.

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

    ./mysql-memory --hostname localhost --username root --password mypassword

Output:

.. code-block:: text

    3.1% - total: 15.3GiB, used: 492.6MiB. Maximum possible memory usage is 20.8% (possible peak: 3.2GiB). Overall possible memory usage with other process will exceed memory [WARNING]. Dedicate this server to your database for highest performance.


States
------

* WARN if max_used_memory > 2 GB on 32 bit systems.
* WARN if max_used_memory > 85%.
* WARN if physical_memory < max_peak_memory + memory usage by other processes (except some specific like MySQL/MariaDB or Systemd).


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description
    mysql_aria_pagecache_buffer_size,           Bytes,              "The size of the buffer used for index and data blocks for Aria tables. This can include explicit Aria tables, system tables, and temporary tables."
    mysql_innodb_buffer_pool_size,              Bytes,              "InnoDB buffer pool size in bytes. The primary value to adjust on a database server with entirely/primarily InnoDB tables, can be set up to 80% of the total memory in these environments."
    mysql_innodb_log_buffer_size,               Bytes,              "Size in bytes of the buffer for writing InnoDB redo log files to disk. Increasing this means larger transactions can run without needing to perform disk I/O before committing."
    mysql_join_buffer_size,                     Bytes,              "Minimum size in bytes of the buffer used for queries that cannot use an index, and instead perform a full table scan."
    mysql_key_buffer_size,                      Bytes,              "Size of the buffer for the index blocks used by MyISAM tables and shared for all threads."
    mysql_max_allowed_packet,                   Bytes,              "Maximum size in bytes of a packet or a generated/intermediate string. The packet message buffer is initialized with the value from net_buffer_length, but can grow up to max_allowed_packet bytes."
    mysql_max_connections,                      Number,             "The maximum number of simultaneous client connections."
    mysql_max_heap_table_size,                  Bytes,              "Maximum size in bytes for user-created MEMORY tables."
    mysql_max_peak_memory,                      Bytes,              server_buffers + total_per_thread_buffers + performance schema usage
    mysql_max_tmp_table_size,                   Bytes,              "max(max_heap_table_size, tmp_table_size)"
    mysql_max_total_per_thread_buffers,         Bytes,              per_thread_buffers \* max_used_connections
    mysql_max_used_connections,                 Number,             "Max number of connections ever open at the same time. The global value can be flushed by FLUSH STATUS."
    mysql_max_used_memory,                      Bytes,              server_buffers + max_total_per_thread_buffers + performance schema usage
    mysql_pct_max_physical_memory,              Percentage,         max_peak_memory / physical_memory \* 100
    mysql_pct_max_used_memory,                  Percentage,         max_used_memory / physical_memory \* 100
    mysql_per_thread_buffers,                   Bytes,              Have a look at the source code.
    mysql_physical_memory,                      Bytes,              Total physical memory (exclusive swap).
    mysql_query_cache_size,                     Bytes,              "Size in bytes available to the query cache. About 40KB is needed for query cache structures, so setting a size lower than this will result in a warning."
    mysql_read_buffer_size,                     Bytes,              "Each thread performing a sequential scan (for MyISAM, Aria and MERGE tables) allocates a buffer of this size in bytes for each table scanned."
    mysql_read_rnd_buffer_size,                 Bytes,              "Size in bytes of the buffer used when reading rows from a MyISAM table in sorted order after a key sort."
    mysql_server_buffers,                       Bytes,              Have a look at the source code.
    mysql_sort_buffer_size,                     Bytes,              "Each session performing a sort allocates a buffer with this amount of memory. Not specific to any storage engine."
    mysql_thread_stack,                         Bytes,              "Stack size for each thread."
    mysql_tmp_table_size,                       Bytes,              "The largest size for temporary tables in memory (not MEMORY tables) although if max_heap_table_size is smaller the lower limit will apply."
    mysql_total_per_thread_buffers,             Bytes,              per_thread_buffers \* max_connections


Troubleshooting
---------------

Overall possible memory usage with other process will exceed memory [WARNING]. Dedicate this server to your database for highest performance.
    Decrease ``max_connections``, tune buffer settings, stop other processes or increase memory.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
* Credits:

    * heavily inspired by MySQLTuner (https://github.com/major/MySQLTuner-perl)
