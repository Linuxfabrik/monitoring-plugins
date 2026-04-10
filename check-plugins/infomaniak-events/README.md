# Check infomaniak-events

## Overview

Monitors the Infomaniak status page for open events and incidents. Alerts when active events are reported.

**Data Collection:**

* Queries the Infomaniak API for current events
* Requires a Bearer Token with scope "event" from Infomaniak
* Displays event type, title, services, start/end time, and duration in a table

**Compatibility:**

* Cross-platform


**