# Check fortios-ha-stats

## Overview

Monitors the high-availability cluster status on FortiGate appliances running FortiOS via the REST API. Alerts if the number of HA members differs from the expected count (default: 2). Reports serial number, role, priority, hostname, and synchronization status per member.

**Data Collection:**

* Queries the FortiOS REST API endpoint `/api/v2/monitor/system/ha-statistics/select/` to retrieve HA member details
* Aggregates total sessions and traffic across all cluster members
* Emits per-member perfdata for sessions, network usage, traffic bytes, CPU usage, and memory usage
* Authentication uses a single API token (Token-based authentication)

**Compatibility:**

* Cross-platform

**Important Notes:**

* FortiGate appliances running FortiOS with REST API access and HA configured


## 