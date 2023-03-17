Check countdown
===============

Overview
--------

The check warns before an expiration date of events that are scheduled to occur. Useful to warn before a hardware or contract expiration date. Use ``./countdown --input='<Event Name>, <yyyy-mm-dd>, <WARN days before>, <CRIT days before>'`` (repeating). For example, ``./countdown --input='Supermicro X11 (SerNo ABCD), 2025-12-23, 60, 30'`` returns WARN/CRIT 60/30 days before 2025-12-23, otherwise OK.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/countdown"
    "Check Interval Recommendation",        "Twice a day"
    "Can be called without parameters",     "No"
    "Compiled for",                         "Linux, Windows"


Help
----

.. code-block:: text

    usage: countdown [-h] [-V] [--always-ok] --input INPUT

    Warns before an expiration date is scheduled to occur.

    optional arguments:
      -h, --help     show this help message and exit
      -V, --version  show program's version number and exit
      --always-ok    Always returns OK.
      --input INPUT  "Display Name 1, yyyy-mm-dd, warn, crit" (repeating)


Usage Examples
--------------

.. code-block:: bash

    ./countdown --input='Supermicro X11 (SerNo ABCD), 2023-12-31, 60, None' --input 'Allianz Insurance, 2024-12-31, 120, 30'
    
Output:

.. code-block:: text

    Everything is ok.

    * Supermicro X11 (SerNo ABCD) expires in 229 days (thresholds 60/None)
    * Allianz Insurance expires in 549 days (thresholds 120/30)


States
------

For each event:

* WARN: if event happens in warning days; 'None' is not possible
* CRIT: if event happens in critical days; 'None' means that CRIT is never returned


Perfdata / Metrics
------------------

There is no perfdata.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
