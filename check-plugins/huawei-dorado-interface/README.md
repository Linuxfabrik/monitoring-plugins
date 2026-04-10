# Check huawei-dorado-interface

## Overview

Checks the health and running status of all interface modules (I/O modules) on a Huawei OceanStor Dorado storage system via the REST API (`/intf_module` endpoint). Alerts when any module reports a non-normal health or running state. Reports model, run mode (FC, Ethernet, RoCE, etc.) and LED status per module.

**Data Collection:**

* Queries the Huawei OceanStor Dorado REST API at `https://<ip>:<port>/deviceManager/rest/<deviceId>/intf_module`
* Authenticates via session tokens (iBaseToken + cookie), cached in a SQLite database to avoid repeated logins
* On transient authorization errors, automatically retries up to 9 times with 1-second intervals

**Compatibility:**

* Cross-platform


**