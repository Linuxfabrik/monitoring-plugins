Check mysql-table-indexes
=========================

Overview
--------

Checks for missing indexes in MySQL/MariaDB tables. Logic is taken from `MySQLTuner script <https://github.com/major/MySQLTuner-perl>`_, v1.9.8.

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
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-table-indexes"
    "Check Interval Recommendation",        "Once a day"
    "Can be called without parameters",     "Yes"
    "Available for",                        "Python 3, Windows"
    "Requirements",                         "Python module ``pymysql``; User with no privileges, locked down to ``127.0.0.1`` - for example ``monitoring@127.0.0.1``. Usernames in MySQL/MariaDB are limited to 16 chars in specific versions."


Help
----

.. code-block:: text

    usage: mysql-table-indexes [-h] [-V] [--always-ok] [-H HOSTNAME]
                               [-p PASSWORD] [--port PORT] [-u USERNAME]

    Checks for missing indexes in MySQL/MariaDB tables.

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

    ./mysql-table-indexes --hostname localhost --username root --password mypassword

Output:

.. code-block:: text

    Tables without indexes: employees.current_dept_emp, employees.dept_emp_latest_date [WARNING]


States
------

* WARN if tables without indexes are found.


Perfdata / Metrics
------------------

There is no perfdata.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
* Credits:

    * heavily inspired by MySQLTuner (https://github.com/major/MySQLTuner-perl)
