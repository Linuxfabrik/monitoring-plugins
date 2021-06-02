Check needs-restarting
======================

Overview
--------

Checks for processes that started running before they or some component that they use were updated. Returns WARN if a full reboot is required or if services might need a restart, and in any other case OK. May take more than 10 seconds to execute.

We recommend to run this check once a day or after a ``yum update`` only.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/needs-restarting"
    "Check Interval Recommendation",        "Once a day"
    "Available for",                        "Python 2"
    "Requirements",                         "Python module ``psutil``, command-line tool ``foo``"
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

    ./needs-restarting
    
Output:

.. code-block:: text

    TODOVM Output


States
------

* WARN on needed service or system restarts.
* Does not WARN or CRIT on other problems like ``Modular dependency problem`` etc.


Perfdata / Metrics
------------------

There is no perfdata.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
