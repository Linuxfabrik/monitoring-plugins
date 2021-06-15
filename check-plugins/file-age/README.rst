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
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/file-age"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "Yes"
    "Available for",                        "Python 2, Python 3, Windows"
    "Requirements",                         "Python module ``psutil``"


Help
----

.. code-block:: text

    usage: file-age [-h] [--always-ok] [--filename FILENAME] [-u URL]
                    [--timeout TIMEOUT] [--password PASSWORD] [--pattern PATTERN]
                    [--username USERNAME] [--only-dirs] [--only-files] [-V]
                    [-c CRIT] [--critical-count CRIT_COUNT] [-w WARN]
                    [--warning-count WARN_COUNT]

    Checks the time of last data modification for a file or directory, in seconds.

    optional arguments:
      -h, --help            show this help message and exit
      --always-ok           Always returns OK.
      --filename FILENAME   File (or directory) name to check. Supports glob in
                            accordance with
                            https://docs.python.org/2.7/library/glob.html. Beware
                            of using recursive globs. This is mutually exclusive
                            with -u / --url.
      -u URL, --url URL     Set the url of the file (or directory) to check,
                            starting with "smb://". This is mutually exclusive
                            with --filename.
      --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
      --password PASSWORD   SMB Password.
      --pattern PATTERN     The search string to match against the names of SMB
                            directories or files. This pattern can use '*' as a
                            wildcard for multiple chars and '?' as a wildcard for
                            a single char. Does not support regex patterns.
                            Default: *.
      --username USERNAME   SMB Username.
      --only-dirs           Only consider directories.
      --only-files          Only consider files.
      -V, --version         show program's version number and exit
      -c CRIT, --critical CRIT
                            Set the critical age threshold in seconds. Supports
                            ranges. Default: >= 31536000s (365d)
      --critical-count CRIT_COUNT
                            Set the critical threshold for the number of critical
                            matches found. Supports ranges. Default: > 0
      -w WARN, --warning WARN
                            Set the warning age threshold in seconds. Supports
                            ranges. Default: >= 2592000s (30d)
      --warning-count WARN_COUNT
                            Set the warning threshold for the number of critical
                            matches found. Supports ranges. Default: > 0


Usage Examples
--------------

.. code-block:: bash

    # file is more than 5 seconds old -> warning
    # file is more than 10 seconds old -> critical
    ./file-age --filename '/path/to/file' --warning 5 --critical 10

    # same thresholds, but checking multiple files
    ./file-age --filename '/path/to/files/*' --warning 5 --critical 10

    # same thresholds, but recursive (might use a lot of memory)
    ./file-age --filename '/path/to/files/**/*' --warning 5 --critical 10

    # Check if an application creates at least 2 files every 10s, else throw a warning.
    # If it is missing for more than 20s, throw a critical.
    ./file-age --filename '/path/to/files/*' --warning '15:' --warning-count '3:' --critical '20:' --critical-count '2:'

    # Check if an application removes files fast enough.
    # If there are more than 2 files in the last 10s, throw a warning.
    # If there are more than 3 files in the last 15s, throw a critical.
    # No files are ok.
    ./file-age --filename '/path/to/files/*' --warning '10:' --warning-count 2 --critical '15:' --critical-count 3
    
Output:

.. code-block:: text

    All 1 file are inside the timerange (129600/31536000) and inside the allowed count (0/0).

    * /backup/mongodb-dump/mongodb-dump.tar.gz: 16h 15m


States
------

TODO States


Perfdata / Metrics
------------------

There is no perfdata.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
