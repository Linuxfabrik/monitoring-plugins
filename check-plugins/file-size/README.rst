Check file-size
===============

Overview
--------

Checks the size of files in bytes, ignoring directories as the size of a directory is not defined consistently across file systems and is never the size of the contents. This check supports both Nagios ranges and Samba shares.

The plugin can follow symbolic links. Depending on the file and user (e.g. running as *icinga*), sudo (sudoers) may be required. It supports globs according to `Python 3 <https://docs.python.org/3/library/pathlib.html#pathlib.Path.glob>`_. Note that using recursive globs can cause high memory usage. Also note that the plugin requires a valid qualifier when specifying parameters, e.g. ``--warning=10K`` for 10 KiB (instead of ``--warning=10000`` as in previous versions).


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70

    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/file-size"
    "Check Interval Recommendation",        "Every 15 minutes"
    "Can be called without parameters",     "Yes"
    "Compiled for Windows",                 "Yes"
    "3rd Party Python modules",             "optional: ``PySmbClient``, ``smbprotocol``"


Help
----

.. code-block:: text

    usage: file-size [-h] [-V] [--always-ok] [-c CRIT] [--filename FILENAME]
                     [--pattern PATTERN] [--password PASSWORD] [--timeout TIMEOUT]
                     [-u URL] [--username USERNAME] [-w WARN]

    Checks the size for a file (in bytes).

    options:
      -h, --help           show this help message and exit
      -V, --version        show program's version number and exit
      --always-ok          Always returns OK.
      -c, --critical CRIT  Threshold for the file size in a human readable format
                           (base is always 1024; valid qualifiers are b, k/kb/kib,
                           m/mb/mib, g/gb/gib etc.). Supports Nagios ranges.
                           Example: `:1G` alerts if size is greater than 1
                           GiB.Default: 1G
      --filename FILENAME  File name to check. Supports glob in accordance with
                           https://docs.python.org/2.7/library/glob.html. Note
                           that using recursive globs can cause high memory usage.
                           This is mutually exclusive with `-u` / `--url`.
      --pattern PATTERN    The search string to match against the names of SMB
                           directories or files. This pattern can use "*"" as a
                           wildcard for multiple chars and "?"" as a wildcard for
                           a single char. Does not support regex patterns.
                           Default: *.
      --password PASSWORD  SMB Password.
      --timeout TIMEOUT    Network timeout in seconds. Default: 3 (seconds)
      -u, --url URL        Set the url of the file to check, starting with
                           "smb://". This is mutually exclusive with `--filename`.
      --username USERNAME  SMB Username.
      -w, --warning WARN   Threshold for the file size in a human readable format
                           (base is always 1024; valid qualifiers are b, k/kb/kib,
                           m/mb/mib, g/gb/gib etc.). Supports Nagios ranges.
                           Example: `:1G` alerts if size is greater than 1
                           GiB.Default: 25M


Usage Examples
--------------

Warn if file is greater than 25M, crit if it is greater than 1G:

.. code-block:: bash

    ./file-size --filename=/var/log/coolwsd.log --warning=25M --critical=1G

Output:

.. code-block:: text

    1 file checked. It is within the given size thresholds (25M/1G). Checked /var/log/coolwsd.log: 119.9KiB

Warn if files are not within 6 to 10 KB, crit if files are larger than 14 KB (plus showing the various formats):

.. code-block:: bash

    ./file-size --filename '/path/to/m*.png*' --warning '6 KiB:10k' --critical ':14 KB'

Output:

.. code-block:: text

    28 files checked. 21 are outside the given size thresholds (6 KiB:10k/:14 KB).

    File                                   ! Size    ! State      
    ---------------------------------------+---------+------------
    mailq.png                              ! 5.2KiB  ! [WARNING]  
    matomo-version.png                     ! 7.2KiB  ! [OK]       
    memory-usage.png                       ! 12.4KiB ! [WARNING]  
    mydumper-version.png                   ! 8.3KiB  ! [OK]       
    mysql-aria.png                         ! 12.2KiB ! [WARNING]  
    mysql-connections.png                  ! 15.3KiB ! [CRITICAL] 
    mysql-database-metrics.png             ! 15.2KiB ! [CRITICAL] 
    mysql-innodb-buffer-pool-instances.png ! 12.7KiB ! [WARNING]  
    mysql-innodb-buffer-pool-size.png      ! 15.5KiB ! [CRITICAL] 
    mysql-innodb-log-waits.png             ! 9.2KiB  ! [OK]       
    mysql-joins.png                        ! 11.7KiB ! [WARNING]  
    mysql-logfile.png                      ! 15.5KiB ! [CRITICAL] 
    mysql-memory.png                       ! 16.5KiB ! [CRITICAL] 
    mysql-open-files.png                   ! 8.8KiB  ! [OK]       
    mysql-perf-metrics.png                 ! 6.9KiB  ! [OK]       
    mysql-slow-queries.png                 ! 9.2KiB  ! [OK]       
    mysql-sorts.png                        ! 10.9KiB ! [WARNING]  
    mysql-storage-engines.png              ! 16.9KiB ! [CRITICAL] 
    mysql-system.png                       ! 19.6KiB ! [CRITICAL] 
    mysql-table-cache.png                  ! 26.3KiB ! [CRITICAL] 
    mysql-table-definition-cache.png       ! 14.0KiB ! [CRITICAL] 
    mysql-table-indexes.png                ! 9.9KiB  ! [WARNING]  
    mysql-table-locks.png                  ! 10.3KiB ! [WARNING]  
    mysql-temp-tables.png                  ! 12.3KiB ! [WARNING]  
    mysql-thread-cache.png                 ! 10.2KiB ! [WARNING]  
    mysql-traffic.png                      ! 10.8KiB ! [WARNING]  
    mysql-user-security.png                ! 16.3KiB ! [CRITICAL] 
    mysql-version.png                      ! 10.3KiB ! [WARNING]

The same as above, but recursive (might use a lot of memory):

.. code-block:: bash

    ./file-size --filename '/path/to/**/m*.png*' --warning 6000B:10K --critical :14KB


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
