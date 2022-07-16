Check mysql-aria
================

Overview
--------

Checks some metrics of the Aria Storage Engine in MySQL/MariaDB. The logic is taken from `MySQLTuner script <https://github.com/major/MySQLTuner-perl>`_:mariadb_aria(), v1.9.8.

Hints:

* On RHEL 7+, one way to install the Python MySQL Connector is via ``pip install pymysql``
* Compared to check_mysql / MySQLTuner this check currently:

    * supports only simple login with username/password (not via SSL/TLS)
    * does not support a connection via socket


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-aria"
    "Check Interval Recommendation",        "Once an hour"
    "Can be called without parameters",     "No"
    "Available for",                        "Python 3, Windows"
    "Requirements",                         "Python module ``pymysql``; User with no privileges, locked down to ``127.0.0.1`` - for example ``monitoring@127.0.0.1``. Usernames in MySQL/MariaDB are limited to 16 chars in specific versions."


Help
----

.. code-block:: text

    usage: mysql-aria [-h] [-V] [--always-ok] [-H HOSTNAME] -p PASSWORD
                      [--port PORT] -u USERNAME

    Checks some metrics of the Aria Storage Engine in MySQL/MariaDB.

    options:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      -H HOSTNAME, --hostname HOSTNAME
                            MySQL/MariaDB hostname. Default: 127.0.0.1
      -p PASSWORD, --password PASSWORD
                            Use the indicated password to authenticate the
                            connection.
      --port PORT           MySQL/MariaDB port. Default: 3306
      -u USERNAME, --username USERNAME
                            MySQL/MariaDB username.


Usage Examples
--------------

.. code-block:: bash

    ./mysql-aria --username mon-aria --password mypassword
    
Output:

.. code-block:: text

    Aria pagecache size / total Aria indexes: 128.0MiB/0.0B, 99.9% Aria pagecache hit rate (1.5G cached / 763.3K reads)


States
------

* WARN if ``aria_pagecache_buffer_size`` < ``total_aria_indexes`` and ``pct_aria_keys_from_mem`` < 95%.
* WARN if ``aria_pagecache_read_requests`` > 0 and ``pct_aria_keys_from_mem`` < 95%.


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description                                           
    mysql_aria_pagecache_buffer_size,           Bytes,              The size of the buffer used for index and data blocks for Aria tables.
    mysql_total_aria_indexes,                   Bytes,              Sum of all Aria Indexes.
    mysql_pct_aria_keys_from_mem,               Percentage,         aria_pagecache_reads / aria_pagecache_read_requests \* 100
    mysql_aria_pagecache_read_requests,         Number,             The number of requests to read something from the Aria page cache.
    mysql_aria_pagecache_reads,                 Number,             The number of Aria page cache read requests that caused a block to be read from the disk.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
* Credits:

    * heavily inspired by MySQLTuner (https://github.com/major/MySQLTuner-perl)
