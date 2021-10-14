Check file-count
================

Overview
--------

Checks the number of matching files or directories found. It can be also used to check the existence / absence of a single file.

Depending on the file and user (e.g. running as *icinga*), sudo (sudoers) is needed. It supports globs in accordance with `Python 3 <https://docs.python.org/3/library/pathlib.html#pathlib.Path.glob>`_ or `Python 2 <https://docs.python.org/2.7/library/glob.html>`_. Beware that using recursive globs might cause high memory usage. Also note that there are small differences in recursive file matching between Python 2 and Python 3. Optionally, the check can be restricted to only consider files that were modified in a given timerange.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/file-count"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "Yes"
    "Available for",                        "Python 2, Python 3, Windows"
    "Requirements",                         "Python module ``psutil``"


Help
----

.. code-block:: text

    usage: file-count [-h] [--always-ok] [--filename FILENAME] [-u URL]
                      [--timeout TIMEOUT] [--password PASSWORD]
                      [--pattern PATTERN] [--username USERNAME] [--only-dirs]
                      [--only-files] [-V] [-c CRIT] [-w WARN]
                      [--timerange TIMERANGE]

    Checks the number of matching files.

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
                            Set the critical number of files. Supports ranges.
      -w WARN, --warning WARN
                            Set the warning number of files. Supports ranges.
      --timerange TIMERANGE
                            Set the timerange (seconds) in which the files should
                            be considered. Supports ranges.


Usage Examples
--------------

.. code-block:: bash

    # check the existence of a file; if missing warn
    ./file-count --filename '/path/to/file' --warning 1

    # check the absence of a file; if present warn
    ./file-count --filename '/path/to/file' --warning '~:0'

    # check that there are at least 5 `.md` files, else warn
    ./file-count --filename '/path/to/*.md' --warning 5

    # check that there are at least 5 files modified in the last 10 seconds, else warn
    ./file-count --filename '/path/to/file/*' --warning 5 --timerange 5 

Output:

.. code-block:: text

    TODO


States
------

TODO States


Perfdata / Metrics
------------------

TODO Perfdata


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.