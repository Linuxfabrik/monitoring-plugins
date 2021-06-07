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

    usage: service [-h] [-V] --service SERVICE [--severity {warn,crit}]
                   [--status {running,paused,start_pending,pause_pending,continue_pending,stop_pending,stopped}]
                   [--starttype {automatic,manual,disabled}]

    Check the state of a Windows service.

    optional arguments:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --service SERVICE     Name of the service.
      --severity {warn,crit}
                            Severity if something is found. One of "warn" or
                            "crit". Default: warn
      --status {running,paused,start_pending,pause_pending,continue_pending,stop_pending,stopped}
                            Expected service status (repeating). Default:
                            ['running']
      --starttype {automatic,manual,disabled}
                            Expected service start type. Default: automatic


Usage Examples
--------------

.. code-block:: bash

    ./service --task Schedule --status running --severity crit
    
Output:

.. code-block:: text

    TODO


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
