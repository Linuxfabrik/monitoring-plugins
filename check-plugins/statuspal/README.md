# Check statuspal

## Overview

Monitors a [Statuspal](https://www.statuspal.io/) status page, checking overall status, service states, active incidents, and scheduled maintenances.

**Data Collection:**

* Fetches JSON from the Statuspal API v2 `summary` endpoint
* Recursively flattens nested service trees into a dotted hierarchy (e.g. `Global.DNS`)
* Lists active incidents with their latest update, and upcoming/ongoing maintenances

**Important Notes:**

* Statuspal EU (`statuspal.eu`) and US (`statuspal.io`) endpoints
List of public Statuspal sites - Europe:
* <https://statuspal.eu/api/v2/status_pages/a/summary>
* <https://statuspal.eu/api/v2/status_pages/exoscalestatus/summary>
* <https://statuspal.eu/api/v2/status_pages/oneid/summary>
* <https://statuspal.eu/api/v2/status_pages/rasannnt/summary>
* <https://statuspal.eu/api/v2/status_pages/rmdit/summary>
* <https://statuspal.eu/api/v2/status_pages/seppmail/summary>
List of public Statuspal sites - USA:
* <https://statuspal.io/api/v2/status_pages/2factor/summary>
* <https://statuspal.io/api/v2/status_pages/activityinfo/summary>
* <https://statuspal.io/api/v2/status_pages/ae/summary>
* <https://statuspal.io/api/v2/status_pages/aeratechnology/summary>
* <https://statuspal.io/api/v2/status_pages/alchemix/summary>
* <https://statuspal.io/api/v2/status_pages/aleeva/summary>
* <https://statuspal.io/api/v2/status_pages/amestoapps/summary>
* <https://statuspal.io/api/v2/status_pages/animaker/summary>
* <https://statuspal.io/api/v2/status_pages/anycloud/summary>
* <https://statuspal.io/api/v2/status_pages/aplaut/summary>
* <https://statuspal.io/api/v2/status_pages/arvancloud/summary>
* <https://statuspal.io/api/v2/status_pages/as134220/summary>
* <https://statuspal.io/api/v2/status_pages/ascentlogistics/summary>
* <https://statuspal.io/api/v2/status_pages/avakin/summary>
* <https://statuspal.io/api/v2/status_pages/cloudcone/summary>
* <https://statuspal.io/api/v2/status_pages/edudip/summary>
* <https://statuspal.io/api/v2/status_pages/elkir/summary>
* <https://statuspal.io/api/v2/status_pages/emango/summary>
* <https://statuspal.io/api/v2/status_pages/everynet/summary>
* <https://statuspal.io/api/v2/status_pages/finqu/summary>
* <https://statuspal.io/api/v2/status_pages/hosttech/summary>
* <https://statuspal.io/api/v2/status_pages/maslak/summary>
* You need to provide the URL to the Statuspal API `summary` endpoint
* API Documentation: <https://www.statuspal.io/api-docs/v2>

**Compatibility:**

* Cross-platform


## 