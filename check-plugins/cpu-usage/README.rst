Check cpu-usage
===============

Overview
--------

Returns a bunch of numbers representing the current system-wide CPU utilization as a percentage. Outputs the cpu times having > 0% in the first line, sorted by value. Warns only if any of ``user``, ``system``, ``iowait`` or overall ``cpu-usage`` is above a certain threshold within the last n checks (default: 5).

Hints and Recommendations:
* We check system-wide CPU stats, not per-CPU.
* ``--count=5`` (the default) while checking every minute means that the check reports a warning if any of ``user``, ``system``, ``iowait`` or overall ``cpu-usage`` was above a threshold in the last 5 minutes.
* Check needs at least 250ms to run.
* Check uses a SQLite database in ``/tmp`` to store its historical data.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/cpu-usage"
    "Check Interval Recommendation",        "Once a minute"
    "Available for",                        "Python 2, Python 3, Windows"
    "Requirements",                         "Python2 module ``psutil``, command-line tool ``foo``"
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

    ./cpu-usage
    ./cpu-usage --count=15 --warning=50 --critical=70
    
Output:

.. code-block:: text

    TODOVM Output


States
------

* OK if ``user``, ``system``, ``iowait`` and overall ``cpu-usage`` are all below the thresholds within the last ``--count`` checks.
* Otherwise CRIT or WARN.


Perfdata / Metrics
------------------


* ``cpu-usage``: %. The overall cpu usage. This is (100 - ``idle``).
* ``ctx_switches``: Continous counter. Number of context switches (voluntary + involuntary) since boot. A context switch is a procedure that a computer’s CPU (central processing unit) follows to change from one task (or process) to another while ensuring that the tasks do not conflict.
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
* ``user``: %. Percent time spent in user space. User CPU time is the time spent on the processor running your program’s code (or code in libraries).


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
