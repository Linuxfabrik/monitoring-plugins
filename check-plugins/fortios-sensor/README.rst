Check fortios-sensor
====================

Overview
--------

The check fetches detailed sensor information from a Forti Appliance like FortiGate running FortiOS, using the FortiOS REST API. Warns automatically by comparing to pre-defined appliance thresholds. The authentication is done via a single API token (Token-based authentication), not via Session-based authentication, which is stated as "legacy".


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70
    
    "Check Plugin Download",                "https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/tree/master/check-plugins/fortios-sensor"
    "Check Interval Recommendation",        "Every 15 minutes"
    "Available for",                        "Python 2"
    "Requirements",                         "Python module ``psutil``, command-line tool ``foo``"
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

    ./fortios-sensor --hostname fortigate-cluster.linuxfabrik.io --password sSEaTjuNbPYW5yepUD2JtDhyykY59D
    
Output:

.. code-block:: text

    TODOVM Output


States
------

* CRIT, if sensor value is <= lower_critical or >= upper_critical
* WARN, if sensor value is <= lower_non_critical or >= upper_non_critical


Perfdata / Metrics
------------------

Depends on your hardware. Example:

* fan.fan1
* fan.fan2
* fan.fan3
* fan.fan4
* fan.fan5
* fan.fan6
* fan.ps1_fan_1
* fan.ps2_fan_1
* temperature.cpu_0_core_0
* temperature.cpu_0_core_1
* temperature.cpu_0_core_2
* temperature.cpu_0_core_3
* temperature.cpu_0_core_4
* temperature.cpu_0_core_5
* temperature.cpu_0_core_6
* temperature.cpu_0_core_7
* temperature.cpu_1_core_0
* temperature.cpu_1_core_1
* temperature.cpu_1_core_2
* temperature.cpu_1_core_3
* temperature.cpu_1_core_4
* temperature.cpu_1_core_5
* temperature.cpu_1_core_6
* temperature.cpu_1_core_7
* temperature.dts_cpu0
* temperature.dts_cpu1
* temperature.ps1_temp
* temperature.ps2_temp
* temperature.td1
* temperature.td2
* temperature.td3
* temperature.td4
* temperature.ts1
* temperature.ts2
* temperature.ts3
* temperature.ts4
* temperature.ts5
* voltage.+12v
* voltage.+3.3vsb
* voltage.+3.3vsb_smc
* voltage.3vdd
* voltage.cpu0_pvccin
* voltage.cpu1_pvccin
* voltage.mac_1.025v
* voltage.mac_avs_1v
* voltage.p1v05_pch
* voltage.p3v3_aux
* voltage.ps1_vin
* voltage.ps1_vout_12v
* voltage.ps2_vin
* voltage.ps2_vout_12v
* voltage.pvccio
* voltage.pvddq_ab
* voltage.pvddq_ef
* voltage.pvtt_ab
* voltage.pvtt_cd
* voltage.pvtt_gh
* voltage.vcc1.15v
* voltage.vcc2.5v
* voltage.vcc3v3
* voltage.vcc5v


Credits, License
----------------

* Authors: `Linuxfabrik GmbH, Zurich <https://www.linuxfabrik.ch>`_
* License: The Unlicense, see `LICENSE file <https://git.linuxfabrik.ch/linuxfabrik/monitoring-plugins/-/blob/master/LICENSE>`_.
