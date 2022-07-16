Check mysql-innodb-buffer-pool-instances
========================================

Overview
--------

Checks the InnoDB buffer pool instance configuration in MySQL/MariaDB. Logic is taken from `MySQLTuner script <https://github.com/major/MySQLTuner-perl>`_:mysql_innodb(), v1.9.8.

Hints:

* MariaDB: Applies only to versions < 10.5.1.
* On RHEL 7+, one way to install the Python MySQL Connector is via ``pip install pymysql``
* Compared to check_mysql / MySQLTuner this check currently:

    * supports only simple login with username/password (not via SSL/TLS)
    * does not support a connection via socket


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-innodb-buffer-pool-instances"
    "Check Interval Recommendation",        "Once a day"
    "Can be called without parameters",     "Yes"
    "Available for",                        "Python 3, Windows"
    "Requirements",                         "Python module ``pymysql``; User with no privileges, locked down to ``127.0.0.1`` - for example ``monitoring@127.0.0.1``. Usernames in MySQL/MariaDB are limited to 16 chars in specific versions."


Help
----

.. code-block:: text

    usage: mysql-innodb-buffer-pool-instances [-h] [-V] [--always-ok]
                                              [-H HOSTNAME] [-p PASSWORD]
                                              [--port PORT] [-u USERNAME]

    Checks the InnoDB buffer pool instance configuration in MySQL/MariaDB.

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

    ./mysql-innodb-buffer-pool-instances --hostname localhost --username root --password mypassword

Output:

.. code-block:: text

    8 InnoDB buffer pool instances. innodb_buffer_pool_size <= 1G and innodb_buffer_pool_instances !=1 [WARNING]. Set innodb_buffer_pool_instances to 1.


States
------

* WARN if ``innodb_buffer_pool_instances`` > 64.
* WARN if ``innodb_buffer_pool_size`` > 1 GB and ``innodb_buffer_pool_instances`` <> ``min(innodb_buffer_pool_size in GB, 64 GB)``.
* WARN if ``innodb_buffer_pool_size`` <= 1 GB and ``innodb_buffer_pool_instances`` <> 1.


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description
    mysql_innodb_buffer_pool_instances,         Number,             "If innodb_buffer_pool_size is set to more than 1GB, innodb_buffer_pool_instances divides the InnoDB buffer pool into this many instances."
    mysql_innodb_buffer_pool_size,              Bytes,              "InnoDB buffer pool size in bytes. The primary value to adjust on a database server with entirely/primarily InnoDB tables, can be set up to 80% of the total memory in these environments."


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
* Credits:

    * heavily inspired by MySQLTuner (https://github.com/major/MySQLTuner-perl)
