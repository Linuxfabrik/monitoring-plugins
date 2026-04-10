# Check huawei-dorado-hypermetropair

## Overview

Checks the health, running status, and synchronization state of all HyperMetro pairs on a Huawei OceanStor Dorado storage system via the REST API (`/hypermetropair` endpoint). Alerts when any pair reports a non-normal state or synchronization issue. Reports link status, last sync time, sync duration, sync progress, local/remote data consistency and host access state per pair.

**Data Collection:**

* Queries the Huawei OceanStor Dorado REST API at `https://<ip>:<port>/deviceManager/rest/<deviceId>/hypermetropair`
* Authenticates via session tokens (iBaseToken + cookie), cached in a SQLite database to avoid repeated logins
* On transient authorization errors, automatically retries up to 9 times with 1-second intervals

**Compatibility:**

* Cross-platform


**