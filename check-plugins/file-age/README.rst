Check efile-age
===============

Overview
--------

Checks the time of last data modification for a file or directory, in seconds. The plugin is able to follow symlinks. Depending on the file and user (e.g. running as 'icinga') sudo (sudoers) is needed.
It supports glob in accordance with https://docs.python.org/3/library/pathlib.html#pathlib.Path.glob (python3) or https://docs.python.org/2.7/library/glob.html (python2).
Beware that using recursive globs might cause high memory usage.
Also note that there are small differences in recursive file matching between python2 and python3.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/file-age"
    "Check Interval Recommendation",        "Once a minute"
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

    TODOVM Output


States
------

TODO States


Perfdata / Metrics
------------------

TODO Perfdat


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
