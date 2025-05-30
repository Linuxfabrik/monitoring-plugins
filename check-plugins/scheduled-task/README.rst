Check scheduled-task
====================

Overview
--------

Checks the status of a Windows scheduled task.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70

    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/scheduled-task"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "No"
    "Compiled for Windows",                 "Yes"
    "3rd Party Python modules",             "``psutil``"


Help
----

.. code-block:: text

    usage: scheduled-task [-h] [-V] [--severity {warn,crit}]
                          [--status {Disabled,Queued,Ready,Running,Unknown}]
                          --task TASK

    Check the status of a scheduled task.

    options:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --severity {warn,crit}
                            Severity if something is found. Default: warn
      --status {Disabled,Queued,Ready,Running,Unknown}
                            Expected task status (repeating). Default: ['Ready',
                            'Running']
      --task TASK           Name of the scheduled task.


Usage Examples
--------------

.. code-block:: bash

    scheduled-task.exe --task \Microsoft\Windows\DiskCleanup\SilentCleanup --status Disabled  --severity crit

Output:

.. code-block:: text

    \Microsoft\Windows\DiskCleanup\SilentCleanup is Ready


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
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
