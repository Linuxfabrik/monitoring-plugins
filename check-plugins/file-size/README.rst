Check file-size
===============

Overview
--------

Checks the size for a file in bytes, ignoring directories as the size of a directory is not consistently defined across filesystems, and never is the size of the contents.

The plugin is able to follow symbolic links. Depending on the file and user (e.g. running as *icinga*), sudo (sudoers) is needed. It supports globs in accordance with `Python 3 <https://docs.python.org/3/library/pathlib.html#pathlib.Path.glob>`_ or `Python 2 <https://docs.python.org/2.7/library/glob.html>`_. Beware that using recursive globs might cause high memory usage. Also note that there are small differences in recursive file matching between Python 2 and Python 3.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/file-size"
    "Check Interval Recommendation",        "Every 15 minutes"
    "Can be called without parameters",     "Yes"
    "Available for",                        "Python 2, Python 3, Windows"
    "Requirements",                         "Python module ``psutil``"


Help
----

.. code-block:: text

    usage: file-size [-h] [--always-ok] [--filename FILENAME] [-u URL]
                     [--timeout TIMEOUT] [--password PASSWORD]
                     [--pattern PATTERN] [--username USERNAME] [-V] [-c CRIT]
                     [-w WARN]

    Checks the size for a file or directory, in bytes.

    optional arguments:
      -h, --help            show this help message and exit
      --always-ok           Always returns OK.
      --filename FILENAME   File (or directory) name to check. Supports glob in
                            accordance with https://docs.python.org/3/library/path
                            lib.html#pathlib.Path.glob. Beware of using recursive
                            globs. This is mutually exclusive with -u / --url.
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
      -V, --version         show program's version number and exit
      -c CRIT, --critical CRIT
                            Set the critical size threshold in bytes. Default: >=
                            1073741824 (1G)
      -w WARN, --warning WARN
                            Set the warning size threshold in bytes. Default: >=
                            26214400 (100M)


Usage Examples
--------------

.. code-block:: bash

    # file is more than 5 bytes old -> warning
    # file is more than 10 bytes old -> critical
    ./file-size --filename '/path/to/file' --warning 5 --critical 10

    # same thresholds, but checking multiple files
    ./file-size --filename '/path/to/files/*' --warning 5 --critical 10

    # same thresholds, but recursive (might use a lot of memory)
    ./file-size --filename '/path/to/files/**/*' --warning 5 --critical 10
    
Output:

.. code-block:: text

    All 1 file are within the given size range (thresholds 5.0MiB/1.0GiB).

    * /var/log/secure: 443.0KiB


States
------

TODO

# file is more than 5 bytes old -> warning
# file is more than 10 bytes old -> critical

# same thresholds, but checking multiple files

# same thresholds, but recursive (might use a lot of memory)


Perfdata / Metrics
------------------

There is no perfdata.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
