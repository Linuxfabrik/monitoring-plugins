# Check apache-httpd-status

## Overview

Monitors Apache httpd performance via the mod_status endpoint (server-status?auto). Alerts when worker usage exceeds the configured thresholds. Reports busy and idle workers, request rates, bytes served, CPU load, connection states, and system load averages. Requires "ExtendedStatus On" in the Apache configuration for full metrics. Uses a local SQLite database to calculate per-second rates from cumulative counters.

**Data Collection:**

* Fetches data from the Apache `mod_status` machine-readable endpoint (`server-status?auto`)
* Parses the scoreboard to count workers in each state (reading, replying, keepalive, DNS lookup, closing, logging, starting, finishing, waiting, free slots)
* Uses a local SQLite database to store previous values and calculate per-interval deltas for accesses, bytes, and duration
* On the first run (or after a restart), returns "Waiting for more data." until at least two measurements are available

**Compatibility:**

* Cross-platform


**