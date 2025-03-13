Check mysql-sorts
=================

Overview
--------

Checks some sort metrics on MySQL/MariaDB. Logic is taken from `MySQLTuner script <https://github.com/major/MySQLTuner-perl>`_:mysql_stats(), v1.9.8.

Hints:

* See `additional notes for all mysql monitoring plugins <https://github.com/Linuxfabrik/monitoring-plugins/blob/main/PLUGINS-MYSQL.rst>`_


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70

    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-sorts"
    "Check Interval Recommendation",        "Every 5 minutes"
    "Can be called without parameters",     "Yes"
    "Compiled for",                         "Linux, Windows"
    "Requirements",                         "User with no privileges, locked down to ``127.0.0.1`` - for example ``monitoring\@127.0.0.1``. Usernames in MySQL/MariaDB are limited to 16 chars in specific versions."
    "3rd Party Python modules",             "``pymysql``"


Help
----

.. code-block:: text

    usage: mysql-sorts [-h] [-V] [--always-ok] [--defaults-file DEFAULTS_FILE]
                       [--defaults-group DEFAULTS_GROUP] [--timeout TIMEOUT]

    Checks some sort metrics on MySQL/MariaDB.

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
      --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)


Usage Examples
--------------

.. code-block:: bash

    ./mysql-sorts --defaults-file=/var/spool/icinga2/.my.cnf

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
