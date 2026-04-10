# Check fortios-network-io

## Overview

Monitors network I/O and link states on all interfaces of FortiGate appliances running FortiOS via the REST API. Alerts only if bandwidth thresholds have been exceeded for a configurable number of consecutive check runs (default: 5), suppressing short spikes. Reports per-interface traffic counters and link status. Authentication uses a single API token (token-based authentication).

**Data Collection:**

* Queries the FortiOS REST API endpoint `/api/v2/monitor/system/interface/select` to fetch per-interface traffic counters, link state, speed, and duplex mode
* Uses SQLite state persistence between runs to calculate bandwidth deltas and to track link state changes
* On the first run, returns "Waiting for more data." until at least two measurements are available
* `--count=5` (the default) while checking every minute means the check uses a 5-minute sliding window for threshold evaluation

**Compatibility:**

* Cross-platform


**