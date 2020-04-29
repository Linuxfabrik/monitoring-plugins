# Check "fortios-network-io" - Overview

This plugin checks network I/O and interface link states on Forti Appliances like FortiGate running FortiOS via FortiOS REST API. Warns on link up/down, speed or duplex change as well as bandwidth saturation. The authentication is done via a single API token (Token-based authentication), not via Session-based authentication, which is stated as "legacy".

Hints and Recommendations:
* `--count=5` (the default) while checking every minute means that the check reports a warning if any interface was above a threshold in the last 5 minutes.
* Check needs `count` runs to warm up its caches.
* Check uses a SQLite database in `/tmp` to store its historical data.
* The check inventorizes your appliance. If you change any of Forti's interfaces, and you want to reset the check's warnings about this, simply delete its `fortios-network-io.db` file.

We recommend to run this check every minute.


# Installation and Usage

```bash
./fortios-network-io --hostname fortigate-cluster.linuxfabrik.io --password sSEaTjuNbPYW5yepUD2JtDhyykY59D
./fortios-network-io --hostname fortigate-cluster.linuxfabrik.io --password sSEaTjuNbPYW5yepUD2JtDhyykY59D --count 5 --warning 800000000 --critical 900000000
./fortios-network-io --help
```


# States

* WARN or CRIT, if network I/O (bps) is greater or equal a given threshold
* WARN, if link state, speed rate or duplex mode for an interface changes


# Perfdata

Depends on your hardware - as an example:

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


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.