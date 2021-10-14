Check ipmi-sel
==============

Overview
--------

The check calls ``ipmitool sel elist`` to fetch the IPMI System Event Log (SEL). If there are entries, it returns a warning, otherwise everything is expected to be OK. Running this check just makes sense on hardware providing an IPMI interface. Needs sudo.

Tested on:

* Supermicro
* HPE iLO

Known Issues and Limitations are: ``Discrete`` sensors support is not implemented.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/ipmi-sel"
    "Check Interval Recommendation",        "Every 15 minutes"
    "Can be called without parameters",     "Yes"
    "Available for",                        "Python 2, Python 3"
    "Requirements",                         "command-line tool ``ipmitool``"


Help
----

.. code-block:: text

    usage: ipmi-sel [-h] [-V] [--authtype {NONE,PASSWORD,MD2,MD5,OEM}]
                    [-H HOSTNAME] [--interface {lan,lanplus}]
                    [--password PASSWORD] [--port PORT]
                    [--privlevel {CALLBACK,USER,OPERATOR,ADMINISTRATOR}]
                    [--username USERNAME]

    Checks the IPMI System Event Log (SEL) and returns WARN if there are entries.
    Use "ipmitool sel clear" to clear the IPMI System Event Log (SEL).

    optional arguments:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --authtype {NONE,PASSWORD,MD2,MD5,OEM}
                            Specify an authentication type to use during IPMIv1.5
                            lan session activation. Supported types are NONE,
                            PASSWORD, MD2, MD5, or OEM.
      -H HOSTNAME, --hostname HOSTNAME
                            Remote server address, can be IP address or hostname.
                            This option is required for lan and lanplus
                            interfaces.
      --interface {lan,lanplus}
                            Selects IPMI interface to use. Supported types are
                            "lan" (= IPMI v1.5) or "lanplus" (= IPMI v2.0).
      --password PASSWORD   Remote server password.
      --port PORT           Remote server UDP port to connect to. Default is 623.
      --privlevel {CALLBACK,USER,OPERATOR,ADMINISTRATOR}
                            Force session privilege level. Can be CALLBACK, USER,
                            OPERATOR, ADMINISTRATOR. Default is USER.
      --username USERNAME   Remote server username, default is NULL user.


Usage Examples
--------------

.. code-block:: bash

    ./ipmi-sel --privlevel USER --interface lanplus --hostname 10.100.184.29 --username 'user' --password 'pa$$word'
    
Output:

.. code-block:: text

    Everything is ok.


States
------

* WARN, if SEL has entries.
* UNKNOWN on ``ipmitool`` not found or errors running ``ipmitool``.


Perfdata / Metrics
------------------

There is no perfdata.


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
