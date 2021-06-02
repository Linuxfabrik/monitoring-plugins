Check ipmi-sel
==============

Overview
--------

The check calls ``ipmitool sel elist`` to fetch the IPMI System Event Log (SEL). If there are entries, it returns a warning, otherwise everything is expected to be OK. Running this check just makes sense on hardware providing an IPMI interface. Needs sudo.

Tested against:

* Supermicro
* HPE iLO


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/ipmi-sel"
    "Check Interval Recommendation",        "Every 15 minutes"
    "Available for",                        "Python 2"
    "Requirements",                         "Python module ``psutil``, command-line tool ``ipmitool``"
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

    ./ipmi-sel
    ./ipmi-sel --privlevel USER --interface lanplus --hostname 10.100.184.29 --username 'user' --password 'pa$$word'
    
Output:

.. code-block:: text

    TODOVM Output


States
------

* WARN, if SEL has entries.
* UNKNOWN on ``ipmitool`` not found or errors running ``ipmitool``.


Perfdata / Metrics
------------------

There is no perfdata.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
