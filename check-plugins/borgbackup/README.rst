Check borgbackup
================

Overview
--------

Linuxfabrik in-house check, may not be useful for others. Checks the content of ``/var/log/borg/borg.log``. Known Issue and Limitation is that the calculation of the borg process runtime can be wrong.

.. code-block:: bash

    cat /var/log/borg/borg-prune.log
    cat /var/log/borg/borg-create.log

.. code-block:: text

    Return code
    0: success (logged as INFO)
    1: warning (operation reached its normal end, but there were warnings – you should check the log, logged as WARNING)
    2: error (like a fatal error, a local or remote exception, the operation did not reach its normal end, logged as ERROR)
    128+N   killed by signal N (e.g. 137 == kill -9)


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70

    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/borgbackup"
    "Check Interval Recommendation",        "Once a day"
    "Can be called without parameters",     "Yes"
    "Compiled for Windows",                 "No"


Help
----

.. code-block:: text

    usage: borgbackup [-h] [-V] [-c CRIT] [-w WARN]

    Checks the date and return code of the last borgbackup, according to the
    logfile.

    options:
      -h, --help           show this help message and exit
      -V, --version        show program's version number and exit
      -c, --critical CRIT  Set the critical threshold for the time difference to
                           the start of the last backup (in hours). Default: None
      -w, --warning WARN   Set the warning threshold for the time difference to
                           the start of the last backup (in hours). Default: 24


Usage Examples
--------------

.. code-block:: bash

    ./borgbackup 
    
Output:

.. code-block:: text

    Last Backup started 2021-06-02 23:05:07, ended 2021-06-02 23:05:43, took 36s.
    * Create retc: 0, State: 
    * Prune retc: 0, State:


States
------

* WARN on active borg mounts
* WARN on Borg return codes > 1
* WARN or CRIT if last backup start time > n hours


Perfdata / Metrics
------------------

* create_retc
* prune_retc
* duration


Troubleshooting
---------------

local variable '...' referenced before assignment
    Expected behaviour of the check. If either ``starttime``, ``endtime``, ``create_retc`` or ``prune_retc`` is missing (and hence this error message is returned), the backup has failed in any way.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
