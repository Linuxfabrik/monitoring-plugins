Check ping
==========

Overview
--------

Sends ICMP ECHO_REQUEST to network hosts using the built-in ``ping`` command. Without any parameters it tries to send five packets within one second (so its fast!) and exits after five seconds timeout at the latest. It doesn't care about round trip times or packet loss as long the host is still reachable in some way. That means 90% packet loss is ok, while 100% are not. Why? If this check is used to test the host-liveliness (which in 99.9% is its use case), mostly all other service checks depend on its result. For that reason it should be as tolerant and reliable as possible and only throw CRIT (equal to DOWN) if the host is definitely not reachable at all.

``check_ping`` from ``nagios-plugins`` just prints ``PING OK - Packet loss = 0%, RTA = 3.79 ms``, while this check tells you everything that you are used to if using the ``ping`` command directly: ``PING localhost(localhost (::1)): 5 packets transmitted, 5 received, time 828ms. rtt min/avg/max/mdev = 0.029/0.113/0.189/0.052 ms``.

This command works with both IPv4 and IPv6.

The ``--always-ok`` parameter is useful for hosts that do not allow ping, but which can still execute check-plugins. The packet loss will be reported, but the state will be OK.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/ping"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "Yes"
    "Available for",                        "Python 2, Python 3"
    "Requirements",                         "None"


Help
----

.. code-block:: text

    usage: ping [-h] [-V] [--count COUNT] [-H HOSTNAME] [--interval INTERVAL]
                [-t DEADLINE]

    Sends ICMP ECHO_REQUEST to network hosts using the built-in `ping` command.

    optional arguments:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --count COUNT         Stop after sending count ECHO_REQUEST packets.
                            Default: 5
      -H HOSTNAME, --hostname HOSTNAME
                            The ping destination. Default: 127.0.0.1
      --interval INTERVAL   Wait interval seconds between sending each packet.
                            Default: 0.2
      -t DEADLINE, --timeout DEADLINE
                            Specify a timeout, in seconds, before ping exits
                            regardless of how many packets have been sent or
                            received. Default: 5


Usage Examples
--------------

.. code-block:: bash

    ./ping --hostname localhost
    ./ping --interval=0.2 --count=5 --timeout=5 --hostname localhost

Output:

.. code-block:: text

    PING localhost: 5 packets transmitted, 5 received, 0% packet loss, time 829ms. rtt min/avg/max/mdev = 0.036/0.082/0.103/0.023 ms


States
------

* CRIT if sending ICMP ECHO_REQUEST to network host fails
* UNKNOWN if name or service is unknown, out of memory, etc.
* Otherwise OK


Perfdata / Metrics
------------------

* transmitted packets
* received packets
* duplicate packets
* checksum_corrupted packets
* errors
* packet_loss (%)
* time (ms)
* rtt_min (ms)
* rtt_avg (ms)
* rtt_max (ms)
* rtt_mdev (ms)


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
