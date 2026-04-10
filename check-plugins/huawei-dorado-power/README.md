# Check huawei-dorado-power

## Overview

Checks the health and running status of all power supply units (PSUs) on a Huawei OceanStor Dorado storage system via the REST API (`/power` endpoint). Alerts when any PSU reports a non-normal health or running state. Reports manufacturer, model, serial number, production date, input/output voltage and temperature per PSU.

**Data Collection:**

* Queries the Huawei OceanStor Dorado REST API at `https://<ip>:<port>/deviceManager/rest/<deviceId>/power`
* Authenticates via session tokens (iBaseToken + cookie), cached in a SQLite database to avoid repeated logins
* On transient authorization errors, automatically retries up to 9 times with 1-second intervals

**Compatibility:**

* Cross-platform


**