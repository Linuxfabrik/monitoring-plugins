# Check huawei-dorado-host

## Overview

Checks the health and running status of all hosts attached to a Huawei OceanStor Dorado storage system via the REST API (`/host` endpoint). Alerts when any host reports a non-normal health or running state. Reports operating system type and allocated capacity per host.

**Data Collection:**

* Queries the Huawei OceanStor Dorado REST API at `https://<ip>:<port>/deviceManager/rest/<deviceId>/host`
* Authenticates via session tokens (iBaseToken + cookie), cached in a SQLite database to avoid repeated logins
* On transient authorization errors, automatically retries up to 9 times with 1-second intervals

**Compatibility:**

* Cross-platform


**