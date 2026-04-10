# Check huawei-dorado-backup-power

## Overview

Checks the health status of all backup power modules (BBU) on a Huawei OceanStor Dorado storage system via the REST API (`/backup_power` endpoint). Alerts when any module reports a non-normal health or running state.

**Data Collection:**

* Queries the Huawei OceanStor Dorado REST API at `https://<ip>:<port>/deviceManager/rest/<deviceId>/backup_power` to retrieve all BBU module data
* Reports health status, running status, charge count, remaining service life, and voltage for each BBU
* Cookies and iBaseTokens are cached and re-used (the session timeout period is usually 20 minutes, configurable via `--cache-expire`)

**Compatibility:**

* Cross-platform


**