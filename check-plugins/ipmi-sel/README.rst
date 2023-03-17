Check ipmi-sel
==============

Overview
--------

The check calls ``ipmitool sel elist`` to fetch the IPMI System Event Log (SEL). If there are entries, it returns a warning, otherwise everything is expected to be OK. Running this check just makes sense on hardware providing an IPMI interface. Needs sudo.

Hints:

* Tested on Supermicro and HPE iLO
* ``Discrete`` sensors support is not implemented.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/ipmi-sel"
    "Check Interval Recommendation",        "Every 15 minutes"
    "Can be called without parameters",     "Yes"
    "Compiled for",                         "Linux"
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

    *   17 ; 09/10/2019 ; 21:11:27 ; OS Boot ; Installation completed () ; Asserted
    *   16 ; 09/10/2019 ; 21:00:01 ; OS Boot ; Installation started () ; Asserted
    *   15 ; 09/10/2019 ; 20:45:43 ; OS Boot ; Installation started () ; Asserted
    *   14 ; 09/03/2019 ; 21:59:00 ; Unknown #0xff ;  ; Asserted
    *   13 ; 09/03/2019 ; 21:24:49 ; Unknown #0xff ;  ; Asserted
    *   12 ; 09/03/2019 ; 21:23:27 ; Unknown #0xff ;  ; Asserted
    *   11 ; 09/03/2019 ; 21:19:24 ; Unknown #0xff ;  ; Asserted
    *   10 ; 09/03/2019 ; 21:11:20 ; Unknown #0xff ;  ; Asserted
    *    f ; 09/03/2019 ; 21:09:53 ; Unknown #0xff ;  ; Asserted
    *    e ; 09/03/2019 ; 21:08:34 ; Unknown #0xff ;  ; Asserted
    *    d ; 08/26/2019 ; 13:57:02 ; Physical Security Chassis Intru ; General Chassis intrusion () ; Deasserted
    *    c ; 08/17/2019 ; 02:33:33 ; Power Supply PS1 Status ; Failure detected () ; Deasserted
    *    b ; 08/17/2019 ; 02:33:24 ; Power Supply PS1 Status ; Failure detected () ; Asserted
    *    a ; 08/17/2019 ; 02:31:57 ; Power Supply PS1 Status ; Failure detected () ; Deasserted
    *    9 ; 08/17/2019 ; 02:31:44 ; Power Supply PS1 Status ; Failure detected () ; Asserted
    *    8 ; 04/02/2019 ; 14:52:04 ; OS Boot ; Installation completed () ; Asserted
    *    7 ; 04/02/2019 ; 14:46:19 ; OS Boot ; Installation started () ; Asserted
    *    6 ; 03/16/2019 ; 12:16:11 ; OS Boot ; Installation completed () ; Asserted
    *    5 ; 03/16/2019 ; 12:10:02 ; OS Boot ; Installation started () ; Asserted
    *    4 ; 03/16/2019 ; 07:06:24 ; Physical Security Chassis Intru ; General Chassis intrusion () ; Asserted
    *    3 ; 03/13/2019 ; 15:15:34 ; Physical Security Chassis Intru ; General Chassis intrusion () ; Asserted
    *    2 ; 03/13/2019 ; 11:15:43 ; Physical Security Chassis Intru ; General Chassis intrusion () ; Asserted
    *    1 ; 03/12/2019 ; 13:10:45 ; Physical Security Chassis Intru ; General Chassis intrusion () ; Asserted


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
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
