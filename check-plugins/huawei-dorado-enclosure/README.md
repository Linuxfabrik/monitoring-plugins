# Check huawei-dorado-enclosure

## Overview

Checks the health and running status of all enclosures (controller enclosures and disk enclosures) on a Huawei OceanStor Dorado storage system via the REST API (`/enclosure` endpoint). Alerts when any enclosure reports a non-normal health or running state. Reports model, serial number, logic type, MAC address, switch status and temperature per enclosure.

**Data Collection:**

* Queries the Huawei OceanStor Dorado REST API at `https://<ip>:<port>/deviceManager/rest/<deviceId>/enclosure`
* Authenticates via session tokens (iBaseToken + cookie), cached in a SQLite database to avoid repeated logins
* On transient authorization errors, automatically retries up to 9 times with 1-second intervals

**Compatibility:**

* Cross-platform


**