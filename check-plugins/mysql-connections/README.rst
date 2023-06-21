Check mysql-connections
=======================

Overview
--------

Checks the connection usage rate, the rate of aborted connections and if name resolution is active for new connections on MySQL/MariaDB. Logic is taken from `MySQLTuner script <https://github.com/major/MySQLTuner-perl>`_:mysql_stats(), v1.9.8.

Hints:

* See `additional notes for all mysql monitoring plugins <https://github.com/Linuxfabrik/monitoring-plugins/blob/main/PLUGINS-MYSQL.rst>`_


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-connections"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "Yes"
    "Compiled for",                         "Linux, Windows"
    "Requirements",                         "User with no privileges, locked down to ``127.0.0.1`` - for example ``monitoring\@127.0.0.1``. Usernames in MySQL/MariaDB are limited to 16 chars in specific versions."
    "3rd Party Python modules",             "``pymysql``"


Help
----

.. code-block:: text

    usage: mysql-connections [-h] [-V] [--always-ok]
                             [--defaults-file DEFAULTS_FILE]
                             [--defaults-group DEFAULTS_GROUP]
                             [--ignore-name-resolution] [--timeout TIMEOUT]

    Checks the connection usage rate, the rate of aborted connections and if name
    resolution is active for new connections on MySQL/MariaDB.

    options:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      --defaults-file DEFAULTS_FILE
                            Specifies a cnf file to read parameters like user,
                            host and password from (instead of specifying them on
                            the command line), for example
                            `/var/spool/icinga2/.my.cnf`. Default:
                            /var/spool/icinga2/.my.cnf
      --defaults-group DEFAULTS_GROUP
                            Group/section to read from in the cnf file. Default:
                            client
      --ignore-name-resolution
                            Do not check if name resolution is active. Default:
                            False
      --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)


Usage Examples
--------------

.. code-block:: bash

    ./mysql-connections --defaults-file=/var/spool/icinga2/.my.cnf

Output:

.. code-block:: text

    0.0% aborted connections (0.0/1.3K); max. 36.4% used (4/11); Name resolution is active: A reverse name resolution is made for each new connection and can reduce performance [WARNING]. Configure your accounts with ip or subnets only, then update your configuration with skip-name-resolve=ON.


States
------

* WARN if the number of connections is more than 85% of the maximum possible number of simultaneous client connections (setting ``max_connections``).
* WARN if the number of aborted connections is more than 3% of all client connections.
* WARN if name resolution is active (if `--ignore-name-resolution` is ommitted).


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description
    mysql_aborted_connects,                     Continous Counter,  "Number of failed server connection attempts. This can be due to a client using an incorrect password, a client not having privileges to connect to a database, a connection packet not containing the correct information, or if it takes more than connect_timeout seconds to get a connect packet."
    mysql_connections,                          Continous Counter,  "Number of all connection attempts (both successful and unsuccessful)."
    mysql_interactive_timeout,                  Seconds,            "Time in seconds that the server waits for an interactive connection (one that connects with the mysql_real_connect() CLIENT_INTERACTIVE option) to become active before closing it."
    mysql_max_connections,                      Number,             "The maximum number of simultaneous client connections."
    mysql_max_used_connections,                 Number,             "Max number of connections ever open at the same time."
    mysql_pct_connections_aborted,              Percentage,         Aborted_connects / Connections \* 100
    mysql_pct_connections_used,                 Percentage,         Max_used_connections / max_connections \* 100
    mysql_wait_timeout,                         Seconds,            "Time in seconds that the server waits for a connection to become active before closing it."


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
* Credits:

    * heavily inspired by MySQLTuner (https://github.com/major/MySQLTuner-perl)
