Check mysql-kernel
==================

Overview
--------

Checks the kernel settings specifically for MySQL/MariaDB. Logic is taken from `MySQLTuner script <https://github.com/major/MySQLTuner-perl>`_:get_kernel_info(), v1.9.8.

Hints:

* Must be running locally on the MySQL/MariaDB server to be able to check the kernel settings.

  
Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-kernel"
    "Check Interval Recommendation",        "Once a day"
    "Can be called without parameters",     "Yes"
    "Available for",                        "Python 3"
    "Requirements",                         "None"


Help
----

.. code-block:: text

    usage: mysql-kernel [-h] [-V] [--always-ok]

    Checks the kernel settings specifically for MySQL/MariaDB.

    options:
      -h, --help     show this help message and exit
      -V, --version  show program's version number and exit
      --always-ok    Always returns OK


Usage Examples
--------------

.. code-block:: bash

    ./mysql-kernel
    
Output:

.. code-block:: text

    vm.swappiness is 60, should be <= 10 (use `echo 10 > /proc/sys/vm/swappiness`). sunrpc.tcp_slot_table_entries is 2, should be > 100 (use `echo 128 > /proc/sys/sunrpc/tcp_slot_table_entries`).


States
------

* WARN if any of the checked Kernel parameters is not in the optimal range.
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


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
* Credits:

    * heavily inspired by MySQLTuner (https://github.com/major/MySQLTuner-perl)
