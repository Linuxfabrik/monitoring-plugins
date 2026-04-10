# Check haproxy-status

## Overview

Monitors HAProxy performance and health via the stats endpoint. Reports frontend and backend session usage, request rates, response times, error rates, and server states. Alerts when session usage exceeds the configured thresholds or when backends/servers are in an unhealthy state. Supports extended reporting via `--lengthy`.

**Data Collection:**

* Connects to the HAProxy stats interface via a Unix domain socket (`unix:///run/haproxy.sock` by default) or HTTP(S) endpoint
* Parses the HAProxy CSV stats output for all frontends, backends, and servers
* Checks session usage against `--warning`/`--critical` thresholds (percentage of session limit)
* Checks queue usage and session rate against the same thresholds
* For HTTP access, supports Basic authentication (`--username` / `--password`)

**Compatibility:**

* Linux only


**