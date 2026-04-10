# Check huawei-dorado-disk

## Overview

Checks the health and running status of all disks on a Huawei OceanStor Dorado storage system via the REST API (`/disk` endpoint). Alerts when any disk reports a non-normal health or running state. Reports abrasion rate, capacity usage, runtime, temperature and remaining service life per disk.

**Data Collection:**

* Queries the Huawei OceanStor Dorado REST API at `https://<ip>:<port>/deviceManager/rest/<deviceId>/disk`
* Authenticates via session tokens (iBaseToken + cookie), cached in a SQLite database to avoid repeated logins
* On transient authorization errors, automatically retries up to 9 times with 1-second intervals

**Compatibility:**

* Cross-platform


**