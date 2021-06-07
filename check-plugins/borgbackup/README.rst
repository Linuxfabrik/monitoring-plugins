Check borgbackup
================

Overview
--------

Linuxfabrik in-house check. Known Issue and Limitation is that the calculation of the borg process runtime can be wrong.

Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/borgbackup"
    "Check Interval Recommendation",        "Once a day"
    "Can be called without parameters",     "Yes"
    "Available for",                        "Python 2"
    "Requirements",                         "None"


Help
----

.. code-block:: text

    usage: borgbackup [-h] [-V] [-c CRIT] [-w WARN]

    Checks the date and return code of the last borgbackup, according to the
    logfile.

    optional arguments:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      -c CRIT, --critical CRIT
                            Set the critical threshold for the time difference to
                            the start of the last backup (in hours). Default: None
      -w WARN, --warning WARN
                            Set the warning threshold for the time difference to
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
* WARN if last backup start time > n hours


Perfdata / Metrics
------------------

* create_retc
* prune_retc
* duration


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
