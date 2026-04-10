# Check fortios-memory-usage

## Overview

Monitors memory utilization on FortiGate appliances running FortiOS via the REST API. First checks against the globally configured memory-use-threshold on the appliance, then falls back to command-line thresholds if no global configuration exists. Alerts when memory usage exceeds the configured thresholds.

**Data Collection:**

* Queries the FortiOS REST API endpoint `/api/v2/monitor/system/resource/usage?resource=mem&interval=1-min` for the current memory usage
* Queries `/api/v2/cmdb/system/global` to read the appliance's globally configured `memory-use-threshold-green` (warning) and `memory-use-threshold-red` (critical); if present, these values override `--warning` and `--critical`
* Authentication uses a single API token (Token-based authentication)

**Compatibility:**

* Cross-platform


**