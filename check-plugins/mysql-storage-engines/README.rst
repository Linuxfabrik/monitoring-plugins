Check mysql-storage-engines
===========================

Overview
--------

Checks storage engines, fragmented tables and autoindex usage in MySQL/MariaDB. Logic is taken from `MySQLTuner script <https://github.com/major/MySQLTuner-perl>`_, v1.9.8.

Hints:

* Requires MySQL/MariaDB v5.5+.
* On RHEL 7+, the Python MySQL Connector can be installed with ``pip3 install mysql-connector-python``
* Compared to check_mysql / MySQLTuner this check currently:

    * supports only simple login with username/password (not via SSL/TLS)
    * does not support a connection via socket


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-storage-engines"
    "Check Interval Recommendation",        "Once a day"
    "Can be called without parameters",     "Yes"
    "Available for",                        "Python 3, Windows"
    "Requirements",                         "Python module ``pymysql``; User with no privileges, locked down to ``127.0.0.1`` - for example ``monitoring@127.0.0.1``. Usernames in MySQL/MariaDB are limited to 16 chars in specific versions."


Help
----

.. code-block:: text

    usage: mysql-storage-engines [-h] [-V] [--always-ok] [-H HOSTNAME]
                                 [-p PASSWORD] [--port PORT] [--timeout TIMEOUT]
                                 [-u USERNAME]

    Checks storage engines, fragmented tables and autoindex usage in
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
      --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
      -u USERNAME, --username USERNAME
                            MySQL/MariaDB username. Default: root


Usage Examples
--------------

.. code-block:: bash

    ./mysql-storage-engines --hostname localhost --username root --password mypassword

Output:

.. code-block:: text

    There are warnings.

    * 1 fragmented table
    * OPTIMIZE TABLE `backup20190815`.`docs`; -- can free 2.6GiB
    * Total freed space after all OPTIMIZE TABLEs: 2.6GiB
    * accounting.contact has an autoincrement value near max capacity (97.0%)


States
------

* WARN if InnoDB is enabled but isn't being used
* WARN if BDB is enabled but isn't being used
* WARN if MYISAM is enabled but isn't being used
* WARN if fragmented tables are found
* WARN if a table's autoincrement value is >= 75% max capacity


Perfdata / Metrics
------------------

There is no perfdata.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
* Credits:

    * heavily inspired by MySQLTuner (https://github.com/major/MySQLTuner-perl)
