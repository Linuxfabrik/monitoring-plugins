# Check huawei-dorado-fan

## Overview

Checks the health and running status of all fans on a Huawei OceanStor Dorado storage system via the REST API (`/fan` endpoint). Alerts when any fan reports a non-normal health or running state. Reports the run level (low, normal, high) per fan.

**Data Collection:**

* Queries the Huawei OceanStor Dorado REST API at `https://<ip>:<port>/deviceManager/rest/<deviceId>/fan`
* Authenticates via session tokens (iBaseToken + cookie), cached in a SQLite database to avoid repeated logins
* On transient authorization errors, automatically retries up to 9 times with 1-second intervals

**Compatibility:**

* Cross-platform


**