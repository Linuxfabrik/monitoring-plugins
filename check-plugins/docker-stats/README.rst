Check "docker-stats"
====================

Overview
--------

This check prints various statistics for all running Docker containers, in much the same way as the Unix application top, using the "docker stats" command. We recommend to run this check every minute.


Installation and Usage
----------------------

Requirements:

* ``docker``

.. code-block:: bash

    ./docker-stats
    ./docker-stats --always-ok
    ./docker-stats --warning-cpu 70 --critical-cpu 90 --count 5 --warning-mem 90 --critical-mem 95
    ./docker-stats --help

Output::

    Everything is ok.

    Container CPU % State Mem %  State RX bps    TX bps    BlockIn/s BlockOut/s 
    --------- ----- ----- ------ ----- --------- --------- --------- ---------- 
    cont01    0.1   [OK]  1.79   [OK]  0.0bps    0.0bps    0.0B      0.0B
    cont02    0.0   [OK]  2.11   [OK]  0.0bps    0.0bps    0.0B      0.0B


States
------

Alerts if

* any container memory usage is above the memory thresholds
* the docker host memory usage is above the memory thresholds
* any container cpu usage is above the cpu thresholds during the last n checks (default: 5)


Perfdata
--------

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


Hints and Recommendations
-------------------------

* Not tested with ``podman``.
* We are not fetching the Docker API, because a ``/stats`` request on a container takes round about two seconds - for each.
* We check system-wide CPU stats, not per-CPU. If a container reports 100% CPU usage, all cores are used (during a certain period of time).
* `--count=5` (the default) while checking every minute means that the check reports a warning if cpu-usage of a container was above a threshold in the last 5 minutes.
* The Net RX and TX rates in bps are approximate values.
* The Block In and Block Out rates in Bytes per second are approximate values.
* The check needs at least 3sec to run.
* The check uses a SQLite database in ``/tmp`` to store its historical data.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see LICENSE file.
