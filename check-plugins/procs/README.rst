Check procs
===========

Overview
--------

Prints the number of currently running processes and warns on metrics like process counts or process memory usage. You may filter the process list by process name, arguments and/or user name.

In output, process states are summarized like so:

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Reported            Proc State,  Description
    dead,               X,           "dead (should never be seen)"
    paging,             W,           "paging (not valid since the 2.6.xx kernel)"
    running,            R,           "running or runnable (on run queue)"
    sleeping,           "I, S",      "idle kernel thread, interruptible sleep (waiting for an event to complete)"
    stopped,            "t, T",      "stopped by debugger during the tracing, stopped by job control signal"
    uninterruptible,    D,           "uninterruptible sleep (usually due to I/O)"
    zombies,            Z,           "defunct ('zombie') process, terminated but not reaped by its parent"

Hints:

* RSS aka "Resident Set Size" ("Res"): This is the non-swapped physical memory a process has used. On UNIX it matches "top"'s RES column. On Windows this is an alias for wset field and it matches "Mem Usage" column of ``taskmgr.exe``.
* Be aware of the differences in memory counting between different tools like top, htop, glances, GNOME System Monitor etc.
* Memory counting also changed between different Linux Kernel versions.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/procs"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "Yes"
    "Available for",                        "Python 2, Python 3, Windows"
    "Requirements",                         "Python module ``psutil``"


Help
----

.. code-block:: text

    usage: procs [-h] [-V] [--always-ok] [--argument ARGUMENT]
                 [--command COMMAND] [-c CRIT] [--critical-mem CRIT_MEM]
                 [--critical-mem-percent CRIT_MEM_PERCENT]
                 [--critical-age CRIT_AGE] [--no-kthreads]
                 [--status {dead,disk-sleep,idle,locked,parked,running,sleeping,stopped,suspended,tracing-stop,waiting,wake-kill,waking,zombie}]
                 [--username USERNAME] [-w WARN] [--warning-mem WARN_MEM]
                 [--warning-mem-percent WARN_MEM_PERCENT]
                 [--warning-age WARN_AGE]

    Prints the number of currently running processes and warns on metrics like
    process counts or process memory usage. You may filter the process list by
    process name, arguments and/or user name.

    optional arguments:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      --argument ARGUMENT   Filter: Search only for processes containing ARGUMENT
                            in the command, for example `-s` (case-insensitive).
      --command COMMAND     Filter: Search only for processes starting with
                            COMMAND, for example `bash` (without path, case-
                            insensitive).
      -c CRIT, --critical CRIT
                            Threshold for the number of processes. Type: None or
                            Range. Default: None
      --critical-mem CRIT_MEM
                            Threshold for memory usage, in bytes. Type: None or
                            Range. Default: None
      --critical-mem-percent CRIT_MEM_PERCENT
                            Threshold for memory usage, in percent. Type: None or
                            Range. Default: None
      --critical-age CRIT_AGE
                            Threshold for age of the process, in seconds. Type:
                            None or Range. Default: None
      --no-kthreads         Filter: Only scan for non kernel threads (works on
                            Linux only). Default: False
      --status {dead,disk-sleep,idle,locked,parked,running,sleeping,stopped,suspended,tracing-stop,waiting,wake-kill,waking,zombie}
                            Filter: Search only for processes that have a specific
                            status. Default: None,
      --username USERNAME   Filter: Search only for processes with specific user
                            name, e.g. `apache` (case-insensitive).
      -w WARN, --warning WARN
                            Threshold for the number of processes. Type: None or
                            Range. Default: None
      --warning-mem WARN_MEM
                            Threshold for memory usage, in bytes. Type: None or
                            Range. Default: None
      --warning-mem-percent WARN_MEM_PERCENT
                            Threshold for memory usage, in percent. Type: None or
                            Range. Default: None
      --warning-age WARN_AGE
                            Threshold for age of the process, in seconds. Type:
                            None or Range. Default: None


Usage Examples
--------------

.. code-block:: bash

    ./procs

Output:

.. code-block:: text

    356 procs using 9.5GiB RAM (62.7%), oldest proc created 7h 44m ago, 5 running (1x glances, 1x WebExtensions, 1x systemd-resolved, 1x firefox, 1x Privileged Cont), 351 sleeping

Other examples:

.. code-block:: bash

    ./procs --no-kthreads --always-ok

    # warn if there are less than two or more than 100 httpd processes
    # crit if there are less than one or more than 150 httpd processes
    ./procs --command=httpd --warning=2:100 --critical=1:150

    # warn if "soffice" conversion consumes too much memory or was created more than 50 seconds ago
    ./procs --command=soffice --warning-mem-percent=10 --warning-age=50

    # warn if at least 1 zombie process exists
    ./procs --status=zombie --warning=0

    # count Firefox processes (Firefox's process name is "Web Content")
    ./procs --command='web content'


How to get process names
------------------------

Some process names in Python's psutil do not match the ones from ``ps aux``. To get a list with all processes, their names and details from a Python point of view, do:

.. code-block:: python

    (echo "import psutil"; echo "processes = psutil.process_iter()"; echo "for process in processes: print(process)") | python


States
------

* WARN or CRIT depending on your parameters, or if no processes can be found.


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description                                           
    procs,                                      Number,             Number of procs found matching the filter criteria
    procs_age,                                  Continous Counter,  Age of the oldest proc found in seconds
    procs_dead,                                 Number,             Number of dead procs
    procs_mem,                                  Bytes,              RAM usage of procs found
    procs_mem_percent,                          Percentage,         RAM usage of procs found
    procs_running,                              Number,             Number of procs in running state
    procs_sleeping,                             Number,             Number of procs in idle or interruptible sleep state
    procs_stopped,                              Number,             Number of procs stopped by debugger during the tracing or by job control signal
    procs_uninterruptible,                      Number,             Number of procs in uninterruptible state
    procs_zombies,                              Number,             Number of zombie processes


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
