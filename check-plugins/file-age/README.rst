Check file-age
==============

Overview
--------

Checks the time of last data modification for a file or directory, in seconds.

The plugin is able to follow symbolic links. Depending on the file and user (e.g. running as *icinga*), sudo (sudoers) is needed. It supports globs in accordance with `Python 3 <https://docs.python.org/3/library/pathlib.html#pathlib.Path.glob>`_ or `Python 2 <https://docs.python.org/2.7/library/glob.html>`_. Beware that using recursive globs might cause high memory usage. Also note that there are small differences in recursive file matching between Python 2 and Python 3.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70

    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/file-age"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "Yes"
    "Compiled for Windows",                 "Yes"
    "3rd Party Python modules",             "``PySmbClient``, ``smbprotocol``"


Help
----

.. code-block:: text

    usage: file-age [-h] [-V] [--always-ok] [-c CRIT]
                    [--critical-count CRIT_COUNT] [--filename FILENAME]
                    [--only-dirs] [--only-files] [--password PASSWORD]
                    [--pattern PATTERN] [--perfdata-mode {mean,median,None}]
                    [--timeout TIMEOUT] [-u URL] [--username USERNAME] [-w WARN]
                    [--warning-count WARN_COUNT]

    Checks the time of last data modification for a file or directory, in seconds.

    options:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      -c, --critical CRIT   Set the critical age threshold in seconds. Supports
                            ranges. Default: >= 31536000s (365d)
      --critical-count CRIT_COUNT
                            Set the critical threshold for the number of files
                            found within the critical age. Supports ranges.
                            Default: > 0
      --filename FILENAME   File or directory name to check. Supports glob in
                            accordance with
                            https://docs.python.org/2.7/library/glob.html. Beware
                            of using recursive globs. This is mutually exclusive
                            with -u / --url.
      --only-dirs           Only consider directories.
      --only-files          Only consider files.
      --password PASSWORD   SMB: Password.
      --pattern PATTERN     SMB: The search string to match against the names of
                            SMB directories or files. This pattern can use '*' as
                            a wildcard for multiple chars and '?' as a wildcard
                            for a single char. Does not support regex patterns.
                            Default: *.
      --perfdata-mode {mean,median,None}
                            Set the performance data aggregation mode. Default:
                            None.
      --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
      -u, --url URL         SMB: Set the url of the file (or directory) to check,
                            starting with "smb://". This is mutually exclusive
                            with --filename.
      --username USERNAME   SMB: Username.
      -w, --warning WARN    Set the warning age threshold in seconds. Supports
                            ranges. Default: >= 2592000s (30d)
      --warning-count WARN_COUNT
                            Set the warning threshold for the number of files
                            found within the warning age. Supports ranges.
                            Default: > 0 (30d)


Usage Examples
--------------

.. code-block:: bash

    # file is more than 5 seconds old -> warning
    # file is more than 10 seconds old -> critical
    ./file-age --filename='/path/to/file' --warning=5 --critical=10

    # same thresholds, but checking multiple files
    ./file-age --filename='/path/to/files/*' --warning=5 --critical=10

    # same thresholds, but recursive (might use a lot of memory)
    ./file-age --filename='/path/to/files/**/*' --warning=5 --critical=10

    # Check if an application creates at least 2 files every 10s, else throw a warning.
    # If it is missing for more than 20s, throw a critical.
    ./file-age --filename='/path/to/files/*' --warning='15:' --warning-count='3:' --critical='20:' --critical-count='2:'

    # Check if an application removes files fast enough.
    # If there are more than 2 files in the last 10s, throw a warning.
    # If there are more than 3 files in the last 15s, throw a critical.
    # No files are ok.
    ./file-age --filename='/path/to/files/*' --warning='10:' --warning-count=2 --critical='15:' --critical-count=3

Output:

.. code-block:: text

    Everything is ok. 3 items checked, all within the specified count and time range.

    * /tmp/test/file-1d-ago: 1D 56m
    * /tmp/test/file-2d-ago: 2D 56m
    * /tmp/test/file-today: 56m 11s

.. code-block:: text

    Everything is ok. 3 items checked. All within the specified count range, but 2 outside "1D" time range, and 0 outside "1Y" time range.

    * /tmp/test/file-1d-ago: 1D 56m [WARNING]
    * /tmp/test/file-2d-ago: 2D 56m [WARNING]
    * /tmp/test/file-today: 56m 1s

.. code-block:: text

    1 item outside count range "0" and outside "@86400" time range. 2 items outside count range "0" and outside "0:86400" time range. 3 items checked.

    * /tmp/test/file-1d-ago: 1D 55m [CRITICAL]
    * /tmp/test/file-2d-ago: 2D 55m [CRITICAL]
    * /tmp/test/file-today: 55m 47s [WARNING]


States
------

* WARN or CRIT on provided ranges.


Perfdata / Metrics
------------------

The ``--perfdata-mode`` decides which aggregation mode is going to be used.
The check won't return any performance data for empty directories (even with the flag being set).

* ``mean-ages``: Seconds. The mean, also known as the average (the sum divided by the number of elements).
* ``median-ages``: Seconds. The median, the "middle" element in a sorted list.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
