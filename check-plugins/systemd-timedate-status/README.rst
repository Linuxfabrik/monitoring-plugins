Check systemd-timedate-status
=============================

Overview
--------

Checks current settings of the system clock and RTC, including whether network time synchronization is active - the same as if using ``timedatectl status`` manually.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/systemd-timedate-status"
    "Check Interval Recommendation",        "Once a day"
    "Can be called without parameters",     "Yes"
    "Available for",                        "Python 3"
    "Requirements",                         "None"


Help
----

.. code-block:: text

    usage: systemd-timedate-status [-h] [-V] [--always-ok] [--test TEST]

    Checks current settings of the system clock and RTC, including whether network
    time synchronization is active.

    options:
      -h, --help     show this help message and exit
      -V, --version  show program's version number and exit
      --always-ok    Always returns OK.
      --test TEST    For unit tests. Needs "path-to-stdout-file,path-to-stderr-
                     file,expected-retc".


Usage Examples
--------------

.. code-block:: bash

    ./systemd-timedate-status

Output:

.. code-block:: text

    System clock synchronized: yes. NTP service: active. The system is configured to read the RTC time in the local time zone. This mode cannot be fully supported. It will create various problems with time zone changes and daylight saving time adjustments. The RTC time is never updated, it relies on external facilities to maintain it. If at all possible, use RTC in UTC by calling `timedatectl set-local-rtc 0` [WARNING].


States
------

* WARN if system is configured to read the RTC time in the local time zone.


Perfdata / Metrics
------------------

There is no perfdata.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
