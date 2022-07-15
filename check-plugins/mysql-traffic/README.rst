Check mysql-traffic
===================

Overview
--------

Collects uptime, queries per second, connections and traffic stats for MySQL/MariaDB. Logic is taken from `MySQLTuner script <https://github.com/major/MySQLTuner-perl>`_:mysql_stats(), v1.9.8.

Hints:

* On RHEL 7+, the Python MySQL Connector can be installed with ``pip3 install mysql-connector-python``
* Compared to check_mysql / MySQLTuner this check currently:

    * supports only simple login with username/password (not via SSL/TLS)
    * does not support a connection via socket


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-traffic"
    "Check Interval Recommendation",        "Every minute"
    "Can be called without parameters",     "Yes"
    "Available for",                        "Python 3, Windows"
    "Requirements",                         "Python module ``pymysql``; User with no privileges, locked down to ``127.0.0.1`` - for example ``monitoring@127.0.0.1``. Usernames in MySQL/MariaDB are limited to 16 chars in specific versions."


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

    Up 1W 3D (907.7K q [1.0 qps], 470.0 conn, TX: 560.2M, RX: 96.4M); Read/Write: 65.3%/34.7%


States
------

* Always returns OK.


Perfdata / Metrics
------------------

'mysql_com_delete'=1155c;;;0; 'mysql_com_insert'=3868c;;;0; 'mysql_com_replace'=0c;;;0; 'mysql_com_select'=240552c;;;0; 'mysql_com_update'=122929c;;;0; 'mysql_connections'=470c;;;0; 'mysql_questions'=907709c;;;0;


.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description
    mysql_bytes_received,                       Bytes,              Total bytes received from all clients.
    mysql_bytes_sent,                           Bytes,              Total bytes sent to all clients.
    mysql_com_delete,                           Continous Counter,  "Number of DELETE commands executed. Differs from Handler_delete, which counts the number of times rows have been deleted from tables."
    mysql_com_insert,                           Continous Counter,  Number of INSERT commands executed.
    mysql_com_replace,                          Continous Counter,  Number of REPLACE commands executed.
    mysql_com_select,                           Continous Counter,  Number of SELECT commands executed. Also includes queries that make use of the query cache.
    mysql_com_update,                           Continous Counter,  Number of UPDATE commands executed.
    mysql_connections,                          Continous Counter,  Number of connection attempts (both successful and unsuccessful) 
    mysql_pct_reads,                            Percentage,         total_reads / (total_reads + total_writes) \* 100
    mysql_pct_writes,                           Percentage,         100 - pct_reads
    mysql_qps,                                  Number,             Queries per second.
    mysql_questions,                            Continous Counter,  "Number of statements executed by the server, excluding COM_PING, COM_STATISTICS, COM_STMT_PREPARE, COM_STMT_CLOSE, and COM_STMT_RESET statements."
    mysql_uptime,                               Seconds,            Number of seconds the server has been running.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
* Credits:

    * heavily inspired by MySQLTuner (https://github.com/major/MySQLTuner-perl)
