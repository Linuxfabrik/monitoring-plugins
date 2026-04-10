# Check fortios-sensor

## Overview

Checks hardware sensor readings (temperature, voltage, fan speed) on FortiGate appliances running FortiOS via the REST API. Alerts when any sensor value crosses the appliance-defined thresholds (`lower_non_critical`, `lower_critical`, `upper_non_critical`, `upper_critical`). Sensors reporting a value of 0.0 are skipped automatically. Authentication uses a single API token (token-based authentication).

**Data Collection:**

* Queries the FortiOS REST API endpoint `/api/v2/monitor/system/sensor-info/select` to fetch all hardware sensor readings and their thresholds

**Compatibility:**

* Cross-platform

**Important Notes:**

* FortiGate appliances running FortiOS with REST API enabled


## 