# Check huawei-dorado-controller

## Overview

Checks the health and running status of all controllers on a Huawei OceanStor Dorado storage system via the REST API (`/controller` endpoint). Alerts when any controller reports a non-normal health or running state.

**Data Collection:**

* Queries the Huawei OceanStor Dorado REST API at `https://<ip>:<port>/deviceManager/rest/<deviceId>/controller`
* Authenticates via session tokens (iBaseToken + cookie), cached in a SQLite database to avoid repeated logins
* On transient authorization errors, automatically retries up to 9 times with 1-second intervals

**Compatibility:**

* Cross-platform


**