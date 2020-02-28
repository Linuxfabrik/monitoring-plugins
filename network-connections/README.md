# Overview

Counts tcp, tcp6, udp and udp6 connection details. Emulating `ss -antp`.

* `CLOSED`: Closed. The socket is not being used.
* `CLOSING`: Closed, then remote shutdown; awaiting acknowledgment.
* `CLOSE_WAIT`: Remote shutdown; waiting for the socket to close - means the other end of the connection has been closed while the local end is still waiting for the application to close.
* `ESTABLISHED`: Connection has been established.
* `FIN_WAIT_1`: Socket closed; shutting down connection.
* `FIN_WAIT_2`: Socket closed; waiting for shutdown from remote.
* `IDLE`: Idle, opened but not bound.
* `LAST_ACK`: Remote shutdown, then closed; awaiting acknowledgment.
* `LISTEN`: Listening for incoming connections.
* `SYN_RECEIVED`: Active/initiate synchronization received and the connection under way.
* `SYN_SENT`: Actively trying to establish connection.
* `TIME_WAIT`: Wait after close for remote shutdown retransmission.

We recommend to run this check every minute.


# Installation and Usage

Requirements:
* Python2 module `psutil`

```bash
./network-connections
./network-connections --help
```


# States and Perfdata

* Always returns OK.

Perfdata - for example:

* tcp_CLOSE_WAIT
* tcp_ESTABLISHED
* tcp_LISTEN
* tcp_TIME_WAIT
* tcp6_ESTABLISHED
* tcp6_LISTEN
* udp_NONE
* udp6_NONE


# Known Issues and Limitations

* Does not WARN or CRIT on anything, because we do not know on what. Until there is some clarification, this check is useful for debugging purposes.


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.
* Credits
  - https://github.com/giampaolo/psutil/blob/master/scripts/netstat.py
