Check mysql-sorts
=================

Overview
--------

Checks some sort metrics on MySQL/MariaDB. Logic is taken from `MySQLTuner script <https://github.com/major/MySQLTuner-perl>`_:mysql_stats(), v1.9.8.

Hints:

* On RHEL 7+, the Python MySQL Connector can be installed with ``pip3 install mysql-connector-python``
* Compared to check_mysql / MySQLTuner this check currently:

    * supports only simple login with username/password (not via SSL/TLS)
    * does not support a connection via socket


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-sorts"
    "Check Interval Recommendation",        "Every 5 minutes"
    "Can be called without parameters",     "Yes"
    "Available for",                        "Python 3, Windows"
    "Requirements",                         "Python module ``pymysql``; User with no privileges, locked down to ``127.0.0.1`` - for example ``monitoring@127.0.0.1``. Usernames in MySQL/MariaDB are limited to 16 chars in specific versions."


Help
----

.. code-block:: text

    usage: mysql-sorts [-h] [-V] [--always-ok] [-H HOSTNAME] [-p PASSWORD]
                       [--port PORT] [-u USERNAME]

    Checks some sort metrics on MySQL/MariaDB.

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

    ./mysql-sorts --hostname localhost --username root --password mypassword

Output:

.. code-block:: text

    901.6K sorts used a full table scan. Sorts requiring temporary tables: 0% (0.0 temp sorts / 3.1M sorts).


States
------

* WARN if there are more than 10% sort merge passes (sorts requiring temporary tables).


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description
    mysql_pct_temp_sort_table,                  Percentage,         sort_merge_passes / total_sorts \* 100
    mysql_read_rnd_buffer_size,                 Bytes,              "Size in bytes of the buffer used when reading rows from a MyISAM table in sorted order after a key sort."
    mysql_sort_buffer_size,                     Bytes,              "Each session performing a sort allocates a buffer with this amount of memory. Not specific to any storage engine."
    mysql_sort_merge_passes,                    Continous Counter,  "Number of merge passes performed by the sort algorithm."
    mysql_sort_range,                           Continous Counter,  "Number of sorts which used a range."
    mysql_sort_scan,                            Continous Counter,  "Number of sorts which used a full table scan."
    mysql_total_sorts,                          Continous Counter,  sort_scan + sort_range


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
* Credits:

    * heavily inspired by MySQLTuner (https://github.com/major/MySQLTuner-perl)
