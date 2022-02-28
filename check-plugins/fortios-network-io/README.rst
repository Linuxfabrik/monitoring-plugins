Check fortios-network-io
========================

Overview
--------

This plugin checks network I/O and link states on all interfaces found on a Forti Appliance like FortiGate running FortiOS, using the FortiOS REST API. Warns on link up/down, speed or duplex change as well as bandwidth saturation. The authentication is done via a single API token (Token-based authentication), not via Session-based authentication, which is stated as "legacy".

Hints:

* ``--count=5`` (the default) while checking every minute means that the check reports a warning if any interface was above a threshold in the last 5 minutes.
* Check needs ``count`` runs to warm up its caches.
* The check inventorizes your appliance. If you change any of Forti's interfaces, and you want to reset the check's warnings about this, simply delete its ``/tmp/fortios-network-io.db`` file.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70

    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/fortios-network-io"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "No"
    "Available for",                        "Python 2, Python 3, Windows"
    "Requirements",                         "None"
    "Handles Periods",                      "Yes"
    "Uses SQLite DBs",                      "Yes"


Help
----

.. code-block:: text

    usage: fortios-network-io [-h] [-V] [--always-ok] [--count COUNT] [-c CRIT]
                              -H HOSTNAME [--insecure] [--no-proxy] --password
                              PASSWORD [--timeout TIMEOUT] [-w WARN]

    optional arguments:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      --count COUNT         Number of times the value has to be above the given
                            thresholds. Default: 5
      -c CRIT, --critical CRIT
                            Set the critical threshold for link saturation for
                            <count> checks, in bps. Default: 900000000
      -H HOSTNAME, --hostname HOSTNAME
                            FortiOS-based Appliance address, optional including
                            port ("192.168.1.1:443").
      --insecure            This option explicitly allows to perform "insecure"
                            SSL connections. Default: False
      --no-proxy            Do not use a proxy. Default: False
      --password PASSWORD   FortiOS REST API Single Access Token.
      --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)
      -w WARN, --warning WARN
                            Set the warning threshold for link saturation for
                            <count> checks, in bps. Default: 800000000


Usage Examples
--------------

.. code-block:: bash

    ./fortios-network-io --hostname fortigate-cluster.linuxfabrik.io --password mypass --count 5 --warning 800000000 --critical 900000000

Output:

.. code-block:: text

    port8: 338.9KiB/33.4KiB bps (rx/tx, current).
    interface   ! rx1bps   ! tx1bps  ! rx5bps   ! tx5bps
    ------------+----------+---------+----------+---------
    mgmt1       ! 2.6KiB   ! 2.5KiB  ! 2.6KiB   ! 2.5KiB
    modem       ! 0.0B     ! 0.0B    ! 0.0B     ! 0.0B
    npu0_vlink0 ! 0.0B     ! 0.0B    ! 0.0B     ! 0.0B
    npu1_vlink0 ! 0.0B     ! 0.0B    ! 0.0B     ! 0.0B
    npu1_vlink1 ! 0.0B     ! 0.0B    ! 0.0B     ! 0.0B
    port8       ! 338.9KiB ! 33.4KiB ! 334.0KiB ! 33.3KiB


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
