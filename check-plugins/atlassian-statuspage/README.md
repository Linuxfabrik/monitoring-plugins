# Check atlassian-statuspage

## Overview

Monitors a public Atlassian Statuspage for incidents and maintenance windows. Returns OK when no incidents are reported, WARN for minor incidents or scheduled maintenance, and CRIT for major or critical incidents. Works with any Statuspage-powered status page, not just Atlassian's own.

**Data Collection:**

* Queries the `/api/v2/status.json` endpoint of the specified Statuspage URL
* Maps the Statuspage incident indicator to Nagios states according to the [Atlassian impact calculation](https://support.atlassian.com/statuspage/docs/top-level-status-and-incident-impact-calculations/)
* Reports the time elapsed since the last status update when an incident is active

**Compatibility:**

* Cross-platform

**Important Notes:**

* Works with any public status page powered by Atlassian Statuspage (e.g. GitHub, Cloudflare, Datadog)


## 