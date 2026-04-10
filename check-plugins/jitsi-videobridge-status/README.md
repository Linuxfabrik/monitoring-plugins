# Check jitsi-videobridge-status

## Overview

Checks the Jitsi Videobridge health state via the `/about/health` REST endpoint. Returns OK if the bridge is healthy, WARN or CRIT otherwise.

**Data Collection:**

* Queries the `/about/health` endpoint on the Jitsi Videobridge private REST interface
* The Videobridge performs periodic internal health tests and returns the latest result
* A HTTP 200 response indicates a healthy state; any other status indicates a problem
* For details see the [Jitsi Videobridge health check documentation](https://github.com/jitsi/jitsi-videobridge/blob/master/doc/health-checks.md)

**Compatibility:**

* Cross-platform

**Important Notes:**

* Jitsi Videobridge v2.1+


## 