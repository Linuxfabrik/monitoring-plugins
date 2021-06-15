Check procs
===========

Overview
--------

Checks the number of currently running processes and warns on process counts or process memory usage. You may filter the process list by process name, arguments and/or user name.

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
                 [--command COMMAND] [-c CRIT] [--critical-mem CRIT_MEM]
                 [--no-kthreads] [--username USERNAME] [-w WARN]
                 [--warning-mem WARN_MEM]

    Checks the number of currently running processes and warns on process counts
    or zombie process states.

    optional arguments:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      --argument ARGUMENT   Only scan for processes containing ARGUMENT in the
                            command, for example `-s` (case-insensitive).
      --command COMMAND     Only scan for processes starting with COMMAND, for
                            example `bash` (without path, case-insensitive).
      -c CRIT, --critical CRIT
                            Set the critical threshold for the number of processes
                            (none, range or int). Default: None
      --critical-mem CRIT_MEM
                            Set the critical threshold Memory Usage in bytes.
                            Default: None
      --no-kthreads         Only scan for non kernel threads (works on Linux
                            only). Default: False.
      --username USERNAME   Only scan for processes with user name, for example
                            `apache` (case-insensitive).
      -w WARN, --warning WARN
                            Set the warning threshold for the number of processes
                            (none, range or int). Default: None
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

    380 procs using 9.7GiB mem - 1 running (1x sublime_text, 1x kworker/u17:2+i915_flip), 378 sleeping, 1 uninterruptible (1x sublime_text, 1x kworker/u17:2+i915_flip)


States
------

* WARN or CRIT if process count is above a given threshold.
* WARN or CRIT if memory usage for all or filtered processes is above a given threshold.


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
