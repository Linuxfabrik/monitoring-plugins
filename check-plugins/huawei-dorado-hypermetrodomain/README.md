# Check huawei-dorado-hypermetrodomain

## Overview

Checks the running status of all HyperMetro domains on a Huawei OceanStor Dorado storage system via the REST API (`/hypermetrodomain` endpoint). Alerts when any domain reports a non-normal running state. Reports the quorum server name and quorum type per domain.

**Data Collection:**

* Queries the Huawei OceanStor Dorado REST API at `https://<ip>:<port>/deviceManager/rest/<deviceId>/hypermetrodomain`
* Authenticates via session tokens (iBaseToken + cookie), cached in a SQLite database to avoid repeated logins
* On transient authorization errors, automatically retries up to 9 times with 1-second intervals

**Compatibility:**

* Cross-platform


**