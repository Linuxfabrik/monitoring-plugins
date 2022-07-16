Check mysql-database-metrics
============================

Overview
--------

Checks index sizes and consistent engine and collation use in MySQL/MariaDB schemas. Logic is taken from `MySQLTuner script <https://github.com/major/MySQLTuner-perl>`_, v1.9.8.

Hints:

* On RHEL 7+, one way to install the Python MySQL Connector is via ``pip install pymysql``
* Compared to check_mysql / MySQLTuner this check currently:

    * supports only simple login with username/password (not via SSL/TLS)
    * does not support a connection via socket


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-database-metrics"
    "Check Interval Recommendation",        "Once a day"
    "Can be called without parameters",     "Yes"
    "Available for",                        "Python 3, Windows"
    "Requirements",                         "Python module ``pymysql``; User with no privileges, locked down to ``127.0.0.1`` - for example ``monitoring@127.0.0.1``. Usernames in MySQL/MariaDB are limited to 16 chars in specific versions."


Help
----

.. code-block:: text

    usage: mysql-database-metrics [-h] [-V] [--always-ok] [-H HOSTNAME]
                                  [-p PASSWORD] [--port PORT]
                                  [--timeout TIMEOUT] [-u USERNAME]

    Checks index sizes and consistent engine and collation use in MySQL/MariaDB
    schemas.

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

    ./mysql-database-metrics --hostname localhost --username root --password mypassword

Output:

.. code-block:: text

    There are warnings.

    * Index size is larger than data size: xca (11.4MiB / 5.4MiB)
    * Multi storage engines (use one storage engine for all tables): appldb (2x)
    * Multi collations (use one collation for all tables): accounting (2x), piwik (2x), wordpress-www (2x)
    * Multi table engines (use one engine for all tables): appldb (2x)
    * Multi charsets for text-like cols (use one charset for all cols if possible): accounting (2x), piwik (2x), django-mvc (2x), wordpress-www (2x), django-mvc-devel (2x)
    * Multi collations for text-like cols (use one charset for all cols if possible): accounting (3), piwik (2x), django-mvc (2x), wordpress-www (2x), django-mvc-devel (2x)


States
------

* WARN if index size is larger than data size
* WARN if more than one storage engine is used
* WARN if more than one collation is used
* WARN if more than one table engine is used
* WARN if more than one charsets for text-like col is used
* WARN if more than one collations for text-like col is used


Perfdata / Metrics
------------------

There is no perfdata.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
* Credits:

    * heavily inspired by MySQLTuner (https://github.com/major/MySQLTuner-perl)
