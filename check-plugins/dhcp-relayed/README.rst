Check dhcp-relayed
==================

Overview
--------

This plugin tests if a DHCP server (local or remote) can offer IPv4 addresses. It emulates a DHCP client and checks the DHCP offer response from the DHCP server. It does not send a DHCP request.

Hints:

* May take three or more seconds to run.
* Requires sudo permissions to open and listen on port 68/udp. Therefore, the machine running this plugin must not be running a dhcp client listening on port 68/udp, like ``systemd-networkd`` for example.
* Uses standard UDP sockets instead of raw sockets, so this plugin needs to run on a machine that actually has a fixed IP address.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/dhcp-relayed"
    "Check Interval Recommendation",        "Every 5 minutes"
    "Can be called without parameters",     "Yes"
    "Compiled for",                         "Linux, Windows"


Help
----

.. code-block:: text

    usage: dhcp-relayed [-h] [-V] [--always-ok] [--mac MAC] [--timeout TIMEOUT]

    This plugin tests if a DHCP server (local or remote) can offer IPv4 addresses.
    It emulates a DHCP client and checks the DHCP offer response from the DHCP
    server.

    options:
      -h, --help         show this help message and exit
      -V, --version      show program's version number and exit
      --always-ok        Always returns OK.
      --mac MAC          Network MAC address to use. Doesn't have to be an
                         existing MAC address. If you specify `--mac=random`, a
                         random MAC address will be used. If omitted, the hardware
                         address is obtained as described in
                         https://docs.python.org/3/library/uuid.html#uuid.getnode.
      --timeout TIMEOUT  Network timeout in seconds. Default: 7 (seconds)


Usage Examples
--------------

.. code-block:: bash

    ./dhcp-relayed
    ./dhcp-relayed --mac=random
    ./dhcp-relayed --mac=80:32:15:12:34:AB
    ./dhcp-relayed --mac=8032151234AB

Output:

.. code-block:: text

    Offered IP: 192.168.122.99/255.255.255.0 (MAC: 52540024b33a); Server ID: 192.168.122.1; Broadcast Addr: 192.168.122.255


States
------

* WARN if a "Socket timeout" occurs, maybe due to DHCP pool exhaustion.
* WARN if the returned IP address is 0.0.0.0.


Perfdata / Metrics
------------------

There is no perfdata.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
* Credits:
    * inspired by `check_dhcp_relayed <https://exchange.nagios.org/directory/Plugins/Network-Protocols/DHCP-and-BOOTP/check_dhcp_relayed/details>`_
    * inspired by https://code.activestate.com/recipes/577649-dhcp-query/
