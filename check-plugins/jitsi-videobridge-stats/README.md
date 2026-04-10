# Check jitsi-videobridge-stats

## Overview

Monitors Jitsi Videobridge performance via the COLIBRI REST API. Reports conference count, participant count, video channels, bitrates, packet rates, and other bridge metrics.

**Data Collection:**

* Queries the `/colibri/stats` endpoint on the Jitsi Videobridge private REST interface
* The [private REST interface must be activated first](https://github.com/jitsi/jitsi-videobridge/blob/master/doc/rest.md)
* All `total_*` values are reported as continuous counters (uom `c`) so that graphing tools like Grafana can display rates over time correctly
* For details on the statistics, see the [Jitsi Videobridge statistics documentation](https://github.com/jitsi/jitsi-videobridge/blob/master/doc/statistics.md)

**Compatibility:**

* Cross-platform


**