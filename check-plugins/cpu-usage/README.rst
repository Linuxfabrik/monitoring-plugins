Check cpu-usage
===============

Overview
--------

Returns a bunch of numbers representing the current system-wide CPU utilization as a percentage. Outputs the cpu times having > 0% in the first line, sorted by value. In addition, the top 3 processes which consumed the most CPU time are listed. Warns only if any of ``user``, ``system``, ``iowait`` or overall ``cpu-usage`` is above a certain threshold within the last n checks (default: 5).

Hints and Recommendations:

* We check system-wide CPU stats, not per-CPU.
* ``--count=5`` (the default) while checking every minute means that the check reports a warning if any of ``user``, ``system``, ``iowait`` or overall ``cpu-usage`` was above a threshold in the last 5 minutes.
* Check needs at least 250ms to run.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/cpu-usage"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "Yes"
    "Available for",                        "Python 2, Python 3, Windows"
    "Requirements",                         "Python module ``psutil``"
    "Handles Periods",                      "Yes"
    "Uses SQLite DBs",                      "Yes"


Help
----

.. code-block:: text

    usage: cpu-usage [-h] [-V] [--always-ok] [--count COUNT] [-c CRIT] [-w WARN]

    Mainly provides utilization percentages for each specific CPU time. Takes a
    time period into account: the cpu usage within a certain amount of time has to
    be equal or above given thresholds before a warning is raised.

    optional arguments:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      --count COUNT         Number of times the value has to be above the given
                            thresholds. Default: 5
      -c CRIT, --critical CRIT
                            Set the critical threshold CPU Usage Percentage.
                            Default: 90
      -w WARN, --warning WARN
                            Set the warning threshold CPU Usage Percentage.
                            Default: 80


Usage Examples
--------------

.. code-block:: bash

    ./cpu-usage --count=15 --warning=50 --critical=70
    
Output:

.. code-block:: text

    2.6% - user: 1.6%, system: 0.7%, irq: 0.2%, softirq: 0.1%
    guest: 0.0%, iowait: 0.0%, guest_nice: 0.0%, steal: 0.0%, nice: 0.0%
    interrupts: 582.9M, soft_interrupts: 343.6M, ctx_switches: 1.1G

    Top3 processes which consumed the most cpu time:
    1. Xorg: 2h 13m
    2. gnome-shell: 2h 1m
    3. firefox: 1h 24m


States
------

* OK if ``user``, ``system``, ``iowait`` and overall ``cpu-usage`` are all below the thresholds within the last ``--count`` checks.
* Otherwise CRIT or WARN.


Perfdata / Metrics
------------------

* ``cpu-usage``: %. The overall cpu usage. This is (100 - ``idle``).
* ``ctx_switches``: Continous counter. Number of context switches (voluntary + involuntary) since boot. A context switch is a procedure that a computer's CPU (central processing unit) follows to change from one task (or process) to another while ensuring that the tasks do not conflict.
* ``guest``: %. Linux 2.6.24+: Time spent running a virtual CPU.
* ``guest_nice``: %. Linux 3.2.0+
* ``idle``: %. If the CPU has completed all tasks it is idle.
* ``interrupts``: Continous counter. Number of interrupts since boot.
* ``iowait``: %. Time spent waiting for I/O to complete. This is not accounted in idle time counter.
* ``irq``: %. Time spent for servicing hardware interrupts.
* ``nice``: %. Time spent by niced (prioritized) processes executing in user mode; this also includes guest_nice time.
* ``soft_interrupts``: Continous counter. Number of software interrupts since boot.
* ``steal``: %. Linux 2.6.11+; Percentage of time a virtual CPU waits for a real CPU while the hypervisor is servicing another virtual processor.
* ``system``: %. Percent time spent in kernel space. System CPU time is the time spent running code in the Operating System kernel.
* ``user``: %. Percent time spent in user space. User CPU time is the time spent on the processor running your program's code (or code in libraries).


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
* Credits: `psutil Documentation <https://psutil.readthedocs.io/en/latest/>`_
