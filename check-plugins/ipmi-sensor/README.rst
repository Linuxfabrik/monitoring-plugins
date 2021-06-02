Check ipmi-sensor
=================

Overview
--------

The check calls ``ipmitool sensor list`` to fetch detailed sensor information. Running this check just makes sense on hardware using an IPMI interface. Needs sudo.
It has been tested agains Supermicro and HPE iLO. Known Issues and Limitations are: ``Discrete`` sensors support is not implemented.


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/ipmi-sensor"
    "Check Interval Recommendation",        "Every 15 minutes"
    "Available for",                        "Python 2"
    "Requirements",                         "Python module ``ipmitool``, command-line tool ``foo``"
    "Handles Periods",                      "Yes"
    "Uses SQLite DBs",                      "Yes"
    "Perfdata compatible with Prometheus",  "Yes"

   
Help
----

.. code-block:: text

    usage: example [-h] [-V]

    Example Check.

    optional arguments:
      -h, --help       show this help message and exit
      -V, --version    show program's version number and exit


Usage Examples
--------------

.. code-block:: bash

    ./ipmi-sensor
    ./ipmi-sensor --privlevel USER --interface lanplus --hostname 10.100.184.29 --username 'user' --password 'pa$$word'
    
Output:

.. code-block:: text

    TODOVM Output


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
