Check scheduled-task
====================

Overview
--------

Checks the status of a Windows scheduled task.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/scheduled-task"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "No"
    "Available for",                        "Python 3, Windows"
    "Requirements",                         "Python module ``psutil``"


Help
----

.. code-block:: text

    usage: scheduled-task [-h] [-V] --task TASK [--severity {warn,crit}]
                       [--status {Disabled,Queued,Ready,Running,Unknown}]

    Check the status of a scheduled task.

    optional arguments:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --task TASK           Name of the scheduled task.
      --severity {warn,crit}
                            Severity if something is found. One of "warn" or
                            "crit". Default: warn
      --status {Disabled,Queued,Ready,Running,Unknown}
                            Expected task status (repeating). Default: ['Ready',
                            'Running']


Usage Examples
--------------

.. code-block:: bash

    ./scheduled-task --task Schedule --status Disabled  --severity crit
    
Output:

.. code-block:: text

    TODO


States
------

* WARN if result does not match the expected status.
* CRIT only if configured as such.


Perfdata / Metrics
------------------

There is no perfdata.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
