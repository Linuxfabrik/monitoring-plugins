Check mysql-perf-metrics
========================

Overview
--------

Checks some performance related metrics and best practice configurations for MySQL/MariaDB. Logic is taken from `MySQLTuner script <https://github.com/major/MySQLTuner-perl>`_, v1.9.8.

Hints:

* Requires MySQL/MariaDB v5.5+.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-perf-metrics"
    "Check Interval Recommendation",        "Once a day"
    "Can be called without parameters",     "Yes"
    "Available for",                        "Python 3, Windows"
    "Requirements",                         "Python module ``pymysql``; User with no privileges, locked down to ``127.0.0.1`` - for example ``monitoring@127.0.0.1``. Usernames in MySQL/MariaDB are limited to 16 chars in specific versions."


Help
----

.. code-block:: text

    usage: mysql-perf-metrics [-h] [-V] [--always-ok] [-H HOSTNAME] [-p PASSWORD]
                              [--port PORT] [-u USERNAME]

    Checks some performance metrics and best practice configurations for
    MySQL/MariaDB.

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

    ./mysql-perf-metrics --hostname localhost --username root --password mypassword

Output:

.. code-block:: text

    Stat are updated during querying INFORMATION_SCHEMA [WARNING]. Set innodb_stats_on_metadata to OFF. Concurrent INSERTs are off [WARNING]. Set concurrent_insert to AUTO or ALWAYS. InnoDB File per table is not activated [WARNING]. Set innodb_file_per_table to ON.


States
------

* WARN if concurrent_insert is not set to AUTO or ALWAYS
* WARN if innodb_file_per_table is not set to ON
* WARN if innodb_stats_on_metadata is not set to OFF


Perfdata / Metrics
------------------

There is no perfdata.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
* Credits:

    * heavily inspired by MySQLTuner (https://github.com/major/MySQLTuner-perl)
