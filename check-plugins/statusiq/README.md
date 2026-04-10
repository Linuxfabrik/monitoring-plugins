# Check statusiq

## Overview

Monitors a [StatusIQ](https://www.site24x7.com/statusiq/) (by Site24x7) status page via its RSS feed. Returns a component-by-component status overview with Nagios-compatible alerting.

**Data Collection:**

* Fetches the RSS feed of the specified StatusIQ status page (appends `/rss` to the URL)
* Parses the XML feed using BeautifulSoup to extract component statuses and publication dates

**Compatibility:**

* Cross-platform

**Important Notes:**

* Any StatusIQ status page with RSS enabled (e.g. `https://status.trustid.ch`, `https://status.kobv.de`)


## 