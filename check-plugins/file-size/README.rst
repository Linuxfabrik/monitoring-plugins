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

    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/file-size"
    "Check Interval Recommendation",        "Every 15 minutes"
    "Can be called without parameters",     "Yes"
    "Compiled for",                         "Linux, Windows"
    "3rd Party Python modules",             "``PySmbClient``, ``smbprotocol``"


Help
----

.. code-block:: text

    usage: file-size [-h] [-V] [--always-ok] [-c CRIT] [--filename FILENAME]
                     [--pattern PATTERN] [--password PASSWORD]
                     [--timeout TIMEOUT] [-u URL] [--username USERNAME] [-w WARN]

    Checks the size for a file or directory, in bytes.

    optional arguments:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      -c CRIT, --critical CRIT
                            Set the critical size threshold in bytes. Default: >=
                            1073741824 (1G)
      --filename FILENAME   File (or directory) name to check. Supports glob in
                            accordance with
                            https://docs.python.org/2.7/library/glob.html. Beware
                            of using recursive globs. This is mutually exclusive
                            with -u / --url.
      --pattern PATTERN     The search string to match against the names of SMB
                            directories or files. This pattern can use '*' as a
                            wildcard for multiple chars and '?' as a wildcard for
                            a single char. Does not support regex patterns.
                            Default: *.
      --password PASSWORD   SMB Password.
      --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
      -u URL, --url URL     Set the url of the file (or directory) to check,
                            starting with "smb://". This is mutually exclusive
                            with --filename.
      --username USERNAME   SMB Username.
      -w WARN, --warning WARN
                            Set the warning size threshold in bytes. Default: >=
                            26214400 (100M)


Usage Examples
--------------

.. code-block:: bash

    # file is more than 5 bytes big -> warning
    # file is more than 10 bytes big -> critical
    ./file-size --filename '/path/to/file' --warning 5 --critical 10

    # same thresholds, but checking multiple files
    ./file-size --filename '/path/to/files/*' --warning 5 --critical 10

    # same thresholds, but recursive (might use a lot of memory)
    ./file-size --filename '/path/to/files/**/*' --warning 5 --critical 10

Output:

.. code-block:: text

    1 file is below the given size thresholds (3.8MiB/1.0GiB).

    * /var/log/firewalld: 28.1KiB


States
------

* OK if all the found files are below the given size thresholds.
* Otherwise CRIT or WARN.




Perfdata / Metrics
------------------

There is no perfdata.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
