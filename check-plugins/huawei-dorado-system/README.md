# Check huawei-dorado-system

## Overview

Checks overall system health, capacity and running status of a Huawei OceanStor Dorado storage system via the REST API (`/system/` endpoint). Alerts when the system reports a non-normal health or running state, or when storage capacity exceeds configurable thresholds. Reports product model, firmware version, health/running status, total sector capacity usage and storage pool capacity usage.

**Data Collection:**

* Queries the Huawei OceanStor Dorado REST API at `https://<ip>:<port>/deviceManager/rest/<deviceId>/system/`
* Authenticates via session tokens (iBaseToken + cookie), cached in a SQLite database to avoid repeated logins
* On transient authorization errors, automatically retries up to 9 times with 1-second intervals

**Compatibility:**

* Cross-platform


**