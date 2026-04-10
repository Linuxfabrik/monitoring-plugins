# Check ipmi-sensor

## Overview

Checks IPMI sensor readings (temperature, voltage, fan speed, power, etc.) using ipmitool. Alerts when any sensor reports a non-ok status. Provides detailed output including current values, thresholds, and sensor states. Requires root or sudo.

**Data Collection:**

* Executes `ipmitool sensor list` locally or against a remote BMC/iLO via IPMI over LAN
* For remote access, supports both IPMI v1.5 (`--interface=lan`) and IPMI v2.0 (`--interface=lanplus`)
* Emits perfdata for every threshold-based sensor with IPMI-reported warning, critical, and min/max values

**Compatibility:**

* Cross-platform


**