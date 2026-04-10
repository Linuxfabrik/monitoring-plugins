# Check nextcloud-stats

## Overview

Monitors Nextcloud usage statistics via the server info API, including active user counts over time, file shares by category, and storage metrics. Also reports PHP, database, and web server configuration details.

**Data Collection:**

* Queries the Nextcloud serverinfo API endpoint (`/ocs/v2.php/apps/serverinfo/api/v1/info`) using HTTP Basic authentication
* Reports active users (last 5 minutes, 1 hour, 24 hours), total files, apps, shares (by type), storage distribution, PHP settings, database type/size, and web server/memcache configuration

**Compatibility:**

* Cross-platform


**