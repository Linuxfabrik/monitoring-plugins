Check openvpn-client-list
=========================

Overview
--------

Prints a list of all clients connected to the OpenVPN Server, and optionally checks their number against thresholds. Fetches the info from ``/var/log/openvpn-status.log`` (default), which you configure on your OpenVPN appliance using ``status /var/log/openvpn-status.log``. Needs sudo.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/openvpn-client-list"
    "Check Interval Recommendation",        "Every 5 minutes"
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

    ./openvpn-client-list
    ./openvpn-client-list --warning 20 --critical 100 --filename /var/log/openvpn-status.log
    
Output:

.. code-block:: text

    TODOVM Output


States
------

* WARN or CRIT if number of connected users is above a given threshold.


Perfdata / Metrics
------------------

* Number of clients connected.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
