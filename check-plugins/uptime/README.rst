Check uptime
============

Overview
--------

Checks and tells how long the system has been running (in days). Note that the plugin now requires a time qualifier when specifying parameters, e.g. ``--warning=180D`` for 180 days (instead of ``--warning=180`` as in previous versions).


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/uptime"
    "Check Interval Recommendation",        "Every 5 minutes"
    "Can be called without parameters",     "Yes"
    "Compiled for",                         "Linux, Windows"
    "3rd Party Python modules",             "``psutil``"


Help
----

.. code-block:: text

    usage: uptime [-h] [-V] [--always-ok] [-c CRIT] [-w WARN]

    Check how long the system has been running.

    options:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      -c CRIT, --critical CRIT
                            Threshold for the uptime in a human readable format
                            (10m = 10 minutes; s = seconds, m = minutes, h =
                            hours, D = days, W = weeks, M = months, Y = years).
                            Supports Nagios ranges. Example: `:1Y` alerts if
                            uptime is greater than 1 year.Default: :1Y
      -w WARN, --warning WARN
                            Threshold for the uptime in a human readable format
                            (10m = 10 minutes; s = seconds, m = minutes, h =
                            hours, D = days, W = weeks, M = months, Y = years).
                            Supports Nagios ranges. Example: `5m:180D` warns if
                            uptime is not between 5 minutes and 180 days.Default:
                            3m:180D


Usage Examples
--------------

Warn if more than 180 days, crit if more than 365 days up:

.. code-block:: bash

    ./uptime --warning=180D --critical=1Y

Output:

.. code-block:: text

    Up 2W 6h since 2024-03-30 08:08:01 (thresholds 180D/1Y)

Warn if less than 5 minutes up:

.. code-block:: bash

    ./uptime --warning=5m:

Output:

.. code-block:: text

    Up 4m since 2024-03-30 08:08:01 (thresholds 5m:/:1Y) [WARNING]

Warn if not in 5 minutes to 6 months and 5 days uptime. If more than 2 years up, return crit:

.. code-block:: bash

    ./uptime --warning=5m:6M5D --critical=2Y
    # alternatively: ./uptime --warning='5m:6M 5D' --critical=2Y

Output over time:

.. code-block:: text

    Up 1m 39s since 2024-03-30 08:08:01 (thresholds 5m:6M5D/2Y) [WARNING]
    Up 6M since 2024-03-30 08:08:01 (thresholds 5m:6M5D/2Y)
    Up 6M 6D since 2024-03-30 08:08:01 (thresholds 5m:6M5D/2Y) [WARNING]


States
------

* WARN or CRIT if system uptime is above a given threshold.


Perfdata / Metrics
------------------

* Uptime (seconds)


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
