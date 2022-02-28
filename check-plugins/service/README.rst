Check service
=============

Overview
--------

Checks the state of a Windows service.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70

    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/service"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "No"
    "Available for",                        "Python 3, Windows"
    "Requirements",                         "Python module ``psutil``"


Help
----

.. code-block:: text

    usage: service [-h] [-V] --service SERVICE [--severity {crit,warn}]
                   [--starttype {automatic,disabled,manual}]
                   [--status {continue_pending,pause_pending,paused,running,start_pending,stop_pending,stopped}]

    Check the state of a Windows service.

    optional arguments:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --service SERVICE     Name of the service.
      --severity {crit,warn}
                            Severity if something is found. Default: warn
      --starttype {automatic,disabled,manual}
                            Expected service start type. Default: automatic
      --status {continue_pending,pause_pending,paused,running,start_pending,stop_pending,stopped}
                            At least one expect


Usage Examples
--------------

.. code-block:: bash

    service.exe --service Schedule --status running --severity crit

Output:

.. code-block:: text

    Schedule is running, automatic


States
------

* WARN if result does not match the given parameter values.
* CRIT only if configured as such.


Perfdata / Metrics
------------------

There is no perfdata.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
