Check sensors-fans
===================

Overview
--------

Return hardware fans speed. Fan speed is expressed in RPM (rounds per minute). OK if no fans are found.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/sensors-fans"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "Yes"
    "Available for",                        "Python 2, Python 3"
    "Requirements",                         "Python module ``psutil``"


Help
----

.. code-block:: text

    usage: sensors-fans [-h] [-V] [--always-ok] [-c CRIT] [-w WARN]

    Return hardware fans speed. Fan speed is expressed in RPM (rounds per minute).

    optional arguments:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      -c CRIT, --critical CRIT
                            Set the critical threshold for fan speed in RPM.
                            Default: 20000
      -w WARN, --warning WARN
                            Set the warning threshold for fan speed in RPM.
                            Default: 10000


Usage Examples
--------------

.. code-block:: bash

    ./sensors-fans --warning 10000 --critical 20000
    
Output:

.. code-block:: text

    dell_smm: dell_smm = 4714 RPM, dell_smm = 4428 RPM


States
------

* WARN or CRIT if fan speed (RPM) is above a given threshold.


Perfdata / Metrics
------------------

* for each fan: its speed (RPM)


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
* Credits: https://github.com/giampaolo/psutil/blob/master/scripts/fans.py
