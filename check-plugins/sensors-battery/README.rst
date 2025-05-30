Check sensors-battery
=====================

Overview
--------

Return battery status information. If no battery is installed or metrics can't be determined OK is returned.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70

    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/sensors-battery"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "Yes"
    "Compiled for Windows",                 "No"
    "3rd Party Python modules",             "``psutil``"


Help
----

.. code-block:: text

    usage: sensors-battery [-h] [-V] [--always-ok] [-c CRIT] [-w WARN]

    Return battery status information. If no battery is installed or metrics can't
    be determined OK is returned.

    options:
      -h, --help           show this help message and exit
      -V, --version        show program's version number and exit
      --always-ok          Always returns OK.
      -c, --critical CRIT  Set the critical threshold for battery power left as a
                           percentage. Default: 5
      -w, --warning WARN   Set the warning threshold for battery power left as a
                           percentage. Default: 20


Usage Examples
--------------

.. code-block:: bash

    ./sensors-battery --warning 20 --critical 5
    
Output:

.. code-block:: text

    94.13%, 4h 40m left (not plugged in and discharging)


States
------

* WARN or CRIT if battery power left as % is below a given threshold.


Perfdata / Metrics
------------------

* battery power as a percentage (%)
* time left (seconds)


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
* Credits: https://github.com/giampaolo/psutil/blob/master/scripts/battery.py
