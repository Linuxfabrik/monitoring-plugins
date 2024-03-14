Check file-descriptors
======================

Overview
--------

Checks the number of assigned file handles in percent. Also shows the top 3 processes that currently have the highest number of open file descriptors (not cumulative). Depending on the user (e.g. running as *icinga*), sudo (sudoers) is needed.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/file-descriptors"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "Yes"
    "Compiled for",                         "Linux"
    "3rd Party Python modules",             "``psutil``"


Help
----

.. code-block:: text

    usage: file-descriptors [-h] [-V] [--always-ok] [-c CRIT] [-w WARN]

    Checks the number of allocated file handles in percent.

    options:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      -c CRIT, --critical CRIT
                            Set the critical threshold for file descriptor usage
                            (in percent). Default: 95
      -w WARN, --warning WARN
                            Set the warning threshold for file descriptor usage
                            (in percent). Default: 90


Usage Examples
--------------

.. code-block:: bash

    ./file-descriptors --warning 90 --critical 95
    
Output:

.. code-block:: text

    2.2% file descriptors used (2.1K/94.1K)

    Top3 processes opening file descriptors:
    1. mongod: 183 FD
    2. master: 91 FD
    3. mariadbd: 75 FD


States
------

* WARN or CRIT if usage of file descriptors in % is above a given threshold.


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1

    Name,                                       Type,               Description
    fd,                                         Percentage,         Number of allocated file handles / number of system-wide maximum number of file handles \* 100


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
