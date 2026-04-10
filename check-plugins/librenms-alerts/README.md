# Check librenms-alerts

## Overview

Checks for unacknowledged alerts in LibreNMS and reports the most recent alert per device. Only considers devices that do not have alerting disabled in their LibreNMS device settings. When you acknowledge an alert in the LibreNMS web UI (Alerts > Notifications), this check changes the status for the corresponding device to OK.

**Data Collection:**

* Queries the LibreNMS MySQL/MariaDB database directly (the API is too resource-intensive for large-scale environments)
* Joins `devices`, `alerts`, `alert_rules`, `device_groups`, and `locations` tables to build the device/alert overview
* Supports filtering by device group (`--device-group`, with SQL wildcards), device hostname (`--device-hostname`, repeatable), and device type (`--device-type`, repeatable)
* In default (compact) mode, only devices with active alerts are shown; use `--lengthy` to display all devices with extended details (hardware, type, OS, location, uptime)

**Compatibility:**

* Cross-platform


**