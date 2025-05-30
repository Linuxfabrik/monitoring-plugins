Check updates
=============

Overview
--------

Checks the the number of pending Windows updates.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70

    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/updates"
    "Check Interval Recommendation",        "Once a day"
    "Can be called without parameters",     "Yes"
    "Compiled for Windows",                 "Yes"
    "3rd Party Python modules",             "``psutil``"


Help
----

.. code-block:: text

    usage: updates [-h] [-V] [--always-ok] [-c CRIT] [--timeout TIMEOUT] [-w WARN]

    Checks the number of pending Windows updates.

    options:
      -h, --help           show this help message and exit
      -V, --version        show program's version number and exit
      --always-ok          Always returns OK.
      -c, --critical CRIT  Set the critical threshold for the number of pending
                           updates. Default: 50
      --timeout TIMEOUT    Network timeout in seconds. Default: 300 (seconds)
      -w, --warning WARN   Set the warning threshold for the number of pending
                           updates. Default: 2


Usage Examples
--------------

.. code-block:: bash

    updates.exe --critical 10

Output:

.. code-block:: text

    There are 3 pending updates:

    * Windows Malicious Software Removal Tool x64 - v5.98 (KB890830) [2/8/2022 12:00:00 AM]
    * 2022-02 Cumulative Update Preview for .NET Framework 3.5, 4.7.2 and 4.8 for Windows Server 2019 for x64 (KB5011267) [2/15/2022 12:00:00 AM]
    * 2022-02 Cumulative Update for Windows Server 2019 (1809) for x64-based Systems (KB5010351) [2/8/2022 12:00:00 AM]


States
------

* WARN or CRIT if number of updates is above a given threshold.


Perfdata / Metrics
------------------

* ``pending_updates``: Number of pending updates.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
