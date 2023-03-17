Check journald-usage
====================

Overview
--------

Checks the current disk usage of all journal files of the systemd journal (in fact the sum of the disk usage of all archived and active journal files).

From ``man journald.conf``:

.. code-block:: text

    SystemMaxUse= and RuntimeMaxUse= control how much disk space the
    journal may use up at most.  SystemKeepFree= and RuntimeKeepFree=
    control how much disk space systemd-journald shall leave free for
    other uses.  systemd-journald will respect both limits and use the
    smaller of the two values.

    The first pair defaults to 10% and the second to 15% of the size of
    the respective file system, but each value is capped to 4G. If the
    file system is nearly full and either SystemKeepFree= or
    RuntimeKeepFree= are violated when systemd-journald is started, the
    limit will be raised to the percentage that is actually free. This
    means that if there was enough free space before and journal files
    were created, and subsequently something else causes the file
    system to fill up, journald will stop using more space, but it will
    not be removing existing files to reduce the footprint again,
    either. Also note that only archived files are deleted to reduce
    the space occupied by journal files. This means that, in effect,
    there might still be more space used than SystemMaxUse= or
    RuntimeMaxUse= limit after a vacuuming operation is complete.



Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/journald-usage"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "Yes"
    "Compiled for",                         "Linux"


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
                            Set the WARN threshold in GiB. Default: >= 6


Usage Examples
--------------

.. code-block:: bash

    ./journald-usage --warning=500

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
