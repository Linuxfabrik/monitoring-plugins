Check procs
===========

Overview
--------

Checks the number of currently running processes and warns on process counts.

Process State Codes are summarized:

.. code-block:: text

    procstate   shown as/grouped  meaning
    ---------   ----------------  -------------------------------------------------------------------
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
    "Can be called without parameters",     "Yes"
    "Available for",                        "Python 2, Python 3, Windows"
    "Requirements",                         "Python module ``psutil``"


Help
----

.. code-block:: text

    usage: procs [-h] [-V] [--always-ok] [--argument ARGUMENT]
                 [--command COMMAND] [-c CRIT] [--critical-cpu CRIT_CPU]
                 [--critical-mem CRIT_MEM] [--no-kthreads] [--username USERNAME]
                 [-w WARN] [--warning-cpu WARN_CPU] [--warning-mem WARN_MEM]

    Checks the number of currently running processes and warns on process counts
    or zombie process states.

    optional arguments:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      --argument ARGUMENT   Only scan for processes containing ARGUMENT in the
                            command.
      --command COMMAND     Only scan for processes starting with COMMAND (without
                            path).
      -c CRIT, --critical CRIT
                            Set the critical threshold for the number of processes
                            (none, range or int). Default: None
      --critical-cpu CRIT_CPU
                            Set the critical threshold CPU Usage Percentage.
                            Default: None
      --critical-mem CRIT_MEM
                            Set the critical threshold Memory Usage in bytes.
                            Default: None
      --no-kthreads         Only scan for non kernel threads (works on Linux
                            only). Default: False.
      --username USERNAME   Only scan for processes with user name.
      -w WARN, --warning WARN
                            Set the warning threshold for the number of processes
                            (none, range or int). Default: None
      --warning-cpu WARN_CPU
                            Set the warning threshold CPU Usage Percentage.
                            Default: None
      --warning-mem WARN_MEM
                            Set the warning threshold Memory Usage in bytes.
                            Default: None


Usage Examples
--------------

.. code-block:: bash

    ./procs --no-kthreads --always-ok
    ./procs --warning 2:100 --critical 1:150 --command httpd
    
Output:

.. code-block:: text

    349 procs - 347 sleeping, 1 running (1x virt-manager), 1 uninterruptible (1x glances)|'procs'=349;;;0; 'procs_sleeping'=347;;;0; 'procs_running'=1;;;0; 'procs_uninterruptible'=1;;;0; 'procs_zombies'=0;;;0; 'procs_stopped'=0;;;0; 'procs_dead'=0;;;0;


States
------

* WARN or CRIT if process count is above a given threshold.


Perfdata / Metrics
------------------

* ``procs``: Total number of processes.
* ``procs_cpu``
* ``procs_dead``
* ``procs_mem``
* ``procs_paging``
* ``procs_running``
* ``procs_sleeping``
* ``procs_stopped``
* ``procs_uninterruptible``
* ``procs_zombies``


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
