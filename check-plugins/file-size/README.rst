Check efile-size
================

Overview
--------

Checks the size for a file in bytes, ignoring directories as the size of a directory is not consistently defined across filesystems, and never is the size of the contents.
The plugin is able to follow symlinks. Depending on the file and user (e.g. running as 'icinga') sudo (sudoers) is needed.
It supports glob in accordance with https://docs.python.org/3/library/pathlib.html#pathlib.Path.glob (python3) or https://docs.python.org/2.7/library/glob.html (python2).
Beware that using recursive globs might cause high memory usage.
Also note that there are small differences in recursive file matching between python2 and python3.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/file-size"
    "Check Interval Recommendation",        "Every 15 minutes"
    "Available for",                        "Python 2, Python 3, Windows"
    "Requirements",                         "Python module ``psutil``, command-line tool ``foo``"
    "Handles Periods",                      "Yes"
    "Uses SQLite DBs",                      "Yes"
    "Perfdata compatible with Prometheus",  "Yes"


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

    TODOVM Usage
    # file is more than 5 bytes old -> warning
    # file is more than 10 bytes old -> critical
    ./file-size --filename '/path/to/file' --warning 5 --critical 10

    # same thresholds, but checking multiple files
    ./file-size --filename '/path/to/files/*' --warning 5 --critical 10

    # same thresholds, but recursive (might use a lot of memory)
    ./file-size --filename '/path/to/files/**/*' --warning 5 --critical 10
    
Output:

.. code-block:: text

    TODOVM Output


States
------

TODOVM States
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
