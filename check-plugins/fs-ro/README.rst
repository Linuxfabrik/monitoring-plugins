Check fs-ro
===========

Overview
--------

This plugin checks for read-only mount points, such as ``/`` mounted read-only due to file system errors, mounted CD-ROMs or ISO files, etc. It always ignores ramfs and squashfs (snapd) by default.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/fs-ro"
    "Check Interval Recommendation",        "Every 15 minutes"
    "Can be called without parameters",     "Yes"
    "Available for",                        "Python 2, Python 3"
    "Requirements",                         "None"


Help
----

.. code-block:: text

    usage: fs-ro [-h] [-V] [--always-ok] [--ignore IGNORE] [--test TEST]

    Warns if a file system is mounted read-only.

    optional arguments:
      -h, --help       show this help message and exit
      -V, --version    show program's version number and exit
      --always-ok      Always returns OK.
      --ignore IGNORE  Mount point that should be ignored (repeatable). For
                       example, if you provide `/sys/fs`, all mount points
                       starting with `/sys/fs` will be ignored. Default: ['/proc',
                       '/snap', '/sys/fs']
      --test TEST      For unit tests. Needs "path-to-stdout-file,path-to-stderr-
                       file,expected-retc".


Usage Examples
--------------

.. code-block:: bash

    ./fs-ro --ignore /proc,/sys/fs

Output:

.. code-block:: text

    Everything is ok. 21 mount points checked.


States
------

* WARN if a read only mount point is found (which is not on the ignore list).


Perfdata / Metrics
------------------

There is no perfdata.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
