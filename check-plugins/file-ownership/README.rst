Check file-ownership
====================

Overview
--------

Checks the ownership (owner and group, both have to be names) of a list of files. Depending on the file and user (e.g. running as 'icinga') sudo (sudoers) is needed.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/file-ownership"
    "Check Interval Recommendation",        "Every 5 minutes"
    "Available for",                        "Python 2, Python 3"
    "Requirements",                         "Python module ``psutil``, command-line tool ``stat``"
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

    ./file-ownership
    ./file-ownership/file-ownership --filename root:root,/tmp
    
Output:

.. code-block:: text

    TODOVM Output


States
------

* WARN if ownership does not match expected values.


Perfdata / Metrics
------------------

There is no perfdata.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
