# Check fortios-version

## Overview

Checks the installed FortiOS version against the endoflife.date API and alerts if the version is end-of-life or if newer major, minor, or patch releases are available. By default, alerts 30 days before the official EOL date. The offset is configurable.

**Data Collection:**

* Queries the FortiOS REST API endpoint `/api/v2/monitor/system/firmware/` to determine the installed version
* Compares the installed version against the endoflife.date API (`https://endoflife.date/api/fortios.json`) to determine EOL status and available updates
* Caches the endoflife.date API response in a local SQLite database (`$TEMP/linuxfabrik-lib-version.db`)

**Compatibility:**

* Cross-platform

**Important Notes:**

* FortiGate appliances running FortiOS with REST API enabled


## 