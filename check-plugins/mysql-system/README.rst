Check mysql-system
==================

Overview
--------

Checks system requirements and kernel settings specifically for MySQL/MariaDB. Logic is taken from `MySQLTuner script <https://github.com/major/MySQLTuner-perl>`_:get_kernel_info(), v1.9.8.

Unlike MySQLTuner, this plugin does not check if all processes other than MySQL/MariaDB use more than 15% of the total system memory. One reason for this is that you may want or need to run a small DB server on an application server and have it well tuned for that use case. Another reason is that if you are running MySQL/MariaDB on an application server with a lot of RAM, the DB may not need or require 85% RAM.

Hints:

* See `additional notes for all mysql monitoring plugins <https://github.com/Linuxfabrik/monitoring-plugins/blob/main/PLUGINS-MYSQL.rst>`_
* Does not need access to MySQL/MariaDB itself.
* Must be running locally on the MySQL/MariaDB server to be able to check the system requirements.
* On Windows there are no kernel settings that can be checked.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70

    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-system"
    "Check Interval Recommendation",        "Every 5 minutes"
    "Can be called without parameters",     "Yes"
    "Compiled for",                         "Linux, Windows"
    "3rd Party Python modules",             "``psutil``"


Help
----

.. code-block:: text

    usage: mysql-system [-h] [-V] [--always-ok]
                        [--maxportsallowed MAXPORTSALLOWED]

    Checks system requirements and kernel settings specifically for MySQL/MariaDB.

    options:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      --maxportsallowed MAXPORTSALLOWED
                            Number of ports opened allowed on this host. Default:
                            0 (check disabled)


Usage Examples
--------------

.. code-block:: bash

    ./mysql-system --maxportsallowed 15

Output:

.. code-block:: text

    There are too many listening ports: 56 opened > 15 allowed (consider dedicating a server for your database installation with less services running on). vm.swappiness is 60, should be <= 10 (use `echo 10 > /proc/sys/vm/swappiness`). sunrpc.tcp_slot_table_entries is 2, should be > 100 (use `echo 128 > /proc/sys/sunrpc/tcp_slot_table_entries`).


States
------

* WARN if there are too many listening ports.
* WARN if any of the checked Linux Kernel parameters is not in the optimal range.
* OK in all other cases.


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description                                           
    mysql_kernel_fs.aio-max-nr,                 Number,             Defines the maximum number of asynchronous I/O operations the system can handle on the server.
    mysql_kernel_sunrpc.tcp_slot_table_entries, Number,             Sets the number of (TCP) RPC entries to pre-allocate for in-flight RPC requests (essentially the minimum).
    mysql_kernel_vm.swappiness,                 Percentage,         "Changes the balance between swapping out runtime memory, as opposed to dropping pages from the system page cache."
    mysql_opened_ports,                         Number,             Number of opened ports.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
* Credits:

    * heavily inspired by MySQLTuner (https://github.com/major/MySQLTuner-perl)
