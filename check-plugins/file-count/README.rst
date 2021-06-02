Check file-count
================

Overview
--------

Checks the number of matching files or directories found. It can be also used to check the existence / absence of a single file. Depending on the file and user (e.g. running as 'icinga') sudo (sudoers) is needed.
It supports glob in accordance with https://docs.python.org/3/library/pathlib.html#pathlib.Path.glob (python3) or https://docs.python.org/2.7/library/glob.html (python2).
Beware that using recursive globs might cause high memory usage.
Also note that there are small differences in recursive file matching between python2 and python3.
Optionally, the check can be restricted to only consider files that were modified in a given timerange.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/file-count"
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

    TODOVM Output


States
------

TODO State



Perfdata / Metrics
------------------

TODO Perfdata


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
