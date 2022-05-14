Check mysql-traffic
===================

Overview
--------

Collects uptime, queries per second, connections and traffic stats for MySQL/MariaDB. Logic is taken from `MySQLTuner script <https://github.com/major/MySQLTuner-perl>`_:mysql_stats(), v1.9.8.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-traffic"
    "Check Interval Recommendation",        "Every minute"
    "Can be called without parameters",     "Yes"
    "Available for",                        "Python 3, Windows"
    "Requirements",                         "Python module ``mysql.connector``; User with no privileges, locked down to ``127.0.0.1`` - for example ``mon-aria@127.0.0.1``. Usernames in MySQL/MariaDB are limited to 16 chars in specific versions."


Help
----

.. code-block:: text

    usage: mysql-traffic [-h] [-V] [-H HOSTNAME] [-p PASSWORD] [--port PORT]
                         [-u USERNAME]

    Collects uptime, queries per second, connections and traffic stats for
    MySQL/MariaDB.

    options:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
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

    ./mysql-traffic

Output:

.. code-block:: text

    Up 1h 6m (817.0 q [0.2 qps], 331.0 conn, TX: 1.4M, RX: 104.5K); Reads / Writes: 100% / 0%


States
------

* Always returns OK.


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description
    mysql_bytes_received,                       Bytes,              Total bytes received from all clients.
    mysql_bytes_sent,                           Bytes,              Total bytes sent to all clients.
    mysql_com_delete,                           Number,             "Number of DELETE commands executed. Differs from Handler_delete, which counts the number of times rows have been deleted from tables."
    mysql_com_insert,                           Number,             Number of INSERT commands executed.
    mysql_com_replace,                          Number,             Number of REPLACE commands executed.
    mysql_com_select,                           Number,             Number of SELECT commands executed. Also includes queries that make use of the query cache.
    mysql_com_update,                           Number,             Number of UPDATE commands executed.
    mysql_connections,                          Number,             Number of connection attempts (both successful and unsuccessful) 
    mysql_pct_reads,                            Percentage,         total_reads / (total_reads + total_writes) \* 100
    mysql_pct_writes,                           Percentage,         100 - pct_reads
    mysql_qps,                                  Number,             Queries per second.
    mysql_questions,                            Number,             "Number of statements executed by the server, excluding COM_PING, COM_STATISTICS, COM_STMT_PREPARE, COM_STMT_CLOSE, and COM_STMT_RESET statements."
    mysql_uptime,                               Seconds,            Number of seconds the server has been running.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
* Credits:

    * heavily inspired by MySQLTuner (https://github.com/major/MySQLTuner-perl)
