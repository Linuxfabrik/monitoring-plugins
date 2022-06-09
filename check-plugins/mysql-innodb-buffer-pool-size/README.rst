Check mysql-innodb-buffer-pool-size
===================================

Overview
--------

Checks the size of the InnoDB buffer pool in MySQL/MariaDB. Logic is taken from `MySQLTuner script <https://github.com/major/MySQLTuner-perl>`_:mysql_innodb(), v1.9.8.

Always take care of both ``innodb_buffer_pool_size`` and ``innodb_log_file_size`` when making adjustments. For that have a look at the output example ``InnoDB buffer pool / data size: 36.0GiB / 49.4GiB [WARNING]. Set innodb_buffer_pool_size >= 49.4GiB. innodb_log_file_size * innodb_log_files_in_group / innodb_buffer_pool_size = 9.0GiB * 2 / 36.0GiB = 50.0% [WARNING] (should be 25%). Set innodb_log_file_size to 4.5GiB.``:

* Here, buffer pool is 36 GB.
* Data does not fit in, it needs 49 GB.
* The check plugin complains and makes some suggestions on how to resize ``innodb_buffer_pool_size`` and ``innodb_log_file_size``.
* If we adjust ``innodb_buffer_pool_size`` to 50 GB, and ``innodb_log_files_in_group`` is set to ``2`` (deprecated and ignored from MariaDB 10.5.2), we should set ``innodb_log_file_size`` to ``6.25`` to get the 25% log file versus pool size ratio. Then both warnings should change to OK.
* Attention: Assuming this is a database server with entirely/primarily InnoDB tables, you need at least 64 GB, following the rule that the InnoDB buffer pool size in bytes can be set up to 80% of the total memory in this case.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-innodb-buffer-pool-size"
    "Check Interval Recommendation",        "Every 5 minutes"
    "Can be called without parameters",     "Yes"
    "Available for",                        "Python 3, Windows"
    "Requirements",                         "Python module ``mysql.connector``; User with no privileges, locked down to ``127.0.0.1`` - for example ``monitoring@127.0.0.1``. Usernames in MySQL/MariaDB are limited to 16 chars in specific versions."


Help
----

.. code-block:: text

    usage: mysql-innodb-buffer-pool-size [-h] [-V] [--always-ok] [-H HOSTNAME]
                                         [-p PASSWORD] [--port PORT]
                                         [-u USERNAME]

    Checks the size of the InnoDB buffer pool in MySQL/MariaDB.

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

    ./mysql-innodb-buffer-pool-size --hostname localhost --username root --password mypassword

Output:

.. code-block:: text

    InnoDB buffer pool / data size: 36.0GiB / 49.4GiB [WARNING]. Set innodb_buffer_pool_size >= 49.4GiB. innodb_log_file_size * innodb_log_files_in_group / innodb_buffer_pool_size = 9.0GiB * 2 / 36.0GiB = 50.0% [WARNING] (should be 25%). Set innodb_log_file_size to 4.5GiB.


States
------

* WARN if size of data does not fit into the InnoDB buffer pool.
* WARN if the InnoDB log file size versus the InnoDB pool size ratio is not in the range of 20 to 30%.


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description
    mysql_innodb_buffer_pool_size,              Bytes,              "InnoDB buffer pool size in bytes. The primary value to adjust on a database server with entirely/primarily InnoDB tables, can be set up to 80% of the total memory."
    mysql_innodb_log_file_size,                 Bytes,              "Size in bytes of each InnoDB redo log file in the log group. The combined size can be no more than 512GB. Larger values mean less disk I/O due to less flushing checkpoint activity, but also slower recovery from a crash."
    mysql_innodb_log_files_in_group,            Number,             "Number of physical files in the InnoDB redo log. Deprecated and ignored from MariaDB 10.5.2."
    mysql_innodb_log_size_pct,                  Percentage,         innodb_log_file_size \* innodb_log_files_in_group / innodb_buffer_pool_size \* 100


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
* Credits:

    * heavily inspired by MySQLTuner (https://github.com/major/MySQLTuner-perl)
