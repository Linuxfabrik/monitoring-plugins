Check network-bonding
=====================

Overview
--------

Reports the state of all channel bonding interfaces. Channel bonding enables two or more network interfaces to act as one, simultaneously increasing the bandwidth and providing redundancy.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70

    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/network-bonding"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "Yes"
    "Compiled for",                         "Linux"


Help
----

.. code-block:: text

    usage: network-bonding [-h] [-V] [--always-ok] [--test TEST]

    Reports the state of a channel bonding interface. Channel bonding enables two
    or more network interfaces to act as one, simultaneously increasing the
    bandwidth and providing redundancy.

    options:
      -h, --help     show this help message and exit
      -V, --version  show program's version number and exit
      --always-ok    Always returns OK.
      --test TEST    For unit tests. Needs "path-to-bonding-file".


Usage Examples
--------------

.. code-block:: bash

    ./network-bonding

Output:

.. code-block:: text

    One or more errors.

    * [WARNING] bond0 (IEEE 802.3ad Dynamic link aggregation)
        * Could not detect the MAC Address of the switch. This could indicate that LACP is not configured properly.


States
------

* WARN if any interface in a bonding interface is not up, or if there are warnings considering the configuration.


Perfdata / Metrics
------------------

* ``link_failure_count`` (for each interface)


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
