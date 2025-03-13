Check dns
=========

Overview
--------

Performs a DNS lookup and converts a hostname to one or more IP addresses. Only the name servers configured on the machine running this check plugin (for example those in ``/etc/resolv.conf``) will be queried - you can't query other DNS servers. When no arguments or options are given, the check tries to resolve *localhost*, and the full range of results for any available protocol is returned.

This command works with both IPv4 and IPv6.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70

    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/dns"
    "Check Interval Recommendation",        "Every 15 minutes"
    "Can be called without parameters",     "Yes"
    "Compiled for",                         "Linux, Windows"


Help
----

.. code-block:: text

    usage: dns [-h] [-V] [--always-ok] [-c CRIT] [-H HOSTNAME] [-p PORT]
               [--type {udp,udp6,tcp,tcp6}] [-w WARN]

    Performs a DNS lookup and converts a hostname to one or more IP addresses.
    Only the name servers configured on the machine running this check plugin (for
    example those visible in `/etc/resolv.conf`) will be queried - you can't query
    other DNS servers. This command works with both IPv4 and IPv6.

    options:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      -c, --critical CRIT   Return critical if elapsed time in ms exceeds value.
                            Default: None
      -H, --hostname HOSTNAME
                            The host or ip address to check. Default: localhost
      -p, --port PORT       The port number. Default: 53
      --type {udp,udp6,tcp,tcp6}
                            Connection type. Can be optionally specified in order
                            to narrow the list of addresses returned.
      -w, --warning WARN    Return warning if elapsed time in ms exceeds value.
                            Default: None


Usage Examples
--------------

.. code-block:: bash

    ./dns --hostname $(hostname)
    ./dns --hostname www.example.org --type udp --port 53 --warning 1000 --critical 5000
    
Output:

.. code-block:: text

    Lookup for webserver.linuxfabrik.ch returns 192.168.26.43 (tcp4:53), 192.168.26.43 (udp4:53), 192.168.26.43 (ip4:53)


States
------

* WARN on socket errors, address related errors, network timeouts.
* WARN or CRIT if you provide thresholds for the DNS lookup time duration.
* Otherwise OK.


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1

    Name,                                       Type,               Description
    time,                                       Milliseconds,       DNS lookup time


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
