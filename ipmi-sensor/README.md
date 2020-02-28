# Overview

The check calls `ipmitool sensor list` to fetch detailed sensor information. Running this check just makes sense on hardware using an IPMI interface. Needs sudo.

We recommend to run this check every 15 minutes.


# Installation and Usage

Requirements:
* `ipmitool`

```bash
./ipmi-sensor
./ipmi-sensor --help
```


# States and Perfdata

* CRIT, if sensor value is non-recoverable (very worse).
* CRIT, if sensor value is above/below critical threshold given by IPMI.
* WARN, if sensor value is above/below IPMI non-critical threshold.
* UNKNOWN on `ipmitool` not found or errors running `ipmitool`.

Perfdata (depends on your hardware) - as an example:

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


# Known Issues and Limitations

* The check has to run locally and can't login remotely into an IPMI interface.
* "Discrete" sensors support is not implemented.


# Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see LICENSE file.