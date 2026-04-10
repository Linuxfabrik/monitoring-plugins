# Check redfish-sensor

## Overview

Checks hardware sensor readings (temperature, voltage, fan speed, power) from the Redfish Chassis collection via the Redfish API. Also evaluates fan redundancy status. A Chassis is roughly defined as a physical view of a computer system as seen by a human. A single Chassis resource can house sensors, fans, and other components.

**Data Collection:**

* Queries `/redfish/v1/Chassis` to enumerate chassis members
* For each member, queries the Sensors collection to read individual sensor values, thresholds, and health status
* Also queries the Thermal endpoint for fan redundancy information
* Uses HTTP Basic authentication if `--username` and `--password` are provided
* Only evaluates sensors and chassis in "Enabled" or "Quiesced" state

**Important Notes:**

* Tested on DELL iDRAC and DMTF Simulator
* A check takes up to 10 seconds. Increasing runtime timeout to 30 seconds is recommended.
* This check runs with both HTTP and HTTPS. It uses GET requests only.
* No additional Python Redfish modules need to be installed.

**Compatibility:**

* Linux only


## 