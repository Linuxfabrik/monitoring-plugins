Check dhcp-relayed
==================

Overview
--------

This plugin tests if a local or remote DHCP server can offer IPv4 addresses (to a specific subnet). It emulates a DHCP client and checks the DHCP offer response from the DHCP server. It only sends a DHCPDISCOVER, not a DHCPREQUEST.

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

    usage: dhcp-relayed [-h] [-V] [--always-ok] [--bind-address BIND_ADDRESS]
                        [-H HOSTNAME] [--mac MAC] [--subnet-mask SUBNET_MASK]
                        [--subnet-selection SUBNET_SELECTION] [--timeout TIMEOUT]

    This plugin tests if a local or remote DHCP server can offer IPv4 addresses
    (to a specific subnet). It emulates a DHCP client and checks the DHCP offer
    response from the DHCP server. It only sends a DHCPDISCOVER, not a
    DHCPREQUEST.

    options:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      --bind-address BIND_ADDRESS
                            Bind the socket to address. The socket must not
                            already be bound. Default: 0.0.0.0
      -H, --hostname HOSTNAME
                            DHCP server address, can be IP address or hostname.
                            Default: None
      --mac MAC             Network MAC address to use. Doesn't have to be an
                            existing MAC address. If you specify `--mac=random`, a
                            random MAC address will be used. If omitted, the
                            hardware address is obtained as described in https://d
                            ocs.python.org/3/library/uuid.html#uuid.getnode.
      --subnet-mask SUBNET_MASK
                            The subnet mask option specifies the client's subnet
                            mask. Example: 255.255.255.248. Default: None
      --subnet-selection SUBNET_SELECTION
                            The subnet selection option would override a DHCP
                            server's normal methods of selecting the subnet on
                            which to allocate an address for a client. Example:
                            192.168.122.0. Default: None
      --timeout TIMEOUT     Network timeout in seconds. Default: 7 (seconds)


Usage Examples
--------------

.. code-block:: bash

    ./dhcp-relayed
    ./dhcp-relayed --mac=random
    ./dhcp-relayed --mac=80:32:15:12:34:AB
    ./dhcp-relayed --mac=8032151234AB
    ./dhcp-relayed --bind-address=192.0.2.74 --hostname=192.168.122.1 --subnet-mask=255.255.0.0 --subnet-selection=192.168.122.0

Output:

.. code-block:: text

    DHCPOFFER: IP=192.168.122.99/255.255.255.0 Server ID=192.168.122.1 Broadcast Addr=192.168.122.255
    DHCPDISCOVER: MAC=52540024b33a Host=192.168.122.1 Network=192.168.122.0/255.255.0.0


States
------

* WARN if a "Socket timeout" occurs, perhaps because the DHCP pool is exhausted, does not exist, or similar.
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
