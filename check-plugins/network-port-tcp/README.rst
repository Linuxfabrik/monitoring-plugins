Check network-port-tcp
======================

Overview
--------

Checks whether a network port is reachable. This command works with both IPv4 and IPv6.

The check works fine for tcp connections, but not for udp. The port response for udp is based on the target application (for example DNS or OpenVPN) and is not standard like tcp.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70

    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/network-port-tcp"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "Yes"
    "Compiled for",                         "Linux, Windows"


Help
----

.. code-block:: text

    usage: network-port-tcp [-h] [-V] [-H HOSTNAME] [-p PORT]
                            [--portname PORTNAME] [--severity {warn,crit}]
                            [-t TIMEOUT] [--type {tcp,tcp6}]

    Checks whether a network port is reachable.

    options:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      -H, --hostname HOSTNAME
                            The host or ip address to check. Default: localhost
      -p, --port PORT       The port number. Default: 22
      --portname PORTNAME   The display name of the port.
      --severity {warn,crit}
                            Severity for alerting. Default: warn
      -t, --timeout TIMEOUT
                            Network timeout. Default: 2
      --type {tcp,tcp6}     Connection type. Default: tcp


Usage Examples
--------------

.. code-block:: bash

    ./network-port-tcp --hostname www.linuxfabrik.ch --port 443 --portname https --timeout 1.3 --state warn
    
Output:

.. code-block:: text

    www.linuxfabrik.ch:https/tcp is reachable.


States
------

* WARN (default) or CRIT if port is unreachable.


Perfdata / Metrics
------------------

There is no perfdata.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
