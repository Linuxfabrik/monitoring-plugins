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
    "Compiled for",                         "Linux"


Help
----

.. code-block:: text

    usage: ping [-h] [-V] [--always-ok] [--count COUNT] [-H HOSTNAME]
                [--interval INTERVAL] [-t DEADLINE]

    Sends ICMP ECHO_REQUEST to network hosts using the built-in `ping` command.

    options:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      --count COUNT         Stop after sending count ECHO_REQUEST packets.
                            Default: 5
      -H, --hostname HOSTNAME
                            The ping destination. Default: 127.0.0.1
      --interval INTERVAL   Wait interval seconds between sending each packet.
                            Real number allowed with dot as a decimal separator
                            (regardless locale setup). Default: 0.2
      -t, --timeout DEADLINE
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

    PING 192.0.2.10: 10 packets transmitted, 5 received, 50% packet loss, time 187ms. rtt min/avg/max/mdev = 105.659/105.990/106.333/0.225 ms, pipe 6


States
------

* CRIT if sending ICMP ECHO_REQUEST to network host fails
* UNKNOWN if name or service is unknown, out of memory, etc.
* Otherwise OK


Perfdata / Metrics
------------------

.. csv-table::
    :widths: 25, 15, 60
    :header-rows: 1
    
    Name,                                       Type,               Description                                           
    checksum_corrupted,                         Number,             Packets with corrupted checksum
    duplicates,                                 Number,             "Duplicate packets. If duplicate packets are received, they are not included in the packet loss calculation, although the round trip time of these packets is used in calculating the minimum/average/maximum/mdev round-trip time numbers."
    errors,                                     Number,             Packets with errors
    packet_loss,                                Percentage,         Packet loss in %
    received,                                   Number,             Received packets
    rtt_avg,                                    Milliseconds,       Average round trip time
    rtt_max,                                    Milliseconds,       Maximum round trip time
    rtt_mdev,                                   Milliseconds,       "Population standard deviation (mdev), essentially an average of how far each ping RTT is from the mean RTT. The higher mdev is, the more variable the RTT is (over time)."
    rtt_min,                                    Milliseconds,       Minimum round trip time
    time,                                       Milliseconds,       Time
    transmitted,                                Number,             Transmitted packets


Troubleshooting
---------------

From ``man ping`` and related to this check:

.. code-block:: text

    When using ping for fault isolation, it should first be run on the
    local host, to verify that the local network interface is up and
    running. Then, hosts and gateways further and further away should be
    “pinged”. Round-trip times and packet loss statistics are computed. If
    duplicate packets are received, they are not included in the packet
    loss calculation, although the round trip time of these packets is used
    in calculating the minimum/average/maximum/mdev round-trip time
    numbers.

    Population standard deviation (mdev), essentially an average of how far
    each ping RTT is from the mean RTT. The higher mdev is, the more
    variable the RTT is (over time). With a high RTT variability, you will
    have speed issues with bulk transfers (they will take longer than is
    strictly speaking necessary, as the variability will eventually cause
    the sender to wait for ACKs) and you will have middling to poor VoIP
    quality.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
