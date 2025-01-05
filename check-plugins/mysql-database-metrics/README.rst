Check mysql-database-metrics
============================

Overview
--------

Checks index sizes and consistent engine and collation use in MySQL/MariaDB schemas. Logic is taken from `MySQLTuner script <https://github.com/major/MySQLTuner-perl>`_.

User account requires:

* Access to INFORMATION_SCHEMA (user with no privileges is sufficient).
* SELECT privileges on all schemas and tables to provide accurate results.

Hints:

* See `additional notes for all mysql monitoring plugins <https://github.com/Linuxfabrik/monitoring-plugins/blob/main/PLUGINS-MYSQL.rst>`_
* `For most INFORMATION_SCHEMA tables, each MySQL user has the right to access them, but can see only the rows in the tables that correspond to objects for which the user has the proper access privileges. <https://dev.mysql.com/doc/refman/5.7/en/information-schema-introduction.html#information-schema-privileges>`_. `So you can't grant permission to INFORMATION_SCHEMA directly, you have to grant SELECT permission to the tables on your own schemas, and as you do, those tables will start showing up in INFORMATION_SCHEMA queries <https://stackoverflow.com/questions/60499772/cannot-grant-mysql-user-access-to-information-schema-database>`_. Then this check provide correct results.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70

    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-database-metrics"
    "Check Interval Recommendation",        "Once a day"
    "Can be called without parameters",     "Yes"
    "Compiled for",                         "Linux, Windows"
    "3rd Party Python modules",             "``pymysql``"


Help
----

.. code-block:: text

    usage: mysql-database-metrics [-h] [-V] [--always-ok]
                                  [--defaults-file DEFAULTS_FILE]
                                  [--defaults-group DEFAULTS_GROUP]
                                  [--timeout TIMEOUT]

    Checks index sizes and consistent engine and collation use in MySQL/MariaDB
    schemas.

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

    ./mysql-database-metrics --defaults-file=/var/spool/icinga2/.my.cnf

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

* WARN if the index size is larger than the data size (if at least one of them is larger than 10 MB)
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
