# Check nextcloud-version

## Overview

Checks the installed Nextcloud version against the endoflife.date API and alerts if the version is end-of-life or if newer major, minor, or patch releases are available. By default, alerts 30 days before the official EOL date. The offset is configurable. Requires root or sudo.

**Data Collection:**

* Requires sudo permissions for the UID under which the Nextcloud application runs
* Runs Nextcloud `occ config:list` via sudo to determine the installed version
* Queries the [endoflife.date API](https://endoflife.date/) for Nextcloud lifecycle data
* Caches the API response in a local SQLite database to reduce API calls

**Compatibility:**

* Cross-platform

**Important Notes:**

* Must run on the Nextcloud server itself to access the installation directory


## 