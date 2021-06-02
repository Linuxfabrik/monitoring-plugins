Check procs
===========

Overview
--------

Checks the number of currently running processes and warns on process counts.

Process State Codes are summarized:

    procstate   shown as/grouped  meaning
    --------------------------------------------------------------------------------------------------
           D    uninterruptible   uninterruptible sleep (usually IO)
           R    running           running or runnable (on run queue)
           I    sleeping          idle kernel thread
           S    sleeping          interruptible sleep (waiting for an event to complete)
           T    stopped           stopped by job control signal
           t    stopped           stopped by debugger during the tracing
           W    paging            paging (not valid since the 2.6.xx kernel)
           X    dead              dead (should never be seen)
           Z    zombies           defunct ("zombie") process, terminated but not reaped by its parent


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/procs"
    "Check Interval Recommendation",        "Once a minute"
    "Available for",                        "Python 2, Python 3, Windows"
    "Requirements",                         "Python module ``psutil``, command-line tool ``ps``"
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

    ./procs --no-kthreads --always-ok
    ./procs --warning 2:100 --critical 1:150 --command httpd
    
Output:

.. code-block:: text

    349 tasks, 348 sleeping, 1 uninterruptible (1x glances)|'procs'=349;;;0; 'procs_sleeping'=348;;;0; 'procs_running'=0;;;0; 'procs_uninterruptible'=1;;;0; 'procs_zombies'=0;;;0; 'procs_stopped'=0;;;0; 'procs_dead'=0;;;0;


States
------

* WARN or CRIT if process count is above a given threshold.


Perfdata / Metrics
------------------

* ``procs``: Total number of processes.
* ``procs_sleeping``
* ``procs_running``
* ``procs_uninterruptible``
* ``procs_zombies``
* ``procs_stopped``
* ``procs_paging``
* ``procs_dead``


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
