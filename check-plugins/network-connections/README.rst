Check network-connections
=========================

Overview
--------

Counts tcp (v4), tcp6 (v6), udp (v4) and udp6 (v6) connection details. Output is grouped by connection type and status, ordered by the number of connections (descending). Emulating ``ss -s`` and ``ss -antp``.

Meaning of connection type ``--conn-type`` parameter:

* ``tcp``:  TCP over IPv4
* ``tcp6``:  TCP over IPv6
* ``udp4``:  UDP over IPv4
* ``udp6``:  UDP over IPv6

Meaning of connection status ``--conn-status``  parameter:

* ``CLOSE``: Closed. The socket is not being used.
* ``CLOSE_WAIT``: Remote shutdown; waiting for the socket to close - means the other end of the connection has been closed while the local end is still waiting for the application to close.
* ``CLOSING``: Closed, then remote shutdown; awaiting acknowledgment.
* ``ESTABLISHED``: Connection has been established.
* ``FIN_WAIT_1``: Socket closed; shutting down connection.
* ``FIN_WAIT_2``: Socket closed; waiting for shutdown from remote.
* ``IDLE``: Idle, opened but not bound.
* ``LAST_ACK``: Remote shutdown, then closed; awaiting acknowledgment.
* ``LISTEN``: Listening for incoming connections.
* ``NONE``: For UDP sockets this is always going to be "None".
* ``SYN_RECV``: Active/initiate synchronization received and the connection under way.
* ``SYN_SENT``: Actively trying to establish connection.
* ``TIME_WAIT``: Wait after close for remote shutdown retransmission.

This check optionally alerts if the number of any connection type and status does not fit into the given ranges.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/network-connections"
    "Check Interval Recommendation",        "Once a minute"
    "Can be called without parameters",     "Yes"
    "Available for",                        "Python 2, Python 3, Windows"
    "Requirements",                         "Python module ``psutil``"


Help
----

.. code-block:: text

    usage: network-connections [-h] [-V]
                               [--conn-status {all,close,close_wait,closing,established,fin_wait1,fin_wait2,last_ack,listen,none,syn_recv,syn_sent,time_wait}]
                               [--conn-type {all,tcp,tcp6,udp,udp6}]
                               [-c CRIT] [-w WARN]

    Counts system-wide socket connections like tcp, tcp6, udp or udp6. If you have
    too many connections like TCP_CLOSE and therefore get errors like "too many
    files open", reconfigure and/or restart the application that is receiving or
    processing those connections.

    options:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --conn-status {all,close,close_wait,closing,established,fin_wait1,fin_wait2,last_ack,listen,none,syn_recv,syn_sent,time_wait}
                            Filter the status of the connections (repeating).
                            Default: None
      --conn-type {all,tcp,tcp6,udp,udp6,unix}
                            Filter the family/type of the connections (repeating).
                            Default: None
      -c CRIT, --critical CRIT
                            Threshold for the number of connections. Type: None or
                            Range. Default: None
      -w WARN, --warning WARN
                            Threshold for the number of connections. Type: None or
                            Range. Default: None



Usage Examples
--------------

Just get network statistics and don't alert on anything:

.. code-block:: bash

    ./network-connections

Output:

.. code-block:: text

    tcp ESTABLISHED: 19, udp NONE: 16, tcp LISTEN: 9, udp6 NONE: 5, tcp CLOSE WAIT: 4, tcp6 LISTEN: 4, tcp TIME WAIT: 1, tcp6 CLOSE WAIT: 1

Alert if number of established TCP (v4) connections is higher than 200:

.. code-block:: text

    ./network-connections --conn-type=tcp --conn-status=established --warning=200

Output:

.. code-block:: text

    tcp ESTABLISHED: 260 [WARNING]

Alert if number of any established connection is not between 30 and 40:

.. code-block:: text

    ./network-connections --conn-type=all --conn-status=established --warning=30:40

Output:

.. code-block:: text

    tcp ESTABLISHED: 26 [WARNING]

Use repeating parameter:

.. code-block:: text

    ./network-connections --conn-type=tcp6 --conn-status=established --conn-status=closing --warning=30:40

Output:

.. code-block:: text

    No connections of type "tcp6" in status "established,closing" found.


States
------

* WARN or CRIT if number of connections found does not fit into the given ranges.


Perfdata / Metrics
------------------

Depends on your connections. As an example:

* tcp_CLOSE_WAIT
* tcp_ESTABLISHED
* tcp_LISTEN
* tcp_TIME_WAIT
* tcp6_ESTABLISHED
* tcp6_LISTEN
* udp_NONE
* udp6_NONE


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
* Credits https://github.com/giampaolo/psutil/blob/master/scripts/netstat.py
