Check selinux-mode
==================

Overview
--------

Checks the current mode of SELinux against a desired mode, and returns a warning on a non-match. If ``--mode`` is ommited, we suppose SELinux is in ``Enforcing`` mode.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/selinux-mode"
    "Check Interval Recommendation",        "Every 15 minutes"
    "Available for",                        "Python 2"
    "Requirements",                         "Python module ``psutil``, command-line tool ``getenforce``"
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

    ./selinux-mode
    ./selinux-mode --mode permissive
    
Output:

.. code-block:: text

    TODOVM Output


States
------

* WARN if selinux mode is not as expected.


Perfdata / Metrics
------------------

There is no perfdata.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
