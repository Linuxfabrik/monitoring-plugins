Check mysql-user-security
=========================

Overview
--------

Check user's security in MySQL/MariaDB. Logic is taken from `MySQLTuner script <https://github.com/major/MySQLTuner-perl>`_, v1.9.8.

Hints:

* On RHEL 7+, one way to install the Python MySQL Connector is via ``pip install pymysql``
* Compared to check_mysql / MySQLTuner this check currently:

    * supports only simple login with username/password (not via SSL/TLS)
    * does not support a connection via socket


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-user-security"
    "Check Interval Recommendation",        "Once a day"
    "Can be called without parameters",     "Yes"
    "Available for",                        "Python 3, Windows"
    "Requirements",                         "Python module ``pymysql``; User with SELECT privileges, locked down to ``127.0.0.1`` - for example ``monitoring@127.0.0.1``. Usernames in MySQL/MariaDB are limited to 16 chars in specific versions."


Help
----

.. code-block:: text

    usage: mysql-user-security [-h] [-V] [--always-ok] [-H HOSTNAME]
                               [-p PASSWORD] [--port PORT]
                               [--severity {warn,crit}] [-u USERNAME]

    Check user's security in MySQL/MariaDB.

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
      --severity {warn,crit}
                            Severity for alerts that do not depend on thresholds.
                            One of "warn" or "crit". Default: warn
      -u USERNAME, --username USERNAME
                            MySQL/MariaDB username. Default: root


Usage Examples
--------------

.. code-block:: bash

    ./mysql-user-security --hostname localhost --username root --password mypassword

Output:

.. code-block:: text

    1 anonymous user account [WARNING]. 1 user with username as password [WARNING]. 1 account without hostname restriction [WARNING]. 

    Remove anonymous users:
    * DROP USER ''@'centos7.loc';

    Change user passwords:
    * SET PASSWORD FOR 'root'@'localhost' = PASSWORD("I9n2eSGZ8u9MrScx0ckWYhGpQk6ouKh1yMn7Jnwj");

    Restrict users:
    * RENAME USER 'mariadb-admin'@'%' TO 'mariadb-admin'@'LimitedIPRangeOrLocalhost';


States
------

* WARN if anonymous users are found
* WARN if users having empty passwords are found
* WARN if users with user / uppercase / capitalise user as password are found (does not work on MySQL 8, ignored)
* WARN if users without hostname restriction are found


Perfdata / Metrics
------------------

There is no perfdata.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
* Credits:

    * heavily inspired by MySQLTuner (https://github.com/major/MySQLTuner-perl)
