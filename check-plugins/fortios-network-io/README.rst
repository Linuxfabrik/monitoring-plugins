Check fortios-network-io
========================

Overview
--------

This plugin checks network I/O and link states on all interfaces found on a Forti Appliance like FortiGate running FortiOS, using the FortiOS REST API. Warns on link up/down, speed or duplex change as well as bandwidth saturation. The authentication is done via a single API token (Token-based authentication), not via Session-based authentication, which is stated as "legacy".

Hints:

* ``--count=5`` (the default) while checking every minute means that the check reports a warning if any interface was above a threshold in the last 5 minutes.
* Check needs ``count`` runs to warm up its caches.
* Check uses a SQLite database in ``/tmp`` to store its historical data.
* The check inventorizes your appliance. If you change any of Forti's interfaces, and you want to reset the check's warnings about this, simply delete its ``fortios-network-io.db`` file.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/fortios-network-io"
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

    ./fortios-network-io --hostname fortigate-cluster.linuxfabrik.io --password sSEaTjuNbPYW5yepUD2JtDhyykY59D
    ./fortios-network-io --hostname fortigate-cluster.linuxfabrik.io --password sSEaTjuNbPYW5yepUD2JtDhyykY59D --count 5 --warning 800000000 --critical 900000000
    
Output:

.. code-block:: text

    TODOVM Output


States
------

* WARN or CRIT, if network I/O (bps) is greater or equal a given threshold
* WARN, if link state, speed rate or duplex mode for an interface changes


Perfdata / Metrics
------------------

Depends on your hardware. Example:

* ``modem_rx1``: Received bytes on this interface since the last check
* ``modem_tx1``: Sent bytes since the last check
* ``modem_rxn``: Received bytes since the last n checks (default: 5)
* ``modem_txn``: Sent bytes since the last n checks
* ...


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
