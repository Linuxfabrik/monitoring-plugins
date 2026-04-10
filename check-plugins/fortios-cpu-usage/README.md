# Check fortios-cpu-usage

## Overview

Monitors CPU utilization on FortiGate appliances running FortiOS via the REST API. Alerts only if the threshold has been exceeded for a configurable number of consecutive check runs (default: 5), suppressing short spikes. First checks against the globally configured cpu-use-threshold on the appliance, then falls back to command-line thresholds.

**Data Collection:**

* Queries the FortiOS REST API endpoint `/api/v2/monitor/system/resource/usage?resource=cpu&interval=1-min` for the current CPU usage
* Queries `/api/v2/cmdb/system/global` to read the appliance's globally configured `cpu-use-threshold`; if present, this value overrides `--warning`
* Stores each measurement in a local SQLite database, retaining the last `--count` rows
* Authentication uses a single API token (Token-based authentication)

**Compatibility:**

* Cross-platform


**