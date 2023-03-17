Check docker-stats
==================

Overview
--------

This check prints cpu and memory statistics for all running Docker or Podman containers, using the `docker stats <https://docs.docker.com/engine/reference/commandline/stats/>`_ command. Container CPU usage is divided by the available number of CPU cores ("normalized").

Hint:

    Since ``docker stats`` only returns byte-level data in a human-readable format (e.g. *4.82GB*), claculating network I/O (``RX bps``, ``TX bps``) and block I/O (``BlockIn/s``, ``BlockOut/s``) is imprecise. Therefore, these values are not used at all.

Plugin execution may take up to 10 seconds.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/docker-stats"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "Yes"
    "Compiled for",                         "Linux"
    "Handles Periods",                      "Yes"
    "Uses SQLite DBs",                      "Yes"


Help
----

.. code-block:: text

    usage: docker-stats [-h] [-V] [--always-ok] [--count COUNT]
                        [--critical-cpu CRIT_CPU] [--critical-mem CRIT_MEM]
                        [--full-name] [--warning-cpu WARN_CPU]
                        [--warning-mem WARN_MEM]

    This check prints various statistics for all running Docker containers, in
    much the same way as the Unix application top, using the "docker stats"
    command.

    optional arguments:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      --count COUNT         Number of times the value has to be above the given
                            thresholds. Default: 5
      --critical-cpu CRIT_CPU
                            Set the critical threshold CPU Usage Percentage.
                            Default: 90
      --critical-mem CRIT_MEM
                            Set the critical threshold Memory Usage Percentage.
                            Default: 95
      --full-name           Use full container name, for example
                            `traefik_traefik.2.1idw12p2yqp`. If ommitted, the name
                            will be shortened after the replica number (default
                            behaviour).
      --warning-cpu WARN_CPU
                            Set the warning threshold CPU Usage Percentage.
                            Default: 80
      --warning-mem WARN_MEM
                            Set the warning threshold Memory Usage Percentage.
                            Default: 90


Usage Examples
--------------

.. code-block:: bash

    ./docker-stats --count 5 --warning-cpu 70 --critical-cpu 90 --warning-mem 90 --critical-mem 95

Output:

.. code-block:: text

    Everything is ok.

    Container                 ! CPU % ! Mem % 
    --------------------------+-------+-------
    myconti_app-logger_1      ! 0.0   ! 0.0   
    myconti_backend-core_1    ! 0.1   ! 33.9  
    myconti_ds_1              ! 0.0   ! 11.42


States
------

Alerts if

* any container memory usage is above the memory thresholds
* any container cpu usage is above the cpu thresholds during the last n checks (default: 5)


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description                                           
    cpu,                                        Number,             Number of Host CPUs
    <containername>_cpu_usage,                  Percentage,         "Container's CPU usage (normalized)"
    <containername>_mem_usage,                  Percentage,         "Container's memory usage (Percent)"


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
