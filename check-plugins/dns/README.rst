Check dns
=========

Overview
--------

Performs a DNS lookup and converts a hostname to one or more IP addresses. Only the name servers configured on the machine running this check plugin (for example those visible in ``/etc/resolv.conf``) will be queried - you can't query other DNS servers. When no arguments or options are given, the check tries to resolve "localhost", and the full range of results for any available protocol is returned.

This command works with both IPv4 and IPv6.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/dns"
    "Check Interval Recommendation",        "Every 15 minutes"
    "Available for",                        "Python 2, Python 3"
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

    ./dns
    ./dns --hostname $(hostname)
    ./dns --hostname www.example.org --type udp --port 53
    ./dns --hostname www.example.org --type tcp6 --port 80 --warning 1000 --critical 5000
    
Output:

.. code-block:: text

    TODOVM Output


States
------

* WARN on socket errors, address related errors, network timeouts.
* WARN or CRIT if you provide thresholds for the DNS lookup time duration.
* Otherwise OK.


Perfdata / Metrics
------------------

* time: DNS lookup time


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
