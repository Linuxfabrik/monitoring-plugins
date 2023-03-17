Check fortios-sensor
====================

Overview
--------

The check fetches detailed sensor information from a Forti Appliance like FortiGate running FortiOS, using the FortiOS REST API. Warns automatically by comparing to pre-defined appliance thresholds. The authentication is done via a single API token (Token-based authentication), not via Session-based authentication, which is stated as "legacy".


Fact Sheet
----------

.. csv-table::
    :widths: 30, 70

    "Check Plugin Download",                "https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/fortios-sensor"
    "Check Interval Recommendation",        "Every 15 minutes"
    "Can be called without parameters",     "No"
    "Compiled for",                         "Linux, Windows"


Help
----

.. code-block:: text

    usage: fortios-sensor [-h] [-V] [--always-ok] -H HOSTNAME [--insecure]
                          [--no-proxy] --password PASSWORD [--timeout TIMEOUT]

    Checks FortiOS sensor information in detail.

    optional arguments:
      -h, --help            show this help message and exit
      -V, --version         show program's version number and exit
      --always-ok           Always returns OK.
      -H HOSTNAME, --hostname HOSTNAME
                            FortiOS-based Appliance address, optional including
                            port ("192.168.1.1:443").
      --insecure            This option explicitly allows to perform "insecure"
                            SSL connections. Default: False
      --no-proxy            Do not use a proxy. Default: False
      --password PASSWORD   FortiOS REST API Single Access Token.
      --timeout TIMEOUT     Network timeout in seconds. Default: 3 (seconds)


Usage Examples
--------------

.. code-block:: bash

    ./fortios-sensor --hostname fortigate-cluster.linuxfabrik.io --password mypass


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
* License: The Unlicense, see `LICENSE file <https://unlicense.org/>`_.
