Check network-port-tcp
======================

Overview
--------

Checks whether a network port is reachable.
Known Issues and Limitations are - the check works fine for tcp connections, but not for udp. The port response for udp is based on the target application (for example DNS or OpenVPN) and is not standard like tcp.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/network-port-tcp"
    "Check Interval Recommendation",        "Once a minute"
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

    ./network-port-tcp
    ./network-port-tcp --port 22
    ./network-port-tcp --hostname www.google.ch --port 443 --portname https --timeout 1.3 --state warn
    
Output:

.. code-block:: text

    TODOVM Output


States
------

* WARN (default) or CRIT if port is unreachable.


Perfdata / Metrics
------------------

There is no perfdata.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
