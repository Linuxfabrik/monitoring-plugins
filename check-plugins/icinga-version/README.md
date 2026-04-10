# Check icinga-version

## Overview

Checks the installed Icinga version against the endoflife.date API and alerts if the version is end-of-life or if newer major, minor, or patch releases are available. By default, alerts 30 days before the official EOL date. The offset is configurable.

**Data Collection:**

* Runs `icinga2 --version` locally to determine the installed version
* Queries the endoflife.date API (`https://endoflife.date/api/icinga.json`) for EOL and release information
* Caches API responses in a SQLite database to avoid repeated requests

**Compatibility:**

* Cross-platform


**