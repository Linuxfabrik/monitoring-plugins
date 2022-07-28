Check journald-usage
====================

Overview
--------

Checks the current disk usage of all journal files of the systemd journal (in fact the sum of the disk usage of all archived and active journal files).


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/journald-usage"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "Yes"
    "Available for",                        "Python 3"
    "Requirements",                         "None"


Help
----

.. code-block:: text

    usage: journald-usage [-h] [-V] [--always-ok] [--test TEST] [-w WARN]

    Checks the current disk usage of all journal files of the systemd journal (in
    fact the sum of the disk usage of all archived and active journal files).

    options:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                            stderr-file,expected-retc".
      -w WARN, --warning WARN
                            Set the WARN threshold in MiB. Default: >= 1024


Usage Examples
--------------

.. code-block:: bash

    ./journald-usage --warning=1024

Output:

.. code-block:: text

    3.0GiB used [WARNING] (sum of all archived and active journal files). Remove the oldest archived journal files by using `journalctl --vacuum-size=`, `--vacuum-time=` and/or `--vacuum-files=`.


States
------

* WARN if usage is above the given size of the sum of all archived and active journal files.


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description                                           
    journald-usage,                             Bytes,              Size of the sum of all archived and active journal files


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
