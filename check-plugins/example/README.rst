Check example
=============

Overview
--------

Help text from check command.

Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod
tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam,
quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo
consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse
cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non
proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

Hints:

* Might be useful.
* Could help.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/example"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "Yes|No"
    "Compiled for",                         "Linux, Windows"
    "Requirements",                         "command-line tool ``foo``; User with higher permissions"
    "3rd Party Python modules",             "``psutil``"
    "Handles Periods",                      "Yes"
    "Uses SQLite DBs",                      "Yes"
    "Perfdata compatible with Prometheus",  "Yes"

Hints for the Author (delete those):

* Check Interval Recommendation: other texts are "Every 15 minutes", "Once a day" etc.
* Available for: delete inappropriate ones
* Requirements: delete if none
* Handles Periods: delete if not
* Uses SQLite DBs: delete if not
* Perfdata compatible with Prometheus: delete if not


Help
----

.. code-block:: text

    usage: example [-h] [-V]

    Example Check.

    optional arguments:
      -h, --help       show this help message and exit
      -V, --version    show program's version number and exit


Usage Examples
--------------

.. code-block:: bash

    ./example --warning 80 --critical 90 --count 5

Output:

.. code-block:: text

    Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod
    tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam,
    quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo
    consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse
    cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non
    proident, sunt in culpa qui officia deserunt mollit anim id est laborum.


States
------

* Always returns OK.
* WARN or CRIT if any condition.


Perfdata / Metrics
------------------

There is no perfdata.

OR

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description                                           
    allocation_btree_compares_total,            Continous Counter,  Number of allocation B-tree compares for a filesystem.
    allocation_btree_lookups_total,             Bytes,              Number of allocation B-tree lookups for a filesystem.
    allocation_btree_lookups_total,             Percentage,         Number of allocation B-tree lookups for a filesystem.
    allocation_btree_lookups_total,             None,               Number of allocation B-tree lookups for a filesystem.


Troubleshooting
---------------

My Error Message 1
    My Solution goes here.

My Error Message 2
    My Solution goes here.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
