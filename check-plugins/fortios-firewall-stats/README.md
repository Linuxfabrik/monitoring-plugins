# Check fortios-firewall-stats

## Overview

Summarizes traffic statistics for all IPv4 and IPv6 firewall policies on FortiGate appliances running FortiOS via the REST API. Reports byte and packet counters, active sessions, and hit counts per policy.

**Data Collection:**

* Queries the FortiOS REST API endpoints `/api/v2/monitor/firewall/policy/select/` (IPv4) and `/api/v2/monitor/firewall/policy6/select/` (IPv6)
* If one of the two requests fails (e.g. IPv6 not configured), the check continues with the successful result
* Aggregates byte counters, session counts, and hit counts across all policies
* Authentication uses a single API token (Token-based authentication)

**Compatibility:**

* Cross-platform


**