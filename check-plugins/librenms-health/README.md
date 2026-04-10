# Check librenms-health

## Overview

Retrieves hardware sensor information (temperature, humidity, voltage, power, state, etc.) for each device from a LibreNMS instance and alerts when sensor values exceed their configured thresholds in LibreNMS.

**Data Collection:**

* Queries the LibreNMS MySQL/MariaDB database directly (the API is too resource-intensive for large-scale environments)
* Joins `devices`, `sensors`, `sensors_to_state_indexes`, `state_translations`, `device_groups`, and `locations` tables
* For state-class sensors, displays the state description instead of the raw numeric value
* For numeric sensors with defined limits, displays the value together with its low/high range
* Supports filtering by device group (`--device-group`, with SQL wildcards), device hostname (`--device-hostname`, repeatable), and device type (`--device-type`, repeatable)
* In default (compact) mode, only sensors with alerts are shown; use `--lengthy` to display all sensors with extended details (type, location, sensor class, last update time)

**Compatibility:**

* Cross-platform


**