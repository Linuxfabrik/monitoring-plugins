Check ipmi-sensor
=================

Overview
--------

The check calls ``ipmitool sensor list`` to fetch detailed sensor information. Running this check just makes sense on hardware using an IPMI interface. Needs sudo.

Tested on:

* Supermicro
* HPE iLO

Known Issues and Limitations are: ``Discrete`` sensors support is not implemented.



Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/ipmi-sensor"
    "Check Interval Recommendation",        "Every 15 minutes"
    "Can be called without parameters",     "Yes"
    "Available for",                        "Python 2"
    "Requirements",                         "command-line tool ``ipmitool``"

   
Help
----

.. code-block:: text

    usage: ipmi-sensor [-h] [-V] [--authtype {NONE,PASSWORD,MD2,MD5,OEM}]
                       [-H HOSTNAME] [--interface {lan,lanplus}]
                       [--password PASSWORD] [--port PORT]
                       [--privlevel {CALLBACK,USER,OPERATOR,ADMINISTRATOR}]
                       [--username USERNAME]

    Checks IPMI sensor information in detail.

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

    ./ipmi-sensor --privlevel USER --interface lanplus --hostname 10.100.184.29 --username 'user' --password 'pa$$word'

Output:

.. code-block:: text

    Checked 60 sensors, all are ok.


States
------

* CRIT, if sensor value is non-recoverable (very worse).
* CRIT, if sensor value is above/below critical threshold given by IPMI.
* WARN, if sensor value is above/below IPMI non-critical threshold.
* UNKNOWN on ``ipmitool`` not found or errors running ``ipmitool``.


Perfdata / Metrics
------------------

Depends on your hardware - as an example:

* 1.05V_PCH
* 1.2V_BMC
* 1.5V_PCH
* 12V
* 3.3VCC
* 3.3VSB
* 5VCC
* 5VSB
* CPU_Temp
* DIMMA1_Temp
* DIMMA2_Temp
* DIMMB1_Temp
* DIMMB2_Temp
* DIMMC1_Temp
* DIMMC2_Temp
* DIMMD1_Temp
* DIMMD2_Temp
* FAN1
* FAN2
* FAN3
* FAN4
* PCH_Temp
* Peripheral_Temp
* System_Temp
* VBAT
* Vcpu
* VcpuVRM_Temp
* VDIMMAB
* VDIMMCD
* VmemABVRM_Temp
* VmemCDVRM_Temp


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
