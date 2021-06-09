Check docker-stats
==================

Overview
--------

This check prints various statistics for all running Docker containers, in much the same way as the Unix application top, using the ``docker stats`` command.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/docker-stats"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "Yes"
    "Available for",                        "Python 2, Python 3"
    "Requirements",                         "None"
    "Handles Periods",                      "Yes"
    "Uses SQLite DBs",                      "Yes"


Help
----

.. code-block:: text

    usage: docker-stats [-h] [-V] [--always-ok] [--count COUNT]
                        [--critical-cpu CRIT_CPU] [--critical-mem CRIT_MEM]
                        [--warning-cpu WARN_CPU] [--warning-mem WARN_MEM]

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

    Container       CPU % State Mem %  State RX bps    TX bps    BlockIn/s BlockOut/s 
    ---------       ----- ----- ------ ----- --------- --------- --------- ---------- 
    prod_idp_logger 0.0   [OK]  2.23   [OK]  0.0bps    0.0bps    0.0B      0.0B       
    prod_idp_app    0.2   [OK]  52.11  [OK]  0.0bps    0.0bps    0.0B      0.0B


States
------

Alerts if

* any container memory usage is above the memory thresholds
* the docker host memory usage is above the memory thresholds
* any container cpu usage is above the cpu thresholds during the last n checks (default: 5)


Perfdata / Metrics
------------------

* cpu: Number of Host CPUs
* mem_usage: Docker Host Memory Usage (Bytes)
* mem_usage_percent: Docker Host Memory Usage (Percent)
* <containername>_block_in: Blocks In (Bytes)
* <containername>_block_in_bytespersec: Blocks In (Bytes per second)
* <containername>_block_out: Blocks Out (Bytes)
* <containername>_block_out_bytespersec: Blocks Out (Bytes per second)
* <containername>_cpu_usage: Container's CPU usage (normalized)
* <containername>_mem_usage: Container's memory usage (Bytes)
* <containername>_mem_usage_percent: Container's memory usage (Percent)
* <containername>_rx: Container's received bytes
* <containername>_rx_bps: Container's incoming bits per second
* <containername>_tx: Container's sent bytes
* <containername>_tx_bps: Container's outgoing bits per second


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
